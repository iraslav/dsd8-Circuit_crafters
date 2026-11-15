`timescale 1ns/1ps

module tb_datapath;
    reg clk;
    reg rst_n;
    reg pc_en;
    reg pc_load;
    reg [8:0] branch_addr;
    wire [8:0] pc;

    reg [15:0] instr;
    wire [3:0] opcode;
    wire [2:0] rd, rs1, rs2, cond;
    wire [7:0] imm8, port;
    wire [8:0] addr9;
    wire io_dir;

    reg [2:0] ra1, ra2, wa;
    reg rf_we;
    reg [7:0] wd;
    wire [7:0] rd1, rd2;

    reg flags_we;
    reg [3:0] flags_in;
    wire [3:0] flags_out;

    reg [7:0] mem_addr, mem_wdata;
    reg mem_we;
    wire [7:0] mem_rdata;
    integer errors;

    always #5 clk = ~clk;

    prog_counter pc_dut (
        .clk(clk), .rst_n(rst_n), .pc_en(pc_en), .pc_load(pc_load),
        .branch_addr(branch_addr), .pc(pc)
    );
    instr_decoder decoder (
        .instr(instr), .opcode(opcode), .rd(rd), .rs1(rs1), .rs2(rs2),
        .imm8(imm8), .addr9(addr9), .cond(cond), .port(port), .io_dir(io_dir)
    );
    register_file registers (
        .clk(clk), .rst_n(rst_n), .ra1(ra1), .ra2(ra2), .rd1(rd1),
        .rd2(rd2), .we(rf_we), .wa(wa), .wd(wd)
    );
    flags_reg status_flags (
        .clk(clk), .rst_n(rst_n), .flags_we(flags_we),
        .flags_in(flags_in), .flags_out(flags_out)
    );
    data_memory memory (
        .clk(clk), .addr(mem_addr), .we(mem_we),
        .wdata(mem_wdata), .rdata(mem_rdata)
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

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        pc_en = 1'b0;
        pc_load = 1'b0;
        branch_addr = 9'h000;
        instr = 16'hE702;
        ra1 = 3'h0;
        ra2 = 3'h0;
        wa = 3'h0;
        rf_we = 1'b0;
        wd = 8'h00;
        flags_we = 1'b0;
        flags_in = 4'h0;
        mem_addr = 8'hA5;
        mem_wdata = 8'h00;
        mem_we = 1'b0;
        errors = 0;

        repeat (2) @(posedge clk);
        #1;
        check(pc === 9'h000, "PC resets to zero");
        check(rd1 === 8'h00 && rd2 === 8'h00, "registers reset to zero");
        check(flags_out === 4'h0, "flags reset to zero");
        check(mem_rdata === 8'h00, "data memory initializes to zero");
        check(opcode === 4'hE && rd === 3'h3 && io_dir === 1'b1 &&
              port === 8'h02 && addr9 === 9'h102,
              "decoder extracts overlapping fields");

        rst_n = 1'b1;
        pc_en = 1'b1;
        @(posedge clk);
        #1;
        check(pc === 9'h001, "PC increments");
        pc_load = 1'b1;
        branch_addr = 9'h1FF;
        @(posedge clk);
        #1;
        check(pc === 9'h1FF, "PC loads branch target");
        pc_en = 1'b0;
        @(posedge clk);
        #1;
        check(pc === 9'h1FF, "PC holds when disabled");

        wa = 3'h5;
        wd = 8'hA6;
        rf_we = 1'b1;
        ra1 = 3'h5;
        @(posedge clk);
        #1;
        check(rd1 === 8'hA6, "register write is visible after the clock edge");
        rf_we = 1'b0;

        flags_in = 4'b1011;
        flags_we = 1'b1;
        @(posedge clk);
        #1;
        check(flags_out === 4'b1011, "flags update when enabled");
        flags_we = 1'b0;
        flags_in = 4'b0100;
        @(posedge clk);
        #1;
        check(flags_out === 4'b1011, "flags hold when disabled");

        mem_wdata = 8'h5C;
        mem_we = 1'b1;
        @(posedge clk);
        #1;
        check(mem_rdata === 8'h5C, "data memory writes and reads");

        if (errors == 0) $display("TESTBENCH: PASS");
        else             $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
