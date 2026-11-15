// control_unit.v -- multi-cycle controller for the DSD-8 processor

module control_unit (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] opcode,
    input  wire [2:0] cond,
    input  wire [3:0] flags,      // {Z,N,C,V}
    input  wire       io_ready,
    output reg        pc_en,
    output reg        pc_load,
    output reg        rf_we,
    output reg        mem_we,
    output reg        io_rd,
    output reg        io_wr,
    output reg        flags_we,
    output reg  [1:0] wb_sel,     // 0=ALU 1=DMEM 2=imm8 3=io_rdata
    output reg        halted,
    output reg        retire
);

    localparam FETCH   = 2'b00;
    localparam EXECUTE = 2'b01;
    localparam IO_WAIT = 2'b10;
    localparam HALTED  = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;
    reg branch_taken;

    always @(*) begin
        branch_taken = 1'b0;
        case (cond)
            3'b000: branch_taken = flags[3];       // BEQ
            3'b001: branch_taken = !flags[3];      // BNE
            3'b010: branch_taken = flags[1];       // BCS
            3'b011: branch_taken = !flags[1];      // BCC
            3'b100: branch_taken = flags[2];       // BMI
            3'b101: branch_taken = !flags[2];      // BPL
            3'b110: branch_taken = flags[0];       // BVS
            3'b111: branch_taken = !flags[0];      // BVC
        endcase

        pc_en = 1'b0;
        pc_load = 1'b0;
        rf_we = 1'b0;
        mem_we = 1'b0;
        io_rd = 1'b0;
        io_wr = 1'b0;
        flags_we = 1'b0;
        wb_sel = 2'b00;
        halted = (state == HALTED);
        retire = 1'b0;
        next_state = state;

        case (state)
            FETCH: next_state = EXECUTE;

            EXECUTE: begin
                case (opcode)
                    4'h0: begin
                        pc_en = 1'b1;
                        retire = 1'b1;
                        next_state = FETCH;
                    end
                    4'h1: begin
                        rf_we = 1'b1;
                        wb_sel = 2'b10;
                        pc_en = 1'b1;
                        retire = 1'b1;
                        next_state = FETCH;
                    end
                    4'h2: begin
                        rf_we = 1'b1;
                        wb_sel = 2'b01;
                        pc_en = 1'b1;
                        retire = 1'b1;
                        next_state = FETCH;
                    end
                    4'h3: begin
                        mem_we = 1'b1;
                        pc_en = 1'b1;
                        retire = 1'b1;
                        next_state = FETCH;
                    end
                    4'h4, 4'h5, 4'h6, 4'h7, 4'h8, 4'h9, 4'hA: begin
                        rf_we = 1'b1;
                        flags_we = 1'b1;
                        pc_en = 1'b1;
                        retire = 1'b1;
                        next_state = FETCH;
                    end
                    4'hB: begin
                        flags_we = 1'b1;
                        pc_en = 1'b1;
                        retire = 1'b1;
                        next_state = FETCH;
                    end
                    4'hC: begin
                        pc_en = 1'b1;
                        pc_load = 1'b1;
                        retire = 1'b1;
                        next_state = FETCH;
                    end
                    4'hD: begin
                        pc_en = 1'b1;
                        pc_load = branch_taken;
                        retire = 1'b1;
                        next_state = FETCH;
                    end
                    4'hE: next_state = IO_WAIT;
                    4'hF: begin
                        retire = 1'b1;
                        next_state = HALTED;
                    end
                endcase
            end

            IO_WAIT: begin
                // Direction is encoded in the instruction and is gated by
                // dsd8_cpu; this interface exposes one shared I/O wait state.
                io_rd = 1'b1;
                io_wr = 1'b1;
                if (io_ready) begin
                    rf_we = 1'b1;
                    wb_sel = 2'b11;
                    pc_en = 1'b1;
                    retire = 1'b1;
                    next_state = FETCH;
                end
            end

            HALTED: next_state = HALTED;
            default: next_state = FETCH;
        endcase
    end

    always @(posedge clk) begin
        if (!rst_n) state <= FETCH;
        else        state <= next_state;
    end

endmodule
