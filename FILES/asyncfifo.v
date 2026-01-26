`timescale 1ns / 1ps


module asyncfifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3,
    parameter AF_MARGIN  = 1,
    parameter AE_MARGIN  = 1
)(
    input  wire                   wr_clk,
    input  wire                   rd_clk,
    input  wire                   rst,

    input  wire                   wr_en,
    input  wire                   rd_en,
    input  wire [DATA_WIDTH-1:0]  din,

    output reg  [DATA_WIDTH-1:0]  dout,
    output wire                   full,
    output wire                   empty,
    output wire                   almost_full,
    output wire                   almost_empty,
    output wire                   overflow,
    output wire                   underflow
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // ================= MEMORY =================
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // ================= POINTERS =================
    reg [ADDR_WIDTH:0] wr_ptr_bin, wr_ptr_gray;
    reg [ADDR_WIDTH:0] rd_ptr_bin, rd_ptr_gray;

    // ================= SYNC POINTERS =================
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1, rd_ptr_gray_sync2;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1, wr_ptr_gray_sync2;

    // ================= OVERFLOW / UNDERFLOW COUNTERS =================
    reg [15:0] ovf_cnt;
    reg [15:0] udf_cnt;

    // ================= FUNCTIONS =================
    function [ADDR_WIDTH:0] bin2gray(input [ADDR_WIDTH:0] bin);
        bin2gray = (bin >> 1) ^ bin;
    endfunction

    function [ADDR_WIDTH:0] gray2bin(input [ADDR_WIDTH:0] gray);
        integer i;
        begin
            gray2bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (i = ADDR_WIDTH-1; i >= 0; i = i - 1)
                gray2bin[i] = gray2bin[i+1] ^ gray[i];
        end
    endfunction

    // ================= WRITE LOGIC =================
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
            ovf_cnt     <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;
                wr_ptr_bin  <= wr_ptr_bin + 1;
                wr_ptr_gray <= bin2gray(wr_ptr_bin + 1);
                ovf_cnt     <= 0;
            end
            else if (wr_en && full)
                ovf_cnt <= 16'd50000;   // visible pulse
            else if (ovf_cnt != 0)
                ovf_cnt <= ovf_cnt - 1;
        end
    end

    // ================= READ LOGIC =================
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
            dout        <= 0;
            udf_cnt     <= 0;
        end else begin
            if (rd_en && !empty) begin
                dout <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
                rd_ptr_bin  <= rd_ptr_bin + 1;
                rd_ptr_gray <= bin2gray(rd_ptr_bin + 1);
                udf_cnt     <= 0;
            end
            else if (rd_en && empty)
                udf_cnt <= 16'd50000;   // visible pulse
            else if (udf_cnt != 0)
                udf_cnt <= udf_cnt - 1;
        end
    end

    // ================= POINTER SYNCHRONIZERS =================
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_ptr_gray_sync1 <= 0;
            rd_ptr_gray_sync2 <= 0;
        end else begin
            rd_ptr_gray_sync1 <= rd_ptr_gray;
            rd_ptr_gray_sync2 <= rd_ptr_gray_sync1;
        end
    end

    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_ptr_gray_sync1 <= 0;
            wr_ptr_gray_sync2 <= 0;
        end else begin
            wr_ptr_gray_sync1 <= wr_ptr_gray;
            wr_ptr_gray_sync2 <= wr_ptr_gray_sync1;
        end
    end

    // ================= STATUS LOGIC =================
    wire [ADDR_WIDTH:0] wr_bin_sync = gray2bin(wr_ptr_gray_sync2);
    wire [ADDR_WIDTH:0] rd_bin_sync = gray2bin(rd_ptr_gray_sync2);

    assign full =
        (bin2gray(wr_ptr_bin + 1) ==
        {~rd_ptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1],
          rd_ptr_gray_sync2[ADDR_WIDTH-2:0]});

    assign empty = (rd_ptr_gray == wr_ptr_gray_sync2);

    wire [ADDR_WIDTH:0] fifo_count = wr_ptr_bin - rd_bin_sync;

    assign almost_empty = (fifo_count <= 1) && !empty;
    assign almost_full  = (fifo_count >= (DEPTH - 2)) && !full;

    // ================= OUTPUT FLAGS =================
    assign overflow  = (ovf_cnt != 0);
    assign underflow = (udf_cnt != 0);

endmodule
