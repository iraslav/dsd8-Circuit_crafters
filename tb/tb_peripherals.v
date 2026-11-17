`timescale 1ns/1ps

module tb_peripherals;
    reg clk, rst_n;
    reg [7:0] port, wdata, inject_data;
    reg rd, wr, inject_valid;
    wire [7:0] rdata, tx_data;
    wire ready, tx_valid;
    integer errors;

    dsd8_ref_peripherals dut (
        .clk(clk), .rst_n(rst_n), .periph_port(port), .periph_wdata(wdata),
        .periph_rdata(rdata), .periph_rd(rd), .periph_wr(wr),
        .periph_ready(ready), .uart_rx_inject_valid(inject_valid),
        .uart_rx_inject_data(inject_data), .uart_tx_valid(tx_valid),
        .uart_tx_data(tx_data)
    );
    always #5 clk = ~clk;

    initial begin
        clk = 0; rst_n = 0; port = 0; wdata = 0; rd = 0; wr = 0;
        inject_valid = 0; inject_data = 0; errors = 0;
        repeat (2) @(posedge clk); rst_n = 1;
        port = 8'h20; wdata = 8'h41; wr = 1; #1;
        if (!ready) errors = errors + 1;
        @(posedge clk); #1; wr = 0;
        if (!tx_valid || tx_data !== 8'h41) errors = errors + 1;
        inject_data = 8'h5A; inject_valid = 1; @(posedge clk); #1; inject_valid = 0;
        port = 8'h22; rd = 1; #1;
        if (rdata[1] !== 1'b1 || !ready) errors = errors + 1;
        @(posedge clk); #1; rd = 0;
        port = 8'h21; rd = 1; #1;
        if (rdata !== 8'h5A || !ready) errors = errors + 1;
        @(posedge clk); #1; rd = 0;
        port = 8'h40; rd = 1; #1;
        if (ready) begin end
        repeat (10) @(posedge clk);
        if (!ready) errors = errors + 1;
        rd = 0;
        if (errors == 0) $display("TESTBENCH: PASS");
        else $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
