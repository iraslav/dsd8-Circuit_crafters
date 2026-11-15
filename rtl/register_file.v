// register_file.v -- 8 x 8 registers, two read ports, one write port
// Owner: member B -- this is YOUR module; you are individually examined
// on it at the oral defence.
// Spec: Section 5.6. Port list is FROZEN.
//
// What is required (R14):
//   - all eight registers clear to 0x00 on reset
//   - reads are combinational
//   - a write and a read of the same register on the same cycle return
//     the OLD value on the read ports; the new value is visible from
//     the next cycle onward (do not add write-through forwarding you
//     were not asked for -- it will not match the reference)
//
module register_file (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [2:0] ra1,     // read address 1
    input  wire [2:0] ra2,     // read address 2
    output wire [7:0] rd1,     // combinational read data 1
    output wire [7:0] rd2,     // combinational read data 2
    input  wire       we,      // write enable
    input  wire [2:0] wa,      // write address
    input  wire [7:0] wd       // write data
);

    reg [7:0] regs [0:7];
    integer i;

    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                regs[i] <= 8'h00;
            end
        end else begin
            if (we) regs[wa] <= wd;
        end
    end

    assign rd1 = regs[ra1];
    assign rd2 = regs[ra2];

endmodule
