// addressDecoderTop.v
// Top-level integration of the memory-mapped peripheral system.
//
// Switch roles (same 16 physical switches, same mapping):
//   SW[9:8]  – device select (drives address[9:8])
//   SW[7]    – write enable
//   SW[6]    – read enable
//   SW[5:0]  – 6-bit data / address offset written to / read from
//
// LED output shows:
//   - Data read from DataMemory  when SW[9:8] = 00 and rd_en=1
//   - LED register value         when SW[9:8] = 01
//   - Switch input passthrough   when SW[9:8] = 10 and rd_en=1

`timescale 1ns / 1ps

module addressDecoderTop (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] switches,
    output wire [5:0]  leds
);

    // ------------------------------------------------------------------
    // Build the 10-bit address from the switch inputs:
    //   address[9:8] = SW[9:8]   (device select)
    //   address[7:0] = SW[5:0]   (word offset within the selected device,
    //                              upper 2 bits padded to 0)
    // ------------------------------------------------------------------
    wire [9:0] cpu_addr;
    assign cpu_addr = {switches[9], switches[8], 2'b00, switches[5:0]};

    // Control strobes
    wire wr_en = switches[7];
    wire rd_en = switches[6];

    // ------------------------------------------------------------------
    // Address decoder enable signals
    // ------------------------------------------------------------------
    wire mem_wr, mem_rd;
    wire led_wr;
    wire sw_rd;

    AddressDecoder u_dec (
        .addr   (cpu_addr),
        .wr_en  (wr_en),
        .rd_en  (rd_en),
        .mem_wr (mem_wr),
        .mem_rd (mem_rd),
        .led_wr (led_wr),
        .sw_rd  (sw_rd)
    );

    // ------------------------------------------------------------------
    // Data Memory
    // ------------------------------------------------------------------
    wire [5:0] mem_dout;

    DataMemory u_mem (
        .clk  (clk),
        .we   (mem_wr),
        .re   (mem_rd),
        .loc  (cpu_addr[7:0]),
        .din  (switches[5:0]),
        .dout (mem_dout)
    );

    // ------------------------------------------------------------------
    // LED Interface
    // ------------------------------------------------------------------
    wire [5:0] led_val;

    LEDInterface u_led (
        .clk      (clk),
        .reset    (rst),
        .wr       (led_wr),
        .data_in  (switches[5:0]),
        .led_out  (led_val)
    );

    // ------------------------------------------------------------------
    // Switch Interface
    // ------------------------------------------------------------------
    wire [5:0] sw_dout;

    SwitchInterface u_sw (
        .rd     (sw_rd),
        .sw_in  (switches[5:0]),
        .sw_out (sw_dout)
    );

    // ------------------------------------------------------------------
    // Output mux – select what the LEDs display based on device region
    // ------------------------------------------------------------------
    reg [5:0] display;

    always @(*) begin
        case (cpu_addr[9:8])
            2'b00:   display = mem_dout;   // show data memory read
            2'b01:   display = led_val;    // show LED register contents
            2'b10:   display = sw_dout;    // show switch passthrough
            default: display = 6'b000000;  // reserved / unused
        endcase
    end

    assign leds = display;

endmodule