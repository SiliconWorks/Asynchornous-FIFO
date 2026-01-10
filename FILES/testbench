`timescale 1ns / 1ps


module tb_asyncfifo;

    reg wr_clk = 0;
    reg rd_clk = 0;
    reg rst;

    reg wr_en;
    reg rd_en;
    reg [7:0] din;

    wire [7:0] dout;
    wire full, empty, almost_full, almost_empty;
    wire overflow, underflow;

    // ================= DUT BLOCK =================
    asyncfifo dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .overflow(overflow),
        .underflow(underflow)
    );

    // ================= CLOCK BLOCK =================
    always #5  wr_clk = ~wr_clk;
    always #8  rd_clk = ~rd_clk;

    initial begin
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        #20 rst = 0;

        // ================= WRITE BURST BLOCK =================
        repeat (10) begin
            @(posedge wr_clk);
            wr_en = 1;
            din = din + 1;
            @(posedge wr_clk);
            wr_en = 0;
        end

        #50;

        // ================= READ BURST BLOCK =================
        repeat (10) begin
            @(posedge rd_clk);
            rd_en = 1;
            @(posedge rd_clk);
            rd_en = 0;
        end

        #100;
        $finish;
    end

endmodule
