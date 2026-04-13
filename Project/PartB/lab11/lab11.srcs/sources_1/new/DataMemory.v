module DataMemory (
    input  wire clk,
    input  wire MemWrite,
    input  wire MemRead,
    input  wire [2:0]  funct3,
    input  wire [31:0] address,
    input  wire [31:0] WriteData,
    output reg  [31:0] ReadData
);
    reg [31:0] mem [0:255];
    integer idx;
    initial begin
        for (idx = 0; idx < 256; idx = idx + 1)
            mem[idx] = 32'b0;
        mem[128] = 32'd5;
    end

    wire [7:0] word_addr = address[9:2];

    // Registered write � unchanged
    always @(posedge clk) begin
        if (MemWrite) begin
            case (funct3)
                3'b000: begin
                    case (address[1:0])
                        2'b00: mem[word_addr][7:0]   <= WriteData[7:0];
                        2'b01: mem[word_addr][15:8]  <= WriteData[7:0];
                        2'b10: mem[word_addr][23:16] <= WriteData[7:0];
                        2'b11: mem[word_addr][31:24] <= WriteData[7:0];
                    endcase
                end
                3'b001: begin
                    if (address[1])
                        mem[word_addr][31:16] <= WriteData[15:0];
                    else
                        mem[word_addr][15:0]  <= WriteData[15:0];
                end
                default: mem[word_addr] <= WriteData;
            endcase
        end
    end

    // COMBINATIONAL read � no clock, no raw_read register
    always @(*) begin
        if (MemRead) begin
            case (funct3)
                3'b010: ReadData = mem[word_addr];
                3'b001: ReadData = {{16{mem[word_addr][15]}}, mem[word_addr][15:0]};
                3'b101: ReadData = {16'b0, mem[word_addr][15:0]};
                3'b000: ReadData = {{24{mem[word_addr][7]}},  mem[word_addr][7:0]};
                3'b100: ReadData = {24'b0, mem[word_addr][7:0]};
                default: ReadData = mem[word_addr];
            endcase
        end else
            ReadData = 32'b0;
    end
endmodule