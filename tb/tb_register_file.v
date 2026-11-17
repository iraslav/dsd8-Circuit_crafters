`timescale 1ns/1ps

module tb_register_file;
    reg clk, rst_n, we;
    reg [2:0] ra1, ra2, wa;
    reg [7:0] wd;
    wire [7:0] rd1, rd2;
    integer errors;

    register_file dut (.clk(clk), .rst_n(rst_n), .ra1(ra1), .ra2(ra2),
                       .rd1(rd1), .rd2(rd2), .we(we), .wa(wa), .wd(wd));
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; we = 0; ra1 = 0; ra2 = 0; wa = 0; wd = 0; errors = 0;
        repeat (2) @(posedge clk); #1;
        if (rd1 !== 0 || rd2 !== 0) errors = errors + 1;
        rst_n = 1; wa = 3; wd = 8'hA6; we = 1; ra1 = 3;
        #1 if (rd1 !== 0) errors = errors + 1;
        @(posedge clk); #1; we = 0;
        if (rd1 !== 8'hA6) errors = errors + 1;
        ra2 = 7; wa = 7; wd = 8'h5C; we = 1; #1;
        if (rd2 !== 0) errors = errors + 1;
        @(posedge clk); #1; we = 0;
        if (rd2 !== 8'h5C) errors = errors + 1;
        if (errors == 0) $display("TESTBENCH: PASS");
        else $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
