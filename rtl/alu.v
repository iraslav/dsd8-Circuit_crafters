// alu.v -- arithmetic, logic, shifts, and the four flag outputs
// Owner: member B -- this is YOUR module; you are individually examined
// on it at the oral defence, and it is the one Section 8.5 (R24-R25)
// requires a constrained-random self-checking testbench for.
// Spec: Section 5.7 and Section 2.3. Purely combinational. Port list
// is FROZEN. `op` is the instruction opcode directly (R15) -- no
// separate ALU-control encoding needed.
//
// The arithmetic, carry, overflow, and logical-operation definitions
// follow Section 2.3 and are checked by tb/tb_alu_example.v.

module alu (
    input  wire [7:0] a,
    input  wire [7:0] b,
    input  wire [3:0] op,     // instruction opcode: 0x4 ADD .. 0xB CMP
    output wire [7:0] result,
    output wire       flag_z,
    output wire       flag_n,
    output wire       flag_c,
    output wire       flag_v
);

    wire is_sub = (op == 4'h5) || (op == 4'hB);
    wire [8:0] add_sub = {1'b0, a} + {1'b0, (is_sub ? ~b : b)} + is_sub;

    reg [7:0] result_r;
    reg carry_r;
    reg overflow_r;

    always @(*) begin
        result_r = 8'h00;
        carry_r = 1'b0;
        overflow_r = 1'b0;
        case (op)
            4'h4: begin
                result_r = add_sub[7:0];
                carry_r = add_sub[8];
                overflow_r = (a[7] == b[7]) && (result_r[7] != a[7]);
            end
            4'h5, 4'hB: begin
                result_r = add_sub[7:0];
                carry_r = add_sub[8];
                overflow_r = (a[7] != b[7]) && (result_r[7] != a[7]);
            end
            4'h6: result_r = a & b;
            4'h7: result_r = a | b;
            4'h8: result_r = a ^ b;
            4'h9: begin
                result_r = {a[6:0], 1'b0};
                carry_r = a[7];
            end
            4'hA: begin
                result_r = {1'b0, a[7:1]};
                carry_r = a[0];
            end
            default: begin
                result_r = 8'h00;
                carry_r = 1'b0;
                overflow_r = 1'b0;
            end
        endcase
    end

    assign result = result_r;
    assign flag_z = (result_r == 8'h00);
    assign flag_n = result_r[7];
    assign flag_c = carry_r;
    assign flag_v = overflow_r;

endmodule
