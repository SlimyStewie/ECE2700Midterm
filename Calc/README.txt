Basys 3 4-bit calculator (Vivado / Verilog)

Files
- calculator_basys3.v: synthesizable top-level design
- calculator_basys3_tb.v: behavioral testbench
- basys3_calculator.xdc: Basys 3 pin constraints for clock, SW0-SW9, LD0-LD7, and seven-segment display

Inputs
- SW[3:0]: A, unsigned 0..15
- SW[7:4]: B, unsigned 0..15
- SW[9:8]: operation
  00 = A + B
  01 = A - B
  10 = A * B
  11 = 0

Outputs
- LD[7:0] show the low 8 result bits. Negative subtraction results are represented in two's complement on LEDs.
- Four-digit seven-segment display shows the result in decimal, with a minus sign for negative subtraction results.

Vivado steps
1. Create a new RTL project and select the Basys 3 board / correct FPGA part.
2. Add calculator_basys3.v as a Design Source.
3. Add basys3_calculator.xdc as a Constraints file.
4. (Optional simulation) Add calculator_basys3_tb.v as a Simulation Source and set it as simulation top.
5. Run Behavioral Simulation. The testbench prints PASS/FAIL for arithmetic checks.
6. Run Synthesis, Implementation, and Generate Bitstream.
7. Open Hardware Manager, connect the board, and program the device.

Note: The operands are unsigned 4-bit inputs. Negative values arise from A-B when A < B. Multiplication can produce 0..225, and subtraction ranges from -15..15. The seven-segment display shows a minus sign for negative results. Confirm the XDC matches your exact Basys 3 board revision if using a modified board.
