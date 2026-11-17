`timescale 1ns/1ps

module tb_uart_integration;
    reg clk, rst_n;
    reg [15:0] image [0:511];
    reg [7:0] switches;
    reg [4:0] buttons;
    reg uart_rx_inject_valid;
    reg [7:0] uart_rx_inject_data;
    wire [8:0] imem_addr;
    wire [15:0] imem_data;
    wire [7:0] io_port, io_wdata, io_rdata;
    wire io_rd, io_wr, io_ready, halted;
    wire [7:0] leds, seg_value, seg_enable;
    wire [7:0] periph_port, periph_wdata, periph_rdata;
    wire periph_rd, periph_wr, periph_ready;
    wire uart_tx_valid;
    wire [7:0] uart_tx_data;
    integer errors;
    reg tx_seen;

    assign imem_data = image[imem_addr];
    dsd8_cpu cpu (
        .clk(clk), .rst_n(rst_n), .imem_addr(imem_addr), .imem_data(imem_data),
        .io_port(io_port), .io_wdata(io_wdata), .io_rdata(io_rdata),
        .io_rd(io_rd), .io_wr(io_wr), .io_ready(io_ready), .halted(halted),
        .retire(), .retire_pc(), .retire_ir(), .retire_rf_we(),
        .retire_rf_addr(), .retire_rf_data(), .retire_mem_we(),
        .retire_mem_addr(), .retire_mem_data(), .retire_flags()
    );
    io_bus bus (
        .clk(clk), .rst_n(rst_n), .io_port(io_port), .io_wdata(io_wdata),
        .io_rdata(io_rdata), .io_rd(io_rd), .io_wr(io_wr), .io_ready(io_ready),
        .switches(switches), .buttons(buttons), .leds(leds),
        .seg_value(seg_value), .seg_enable(seg_enable),
        .periph_port(periph_port), .periph_wdata(periph_wdata),
        .periph_rdata(periph_rdata), .periph_rd(periph_rd),
        .periph_wr(periph_wr), .periph_ready(periph_ready)
    );
    dsd8_ref_peripherals peripherals (
        .clk(clk), .rst_n(rst_n), .periph_port(periph_port),
        .periph_wdata(periph_wdata), .periph_rdata(periph_rdata),
        .periph_rd(periph_rd), .periph_wr(periph_wr),
        .periph_ready(periph_ready),
        .uart_rx_inject_valid(uart_rx_inject_valid),
        .uart_rx_inject_data(uart_rx_inject_data),
        .uart_tx_valid(uart_tx_valid), .uart_tx_data(uart_tx_data)
    );
    always #5 clk = ~clk;
    always @(posedge clk) begin
        if (uart_tx_valid) begin
            tx_seen = 1'b1;
            if (uart_tx_data !== 8'h5A) errors = errors + 1;
        end
    end

    initial begin
        image[0] = 16'h1202; // LDI R1, 2 (rx_valid mask)
        image[1] = 16'hE422; // IN R2, 0x22
        image[2] = 16'h6648; // AND R3, R2, R1
        image[3] = 16'hD001; // BEQ LOOP
        image[4] = 16'hE821; // IN R4, 0x21
        image[5] = 16'hE920; // OUT 0x20, R4
        image[6] = 16'hF000; // HLT
        clk = 0; rst_n = 0; switches = 0; buttons = 0;
        uart_rx_inject_valid = 0; uart_rx_inject_data = 8'h00;
        errors = 0; tx_seen = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        repeat (5) @(posedge clk);
        uart_rx_inject_data = 8'h5A;
        uart_rx_inject_valid = 1;
        @(posedge clk); #1;
        uart_rx_inject_valid = 0;
        repeat (200) @(posedge clk);
        if (!tx_seen || !halted) errors = errors + 1;
        if (errors == 0) $display("TESTBENCH: PASS");
        else $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
