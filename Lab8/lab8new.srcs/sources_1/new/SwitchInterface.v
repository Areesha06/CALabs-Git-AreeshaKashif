
`timescale 1ns / 1ps

module SwitchInterface (
    input  wire       rd,            // read enable  (from decoder: sw_rd)
    input  wire [5:0] sw_in,         // raw switch inputs from FPGA pins
    output wire [5:0] sw_out         // data presented to CPU read bus
);

    // Gate the switch value through the read-enable – purely combinational
    assign sw_out = rd ? sw_in : 6'b000000;

endmodule