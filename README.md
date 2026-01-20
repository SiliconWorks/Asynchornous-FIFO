# Asynchornous-FIFO-
<h3><u>PROJECT OVERVIEW:</u></h3>
               
               
TThis project implements a parameterized Asynchronous FIFO in Verilog for reliable data transfer across independent clock domains. It ensures CDC safety by using Gray-code pointers and 2-FF synchronizers to prevent metastability. The design generates stable Full/Empty flags and is fully configurable for various data widths and depths. Functionality is verified through simulations covering wrap-around and simultaneous R/W boundary conditions.

<h3><u>PROBLEM STATEMENT:</u></h3>

In multi-clock digital systems, direct data transfer between asynchronous clock domains can cause metastability and data corruption.
This project addresses the problem by designing a CDC-safe Asynchronous FIFO in Verilog HDL.
The FIFO ensures reliable data transfer using Gray-code pointers and synchronized control logic.
Correct operation is maintained under clock mismatch, pointer wrap-around, and boundary conditions

Inputs    : Binary Input

Conditions: 1.Set
            2.Reset
            
States    : INPUT → WRITE → READ → OUTPUT

<h3><u>FEATURES:</u></h3>

**FIFO states:**
         INPUT → WRITE → READ →  OUTPUT
         
**Explanation:**

EMPTY (0): No data, read disabled, write enabled

PARTIALLY FULL (1 → N-1): Some data, read and write both enabled

FULL (N): All entries occupied, write disabled, read enabled

🔸Binary and Gray-code address generation for metastability-resilient pointer movement.

🔸2-flip-flop synchronizers for reliable cross-domain pointer transfer.

🔸Gray↔Binary converters to maintain CDC safety while enabling binary-domain comparisons.

🔸Full/Empty flag logic driven by synchronized pointers.

<h3><u>TOOLS AND HARDWARE:</u></h3>

FPGA: ZedBoard Zynq-7000

HDL Tool: AMD Vivado 2024 Edition

Language: Verilog HDL

Verification: Vivado Simulator / Testbench for functional validation

<h3><u>  BLOCK DIAGRAM: </u></h3>

The below block diagram shows how the Asynchrnous FIFO works

<img width="1920" height="1080" alt="WRITE POINTER BLOCK" src="https://github.com/user-attachments/assets/f3ec50de-ef2f-40c1-af0d-c1ea826cfbff" />


**Read & Write operations:**

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

<h3><u>ASYNCHRNOUS FIFO STATES:</u></h3>
The below image indicates the FIFO states 

<img width="1237" height="700" alt="image" src="https://github.com/user-attachments/assets/ccf270ef-8083-4400-b652-a38cda11ed63" />



**EMPTY :** The starting state. The buffer contains no data. Any attempt to read from here would typically trigger an Underflow.

**ALMOST EMPTY :** Only one slot is filled. This is a critical threshold state often used to signal the consumer to stop reading soon.

**PARTIALLY FULL OR EMPTY :** The "normal" operating range. The FIFO is neither nearing its maximum capacity nor its empty state.

**ALMOST FULL :** The buffer is nearing capacity. Only one or two slots remain. This signals the producer to slow down or stop writing.

**FULL :** The buffer has reached its maximum capacity.

**Error Conditions**

**OVERFLOW:** This occurs if the system attempts to write (DATA_IN) more data when the state is already FULL. This results in data loss as there is no space left.

**UNDERFLOW:** This occurs if the system attempts to read data when the state is EMPTY. This results in invalid data being passed to the next stage.

<h3><u>DESIGN:</u></h3>
This design implements an asynchronous FIFO that allows safe data transfer between two independent clock domains (wr_clk and rd_clk). Design code for Asynchronous FIFO is given below
https://github.com/duraimurugan9168-svg/Asynchornous-FIFO-/blob/4ce28261f496cd185193f750b2570918b65af8d4/FILES/design

<h3><u>TESTBENCH:</u></h3>
The testbench verifies the functionality of the asynchronous FIFO by generating independent write and read clocks, applying reset, and driving controlled write and read enable signals.
The Testbench code for Asyynchronous FIFO is given below
https://github.com/duraimurugan9168-svg/Asynchornous-FIFO-/blob/dcd3d1ff93411345b0300af3cae70f11f1e331e9/FILES/testbench

<h3><u>SIMULATION AND WAVEFORM:</u></h3>
This waveform represents the functional simulation of an Asynchronous FIFO where write and read operations occur in different clock domains (wr_clk and rd_clk). The FIFO safely transfers data across clock domains using synchronized pointers.
<img width="1919" height="1030" alt="Screenshot 2026-01-09 121448" src="https://github.com/user-attachments/assets/81e0a436-21f1-4e77-87ca-c9984ef71c64" />

<h3><u>TECHNOLOGY VIEW:</u></h3>
<img width="1918" height="1024" alt="Screenshot 2026-01-09 121850" src="https://github.com/user-attachments/assets/4a237d29-43f6-4ee9-89f8-0804eb0a3259" />

<h3><u>SCHEMATIC VIEW:</u></h3>


<h3><u>PORT DECLARATIONS:</u></h3>


<h3><u>FILE STRUCTURE:</u></h3>

<img width="759" height="526" alt="Screenshot 2026-01-20 085700" src="https://github.com/user-attachments/assets/7faba79f-8657-4fc7-b590-91d62b7ecb69" />










