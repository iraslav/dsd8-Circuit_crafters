// dsd8_top.v -- board-level processor integration

module dsd8_top (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] switches,
    input  wire [4:0] buttons,
    output wire [7:0] leds,
    output reg  [6:0] seg,
    output wire [3:0] an,
    output wire       halted
);

    wire [8:0] imem_addr;
    wire [15:0] imem_data;
    wire [7:0] io_port;
    wire [7:0] io_wdata;
    wire [7:0] io_rdata;
    wire io_rd;
    wire io_wr;
    wire io_ready;
    /* verilator lint_off UNUSEDSIGNAL */
    wire [7:0] seg_value;
    wire [7:0] seg_enable;
    wire [7:0] periph_port;
    wire [7:0] periph_wdata;
    wire periph_rd;
    wire periph_wr;
    wire retire;
    wire [8:0] retire_pc;
    wire [15:0] retire_ir;
    wire retire_rf_we;
    wire [2:0] retire_rf_addr;
    wire [7:0] retire_rf_data;
    wire retire_mem_we;
    wire [7:0] retire_mem_addr;
    wire [7:0] retire_mem_data;
    wire [3:0] retire_flags;
    /* verilator lint_on UNUSEDSIGNAL */

    dsd8_cpu cpu (
        .clk(clk),
        .rst_n(rst_n),
        .imem_addr(imem_addr),
        .imem_data(imem_data),
        .io_port(io_port),
        .io_wdata(io_wdata),
        .io_rdata(io_rdata),
        .io_rd(io_rd),
        .io_wr(io_wr),
        .io_ready(io_ready),
        .halted(halted),
        .retire(retire),
        .retire_pc(retire_pc),
        .retire_ir(retire_ir),
        .retire_rf_we(retire_rf_we),
        .retire_rf_addr(retire_rf_addr),
        .retire_rf_data(retire_rf_data),
        .retire_mem_we(retire_mem_we),
        .retire_mem_addr(retire_mem_addr),
        .retire_mem_data(retire_mem_data),
        .retire_flags(retire_flags)
    );

    instr_memory instruction_store (
        .clk(clk),
        .addr(imem_addr),
        .data(imem_data)
    );

    io_bus ports (
        .clk(clk),
        .rst_n(rst_n),
        .io_port(io_port),
        .io_wdata(io_wdata),
        .io_rdata(io_rdata),
        .io_rd(io_rd),
        .io_wr(io_wr),
        .io_ready(io_ready),
        .switches(switches),
        .buttons(buttons),
        .leds(leds),
        .seg_value(seg_value),
        .seg_enable(seg_enable),
        .periph_port(periph_port),
        .periph_wdata(periph_wdata),
        .periph_rdata(8'h00),
        .periph_rd(periph_rd),
        .periph_wr(periph_wr),
        .periph_ready(1'b1)
    );

    assign an = ~seg_enable[3:0];

    always @(*) begin
        case (seg_value[3:0])
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
        endcase
    end

endmodule
