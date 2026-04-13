`timescale 1ns / 1ps
//
// 16 LEDs show control signals of current instruction
// 7-seg shows current PC value in decimal
//
// LED MAPPING (16 bits):
//   led[15] = RegWrite
//   led[14] = ALUSrc
//   led[13] = MemRead
//   led[12] = MemWrite
//   led[11] = MemtoReg
//   led[10] = Branch
//   led[9]  = ALUOp[1]
//   led[8]  = ALUOp[0]
//   led[7]  = ALUControl[3]
//   led[6]  = ALUControl[2]
//   led[5]  = ALUControl[1]
//   led[4]  = ALUControl[0]
//   led[3]  = Zero
//   led[2]  = PCSrc
//   led[1]  = is_jal
//   led[0]  = is_jalr
//
// EXPECTED LED PATTERNS for the 3 new Task B instructions:
//
//   SLTI (I-type ALU, funct3=010 -> ALU_SLT=0111):
//     RegWrite=1, ALUSrc=1, MemRead=0, MemWrite=0,
//     MemtoReg=0, Branch=0, ALUOp=11, ALUControl=0111
//     leds = 16'b1100_0011_0111_xxxx  (x = Zero/PCSrc/jal/jalr depend on data)
//
//   SRA (R-type, funct3=101 funct7[5]=1 -> ALU_SRA=1000):
//     RegWrite=1, ALUSrc=0, MemRead=0, MemWrite=0,
//     MemtoReg=0, Branch=0, ALUOp=10, ALUControl=1000
//     leds = 16'b1000_0010_1000_xxxx
//
//   BLTU (Branch, funct3=110 -> ALU_SLTU=1001):
//     RegWrite=0, ALUSrc=0, MemRead=0, MemWrite=0,
//     MemtoReg=0, Branch=1, ALUOp=01, ALUControl=1001
//     leds = 16'b0000_0101_1001_xxxx
//     led[2] (PCSrc) lights up when branch IS taken

module TopLevelProcessor #(parameter DIV = 100000000)(
    input  wire        clk,
    input  wire        reset,
    output wire [15:0] leds,
    output wire [6:0]  seg,
    output wire [3:0]  an
);

    // =========================================================================
    // Clock divider
    // =========================================================================
    wire slow_clk;
    clock_divider #(.DIV(DIV)) uClkDiv (
        .clk_in (clk),
        .reset  (reset),
        .clk_out(slow_clk)
    );

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
    wire [6:0]  opcode   = instruction[6:0];
    wire [4:0]  rd_addr  = instruction[11:7];
    wire [2:0]  funct3   = instruction[14:12];
    wire [4:0]  rs1_addr = instruction[19:15];
    wire [4:0]  rs2_addr = instruction[24:20];
    wire [6:0]  funct7   = instruction[31:25];

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
    wire [31:0] ReadData1, ReadData2;
    wire [31:0] imm;
    wire [31:0] alu_in_a, alu_in_b;
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
    // 2. PC + 4
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
    // 4. Main Control (UNCHANGED)
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
    // 8. ALU Control (MODIFIED - Task B)
    // =========================================================================
    alu_control uALUCtrl (
        .ALUOp     (ALUOp),
        .funct3    (funct3),
        .funct7    (funct7),
        .ALUControl(ALUControl)
    );

    // =========================================================================
    // 9. ALU input-A
    // =========================================================================
    assign alu_in_a = (opcode == 7'b0110111) ? 32'b0 :
                      (opcode == 7'b0010111) ? pc    :
                                               ReadData1;

    // =========================================================================
    // 10. ALU (MODIFIED - Task B: SRA + SLTU added)
    // =========================================================================
    alu uALU (
        .A         (alu_in_a),
        .B         (alu_in_b),
        .ALUControl(ALUControl),
        .ALUResult (alu_result),
        .Zero      (Zero)
    );

    // =========================================================================
    // 11. Data Memory
    // =========================================================================
    DataMemory uDMem (
        .clk      (slow_clk),
        .MemWrite (MemWrite),
        .MemRead  (MemRead),
        .funct3   (funct3),
        .address  (alu_result),
        .WriteData(ReadData2),
        .ReadData (mem_read_data)
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
    // 13. JAL/JALR write-back
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
    // 15. PC source control
    // TASK B: added BLTU (funct3=110)
    //   BLTU: ALU does unsigned compare (SLTU), result=1 -> Zero=0 -> ~Zero=1
    // =========================================================================
    wire branch_taken =
        Branch & (
            (funct3 == 3'b000) ?  Zero :   // BEQ
            (funct3 == 3'b001) ? ~Zero :   // BNE
            (funct3 == 3'b110) ? ~Zero :   // BLTU (NEW Task B)
                                  1'b0
        );

    assign PCSrc = branch_taken | is_jal | is_jalr;
    assign pc_jump_target = is_jalr ? {alu_result[31:1], 1'b0} : branch_target;

    // =========================================================================
    // 16. Next PC mux
    // =========================================================================
    mux2 #(.WIDTH(32)) uPCMux (
        .in0(pc_plus4),
        .in1(pc_jump_target),
        .sel(PCSrc),
        .out(pc_next)
    );

    // =========================================================================
    // 17. LED output -- 16 control signals (combinational, live every cycle)
    // =========================================================================
    assign leds[15] = RegWrite;
    assign leds[14] = ALUSrc;
    assign leds[13] = MemRead;
    assign leds[12] = MemWrite;
    assign leds[11] = MemtoReg;
    assign leds[10] = Branch;
    assign leds[9]  = ALUOp[1];
    assign leds[8]  = ALUOp[0];
    assign leds[7]  = ALUControl[3];
    assign leds[6]  = ALUControl[2];
    assign leds[5]  = ALUControl[1];
    assign leds[4]  = ALUControl[0];
    assign leds[3]  = Zero;
    assign leds[2]  = PCSrc;
    assign leds[1]  = is_jal;
    assign leds[0]  = is_jalr;

    // =========================================================================
    // 18. Seven-segment: show PC in decimal
    //     PC = 0, 4, 8, 12... so 7-seg steps through these values
    // =========================================================================
    SevenSegController sevenseg (
        .clk   (clk),
        .reset (reset),
        .value (pc[7:0]),
        .seg   (seg),
        .an    (an)
    );

endmodule


// =========================================================================
// Clock Divider (UNCHANGED)
// =========================================================================
module clock_divider #(parameter DIV = 5000000)(
    input  wire clk_in,
    input  wire reset,
    output reg  clk_out = 0
);
    reg [$clog2(DIV)-1:0] counter;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else if (counter == DIV - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
        end
    end
endmodule