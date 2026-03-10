`timescale 1ns / 1ps

module FSM (
    input        clk,
    input        rst,
    input        ALU_Zero,          // from ALU, used in BEQ_CHECK state
    input [31:0] ALU_Result,        // from ALU, written into destination register

    output reg WE,                  // RegisterFile WriteEnable
    output reg [4:0]  rs1,          // RegisterFile read address 1
    output reg [4:0]  rs2,          // RegisterFile read address 2
    output reg [4:0]  rd,           // RegisterFile write address
    output reg [31:0] WriteData,    // RegisterFile write data
    output reg [3:0]  ALUControl,   // ALU operation select
    output reg [4:0]  state         // states
);

    //State Encoding
    localparam [4:0]
        IDLE       = 5'd0,
        WRITE_X1   = 5'd1,
        WRITE_X2   = 5'd2,
        WRITE_X3   = 5'd3,
        ALU_ADD    = 5'd4,
        ALU_SUB    = 5'd5,
        ALU_AND    = 5'd6,
        ALU_OR     = 5'd7,
        ALU_XOR    = 5'd8,
        ALU_SLL    = 5'd9,
        ALU_SRL    = 5'd10,
        BEQ_CHECK  = 5'd11,
        RAW_WRITE  = 5'd12,
        RAW_READ   = 5'd13,
        DONE       = 5'd14;

    reg [4:0] next_state;

    // State Register(sequential)
    always @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-State Logic(combinational)
    always @(*) begin
        if (state == IDLE) begin
            next_state = WRITE_X1;
        end
        else if (state == WRITE_X1) begin
            next_state = WRITE_X2;
        end
        else if (state == WRITE_X2) begin
            next_state = WRITE_X3;
        end
        else if (state == WRITE_X3) begin
            next_state = ALU_ADD;
        end
        else if (state == ALU_ADD) begin
            next_state = ALU_SUB;
        end
        else if (state == ALU_SUB) begin
            next_state = ALU_AND;
        end
        else if (state == ALU_AND) begin
            next_state = ALU_OR;
        end
        else if (state == ALU_OR) begin
            next_state = ALU_XOR;
        end
        else if (state == ALU_XOR) begin
            next_state = ALU_SLL;
        end
        else if (state == ALU_SLL) begin
            next_state = ALU_SRL;
        end
        else if (state == ALU_SRL) begin
            next_state = BEQ_CHECK;
        end
        else if (state == BEQ_CHECK) begin
            next_state = RAW_WRITE;
        end
        else if (state == RAW_WRITE) begin
            next_state = RAW_READ;
        end
        else if (state == RAW_READ) begin
            next_state = DONE;
        end
        else begin
            next_state = DONE;
        end
    end

    //Output Logic(combinational)
    always @(*) begin
        // Safe defaults
        WE         = 1'b0;
        rs1        = 5'd0;
        rs2        = 5'd0;
        rd         = 5'd0;
        WriteData  = 32'b0;
        ALUControl = 4'b0000;

        if (state == WRITE_X1) begin
            WE        = 1'b1;
            rd        = 5'd1;
            WriteData = 32'h10101010;
        end
        else if (state == WRITE_X2) begin
            WE        = 1'b1;
            rd        = 5'd2;
            WriteData = 32'h01010101;
        end
        else if (state == WRITE_X3) begin
            WE        = 1'b1;
            rd        = 5'd3;
            WriteData = 32'h00000005;
        end
        else if (state == ALU_ADD) begin
            rs1        = 5'd1;
            rs2        = 5'd2;
            ALUControl = 4'b0000; //add
            WE         = 1'b1;
            rd         = 5'd4;
            WriteData  = ALU_Result;
        end
        else if (state == ALU_SUB) begin
            rs1        = 5'd1;
            rs2        = 5'd2;
            ALUControl = 4'b0001; //sub
            WE         = 1'b1;
            rd         = 5'd5;
            WriteData  = ALU_Result;
        end
        else if (state == ALU_AND) begin
            rs1        = 5'd1;
            rs2        = 5'd2;
            ALUControl = 4'b0010; //and
            WE         = 1'b1;
            rd         = 5'd6;
            WriteData  = ALU_Result;
        end
        else if (state == ALU_OR) begin
            rs1        = 5'd1;
            rs2        = 5'd2;
            ALUControl = 4'b0011; //or
            WE         = 1'b1;
            rd         = 5'd7;
            WriteData  = ALU_Result;
        end
        else if (state == ALU_XOR) begin
            rs1        = 5'd1;
            rs2        = 5'd2;
            ALUControl = 4'b0100; //xor
            WE         = 1'b1;
            rd         = 5'd8;
            WriteData  = ALU_Result;
        end
        else if (state == ALU_SLL) begin
            rs1        = 5'd1;
            rs2        = 5'd3;      
            ALUControl = 4'b0101; //shift left logic
            WE         = 1'b1;
            rd         = 5'd9;
            WriteData  = ALU_Result;
        end
        else if (state == ALU_SRL) begin
            rs1        = 5'd1;
            rs2        = 5'd3;      
            ALUControl = 4'b0110;   //shift right logic
            WE         = 1'b1;
            rd         = 5'd10;
            WriteData  = ALU_Result;
        end
        else if (state == BEQ_CHECK) begin
            rs1        = 5'd1;
            rs2        = 5'd1;      
            ALUControl = 4'b0111;   //beq
            WE         = 1'b1;
            rd         = 5'd11;
            if (ALU_Zero)
                WriteData = 32'h00000001;
            else
                WriteData = 32'h00000000;
        end
        else if (state == RAW_WRITE) begin
            WE        = 1'b1;
            rd        = 5'd12;
            WriteData = 32'hABCDABCD;
        end
        else if (state == RAW_READ) begin
            rs1 = 5'd12;            // result on ReadData1
        end
      
    end

endmodule