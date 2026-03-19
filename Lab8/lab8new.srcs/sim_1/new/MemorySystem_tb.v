`timescale 1ns/1ps

module MemorySystem_tb;

reg clk;
reg rst;
reg [15:0] switches;
wire [5:0] leds;

// Instantiate DUT 
addressDecoderTop DUT(
    .clk(clk),
    .rst(rst),
    .switches(switches),
    .leds(leds)
);

// clock
always #5 clk = ~clk;

initial begin
    // initial state
    clk = 0;
    rst = 1;
    switches = 0;

    #10;
    rst = 0;

    // Case 1: Write to Data Memory
    switches[9:8] = 2'b00;     // select memory
    switches[7]   = 1;         // write enable
    switches[6]   = 0;         // read disable
    switches[5:0] = 6'b101001; // data
    #10;
    switches[7] = 0;

    // Case 2: Read from Data Memory
    #10;
    switches[6] = 1;
    #10;
    switches[6] = 0;

    // Case 3: Write to LED
    #10;
    switches[9:8] = 2'b01;     // select LED
    switches[7]   = 1;
    switches[5:0] = 6'b111000;
    #10;
    switches[7] = 0;

    // Case 4: Read from Switch
    #10;
    switches[9:8] = 2'b10;     // select switch
    switches[6]   = 1;
    switches[5:0] = 6'b010101;
    #10;
    switches[6] = 0;

    // finish
    #20;
    $stop;
end

endmodule