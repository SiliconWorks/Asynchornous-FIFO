# Asynchornous-FIFO-
<h3><u>Project Overview:</u></h3>
               
               
This project implements a fully parameterized Asynchronous FIFO in Verilog HDL to enable safe and reliable data transfer between independent clock domains. The design follows CDC-safe methodologies, utilizing Gray-code pointers and 2-flip-flop synchronizers to mitigate metastability issues. Binary pointers are used for internal memory addressing, while Gray-coded pointers handle cross-domain communication. Full and Empty flags are generated using synchronized pointers to ensure stable, glitch-free control. The FIFO supports configurable data width and depth, and its functionality is validated through simulation under wrap-around conditions, simultaneous read/write operations, and boundary cases.

<h3><u>Problem statement:</u></h3>

In multi-clock digital systems, direct data transfer between asynchronous clock domains can cause metastability and data corruption.
This project addresses the problem by designing a CDC-safe Asynchronous FIFO in Verilog HDL.
The FIFO ensures reliable data transfer using Gray-code pointers and synchronized control logic.
Correct operation is maintained under clock mismatch, pointer wrap-around, and boundary conditions

Depth     : 8
Inputs    : Binary Input

Conditions: 1.Set
            2.Reset
            
States    : Empty(0)  Almost Empty(1)  Partial conditio(2-5)  Almost Full(6)  Full(7)

<h3><u>Features:</u></h3>

FSM states:
         INPUT → EMPTY → PARTIALLY FULL → FULL → OUTPUT
         
**Explanation:**

EMPTY (0): No data, read disabled, write enabled

PARTIALLY FULL (1 → N-1): Some data, read and write both enabled

FULL (N): All entries occupied, write disabled, read enabled

🔸Binary and Gray-code address generation for metastability-resilient pointer movement.

🔸2-flip-flop synchronizers for reliable cross-domain pointer transfer.

🔸Gray↔Binary converters to maintain CDC safety while enabling binary-domain comparisons.

🔸Full/Empty flag logic driven by synchronized pointers.

<h3><u>Tools & Hardware Used:</u></h3>

FPGA: ZedBoard Zynq-7000

HDL Tool: AMD Vivado 2024 Edition

Language: Verilog HDL

Verification: Vivado Simulator / Testbench for functional validation

<h3><u>  Read & Write operations: </u></h3>

An Asynchronous FIFO enables safe data transfer between two independent clock domains using separate read and write pointers. There is no global FSM; instead, operation is controlled by pointer comparison and FULL/EMPTY flags.

**Operational Principle**

Write side operates only on wr_clk

Read side operates only on rd_clk

Pointers are maintained in binary (for addressing) and Gray code (for CDC safety)

Gray-coded pointers are synchronized across clock domains using 2-FF synchronizers

**Write & Read — Unified Flow:**

On wr_clk (Write Domain):

A write occurs when:

wr_en = 1

full = 0


Actions:

Write data to memory at the current write pointer address

Increment the binary write pointer

Convert the updated pointer to Gray code

Synchronize the Gray-coded write pointer to the read domain

**On rd_clk (Read Domain):**

A read occurs when:

rd_en = 1

empty = 0

Actions:

Read data from memory at the current read pointer address

Increment the binary read pointer

Convert the updated pointer to Gray code

Synchronize the Gray-coded read pointer to the write domain

**FULL & EMPTY Flag Generation:**

EMPTY (Read Domain):
Indicates no unread data is available

FULL (Write Domain):
Indicates FIFO has reached maximum capacity

<h3><u>design.v:</u></h3>
`timescale 1ns / 1ps


module asyncfifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3,
    parameter AF_MARGIN  = 1,
    parameter AE_MARGIN  = 1
)(
    input  wire                   wr_clk,     // Write clock
    input  wire                   rd_clk,     // Read clock
    input  wire                   rst,        // Global reset (async assert)

    input  wire                   wr_en,      // Write enable (1 clk pulse)
    input  wire                   rd_en,      // Read enable (1 clk pulse)
    input  wire [DATA_WIDTH-1:0]  din,        // Write data

    output reg  [DATA_WIDTH-1:0]  dout,       // Read data
    output wire                   full,       // FIFO full flag
    output wire                   empty,      // FIFO empty flag
    output wire                   almost_full,
    output wire                   almost_empty,
    output reg                    overflow,   // Latched overflow
    output reg                    underflow   // Latched underflow
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    // ================= MEMORY BLOCK =================
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // ================= POINTER BLOCK =================
    reg [ADDR_WIDTH:0] wr_ptr_bin  = 0;
    reg [ADDR_WIDTH:0] wr_ptr_gray = 0;
    reg [ADDR_WIDTH:0] rd_ptr_bin  = 0;
    reg [ADDR_WIDTH:0] rd_ptr_gray = 0;

    // ================= SYNC POINTER BLOCK =================
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync1 = 0;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync2 = 0;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync1 = 0;
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync2 = 0;

    // ================= FUNCTIONS BLOCK =================
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

    // ================= WRITE LOGIC BLOCK =================
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_ptr_bin  <= 0;
            wr_ptr_gray <= 0;
            overflow    <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= din;
                wr_ptr_bin  <= wr_ptr_bin + 1;
                wr_ptr_gray <= bin2gray(wr_ptr_bin + 1);
            end else if (wr_en && full) begin
                overflow <= 1;
            end
        end
    end

    // ================= READ LOGIC BLOCK =================
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_ptr_bin  <= 0;
            rd_ptr_gray <= 0;
            dout        <= 0;
            underflow   <= 0;
        end else begin
            if (rd_en && !empty) begin
                dout <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
                rd_ptr_bin  <= rd_ptr_bin + 1;
                rd_ptr_gray <= bin2gray(rd_ptr_bin + 1);
            end else if (rd_en && empty) begin
                underflow <= 1;
            end
        end
    end

    // ================= POINTER SYNC BLOCK =================
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

    // ================= STATUS LOGIC BLOCK =================
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


endmodule










