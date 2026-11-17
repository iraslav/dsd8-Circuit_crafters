`timescale 1ns/1ps

module tb_dsd8_cpu;
    reg clk, rst_n, io_ready;
    reg [7:0] io_rdata;
    wire [8:0] imem_addr;
    wire [15:0] imem_data;
    wire [7:0] io_port, io_wdata;
    wire io_rd, io_wr, halted, retire;
    wire [8:0] retire_pc;
    wire [15:0] retire_ir;
    wire retire_rf_we, retire_mem_we;
    wire [2:0] retire_rf_addr;
    wire [7:0] retire_rf_data, retire_mem_addr, retire_mem_data;
    wire [3:0] retire_flags;
    reg [15:0] image [0:511];
    integer errors, retire_count;

    assign imem_data = image[imem_addr];
    dsd8_cpu dut (
        .clk(clk), .rst_n(rst_n), .imem_addr(imem_addr), .imem_data(imem_data),
        .io_port(io_port), .io_wdata(io_wdata), .io_rdata(io_rdata),
        .io_rd(io_rd), .io_wr(io_wr), .io_ready(io_ready), .halted(halted),
        .retire(retire), .retire_pc(retire_pc), .retire_ir(retire_ir),
        .retire_rf_we(retire_rf_we), .retire_rf_addr(retire_rf_addr),
        .retire_rf_data(retire_rf_data), .retire_mem_we(retire_mem_we),
        .retire_mem_addr(retire_mem_addr), .retire_mem_data(retire_mem_data),
        .retire_flags(retire_flags)
    );
    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (rst_n && retire) begin
            retire_count = retire_count + 1;
            if (retire_count == 1 &&
                (!retire_rf_we || retire_rf_addr !== 3'h1 ||
                 retire_rf_data !== 8'h2A)) errors = errors + 1;
            if (retire_count == 2 && retire_ir !== 16'hF000) errors = errors + 1;
        end
    end

    initial begin
        image[0] = 16'h122A;
        image[1] = 16'hF000;
        clk = 0; rst_n = 0; io_ready = 1; io_rdata = 0;
        errors = 0; retire_count = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        repeat (8) @(posedge clk);
        if (!halted || retire_count != 2) errors = errors + 1;
        if (errors == 0) $display("TESTBENCH: PASS");
        else $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
