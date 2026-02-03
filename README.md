# Asynchornous-FIFO
<h3><u>PROJECT OVERVIEW:</u></h3>
               
               
This project implements a parameterized Asynchronous FIFO in Verilog for reliable data transfer across independent clock domains. It ensures CDC safety by using Gray-code pointers and 2-FF synchronizers to prevent metastability. The design generates stable Full/Empty flags and is fully configurable for various data widths and depths. Functionality is verified through simulations covering wrap-around and simultaneous R/W boundary conditions.

<h3><u> TABLE OF CONTENTS: </u></h3>

**Key contents:**

- [Problem statement](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#problem-statement)
- [Features](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#features)
- [Tools and Hardware](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#tools-and-hardware)
- [Block diagram](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#--block-diagram-)
- [Asynchronous FIFO states](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#asynchrnous-fifo-states)
- [FIFO Table](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#fifo-timing-table)
- [Verilog Implementation](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#verilog-implementation)
- [Simulation](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#simulation)
- [Contributors](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#contributors)
- [Conclusion](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/main/README.md#conclusion)

<h3><u>PROBLEM STATEMENT:</u></h3>

In multi-clock digital systems, direct data transfer between asynchronous clock domains can cause metastability and data corruption.
This project addresses the problem by designing a CDC-safe Asynchronous FIFO in Verilog HDL.
The FIFO ensures reliable data transfer using Gray-code pointers and synchronized control logic.
Correct operation is maintained under clock mismatch, pointer wrap-around, and boundary condition

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

**FPGA:** ZedBoard Zynq-7000

**HDL Tool:** AMD Vivado 2024 Edition

**Language:** Verilog HDL

**Verification:** Vivado Simulator / Testbench for functional validation

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


### **Async FIFO Operational Principle (Short)**

* **Write side** operates on `wr_clk`

* **Read side** operates on `rd_clk`

* Pointers are kept in:

  * **Binary** → memory addressing
  * **Gray code** → safe clock-domain crossing (CDC)

* Gray-coded pointers are synchronized across domains using **2-FF synchronizers**

---

 **Write Domain (`wr_clk`)**

* Write when `wr_en = 1` and `full = 0`
* Actions:

  * Write data to memory
  * Increment write pointer (binary → Gray)
  * Sync write Gray pointer to read domain

---

 **Read Domain (`rd_clk`)**

* Read when `rd_en = 1` and `empty = 0`
* Actions:

  * Read data from memory
  * Increment read pointer (binary → Gray)
  * Sync read Gray pointer to write domain

---




**FULL & EMPTY Flag Generation:**

EMPTY (Read Domain):
Indicates no unread data is available

FULL (Write Domain):
Indicates FIFO has reached maximum capacity

<h3><u>ASYNCHRNOUS FIFO STATES:</u></h3>
The below image indicates the FIFO states 

<img width="1240" height="701" alt="image" src="https://github.com/user-attachments/assets/432d89ff-c023-4fdf-8ee3-c3ce5860b088" />



**EMPTY :** The starting state. The buffer contains no data. Any attempt to read from here would typically trigger an Underflow.

**ALMOST EMPTY :** Only one slot is filled. This is a critical threshold state often used to signal the consumer to stop reading soon.

**PARTIALLY FULL OR EMPTY :** The "normal" operating range. The FIFO is neither nearing its maximum capacity nor its empty state.

**ALMOST FULL :** The buffer is nearing capacity. Only one or two slots remain. This signals the producer to slow down or stop writing.

**FULL :** The buffer has reached its maximum capacity.

**Error Conditions**

**OVERFLOW:** This occurs if the system attempts to write (DATA_IN) more data when the state is already FULL. This results in data loss as there is no space left.

**UNDERFLOW:** This occurs if the system attempts to read data when the state is EMPTY. This results in invalid data being passed to the next stage.

<h3><u>FIFO TIMING TABLE:</u></h3>

| Time (s) | Write | Read | FIFO Cnt | State                  | OUT |
|----------|-------|------|----------|------------------------|-----|
| 0        | –     | –    | 0        | IDLE                   | ❌  |
| 1        | W1    | –    | 1        | EMPTY_WAIT             | ❌  |
| 2        | W2    | –    | 2        | EMPTY_WAIT             | ❌  |
| 3        | W3    | –    | 3        | EMPTY_WAIT (decision)  | ❌  |
| 4        | W4    | –    | 4        | WRITE_MODE             | ❌  |
| 5        | W5    | –    | 5        | WRITE_MODE             | ❌  |
| 6        | W6    | R1   | 5        | WRITE_MODE             | ✅  |
| 7        | W7    | –    | 6        | WRITE_MODE             | ❌  |
| 8        | W8    | R2   | 6        | WRITE_MODE             | ✅  |
| 9        | W9    | –    | 7 (FULL) | FULL_WAIT              | ❌  |
| 10       | –     | R3   | 6        | FULL_WAIT              | ✅  |
| 11       | –     | –    | 6        | FULL_WAIT              | ❌  |
| 12       | –     | R4   | 5        | FULL_WAIT              | ✅  |
| 13       | –     | –    | 5        | FULL_WAIT              | ❌  |
| 14       | –     | R5   | 4        | FULL_WAIT (decision)   | ✅  |
| 15       | W10   | –    | 5        | WRITE_MODE             | ❌  |
| 16       | W11   | R6   | 5        | WRITE_MODE             | ✅  |
| 17       | W12   | –    | 6        | WRITE_MODE             | ❌  |
| 18       | W13   | R7   | 6        | WRITE_MODE             | ✅  |
| 19       | W14   | –    | 7 (FULL) | FULL_WAIT              | ❌  |
| 20       | –     | R8   | 6        | FULL_WAIT              | ✅  |
| 21       | –     | –    | 6        | FULL_WAIT              | ❌  |
| 22       | –     | R9   | 5        | FULL_WAIT              | ✅  |
| 23       | –     | –    | 5        | FULL_WAIT              | ❌  |
| 24       | –     | R10  | 4        | FULL_WAIT (decision)   | ✅  |
| 25       | W15   | –    | 5        | WRITE_MODE             | ❌  |
| 26       | W16   | R11  | 5        | WRITE_MODE             | ✅  |
| 27       | W17   | –    | 6        | WRITE_MODE             | ❌  |
| 28       | W18   | R12  | 6        | WRITE_MODE             | ✅  |
| 29       | W19   | –    | 7 (FULL) | FULL_WAIT              | ❌  |
| 30       | –     | R13  | 6        | FULL_WAIT              | ✅  |


<h3><u>VERILOG IMPLEMENTATION:</u></h3>  

**Design:**

This design implements an asynchronous FIFO that allows safe data transfer between two independent clock domains (wr_clk and rd_clk). Design code for Asynchronous FIFO is given below

[asyncfifo.v](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/e25803a02717f30da43833a0de1aca54d5e8da44/FILES/asyncfifo.v)

**Testbench:**


The testbench verifies the functionality of the asynchronous FIFO by generating independent write and read clocks, applying reset, and driving controlled write and read enable signals.
The Testbench code for Asyynchronous FIFO is given below

[tb_asyncfifo.v](https://github.com/SiliconWorks/Asynchornous-FIFO/blob/dc1fc3ffead233bdd8a9f80220b244209f044258/FILES/tb_asyncfifo.v)

<h3><u>SIMULATION:</u></h3>

**WAVEFORM:**

This waveform represents the functional simulation of an Asynchronous FIFO where write and read operations occur in different clock domains (wr_clk and rd_clk). The FIFO safely transfers data across clock domains using synchronized pointers.
<img width="1919" height="1024" alt="Output Waveform" src="https://github.com/user-attachments/assets/70cc920f-7f1e-422c-93eb-136576a2b298" />




**OUTPUT :**

FIFO in Zedboard Zynq 7000 FPGA :

<img width="1569" height="903" alt="Your paragraph text (5)" src="https://github.com/user-attachments/assets/59d447c3-9ac6-4033-aa43-afa75a7b0be6" />




The output Video of Asynchrnous FIFO is given below


[Output video](https://drive.google.com/file/d/1viKmUqhM3-F26fnSBRfTKp3kEVEVbU0f/view?usp=drive_link)



**TECHNICAL VIEW:**

<img width="971" height="1079" alt="Technical View" src="https://github.com/user-attachments/assets/06203465-841b-4e36-b259-0957a380aa09" />





**SCHEMATIC VIEW:**
<img width="1919" height="515" alt="Schematic View" src="https://github.com/user-attachments/assets/5f097f81-bcd2-4e3a-a391-74166897bf45" />


**FILE STRUCTURE:**

<img width="1115" height="632" alt="File structure" src="https://github.com/user-attachments/assets/407967f0-7493-41d1-83c8-5d3e488eb32e" />



<h3><u>CONTRIBUTORS:</u></h3>

Durai Murugan M , Bannari Amman Institute of Technology     [LinkedIn](https://www.linkedin.com/in/durai-murugan-859b67354)



Vasan T , Bannari Amman Institute of Technology            [LinkedIn](https://www.linkedin.com/in/vasan-t-7225x)



Harish P , Bannari Amman Institute of Technology           [LinkedIn](https://www.linkedin.com/in/harish-p-493476355)


Velmurugan R , Bannari Amman Institute of Technology       [LinkedIn](https://www.linkedin.com/in/velmurugan-r-43b0b2355)



<h3><u>CONCLUSION:</u></h3>

This project successfully demonstrates the design and verification of an Asynchronous FIFO for reliable data transfer between two independent clock domains. By using Gray-coded read and write pointers along with dual flip-flop synchronizers, the design effectively mitigates metastability issues common in CDC systems. The FIFO correctly generates Full, Empty, Almost Full, and Almost Empty flags, ensuring safe and efficient flow control. Simulation results confirm correct operation during normal, boundary, and wrap-around conditions. This implementation provides a robust and scalable solution suitable for real-time embedded and FPGA-based communication systems.






**NOTES:**

This project improved my understanding of clock domain crossing issues and the practical use of Gray code and synchronizers in FPGA designs. It also strengthened my skills in Verilog coding, simulation, and debugging timing-related problems.










