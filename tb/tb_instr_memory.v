`timescale 1ns/1ps

module tb_instr_memory;
    reg clk;
    reg [8:0] addr;
    wire [15:0] data;
    integer errors;

    instr_memory #(.IMAGE("")) dut (
        .clk(clk), .addr(addr), .data(data)
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
        addr = 9'h000;
        errors = 0;
        dut.mem[0] = 16'h140D;
        dut.mem[1] = 16'h46C8;
        dut.mem[9'h1FF] = 16'hF000;
        #1;
        check(data === 16'h140D, "combinational read at address zero");
        addr = 9'h001;
        #1;
        check(data === 16'h46C8, "combinational read follows address");
        addr = 9'h1FF;
        #1;
        check(data === 16'hF000, "last instruction address is accessible");

        if (errors == 0) $display("TESTBENCH: PASS");
        else             $display("TESTBENCH: FAIL (%0d errors)", errors);
        $finish;
    end
endmodule
