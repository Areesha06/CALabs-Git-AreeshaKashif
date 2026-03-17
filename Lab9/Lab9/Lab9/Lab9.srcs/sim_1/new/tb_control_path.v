`timescale 1ns / 1ps


module tb_control_path;

    
    reg [6:0] opcode; // Inputs to Main Control
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch; // Outputs from Main Control
    wire [1:0] ALUOp;
    
    reg [2:0] funct3; // Inputs to ALU Control
    reg [6:0] funct7;

    wire [3:0] ALUControl; // Output from ALU Control

    main_control uut_main (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .ALUOp    (ALUOp)
    );

    alu_control uut_alu (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7     (funct7),
        .ALUControl (ALUControl)
    );

    // display current signal state

    task show;
        input [127:0] instr_name; // up to 16 ASCII chars
        begin
            $display("%-8s | opcode=%b  funct3=%b  funct7[5]=%b | RW=%b AS=%b MR=%b MW=%b M2R=%b Br=%b ALUOp=%b | ALUCtrl=%b",
                     instr_name,
                     opcode, funct3, funct7[5],
                     RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch, ALUOp,
                     ALUControl);
        end
    endtask

    initial begin
        $display("=======================================================");
        $display(" Lab 9 - RISC-V Control Path Simulation");
        $display("=======================================================");
        $display("%-8s | opcode         funct3  f7[5] | RW AS MR MW M2R Br ALUOp | ALUCtrl",
                 "Instr");
        $display("-----------------------------------------------------------------------");

        // ------ R-type instructions (opcode = 0110011) ------
        opcode = 7'b0110011;

        // ADD: funct3=000, funct7[5]=0
        funct3 = 3'b000; funct7 = 7'b0000000; #10; show("ADD");

        // SUB: funct3=000, funct7[5]=1
        funct3 = 3'b000; funct7 = 7'b0100000; #10; show("SUB");

        // SLL: funct3=001, funct7[5]=0
        funct3 = 3'b001; funct7 = 7'b0000000; #10; show("SLL");

        // SRL: funct3=101, funct7[5]=0
        funct3 = 3'b101; funct7 = 7'b0000000; #10; show("SRL");

        // AND: funct3=111, funct7[5]=0
        funct3 = 3'b111; funct7 = 7'b0000000; #10; show("AND");

        // OR: funct3=110, funct7[5]=0
        funct3 = 3'b110; funct7 = 7'b0000000; #10; show("OR");

        // XOR: funct3=100, funct7[5]=0
        funct3 = 3'b100; funct7 = 7'b0000000; #10; show("XOR");

        // ------ I-type ALU: ADDI (opcode = 0010011) ----------
        opcode = 7'b0010011;
        funct3 = 3'b000; funct7 = 7'b0000000; #10; show("ADDI");

        // ------ Load instructions (opcode = 0000011) ---------
        opcode = 7'b0000011;

        // LW: funct3=010
        funct3 = 3'b010; funct7 = 7'b0000000; #10; show("LW");

        // LH: funct3=001
        funct3 = 3'b001; funct7 = 7'b0000000; #10; show("LH");

        // LB: funct3=000
        funct3 = 3'b000; funct7 = 7'b0000000; #10; show("LB");

        // ------ Store instructions (opcode = 0100011) --------
        opcode = 7'b0100011;

        // SW: funct3=010
        funct3 = 3'b010; funct7 = 7'b0000000; #10; show("SW");

        // SH: funct3=001
        funct3 = 3'b001; funct7 = 7'b0000000; #10; show("SH");

        // SB: funct3=000
        funct3 = 3'b000; funct7 = 7'b0000000; #10; show("SB");

        // ------ Branch: BEQ (opcode = 1100011) ---------------
        opcode = 7'b1100011;
        funct3 = 3'b000; funct7 = 7'b0000000; #10; show("BEQ");

        // ------ Illegal / unknown opcode ---------------------
        opcode = 7'b1111111;
        funct3 = 3'b000; funct7 = 7'b0000000; #10; show("ILLEGAL");

        $display("=======================================================");
        $display(" Simulation complete.");
        $display("=======================================================");
        $finish;
    end

    initial begin
        $dumpfile("tb_control_path.vcd");
        $dumpvars(0, tb_control_path);
    end

endmodule