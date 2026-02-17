
`timescale 1ns / 1ps

// ============================================================
//  MODULE: switches
//  Purpose: Memory-mapped interface for reading 16 slide switches
//  - Combinational logic (no pipeline delay)
//  - Supports different address modes for flexible SW reading
//  - For this design, hardcoded to return full 16-bit value
// ============================================================
module switches (
    input        clk,
    input        rst,
    input [15:0] btns,
    input [31:0] writeData,
    input        writeEnable,
    input        readEnable,
    input [29:0] memAddress,
    input [15:0] switches,
    output reg [31:0] readData
);

    initial readData = 32'h00000000;

    // ========================
    // Combinational read logic
    // Returns switch value based on address (no delay)
    // ========================
    always @(*) begin
        // On reset: output zero
        if (rst)
            readData = 32'h00000000;
        
        // When read enabled: return data based on address bits [1:0]
        else if (readEnable) begin
            case (memAddress[1:0])
                2'b00: readData = {24'h0, switches[7:0]};    // Lower 8 switches
                2'b01: readData = {24'h0, switches[15:8]};   // Upper 8 switches
                2'b10: readData = {16'h0, switches};         // Full 16-bit value ? USED
                2'b11: readData = {16'h0, btns};             // Button inputs
                default: readData = 32'h0;
            endcase
        end 
        
        // Read disabled: output zero
        else
            readData = 32'h00000000;
    end

endmodule

