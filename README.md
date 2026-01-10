# Asynchornous-FIFO-
<h3><u>Project Overview:</u></h3>
               
               
This project implements a fully parameterized Asynchronous FIFO in Verilog HDL to enable safe and reliable data transfer between independent clock domains. The design follows CDC-safe methodologies, utilizing Gray-code pointers and 2-flip-flop synchronizers to mitigate metastability issues. Binary pointers are used for internal memory addressing, while Gray-coded pointers handle cross-domain communication. Full and Empty flags are generated using synchronized pointers to ensure stable, glitch-free control. The FIFO supports configurable data width and depth, and its functionality is validated through simulation under wrap-around conditions, simultaneous read/write operations, and boundary cases.


