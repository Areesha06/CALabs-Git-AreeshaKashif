`timescale 1ns / 1ps

module switch (
    input        clk,
    input  [3:0] sw_raw,
    output [3:0] sw_clean
);

    // Debounce each switch individually
    debouncer db0 (.clk(clk), .noisy(sw_raw[0]), .clean(sw_clean[0]));
    debouncer db1 (.clk(clk), .noisy(sw_raw[1]), .clean(sw_clean[1]));
    debouncer db2 (.clk(clk), .noisy(sw_raw[2]), .clean(sw_clean[2]));
    debouncer db3 (.clk(clk), .noisy(sw_raw[3]), .clean(sw_clean[3]));

endmodule