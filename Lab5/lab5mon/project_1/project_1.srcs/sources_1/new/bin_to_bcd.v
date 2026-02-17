`timescale 1ns / 1ps


module bin_to_bcd(
    input [15:0] binary,
    output reg [3:0] thousands,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] ones
);

    integer i;
    reg [31:0] shift;

    always @(*) begin
        shift = 28'd0;
        shift[15:0] = binary;

        for (i = 0; i < 16; i = i + 1) begin
            
            if (shift[19:16] >= 5)
                shift[19:16] = shift[19:16] + 3;

            if (shift[23:20] >= 5)
                shift[23:20] = shift[23:20] + 3;

            if (shift[27:24] >= 5)
                shift[27:24] = shift[27:24] + 3;

            shift = shift << 1;
        end

        ones      = shift[19:16];
        tens      = shift[23:20];
        hundreds  = shift[27:24];
        thousands = shift[31:28];

    end

endmodule

