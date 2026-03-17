`timescale 1ns / 1ps

//   SW[15:9] = opcode  [6:0]
//   SW[8:6] = funct3  [2:0]
//   SW[5] = funct7
//   SW[0] = fsm trigger
//
//   LED[15] = RegWrite
//   LED[14] = ALUSrc
//   LED[13]=MemRead
//   LED[12]=MemWrite
//   LED[11]=MemtoReg
//   LED[10]=Branch
//   LED[9:8] = ALUOp[1:0]
//   LED[3:0] =ALUControl[3:0]
//   LED[7:4] = FSM state (4-bit)
//

module top_control_path (
    input  wire        clk,        
    input  wire        rst,        // reset (BTNC)
    input  wire        btn_next,   // Step to next instruction
    input  wire        btn_auto,   // Auto cycle mode
    input  wire [15:5] sw,        
    output wire [15:0] led         
);

    wire btn_next_db, btn_auto_db;

    button_debounce db_next (
        .clk     (clk),
        .btn_in  (btn_next),
        .btn_out (btn_next_db)
    );

    button_debounce db_auto (
        .clk     (clk),
        .btn_in  (btn_auto),
        .btn_out (btn_auto_db)
    );

    wire [6:0] sw_opcode = sw[15:9];
    wire [2:0] sw_funct3 = sw[8:6];
    wire [6:0] sw_funct7 = {1'b0, sw[5], 5'b00000}; 
    
    localparam FSM_IDLE   = 4'd0;
    localparam FSM_ADD    = 4'd1;
    localparam FSM_SUB    = 4'd2;
    localparam FSM_SLL    = 4'd3;
    localparam FSM_SRL    = 4'd4;
    localparam FSM_AND    = 4'd5;
    localparam FSM_OR     = 4'd6;
    localparam FSM_XOR    = 4'd7;
    localparam FSM_ADDI   = 4'd8;
    localparam FSM_LW     = 4'd9;
    localparam FSM_LH     = 4'd10;
    localparam FSM_LB     = 4'd11;
    localparam FSM_STORE  = 4'd12;
    localparam FSM_BEQ    = 4'd13;
    localparam FSM_MANUAL = 4'd14;

    reg [3:0] state, next_state;


    reg [26:0] div_cnt;
    wire tick = (div_cnt == 27'd99_999_999); // 100M-1

    always @(posedge clk or posedge rst) begin
        if (rst)
            div_cnt <= 0;
        else if (tick)
            div_cnt <= 0;
        else
            div_cnt <= div_cnt + 1;
    end

    // State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= FSM_MANUAL;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = state;

        case (state)
            FSM_MANUAL: begin
                if (btn_next_db) next_state = FSM_ADD;
                else if (btn_auto_db && tick) next_state = FSM_ADD;
            end
            FSM_ADD  : if (tick || btn_next_db) next_state = FSM_SUB;
            FSM_SUB  : if (tick || btn_next_db) next_state = FSM_SLL;
            FSM_SLL  : if (tick || btn_next_db) next_state = FSM_SRL;
            FSM_SRL  : if (tick || btn_next_db) next_state = FSM_AND;
            FSM_AND  : if (tick || btn_next_db) next_state = FSM_OR;
            FSM_OR   : if (tick || btn_next_db) next_state = FSM_XOR;
            FSM_XOR  : if (tick || btn_next_db) next_state = FSM_ADDI;
            FSM_ADDI : if (tick || btn_next_db) next_state = FSM_LW;
            FSM_LW   : if (tick || btn_next_db) next_state = FSM_LH;
            FSM_LH   : if (tick || btn_next_db) next_state = FSM_LB;
            FSM_LB   : if (tick || btn_next_db) next_state = FSM_STORE;
            FSM_STORE: if (tick || btn_next_db) next_state = FSM_BEQ;
            FSM_BEQ  : if (tick || btn_next_db) next_state = FSM_MANUAL;
            default  : next_state = FSM_MANUAL;
        endcase
    end


    reg [6:0] fsm_opcode;
    reg [2:0] fsm_funct3;
    reg [6:0] fsm_funct7;

    always @(*) begin
        // defaults (R-type ADD)
        fsm_opcode = 7'b0110011;
        fsm_funct3 = 3'b000;
        fsm_funct7 = 7'b0000000;

        case (state)
            FSM_MANUAL: begin
                fsm_opcode = sw_opcode;
                fsm_funct3 = sw_funct3;
                fsm_funct7 = sw_funct7;
            end
            FSM_ADD  : begin fsm_opcode=7'b0110011; fsm_funct3=3'b000; fsm_funct7=7'b0000000; end
            FSM_SUB  : begin fsm_opcode=7'b0110011; fsm_funct3=3'b000; fsm_funct7=7'b0100000; end
            FSM_SLL  : begin fsm_opcode=7'b0110011; fsm_funct3=3'b001; fsm_funct7=7'b0000000; end
            FSM_SRL  : begin fsm_opcode=7'b0110011; fsm_funct3=3'b101; fsm_funct7=7'b0000000; end
            FSM_AND  : begin fsm_opcode=7'b0110011; fsm_funct3=3'b111; fsm_funct7=7'b0000000; end
            FSM_OR   : begin fsm_opcode=7'b0110011; fsm_funct3=3'b110; fsm_funct7=7'b0000000; end
            FSM_XOR  : begin fsm_opcode=7'b0110011; fsm_funct3=3'b100; fsm_funct7=7'b0000000; end
            FSM_ADDI : begin fsm_opcode=7'b0010011; fsm_funct3=3'b000; fsm_funct7=7'b0000000; end
            FSM_LW   : begin fsm_opcode=7'b0000011; fsm_funct3=3'b010; fsm_funct7=7'b0000000; end
            FSM_LH   : begin fsm_opcode=7'b0000011; fsm_funct3=3'b001; fsm_funct7=7'b0000000; end
            FSM_LB   : begin fsm_opcode=7'b0000011; fsm_funct3=3'b000; fsm_funct7=7'b0000000; end
            // Store uses SW (funct3=010) as representative store
            FSM_STORE: begin fsm_opcode=7'b0100011; fsm_funct3=3'b010; fsm_funct7=7'b0000000; end
            FSM_BEQ  : begin fsm_opcode=7'b1100011; fsm_funct3=3'b000; fsm_funct7=7'b0000000; end
            default  : begin fsm_opcode=sw_opcode;  fsm_funct3=sw_funct3; fsm_funct7=sw_funct7; end
        endcase
    end


    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    main_control mc (
        .opcode   (fsm_opcode),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .ALUOp    (ALUOp)
    );

    alu_control ac (
        .ALUOp      (ALUOp),
        .funct3     (fsm_funct3),
        .funct7     (fsm_funct7),
        .ALUControl (ALUControl)
    );


    assign led[15]   = RegWrite;
    assign led[14]   = ALUSrc;
    assign led[13]   = MemRead;
    assign led[12]   = MemWrite;
    assign led[11]   = MemtoReg;
    assign led[10]   = Branch;
    assign led[9:8]  = ALUOp;
    assign led[7:4]  = state;  
    assign led[3:0]  = ALUControl;

endmodule


