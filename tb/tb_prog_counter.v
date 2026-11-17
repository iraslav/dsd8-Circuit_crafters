`timescale 1ns/1ps

module tb_prog_counter;
    reg clk, rst_n, pc_en, pc_load;
    reg [8:0] branch_addr;
    wire [8:0] pc;
    integer errors;

    prog_counter dut (.clk(clk), .rst_n(rst_n), .pc_en(pc_en), .pc_load(pc_load),
                      .branch_addr(branch_addr), .pc(pc));
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; pc_en = 0; pc_load = 0; branch_addr = 0; errors = 0;
        repeat (2) @(posedge clk); #1;
        if (pc !== 0) errors = errors + 1;
        rst_n = 1; pc_en = 1; @(posedge clk); #1;
        if (pc !== 1) errors = errors + 1;
        pc_load = 1; branch_addr = 9'h1FF; @(posedge clk); #1;
        if (pc !== 9'h1FF) errors = errors + 1;
        pc_en = 0; @(posedge clk); #1;
        if (pc !== 9'h1FF) errors = errors + 1;
        if (errors == 0) $display("TESTBENCH: PASS");
        else $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
