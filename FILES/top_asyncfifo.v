`timescale 1ns / 1ps





module top_asyncfifo (
    input  wire        clk,
    input  wire        rst,

    input  wire        sw_wr,      // START / STOP
    input  wire        sw_rd,      // MODE SELECT
    input  wire [7:0]  sw_data,    // MANUAL DATA INPUT

    output wire [7:0]  fifo_dout,
    output wire [7:0]  led
);


    // CLOCKS
    wire wr_clk = clk;
    wire rd_clk = clk;

    // DEBOUNCE START / STOP
    wire sw_wr_db;
    debounce db_wr (
        .clk(clk),
        .rst(rst),
        .noisy_in(sw_wr),
        .clean_out(sw_wr_db)
    );
// MODE SELECT BUTTON (sw_rd)
wire sw_mode_db;

debounce db_mode (
    .clk(clk),
    .rst(rst),
    .noisy_in(sw_rd),
    .clean_out(sw_mode_db)
);

    // RUN TOGGLE
    reg run, sw_wr_d;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            run     <= 1'b0;
            sw_wr_d <= 1'b0;
        end else begin
            sw_wr_d <= sw_wr_db;
            if (sw_wr_db & ~sw_wr_d)
                run <= ~run;
        end
    end

// MODE TOGGLE (0 = stored input, 1 = manual input)
reg mode;
reg sw_mode_d;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        mode      <= 1'b0;   // default: stored input
        sw_mode_d <= 1'b0;
    end else begin
        sw_mode_d <= sw_mode_db;
        if (sw_mode_db & ~sw_mode_d)
            mode <= ~mode;   // toggle mode on button press
    end
end

    // STORED INPUT DATA
    reg [7:0] stim_mem [0:6];
    initial begin
        stim_mem[0] = 8'd10;
        stim_mem[1] = 8'd20;
        stim_mem[2] = 8'd30;
        stim_mem[3] = 8'd40;
        stim_mem[4] = 8'd50;
        stim_mem[5] = 8'd60;
        stim_mem[6] = 8'd70;
    end

    reg [2:0] stim_ptr;  

    // WRITE TIMER (1 SECOND)
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
            end else
                wr_cnt <= wr_cnt + 1;
        end
    end

    // READ TIMER (2 SECONDS)
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
            end else
                rd_cnt <= rd_cnt + 1;
        end
    end

    // FIFO SIGNALS
    wire [7:0] dout;
    wire full, empty, almost_full, almost_empty;
    wire overflow, underflow;

    // FSM
    localparam IDLE             = 2'd0,
               WRITE_MODE       = 2'd1,
               FULL_READ_WAIT   = 2'd2,
               EMPTY_WRITE_WAIT = 2'd3;

    reg [1:0] state;
    reg [1:0] read_count;
    reg [1:0] write_count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            read_count  <= 0;
            write_count <= 0;
        end else begin
            case (state)
                IDLE:
                    if (run)
                        state <= WRITE_MODE;

                WRITE_MODE: begin
                    if (full) begin
                        state      <= FULL_READ_WAIT;
                        read_count <= 0;
                    end else if (empty) begin
                        state       <= EMPTY_WRITE_WAIT;
                        write_count <= 0;
                    end
                end

                FULL_READ_WAIT:
                    if (rd_tick && !empty) begin
                        if (read_count == 2)
                            state <= WRITE_MODE;
                        read_count <= read_count + 1;
                    end

                EMPTY_WRITE_WAIT:
                    if (wr_tick && !full) begin
                        if (write_count == 2)
                            state <= WRITE_MODE;
                        write_count <= write_count + 1;
                    end
            endcase
        end
    end

    // FINAL ENABLES
    wire wr_en_final =
        run && wr_tick && !full && (state != FULL_READ_WAIT);

    wire rd_en_final =
        run && rd_tick && !empty && (state != EMPTY_WRITE_WAIT);

    // DATA LATCH FROM STORED MEMORY
    reg [7:0] data_latched;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        data_latched <= 8'd0;
        stim_ptr     <= 0;
    end
    // RESTART NEXT CYCLE
    else if (empty && state == WRITE_MODE) begin
        stim_ptr <= 0;
    end
    else if (wr_en_final) begin
        if (mode == 1'b0) begin
            // STORED INPUT MODE
            data_latched <= stim_mem[stim_ptr];
            if (stim_ptr == 6)
                stim_ptr <= 0;
            else
                stim_ptr <= stim_ptr + 1;
        end else begin
            // MANUAL INPUT MODE
            data_latched <= sw_data;
            stim_ptr     <= stim_ptr;
        end
    end
end

    // FIFO INSTANCE (ADDR_WIDTH = 3 FIFO DEPTH = 8)
    asyncfifo #(
        .ADDR_WIDTH(3)
    ) dut (
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

    // LED STATUS
    assign led[0] = empty;
    assign led[1] = almost_empty;
    assign led[2] = full;
    assign led[3] = almost_full;
    assign led[4] = overflow;
    assign led[5] = underflow;

// WRITE / READ LED PULSE STRETCH
reg [23:0] wr_led_cnt;
reg [23:0] rd_led_cnt;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        wr_led_cnt <= 0;
        rd_led_cnt <= 0;
    end else begin
        // WRITE enable stretch
        if (wr_en_final)
            wr_led_cnt <= 24'hFFFFFF;
        else if (wr_led_cnt != 0)
            wr_led_cnt <= wr_led_cnt - 1;

        // READ enable stretch
        if (rd_en_final)
            rd_led_cnt <= 24'hFFFFFF;
        else if (rd_led_cnt != 0)
            rd_led_cnt <= rd_led_cnt - 1;
    end
end

assign led[6] = (wr_led_cnt != 0);  
assign led[7] = (rd_led_cnt != 0);  

endmodule
