`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Top Level Processor with GCD Assembly Program
// 
// The GCD algorithm runs as RISC-V assembly code inside the processor.
// Button presses write values into memory-mapped addresses in DataMemory.
// The processor polls a start flag, reads A and B, computes GCD, and
// writes the result to a memory-mapped output address.
//
// Memory-Mapped I/O:
//   0x200 (mem[128]) = Input A   (written by BTNU)
//   0x204 (mem[129]) = Input B   (written by BTND)
//   0x208 (mem[130]) = Result    (written by processor, read by display)
//   0x20C (mem[131]) = Start flag (set by BTND, cleared by processor)
//
// User Flow:
//   1. SW[15] ON  -> enable GCD mode
//   2. SW[7:0] = A value, press BTNU -> loads A
//   3. SW[7:0] = B value, press BTND -> loads B and starts GCD
//   4. SW[14] ON  -> enable display output
//   5. 7-segment shows GCD result
//////////////////////////////////////////////////////////////////////////////////

module TopLevelProcessor #(parameter DIV = 5000000)(
    input  wire       clk,
    input  wire       reset,
    
    // ===== GCD Input/Output Interface =====
    input  wire       gcd_enable,        // SW[15]: Enable GCD mode
    input  wire       output_enable,     // SW[14]: Enable output display
    input  wire       a_load,            // BTNU: Load value A
    input  wire       b_load,            // BTND: Load value B and start
    input  wire [7:0] input_val,         // SW[7:0]: Shared input switches

    output wire [6:0] seg,
    output wire [3:0] an
);

    // ================= CLOCK DIVIDER =================
    wire slow_clk;

    clock_divider #(
        .DIV(DIV)
    ) uClkDiv (
        .clk_in (clk),
        .reset  (reset),
        .clk_out(slow_clk)
    );

    // =========================================================================
    // BUTTON EDGE DETECTION (debounce + rising edge)
    // =========================================================================
    reg a_load_d1, a_load_d2, a_load_edge;
    reg b_load_d1, b_load_d2, b_load_edge;
    
    always @(posedge slow_clk) begin
        a_load_d1 <= a_load;
        a_load_d2 <= a_load_d1;
        a_load_edge <= a_load_d1 && ~a_load_d2;
        
        b_load_d1 <= b_load;
        b_load_d2 <= b_load_d1;
        b_load_edge <= b_load_d1 && ~b_load_d2;
    end
    
    // =========================================================================
    // EXTERNAL WRITE SIGNALS TO DATA MEMORY
    // =========================================================================
    // Button presses write switch values into data memory at mapped addresses.
    // Only active when gcd_enable (SW[15]) is ON.
    wire ext_a_wen = a_load_edge & gcd_enable;
    wire ext_b_wen = b_load_edge & gcd_enable;
    wire [31:0] ext_input_val = {24'b0, input_val};
    
    // GCD result read from DataMemory address 0x208 (mem[130])
    wire [31:0] gcd_result;

    // =========================================================================
    // RISC-V PROCESSOR IMPLEMENTATION
    // =========================================================================

    // =========================================================================
    // PC wires
    // =========================================================================
    wire [31:0] pc;
    wire [31:0] pc_plus4;
    wire [31:0] pc_next;
    wire [31:0] branch_target;
    wire [31:0] pc_jump_target;

    // =========================================================================
    // Instruction & decode
    // =========================================================================
    wire [31:0] instruction;

    wire [6:0] opcode    = instruction[6:0];
    wire [4:0] rd_addr   = instruction[11:7];
    wire [2:0] funct3    = instruction[14:12];
    wire [4:0] rs1_addr  = instruction[19:15];
    wire [4:0] rs2_addr  = instruction[24:20];
    wire [6:0] funct7    = instruction[31:25];

    // =========================================================================
    // Control signals
    // =========================================================================
    wire        RegWrite;
    wire        ALUSrc;
    wire        MemRead;
    wire        MemWrite;
    wire        MemtoReg;
    wire        Branch;
    wire [1:0]  ALUOp;
    wire [3:0]  ALUControl;

    // =========================================================================
    // Datapath wires
    // =========================================================================
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;
    wire [31:0] imm;
    wire [31:0] alu_in_a;
    wire [31:0] alu_in_b;
    wire [31:0] alu_result;
    wire        Zero;
    wire [31:0] mem_read_data;
    wire [31:0] wb_from_mem_mux;
    wire [31:0] wb_final;
    wire        PCSrc;

    // =========================================================================
    // 1. Program Counter
    // =========================================================================
    ProgramCounter uPC (
        .clk     (slow_clk),
        .reset   (reset),
        .pc_next (pc_next),
        .pc      (pc)
    );

    // =========================================================================
    // 2. PC + 4 adder
    // =========================================================================
    pcAdder uPCAdd (
        .pc      (pc),
        .pc_plus4(pc_plus4)
    );

    // =========================================================================
    // 3. Instruction Memory
    // =========================================================================
    instructionMemory uIMem (
        .instAddress(pc),
        .instruction(instruction)
    );

    // =========================================================================
    // 4. Main Control
    // =========================================================================
    main_control uCtrl (
        .opcode  (opcode),
        .RegWrite(RegWrite),
        .ALUSrc  (ALUSrc),
        .MemRead (MemRead),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .Branch  (Branch),
        .ALUOp   (ALUOp)
    );

    // =========================================================================
    // 5. Register File
    // =========================================================================
    RegisterFile uRF (
        .clk        (slow_clk),
        .rst        (reset),
        .WriteEnable(RegWrite),
        .rs1        (rs1_addr),
        .rs2        (rs2_addr),
        .rd         (rd_addr),
        .WriteData  (wb_final),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );

    // =========================================================================
    // 6. Immediate Generator
    // =========================================================================
    immGen uImmGen (
        .inst    (instruction),
        .imm_out (imm)
    );

    // =========================================================================
    // 7. ALU input-B mux
    // =========================================================================
    mux2 #(.WIDTH(32)) uALUSrcMux (
        .in0(ReadData2),
        .in1(imm),
        .sel(ALUSrc),
        .out(alu_in_b)
    );

    // =========================================================================
    // 8. ALU Control
    // =========================================================================
    alu_control uALUCtrl (
        .ALUOp     (ALUOp),
        .funct3    (funct3),
        .funct7    (funct7),
        .ALUControl(ALUControl)
    );

    // =========================================================================
    // 9. ALU input-A selection
    // =========================================================================
    assign alu_in_a = (opcode == 7'b0110111) ? 32'b0 :
                      (opcode == 7'b0010111) ? pc    :
                                               ReadData1;

    // =========================================================================
    // 10. ALU
    // =========================================================================
    alu uALU (
        .A         (alu_in_a),
        .B         (alu_in_b),
        .ALUControl(ALUControl),
        .ALUResult (alu_result),
        .Zero      (Zero)
    );

    // =========================================================================
    // 11. Data Memory (with external write ports for GCD I/O)
    // =========================================================================
    DataMemory uDMem (
        .clk      (slow_clk),
        .MemWrite (MemWrite),
        .MemRead  (MemRead),
        .funct3   (funct3),
        .address  (alu_result),
        .WriteData(ReadData2),
        .ReadData (mem_read_data),
        // External write ports for button-to-memory interface
        .ext_a_wen (ext_a_wen),
        .ext_a_val (ext_input_val),
        .ext_b_wen (ext_b_wen),
        .ext_b_val (ext_input_val),
        .gcd_result(gcd_result)
    );

    // =========================================================================
    // 12. Write-back mux
    // =========================================================================
    mux2 #(.WIDTH(32)) uWBMux (
        .in0(alu_result),
        .in1(mem_read_data),
        .sel(MemtoReg),
        .out(wb_from_mem_mux)
    );

    // =========================================================================
    // 13. JAL/JALR write-back override
    // =========================================================================
    wire is_jal  = (opcode == 7'b1101111);
    wire is_jalr = (opcode == 7'b1100111);

    mux2 #(.WIDTH(32)) uJALMux (
        .in0(wb_from_mem_mux),
        .in1(pc_plus4),
        .sel(is_jal | is_jalr),
        .out(wb_final)
    );

    // =========================================================================
    // 14. Branch target
    // =========================================================================
    branchAdder uBranchAdd (
        .pc           (pc),
        .imm          (imm),
        .branch_target(branch_target)
    );

    // =========================================================================
    // 15. PC control
    // =========================================================================
    wire branch_taken = Branch & ((funct3 == 3'b000) ?  Zero : ~Zero);
    assign PCSrc = branch_taken | is_jal | is_jalr;

    assign pc_jump_target = is_jalr ? {alu_result[31:1], 1'b0} : branch_target;

    // =========================================================================
    // 16. Next PC
    // =========================================================================
    mux2 #(.WIDTH(32)) uPCMux (
        .in0(pc_plus4),
        .in1(pc_jump_target),
        .sel(PCSrc),
        .out(pc_next)
    );

    // =========================================================================
    // 17. DISPLAY STATE MACHINE
    // =========================================================================
    // Shows: A value -> B value -> GCD result (stays until reset)
    //
    // States:
    //   DISP_IDLE   - display shows 0, waiting for first input
    //   DISP_A      - display shows latched A value (after BTNU)
    //   DISP_B      - display shows latched B value (after BTND), GCD computing
    //   DISP_RESULT - display shows GCD result, stays here until reset
    // =========================================================================

    localparam DISP_IDLE   = 2'b00;
    localparam DISP_A      = 2'b01;
    localparam DISP_B      = 2'b10;
    localparam DISP_RESULT = 2'b11;

    reg [1:0]  disp_state;
    reg [7:0]  latched_a;     // latched A value for display
    reg [7:0]  latched_b;     // latched B value for display

    always @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            disp_state <= DISP_IDLE;
            latched_a  <= 8'b0;
            latched_b  <= 8'b0;
        end else begin
            case (disp_state)
                DISP_IDLE: begin
                    if (ext_a_wen) begin
                        latched_a  <= input_val;
                        disp_state <= DISP_A;
                    end
                end

                DISP_A: begin
                    if (ext_b_wen) begin
                        latched_b  <= input_val;
                        disp_state <= DISP_B;
                    end
                    // Allow re-loading A while in SHOW_A state
                    if (ext_a_wen)
                        latched_a <= input_val;
                end

                DISP_B: begin
                    // GCD is computing; wait for result to appear
                    // DataMemory clears mem[130] on BTND, so non-zero = done
                    if (gcd_result != 32'b0)
                        disp_state <= DISP_RESULT;
                end

                DISP_RESULT: begin
                    // Stay showing result until reset
                    // But allow starting a new GCD by pressing BTNU
                    if (ext_a_wen) begin
                        latched_a  <= input_val;
                        disp_state <= DISP_A;
                    end
                end
            endcase
        end
    end

    // Display output mux based on state
    reg [7:0] display_out;
    always @(*) begin
        case (disp_state)
            DISP_IDLE:   display_out = 8'd0;
            DISP_A:      display_out = latched_a;
            DISP_B:      display_out = latched_b;
            DISP_RESULT: display_out = gcd_result[7:0];
            default:     display_out = 8'd0;
        endcase
    end

    // =========================================================================
    // 18. Seven Segment Display
    // =========================================================================
    SevenSegController sevenseg (
        .clk(clk),
        .reset(reset),
        .value(display_out),
        .seg(seg),
        .an(an)
    );

endmodule
