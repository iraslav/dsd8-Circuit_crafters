// io_bus.v -- board-port decode and peripheral ready handshake

module io_bus (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  io_port,
    input  wire [7:0]  io_wdata,
    output reg  [7:0]  io_rdata,
    input  wire        io_rd,
    input  wire        io_wr,
    output reg         io_ready,
    input  wire [7:0]  switches,
    input  wire [4:0]  buttons,
    output reg  [7:0]  leds,
    output reg  [7:0]  seg_value,
    output reg  [7:0]  seg_enable,
    output wire [7:0]  periph_port,
    output wire [7:0]  periph_wdata,
    input  wire [7:0]  periph_rdata,
    output wire        periph_rd,
    output wire        periph_wr,
    input  wire        periph_ready
);

    wire request = io_rd | io_wr;
    wire local_port = (io_port < 8'h20);

    assign periph_port = io_port;
    assign periph_wdata = io_wdata;
    assign periph_rd = io_rd && !local_port;
    assign periph_wr = io_wr && !local_port;

    always @(*) begin
        io_rdata = 8'h00;
        case (io_port)
            8'h00: io_rdata = switches;
            8'h01: io_rdata = {3'b000, buttons};
            default: begin
                if (!local_port) io_rdata = periph_rdata;
            end
        endcase

        io_ready = 1'b0;
        if (request) begin
            if (local_port) io_ready = 1'b1;
            else            io_ready = periph_ready;
        end
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            leds       <= 8'h00;
            seg_value  <= 8'h00;
            seg_enable <= 8'h00;
        end else if (io_wr && io_ready) begin
            case (io_port)
                8'h02: leds       <= io_wdata;
                8'h10: seg_value  <= io_wdata;
                8'h11: seg_enable <= io_wdata;
                default: begin
                    leds       <= leds;
                    seg_value  <= seg_value;
                    seg_enable <= seg_enable;
                end
            endcase
        end
    end

endmodule
