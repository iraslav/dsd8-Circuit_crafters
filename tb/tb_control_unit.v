`timescale 1ns/1ps

module tb_control_unit;
    reg clk, rst_n, io_ready;
    reg [3:0] opcode, flags;
    reg [2:0] cond;
    wire pc_en, pc_load, rf_we, mem_we, io_rd, io_wr, flags_we;
    wire [1:0] wb_sel;
    wire halted, retire;
    integer errors;
    integer i;

    always #5 clk = ~clk;

    control_unit dut (
        .clk(clk), .rst_n(rst_n), .opcode(opcode), .cond(cond),
        .flags(flags), .io_ready(io_ready), .pc_en(pc_en),
        .pc_load(pc_load), .rf_we(rf_we), .mem_we(mem_we),
        .io_rd(io_rd), .io_wr(io_wr), .flags_we(flags_we),
        .wb_sel(wb_sel), .halted(halted), .retire(retire)
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

    task enter_execute;
        begin
            #1;
            check(!retire && !pc_en, "fetch state has no side effects");
            @(posedge clk);
            #1;
        end
    endtask

    task leave_execute;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task check_simple_instruction;
        input [3:0] op;
        input expected_rf_we;
        input expected_mem_we;
        input expected_flags_we;
        input [1:0] expected_wb_sel;
        begin
            opcode = op;
            enter_execute;
            check(retire && pc_en, "instruction retires and advances PC");
            check(rf_we === expected_rf_we, "register write control");
            check(mem_we === expected_mem_we, "memory write control");
            check(flags_we === expected_flags_we, "flags write control");
            check(wb_sel === expected_wb_sel, "writeback selection");
            leave_execute;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        io_ready = 1'b0;
        opcode = 4'h0;
        cond = 3'h0;
        flags = 4'h0;
        errors = 0;
        repeat (2) @(posedge clk);
        #1;
        check(!halted && !retire, "reset starts in fetch");
        rst_n = 1'b1;

        check_simple_instruction(4'h0, 1'b0, 1'b0, 1'b0, 2'b00);
        check_simple_instruction(4'h1, 1'b1, 1'b0, 1'b0, 2'b10);
        check_simple_instruction(4'h2, 1'b1, 1'b0, 1'b0, 2'b01);
        check_simple_instruction(4'h3, 1'b0, 1'b1, 1'b0, 2'b00);
        for (i = 4; i <= 10; i = i + 1)
            check_simple_instruction(i[3:0], 1'b1, 1'b0, 1'b1, 2'b00);
        check_simple_instruction(4'hB, 1'b0, 1'b0, 1'b1, 2'b00);

        opcode = 4'hC;
        enter_execute;
        check(retire && pc_en && pc_load, "JMP loads the target");
        leave_execute;

        opcode = 4'hD;
        for (i = 0; i < 8; i = i + 1) begin
            cond = i[2:0];
            case (i)
                0: flags = 4'b1000;
                1: flags = 4'b0000;
                2: flags = 4'b0010;
                3: flags = 4'b0000;
                4: flags = 4'b0100;
                5: flags = 4'b0000;
                6: flags = 4'b0001;
                7: flags = 4'b0000;
            endcase
            enter_execute;
            check(retire && pc_en && pc_load, "taken branch condition");
            leave_execute;
        end
        for (i = 0; i < 8; i = i + 1) begin
            cond = i[2:0];
            case (i)
                0: flags = 4'b0000;
                1: flags = 4'b1000;
                2: flags = 4'b0000;
                3: flags = 4'b0010;
                4: flags = 4'b0000;
                5: flags = 4'b0100;
                6: flags = 4'b0000;
                7: flags = 4'b0001;
            endcase
            enter_execute;
            check(retire && pc_en && !pc_load, "untaken branch falls through");
            leave_execute;
        end

        opcode = 4'hE;
        io_ready = 1'b0;
        enter_execute;
        check(!retire && !pc_en && !rf_we, "I/O execute enters wait without side effects");
        @(posedge clk);
        #1;
        check((io_rd || io_wr) && !retire && !pc_en && !rf_we,
              "I/O request remains asserted while stalled");
        io_ready = 1'b1;
        #1;
        check(retire && pc_en && rf_we && wb_sel == 2'b11,
              "ready completes I/O and selects peripheral read data");
        leave_execute;

        opcode = 4'hF;
        enter_execute;
        check(retire && !halted && !pc_en, "HLT retires and holds PC");
        leave_execute;
        check(halted && !retire && !pc_en, "halted processor remains stopped");

        if (errors == 0) $display("TESTBENCH: PASS");
        else             $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
