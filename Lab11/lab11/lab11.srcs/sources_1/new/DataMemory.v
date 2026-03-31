//`timescale 1ns / 1ps
//// 32-bit DataMemory for single-cycle RISC-V processor
//// Supports LW/SW (word), LH/SH (half), LB/SB (byte) via funct3.
//module DataMemory (
//    input  wire        clk,
//    input  wire        MemWrite,
//    input  wire        MemRead,
//    input  wire [2:0]  funct3,
//    input  wire [31:0] address,
//    input  wire [31:0] WriteData,
//    output reg  [31:0] ReadData
//);
//    reg [7:0] mem [0:1023];
//    integer idx;
//    initial begin
//        for (idx = 0; idx < 1024; idx = idx + 1)
//            mem[idx] = 8'b0;
//    end

//    always @(posedge clk) begin
//        if (MemWrite) begin
//            case (funct3)
//                3'b010: begin
//                    mem[address]   <= WriteData[7:0];
//                    mem[address+1] <= WriteData[15:8];
//                    mem[address+2] <= WriteData[23:16];
//                    mem[address+3] <= WriteData[31:24];
//                end
//                3'b001: begin
//                    mem[address]   <= WriteData[7:0];
//                    mem[address+1] <= WriteData[15:8];
//                end
//                3'b000:   mem[address] <= WriteData[7:0];
//                default: begin
//                    mem[address]   <= WriteData[7:0];
//                    mem[address+1] <= WriteData[15:8];
//                    mem[address+2] <= WriteData[23:16];
//                    mem[address+3] <= WriteData[31:24];
//                end
//            endcase
//        end
//    end

//    always @(*) begin
//        if (MemRead) begin
//            case (funct3)
//                3'b010: ReadData = {mem[address+3],mem[address+2],mem[address+1],mem[address]};
//                3'b001: ReadData = {{16{mem[address+1][7]}},mem[address+1],mem[address]};
//                3'b101: ReadData = {16'b0,mem[address+1],mem[address]};
//                3'b000: ReadData = {{24{mem[address][7]}},mem[address]};
//                3'b100: ReadData = {24'b0,mem[address]};
//                default: ReadData = {mem[address+3],mem[address+2],mem[address+1],mem[address]};
//            endcase
//        end else
//            ReadData = 32'b0;
//    end
//endmodule

`timescale 1ns / 1ps

module DataMemory (
    input  wire        clk,
    input  wire        MemWrite,
    input  wire        MemRead,
    input  wire [2:0]  funct3,
    input  wire [31:0] address,
    input  wire [31:0] WriteData,
    output reg  [31:0] ReadData
);
    // 256-word × 4 lanes = 1 KB. Word address = byte address >> 2.
    (* ram_style = "block" *) reg [7:0] mem0 [0:255];
    (* ram_style = "block" *) reg [7:0] mem1 [0:255];
    (* ram_style = "block" *) reg [7:0] mem2 [0:255];
    (* ram_style = "block" *) reg [7:0] mem3 [0:255];

    wire [7:0] waddr = address[9:2];

    integer idx;
    initial begin
        for (idx = 0; idx < 256; idx = idx + 1) begin
            mem0[idx] = 8'b0;
            mem1[idx] = 8'b0;
            mem2[idx] = 8'b0;
            mem3[idx] = 8'b0;
        end
    end

    // Lane 0 - written by SB, SH, SW
    always @(posedge clk) begin
        if (MemWrite)
            mem0[waddr] <= WriteData[7:0];
    end

    // Lane 1 - written by SH, SW only
    always @(posedge clk) begin
        if (MemWrite && (funct3 == 3'b001 || funct3 == 3'b010))
            mem1[waddr] <= WriteData[15:8];
    end

    // Lane 2 - written by SW only
    always @(posedge clk) begin
        if (MemWrite && (funct3 == 3'b010))
            mem2[waddr] <= WriteData[23:16];
    end

    // Lane 3 - written by SW only
    always @(posedge clk) begin
        if (MemWrite && (funct3 == 3'b010))
            mem3[waddr] <= WriteData[31:24];
    end

    // Combinational read (single-cycle datapath requirement)
    always @(posedge clk) begin
        if (MemRead) begin
            case (funct3)
                3'b010: ReadData = {mem3[waddr], mem2[waddr],
                                    mem1[waddr], mem0[waddr]};           // LW
                3'b001: ReadData = {{16{mem1[waddr][7]}},
                                    mem1[waddr], mem0[waddr]};           // LH  (signed)
                3'b101: ReadData = {16'b0, mem1[waddr], mem0[waddr]};   // LHU (unsigned)
                3'b000: ReadData = {{24{mem0[waddr][7]}}, mem0[waddr]}; // LB  (signed)
                3'b100: ReadData = {24'b0, mem0[waddr]};                // LBU (unsigned)
                default: ReadData = {mem3[waddr], mem2[waddr],
                                     mem1[waddr], mem0[waddr]};
            endcase
        end else
            ReadData = 32'b0;
    end

endmodule