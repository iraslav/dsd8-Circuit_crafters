`timescale 1ns/1ps

module tb_data_memory;
    reg clk, we;
    reg [7:0] addr, wdata;
    wire [7:0] rdata;
    integer errors;

    data_memory dut (.clk(clk), .addr(addr), .we(we), .wdata(wdata), .rdata(rdata));
    always #5 clk = ~clk;

    initial begin
        clk = 0; we = 0; addr = 0; wdata = 0; errors = 0;
        #1 if (rdata !== 0) errors = errors + 1;
        addr = 8'hFF; #1 if (rdata !== 0) errors = errors + 1;
        addr = 8'hA5; wdata = 8'h3C; we = 1;
        @(posedge clk); #1; we = 0;
        if (rdata !== 8'h3C) errors = errors + 1;
        addr = 8'h00; #1 if (rdata !== 0) errors = errors + 1;
        if (errors == 0) $display("TESTBENCH: PASS");
        else $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
