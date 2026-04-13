`timescale 1ns / 1ps

module TopLevelProcessor #(parameter DIV = 5000000)(
    input  wire       clk,
    input  wire       reset,

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
    // 17. Monitor register x10 (a0)
    // =========================================================================
    reg [31:0] x10_monitor;
    always @(posedge slow_clk) begin
        if (reset)
            x10_monitor <= 32'b0;
        else if (RegWrite && rd_addr == 5'd15)
            x10_monitor <= wb_final;
    end
    // =========================================================================
    // 18. Seven Segment Display instead of LEDs
    // =========================================================================
    SevenSegController sevenseg (
        .clk(clk),
        .reset(reset),
        .value(x10_monitor[7:0]),
        .seg(seg),
        .an(an)
    );

endmodule