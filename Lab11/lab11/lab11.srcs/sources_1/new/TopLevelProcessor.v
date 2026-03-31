`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// TopLevelProcessor.v  --  Single-Cycle RV32I Processor
//
// Uses YOUR modules from previous labs:
//   instructionMemory.v  -- your Lab / this submission (byte-array, little-endian)
//   alu.v                -- your Lab 6  (updated control codes to match alu_control)
//   alu_control.v        -- your Lab 9
//   main_control.v       -- your Lab 9  (extended with JAL/JALR/LUI/AUIPC)
//   RegisterFile.v       -- your Lab 7  (duplicate reg decl fixed)
//   DataMemory.v         -- your Lab 8  (upgraded to 32-bit)
//   ProgramCounter.v     -- Lab 11 Task 1
//   pcAdder.v            -- Lab 11 Task 1
//   branchAdder.v        -- Lab 11 Task 1  (PC + imm, no extra shift)
//   mux2.v               -- Lab 11 Task 1
//   immGen.v             -- Lab 11 Task 1
//
// FPGA output:
//   leds[7:0]  = x10 (a0) lower byte  -> wire to 8 on-board LEDs
//////////////////////////////////////////////////////////////////////////////////
module TopLevelProcessor (
    input  wire       clk,
    input  wire       reset,
    output wire [7:0] leds
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
    wire        MemtoReg;   // lowercase t -- matches your main_control port name
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
    wire [31:0] wb_from_mem_mux;  // after MemtoReg mux
    wire [31:0] wb_final;         // after JAL/JALR override mux
    wire        PCSrc;

    // =========================================================================
    // 1. Program Counter
    // =========================================================================
    ProgramCounter uPC (
        .clk     (clk),
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
    // 3. Instruction Memory  -- YOUR module
    //    Port: instAddress (32-bit), instruction (32-bit out)
    // =========================================================================
    instructionMemory uIMem (
        .clk(clk),
        .instAddress(pc),
        .instruction(instruction)
    );

    // =========================================================================
    // 4. Main Control  -- YOUR Lab 9 module
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
    // 5. Register File  -- YOUR Lab 7 module
    //    WriteData = wb_final so JAL/JALR write PC+4 as return address
    // =========================================================================
    RegisterFile uRF (
        .clk        (clk),
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
    // 6. Immediate Generator  -- Lab 11 Task 1
    // =========================================================================
    immGen uImmGen (
        .inst    (instruction),
        .imm_out (imm)
    );

    // =========================================================================
    // 7. ALU input-B mux  (register operand vs immediate)
    // =========================================================================
    mux2 #(.WIDTH(32)) uALUSrcMux (
        .in0(ReadData2),
        .in1(imm),
        .sel(ALUSrc),
        .out(alu_in_b)
    );

    // =========================================================================
    // 8. ALU Control  -- YOUR Lab 9 module
    // =========================================================================
    alu_control uALUCtrl (
        .ALUOp     (ALUOp),
        .funct3    (funct3),
        .funct7    (funct7),
        .ALUControl(ALUControl)
    );

    // =========================================================================
    // 9. ALU input-A selection
    //    LUI   -> 0   (result = imm, the upper immediate)
    //    AUIPC -> PC  (result = PC + imm)
    //    else  -> rs1
    // =========================================================================
    assign alu_in_a = (opcode == 7'b0110111) ? 32'b0 :
                      (opcode == 7'b0010111) ? pc    :
                                               ReadData1;

    // =========================================================================
    // 10. ALU  -- YOUR Lab 6 module (updated control codes)
    // =========================================================================
    alu uALU (
        .A         (alu_in_a),
        .B         (alu_in_b),
        .ALUControl(ALUControl),
        .ALUResult (alu_result),
        .Zero      (Zero)
    );

    // =========================================================================
    // 11. Data Memory  -- YOUR Lab 8 module (upgraded to 32-bit)
    // =========================================================================
    DataMemory uDMem (
        .clk      (clk),
        .MemWrite (MemWrite),
        .MemRead  (MemRead),
        .funct3   (funct3),
        .address  (alu_result),
        .WriteData(ReadData2),
        .ReadData (mem_read_data)
    );

    // =========================================================================
    // 12. Write-back mux  (ALU result vs memory data)
    // =========================================================================
    mux2 #(.WIDTH(32)) uWBMux (
        .in0(alu_result),
        .in1(mem_read_data),
        .sel(MemtoReg),
        .out(wb_from_mem_mux)
    );

    // =========================================================================
    // 13. JAL/JALR write-back override
    //     When jumping, rd gets PC+4 (the return address)
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
    // 14. Branch target address  -- Lab 11 Task 1
    //     branchAdder does PC + imm  (immGen already gives full byte offset)
    // =========================================================================
    branchAdder uBranchAdd (
        .pc           (pc),
        .imm          (imm),
        .branch_target(branch_target)
    );

    // =========================================================================
    // 15. PC source control
    //     BEQ (funct3=000): branch if Zero=1
    //     BNE (funct3=001): branch if Zero=0
    //     JAL / JALR: always jump
    // =========================================================================
    wire branch_taken = Branch & ((funct3 == 3'b000) ?  Zero : ~Zero);
    assign PCSrc = branch_taken | is_jal | is_jalr;

    // JALR target = (rs1 + imm) with LSB cleared  [ALU already computed rs1+imm]
    assign pc_jump_target = is_jalr ? {alu_result[31:1], 1'b0} : branch_target;

    // =========================================================================
    // 16. Next-PC mux
    // =========================================================================
    mux2 #(.WIDTH(32)) uPCMux (
        .in0(pc_plus4),
        .in1(pc_jump_target),
        .sel(PCSrc),
        .out(pc_next)
    );

    // =========================================================================
    // 17. LED output: monitor x10 (a0)
    //     Captures the value each time x10 is written
    // =========================================================================
    reg [31:0] x10_monitor;
    always @(posedge clk) begin
        if (reset)
            x10_monitor <= 32'b0;
        else if (RegWrite && rd_addr == 5'd10)
            x10_monitor <= wb_final;
    end

    assign leds = x10_monitor[7:0];

endmodule