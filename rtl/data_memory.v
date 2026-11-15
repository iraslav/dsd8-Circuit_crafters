// data_memory.v -- 256 x 8 read/write memory
// Owner: member C -- this is YOUR module; you are individually examined
// on it at the oral defence.
// Spec: Section 5.9. Port list is FROZEN -- note that it has no rst_n
// of its own, unlike every other stateful module in this design.
//
// R16: all 256 bytes shall clear to 0x00 by reset, so a read of a
// never-written location returns 0x00, not X. Test T09 checks this
// deliberately.
//
// The array is initialized to zero to satisfy R16; simulation and the
// intended FPGA targets support initial memory contents.

module data_memory (
    input  wire       clk,
    input  wire [7:0] addr,
    input  wire       we,
    input  wire [7:0] wdata,
    output wire [7:0] rdata     // combinational read
);

    reg [7:0] mem [0:255];
    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1) mem[i] = 8'h00;
    end

    always @(posedge clk) begin
        if (we) mem[addr] <= wdata;
    end

    assign rdata = mem[addr];

endmodule
