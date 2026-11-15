// instr_decoder.v -- splits the instruction word into fields
// Owner: member A -- this is YOUR module; you are individually examined
// on it at the oral defence.
// Spec: Section 5.5. Purely combinational. Port list is FROZEN.
//
// Section 5.5's note on deliberate field overlaps applies here: rd and
// cond are the same bits; imm8 and port are the same bits; rs1 and the
// top of addr9 overlap. Extract all of them unconditionally from the
// bit positions given in Appendix A -- the control unit is what
// chooses which ones are meaningful, based on opcode. This module
// should never look at opcode to decide what to output.
//
module instr_decoder (
    input  wire [15:0] instr,
    output wire [3:0]  opcode,   // instr[15:12]
    output wire [2:0]  rd,       // instr[11:9]
    output wire [2:0]  rs1,      // instr[8:6]
    output wire [2:0]  rs2,      // instr[5:3]
    output wire [7:0]  imm8,     // instr[7:0]
    output wire [8:0]  addr9,    // instr[8:0]
    output wire [2:0]  cond,     // instr[11:9]
    output wire [7:0]  port,     // instr[7:0]
    output wire        io_dir    // instr[8]: 0 = IN, 1 = OUT
);

    assign opcode = instr[15:12];
    assign rd     = instr[11:9];
    assign rs1    = instr[8:6];
    assign rs2    = instr[5:3];
    assign imm8   = instr[7:0];
    assign addr9  = instr[8:0];
    assign cond   = instr[11:9];
    assign port   = instr[7:0];
    assign io_dir = instr[8];

endmodule
