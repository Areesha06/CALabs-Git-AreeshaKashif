`timescale 1ns / 1ps

module DataMemory (
    input  wire clk,
    input  wire we, // write enable  (from decoder: mem_wr)
    input  wire re, //read  enable  (from decoder: mem_rd)
    input  wire [7:0] loc, // word address  (address[7:0])
    input  wire [5:0] din, // data in from CPU
    output reg  [5:0] dout // data out to CPU
);

    //512-word storage array
    reg [5:0] ram [511:0];

    // Initialise all locations to zero 
    integer idx;
    initial begin
        for (idx = 0; idx < 512; idx = idx + 1)
            ram[idx] = 6'd0;
    end

    // Write port 
    always @(posedge clk) begin
        if (we)
            ram[loc] <= din;
    end

    // Read port 
    always @(*) begin
        dout = (re) ? ram[loc] : 6'd0;
    end

endmodule