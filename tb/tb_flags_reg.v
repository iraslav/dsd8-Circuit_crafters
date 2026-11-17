`timescale 1ns/1ps

module tb_flags_reg;
    reg clk, rst_n, flags_we;
    reg [3:0] flags_in;
    wire [3:0] flags_out;
    integer errors;

    flags_reg dut (.clk(clk), .rst_n(rst_n), .flags_we(flags_we),
                   .flags_in(flags_in), .flags_out(flags_out));
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; flags_we = 0; flags_in = 0; errors = 0;
        repeat (2) @(posedge clk); #1;
        if (flags_out !== 0) errors = errors + 1;
        rst_n = 1; flags_in = 4'b1010; flags_we = 1;
        @(posedge clk); #1; flags_we = 0;
        if (flags_out !== 4'b1010) errors = errors + 1;
        flags_in = 4'b0101; @(posedge clk); #1;
        if (flags_out !== 4'b1010) errors = errors + 1;
        if (errors == 0) $display("TESTBENCH: PASS");
        else $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
