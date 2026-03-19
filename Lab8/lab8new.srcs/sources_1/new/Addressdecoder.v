// Memory map (address[9:8]):
//   2'b00  ->  Data Memory     
//   2'b01  ->  LED peripheral  
//   2'b10  ->  Switch input   

`timescale 1ns / 1ps

module AddressDecoder (
    input  wire [9:0] addr,        // full 10-bit CPU address
    input  wire       wr_en,       // CPU write 
    input  wire       rd_en,       // CPU read 
    output reg        mem_wr,      // data memory write enable
    output reg        mem_rd,      // data memory read  enable
    output reg        led_wr,      // LED register write enable
    output reg        sw_rd        // switch bus read  enable
);

    // Extract device-select field once for clarity
    wire [1:0] sel = addr[9:8];

    always @(*) begin
        //defaults
        mem_wr = 1'b0;
        mem_rd = 1'b0;
        led_wr = 1'b0;
        sw_rd  = 1'b0;

        if (sel == 2'b00) begin
            // Data Memory
            mem_wr = wr_en;
            mem_rd = rd_en;
        end else if (sel == 2'b01) begin
            // LED output register (write-only from CPU side)
            led_wr = wr_en;
        end else if (sel == 2'b10) begin
            // Switch input register (read-only from CPU side)
            sw_rd = rd_en;
        end
     
    end

endmodule