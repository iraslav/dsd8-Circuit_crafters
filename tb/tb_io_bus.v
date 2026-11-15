`timescale 1ns/1ps

module tb_io_bus;
    reg clk, rst_n;
    reg [7:0] io_port, io_wdata, switches, periph_rdata;
    reg [4:0] buttons;
    reg io_rd, io_wr, periph_ready;
    wire [7:0] io_rdata, leds, seg_value, seg_enable;
    wire io_ready;
    wire [7:0] periph_port, periph_wdata;
    wire periph_rd, periph_wr;
    integer errors;

    always #5 clk = ~clk;

    io_bus dut (
        .clk(clk), .rst_n(rst_n), .io_port(io_port), .io_wdata(io_wdata),
        .io_rdata(io_rdata), .io_rd(io_rd), .io_wr(io_wr),
        .io_ready(io_ready), .switches(switches), .buttons(buttons),
        .leds(leds), .seg_value(seg_value), .seg_enable(seg_enable),
        .periph_port(periph_port), .periph_wdata(periph_wdata),
        .periph_rdata(periph_rdata), .periph_rd(periph_rd),
        .periph_wr(periph_wr), .periph_ready(periph_ready)
    );

    task check;
        input condition;
        input [255:0] message;
        begin
            if (!condition) begin
                errors = errors + 1;
                $display("  FAIL: %0s", message);
            end
        end
    endtask

    task write_local;
        input [7:0] address;
        input [7:0] value;
        begin
            io_port = address;
            io_wdata = value;
            io_wr = 1'b1;
            #1;
            check(io_ready, "local port write is ready");
            @(posedge clk);
            #1;
            io_wr = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        io_port = 8'h00;
        io_wdata = 8'h00;
        switches = 8'hA5;
        buttons = 5'b10110;
        periph_rdata = 8'hC3;
        io_rd = 1'b0;
        io_wr = 1'b0;
        periph_ready = 1'b0;
        errors = 0;
        repeat (2) @(posedge clk);
        #1;
        check(leds == 0 && seg_value == 0 && seg_enable == 0,
              "board output latches reset");
        rst_n = 1'b1;

        io_rd = 1'b1;
        io_port = 8'h00;
        #1;
        check(io_ready && io_rdata == switches, "switch input port");
        io_port = 8'h01;
        #1;
        check(io_ready && io_rdata == {3'b000, buttons}, "button input port");
        io_port = 8'h03;
        #1;
        check(io_ready && io_rdata == 8'h00, "unmapped local port reads zero");
        io_rd = 1'b0;
        #1;
        check(!io_ready, "bus is not ready without a request");

        write_local(8'h02, 8'h5A);
        check(leds == 8'h5A, "LED output latch");
        write_local(8'h10, 8'h3C);
        check(seg_value == 8'h3C, "seven-segment value latch");
        write_local(8'h11, 8'h0F);
        check(seg_enable == 8'h0F, "seven-segment enable latch");

        io_port = 8'h40;
        io_wdata = 8'h77;
        io_wr = 1'b1;
        #1;
        check(!io_ready && periph_wr && !periph_rd,
              "peripheral write request stalls until ready");
        check(periph_port == 8'h40 && periph_wdata == 8'h77,
              "peripheral address and write data forwarded");
        @(posedge clk);
        #1;
        check(leds == 8'h5A, "peripheral wait does not change board outputs");
        periph_ready = 1'b1;
        #1;
        check(io_ready, "peripheral ready completes handshake");
        @(posedge clk);
        #1;
        io_wr = 1'b0;

        io_port = 8'h40;
        io_rd = 1'b1;
        #1;
        check(periph_rd && !periph_wr && io_rdata == 8'hC3 && io_ready,
              "peripheral read data and ready are forwarded");
        io_rd = 1'b0;
        io_port = 8'h7F;
        periph_ready = 1'b1;
        io_wr = 1'b1;
        #1;
        check(io_ready && periph_wr, "unmapped peripheral writes do not stall");
        io_wr = 1'b0;

        if (errors == 0) $display("TESTBENCH: PASS");
        else             $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
