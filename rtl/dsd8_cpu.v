// dsd8_cpu.v -- processor datapath and frozen CPU interface

module dsd8_cpu (
    input  wire        clk,
    input  wire        rst_n,
    output wire [8:0]  imem_addr,
    input  wire [15:0] imem_data,
    output wire [7:0]  io_port,
    output wire [7:0]  io_wdata,
    input  wire [7:0]  io_rdata,
    output wire        io_rd,
    output wire        io_wr,
    input  wire        io_ready,
    output wire        halted,
    output wire        retire,
    output wire [8:0]  retire_pc,
    output wire [15:0] retire_ir,
    output wire        retire_rf_we,
    output wire [2:0]  retire_rf_addr,
    output wire [7:0]  retire_rf_data,
    output wire        retire_mem_we,
    output wire [7:0]  retire_mem_addr,
    output wire [7:0]  retire_mem_data,
    output wire [3:0]  retire_flags
);

    wire [3:0] opcode;
    wire [2:0] rd;
    wire [2:0] rs1;
    wire [2:0] rs2;
    wire [7:0] imm8;
    wire [8:0] addr9;
    wire [2:0] cond;
    wire [7:0] port;
    wire io_dir;

    wire [7:0] rf_rd1;
    wire [7:0] rf_rd2;
    wire [7:0] alu_result;
    wire [3:0] flags;
    wire [3:0] alu_flags;
    wire [7:0] mem_rdata;
    wire [7:0] wb_data;

    wire pc_en;
    wire pc_load;
    wire rf_we;
    wire mem_we;
    wire cu_io_rd;
    wire cu_io_wr;
    wire flags_we;
    wire [1:0] wb_sel;

    wire [2:0] rf_ra2 = ((opcode == 4'h3) ||
                         ((opcode == 4'hE) && io_dir)) ? rd : rs2;
    wire rf_we_actual = rf_we && !((opcode == 4'hE) && io_dir);

    assign io_port = (opcode == 4'hE) ? port : 8'h00;
    assign io_wdata = ((opcode == 4'hE) && io_dir) ? rf_rd2 : 8'h00;
    assign io_rd = cu_io_rd && !io_dir;
    assign io_wr = cu_io_wr && io_dir;
    assign wb_data = (wb_sel == 2'b00) ? alu_result :
                     (wb_sel == 2'b01) ? mem_rdata :
                     (wb_sel == 2'b10) ? imm8 : io_rdata;

    instr_decoder decoder (
        .instr(imem_data),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .imm8(imm8),
        .addr9(addr9),
        .cond(cond),
        .port(port),
        .io_dir(io_dir)
    );

    prog_counter pc_unit (
        .clk(clk),
        .rst_n(rst_n),
        .pc_en(pc_en),
        .pc_load(pc_load),
        .branch_addr(addr9),
        .pc(imem_addr)
    );

    register_file registers (
        .clk(clk),
        .rst_n(rst_n),
        .ra1(rs1),
        .ra2(rf_ra2),
        .rd1(rf_rd1),
        .rd2(rf_rd2),
        .we(rf_we_actual),
        .wa(rd),
        .wd(wb_data)
    );

    alu arithmetic_logic_unit (
        .a(rf_rd1),
        .b(rf_rd2),
        .op(opcode),
        .result(alu_result),
        .flag_z(alu_flags[3]),
        .flag_n(alu_flags[2]),
        .flag_c(alu_flags[1]),
        .flag_v(alu_flags[0])
    );

    flags_reg status_flags (
        .clk(clk),
        .rst_n(rst_n),
        .flags_we(flags_we),
        .flags_in(alu_flags),
        .flags_out(flags)
    );

    data_memory data_store (
        .clk(clk),
        .addr(rf_rd1),
        .we(mem_we),
        .wdata(rf_rd2),
        .rdata(mem_rdata)
    );

    control_unit controller (
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .cond(cond),
        .flags(flags),
        .io_ready(io_ready),
        .pc_en(pc_en),
        .pc_load(pc_load),
        .rf_we(rf_we),
        .mem_we(mem_we),
        .io_rd(cu_io_rd),
        .io_wr(cu_io_wr),
        .flags_we(flags_we),
        .wb_sel(wb_sel),
        .halted(halted),
        .retire(retire)
    );

    assign retire_pc = imem_addr;
    assign retire_ir = imem_data;
    assign retire_rf_we = rf_we_actual;
    assign retire_rf_addr = rf_we_actual ? rd : 3'b000;
    assign retire_rf_data = rf_we_actual ? wb_data : 8'h00;
    assign retire_mem_we = mem_we;
    assign retire_mem_addr = mem_we ? rf_rd1 : 8'h00;
    assign retire_mem_data = mem_we ? rf_rd2 : 8'h00;
    assign retire_flags = flags_we ? alu_flags : flags;

endmodule
