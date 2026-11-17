`timescale 1ns/1ps

module tb_dsd8_top;
    reg clk, rst_n;
    reg [7:0] switches;
    reg [4:0] buttons;
    wire [7:0] leds;
    wire [6:0] seg;
    wire [3:0] an;
    wire halted;
    integer errors;

    dsd8_top dut (.clk(clk), .rst_n(rst_n), .switches(switches),
                  .buttons(buttons), .leds(leds), .seg(seg), .an(an),
                  .halted(halted));
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; switches = 8'hA5; buttons = 5'h12; errors = 0;
        repeat (3) @(posedge clk); #1;
        if (leds !== 0 || an !== 4'hF || halted !== 0) errors = errors + 1;
        rst_n = 1; repeat (2) @(posedge clk); #1;
        if (leds !== 0 || halted !== 0) errors = errors + 1;
        if (errors == 0) $display("TESTBENCH: PASS");
        else $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
