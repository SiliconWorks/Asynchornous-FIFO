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
         
Explanation:

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

<h3><u>  FSM States: </u></h3>
![image alt](https://github.com/duraimurugan9168-svg/Asynchornous-FIFO-/blob/main/Screenshot%202026-01-16%20143321.png?raw=true)





