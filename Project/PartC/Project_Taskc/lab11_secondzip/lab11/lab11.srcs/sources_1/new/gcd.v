`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// GCD Module - Computes Greatest Common Divisor
// Uses Euclidean Algorithm with iterative subtraction
//
// Algorithm:
//   while b != 0:
//       temp = b
//       b = a mod b  (implemented as: b = a - b while b < a)
//       a = temp
//   return a
//////////////////////////////////////////////////////////////////////////////////

module gcd (
    input  wire        clk,
    input  wire        reset,
    input  wire        start,          // Start GCD computation
    input  wire [31:0] a_in,           // First input value
    input  wire [31:0] b_in,           // Second input value
    output reg  [31:0] result,         // GCD result
    output reg         done             // High when computation complete
);

    // State machine states
    localparam STATE_IDLE      = 2'b00;
    localparam STATE_COMPUTE   = 2'b01;
    localparam STATE_DONE      = 2'b10;

    reg [1:0]  state, next_state;
    reg [31:0] a, b;
    
    // =========================================================================
    // State Machine Logic
    // =========================================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= STATE_IDLE;
            a <= 32'b0;
            b <= 32'b0;
            result <= 32'b0;
            done <= 1'b0;
        end else begin
            state <= next_state;
            
            case (state)
                STATE_IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        // Load inputs, replace 0 with 1 to prevent infinite loops
                        a <= (a_in == 32'b0) ? 32'd1 : a_in;
                        b <= (b_in == 32'b0) ? 32'd1 : b_in;
                    end
                end

                STATE_COMPUTE: begin
                    // Correct Euclidean algorithm using subtraction
                    if (a == b) begin
                        result <= a;
                        done <= 1'b1;
                    end else if (a > b) begin
                        a <= a - b;
                    end else if (b > a) begin
                        b <= b - a;
                    end
                end

                STATE_DONE: begin
                    // Result is valid, wait for next start
                    done <= 1'b1;
                    if (start) begin
                        done <= 1'b0;
                    end
                end

                default: begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end

    // =========================================================================
    // Next State Logic
    // =========================================================================
    always @(*) begin
        case (state)
            STATE_IDLE: begin
                if (start)
                    next_state = STATE_COMPUTE;
                else
                    next_state = STATE_IDLE;
            end

            STATE_COMPUTE: begin
                if (a == b)
                    next_state = STATE_DONE;
                else
                    next_state = STATE_COMPUTE;
            end

            STATE_DONE: begin
                if (start)
                    next_state = STATE_COMPUTE;
                else
                    next_state = STATE_DONE;
            end

            default: begin
                next_state = STATE_IDLE;
            end
        endcase
    end

endmodule