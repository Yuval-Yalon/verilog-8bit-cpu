# Verilog 8-bit CPU Core (ALU + RegFile)

A simple **8-bit processor core** implemented in Verilog, designed as a classic RTL project. Includes an 8-function ALU, an 8x8 Register File, and an FSM-based controller.

---

## Features

-   8-bit datapath
-   8-function Arithmetic Logic Unit (ALU)
-   ALU status flags: `Zero` (Z) and `Carry` (C)
-   8x8 Register File (8 registers, 8-bits wide)
-   Dual-port read (asynchronous), single-port write (synchronous) RegFile
-   3-state FSM controller (`IDLE`, `EXECUTE`, `WRITEBACK`)
-   Comprehensive testbench (`testbench.sv`) for full instruction coverage.

---

## Project Modules

| Module | Description |
| :--- | :--- |
| `alu8.v` | Combinational 8-function ALU |
| `regfile.v` | 8x8 Dual-Port Read Register File |
| `top.v` | Top-level FSM Controller & Integrator |
| `testbench.sv`| Self-checking verification environment |

---
## `top.v` Interface

### **Ports**
| Name | Direction | Description |
| :--- | :--- | :--- |
| `clk` | input | Clock signal |
| `rst_n` | input | Active-low reset |
| `start_cmd` | input | Pulse to start a new instruction |
| `op_in` | input | 3-bit Opcode for the ALU |
| `rd_in` | input | Destination Register address |
| `rs1_in` | input | Source Register 1 address |
| `rs2_in` | input | Source Register 2 address |
| `cmd_done` | output | Pulse to indicate instruction complete |
| `z_flag_out` | output | ALU Zero flag status |
| `c_flag_out` | output | ALU Carry flag status |

---

## Instruction Set (ISA)

The 3-bit `op_in` signal maps to the following ALU operations:

| Opcode | Mnemonic | Description |
| :---: | :---: | :--- |
| `3'b000` | `ADD` | `Rd = Rs1 + Rs2` |
| `3'b001` | `SUB` | `Rd = Rs1 - Rs2` |
| `3'b010` | `AND` | `Rd = Rs1 & Rs2` |
| `3'b011` | `OR` | `Rd = Rs1 \| Rs2` |
| `3'b100` | `XOR` | `Rd = Rs1 ^ Rs2` |
| `3'b101` | `SHL` | `Rd = Rs1 << 1` (1-bit shift) |
| `3'b110` | `SHR` | `Rd = Rs1 >> 1` (1-bit shift) |
| `3'b111` | `MOV` | `Rd = Rs2` (Copy Rs2 value) |
