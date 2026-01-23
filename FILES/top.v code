
`timescale 1ns / 1ps


module top_asyncfifo (
    input  wire        clk,        // 100 MHz board clock
    input  wire        rst,        // BTNU (ASYNC RESET)

    input  wire        sw_wr,      // BTNC -> START / STOP
    input  wire        sw_rd,      // unused
    input  wire [7:0]  sw_data,    // SW0-SW7 (FIFO input)

    output wire [7:0]  fifo_dout,  // PMOD JB1 (FIFO output)
    output wire [7:0]  led         // LD0-LD7 (STATUS)
);

    // =====================================================
    // CLOCKS
    // =====================================================
    wire wr_clk = clk;
    wire rd_clk = clk;

    // =====================================================
    // DEBOUNCE START / STOP BUTTON
    // =====================================================
    wire sw_wr_db;
    debounce db_wr (
        .clk(clk),
        .rst(rst),
        .noisy_in(sw_wr),
        .clean_out(sw_wr_db)
    );

    // =====================================================
    // START / STOP TOGGLE
    // =====================================================
    reg run;
    reg sw_wr_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            run     <= 1'b0;
            sw_wr_d <= 1'b0;
        end else begin
            sw_wr_d <= sw_wr_db;
            if (sw_wr_db & ~sw_wr_d)
                run <= ~run;     // toggle start / stop
        end
    end

    // =====================================================
    // FIFO SIGNALS
    // =====================================================
    wire [7:0] dout;
    wire full, empty, almost_full, almost_empty;
    wire overflow, underflow;

    // =====================================================
    // INPUT DATA LATCH
    // =====================================================
    reg [7:0] data_latched;

    // =====================================================
    // WRITE TIMER (1 SECOND @ 100 MHz)
    // =====================================================
    reg [26:0] wr_cnt;
    reg        wr_tick;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_cnt  <= 0;
            wr_tick <= 0;
        end else begin
            wr_tick <= 0;
            if (wr_cnt == 27'd100_000_000) begin
                wr_cnt  <= 0;
                wr_tick <= 1;
            end else begin
                wr_cnt <= wr_cnt + 1;
            end
        end
    end

    // =====================================================
    // READ TIMER (2 SECONDS @ 100 MHz)
    // =====================================================
    reg [27:0] rd_cnt;
    reg        rd_tick;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_cnt  <= 0;
            rd_tick <= 0;
        end else begin
            rd_tick <= 0;
            if (rd_cnt == 28'd200_000_000) begin
                rd_cnt  <= 0;
                rd_tick <= 1;
            end else begin
                rd_cnt <= rd_cnt + 1;
            end
        end
    end

    // =====================================================
    // CONTROL FSM
    // =====================================================
    localparam IDLE           = 2'd0,
               WRITE_MODE     = 2'd1,
               FULL_READ_WAIT = 2'd2;

    reg [1:0] state;
    reg [1:0] read_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            read_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (run)
                        state <= WRITE_MODE;
                end

                WRITE_MODE: begin
                    if (full) begin
                        state      <= FULL_READ_WAIT;
                        read_count <= 0;
                    end
                end

                FULL_READ_WAIT: begin
                    if (rd_tick && !empty) begin
                        if (read_count == 2)
                            state <= WRITE_MODE;   // after 3 reads
                        read_count <= read_count + 1;
                    end
                end
            endcase
        end
    end

    // =====================================================
    // FINAL WRITE / READ ENABLES
    // =====================================================
    wire wr_en_final =
        run &&
        (state == WRITE_MODE) &&
        wr_tick &&
        !full;

    wire rd_en_final =
        run &&
        rd_tick &&
        !empty;

    // =====================================================
    // LATCH DATA ON WRITE
    // =====================================================
    always @(posedge clk or posedge rst) begin
        if (rst)
            data_latched <= 8'd0;
        else if (wr_en_final)
            data_latched <= sw_data;
    end

    // =====================================================
    // ASYNC FIFO INSTANCE
    // =====================================================
    asyncfifo dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst   (rst),

        .wr_en(wr_en_final),
        .rd_en(rd_en_final),
        .din  (data_latched),

        .dout (dout),
        .full (full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty),
        .overflow(overflow),
        .underflow(underflow)
    );

    assign fifo_dout = dout;

    // =====================================================
    // LED STATUS (FLAGS)
    // =====================================================
    assign led[0] = empty;
    assign led[1] = almost_empty;
    assign led[2] = full;
    assign led[3] = almost_full;
    assign led[4] = overflow;
    assign led[5] = underflow;

    // =====================================================
    // WRITE / READ LED PULSE STRETCH
    // =====================================================
    reg [23:0] wr_led_cnt;
    reg [23:0] rd_led_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_led_cnt <= 0;
            rd_led_cnt <= 0;
        end else begin
            if (wr_en_final)
                wr_led_cnt <= 24'hFFFFFF;
            else if (wr_led_cnt != 0)
                wr_led_cnt <= wr_led_cnt - 1;

            if (rd_en_final)
                rd_led_cnt <= 24'hFFFFFF;
            else if (rd_led_cnt != 0)
                rd_led_cnt <= rd_led_cnt - 1;
        end
    end

    assign led[6] = (wr_led_cnt != 0);   // WRITE EVENT
    assign led[7] = (rd_led_cnt != 0);   // READ EVENT

endmodule
