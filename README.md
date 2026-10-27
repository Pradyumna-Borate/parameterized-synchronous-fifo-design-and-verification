# Synchronous FIFO — Verilog RTL and Verification

## Overview

A synchronous First-In, First-Out (FIFO) buffer implemented in Verilog HDL, with multiple testbenches to explore functional verification techniques.

## Design Specifications

- Data width: 8 bits (default)
- FIFO depth: 8 entries (default)
- Synchronous read and write operations
- Circular read and write pointers
- Full and empty status flags
- Simultaneous read and write operations supported
- Extra bit in pointers used to detect a wraparound
- DATA_DEPTH values must be a power of 2

## Verification Approach

### 1. Directed Testing
Directed testing uses explicitly defined stimulus to exercise specific scenarios. The engineer identifies the scenarios to test and checks whether the DUT behaves as expected.

### 2. Scoreboard-Based Verification
The scoreboard introduces an independent reference model that receives the same stimulus as the DUT. It predicts the expected FIFO behavior and compares the expected results against the DUT's outputs, including read data and status flags. This makes the testbench self-checking and automates error detection. The testbench also maintains counters for different checks and errors and displays a summary at the end.

### 3. Randomized Parameterized Testing
The randomized testbench generates varied read/write stimulus and compares the DUT's behavior against the reference model. This helps explore sequences and interactions that may be difficult to enumerate manually, but it may not hit all cases. Functional coverage flags track whether selected important scenarios have occurred, helping identify gaps in the randomly tested scenarios. The testbench is parameterized to support different data widths and FIFO depths.

The project evolved incrementally: I began with directed testing to establish basic FIFO functionality, then developed a scoreboard-based testbench, and finally extended the verification approach with randomized stimulus and functional coverage.

## Repository Structure

- `fifo_implementation.v` — FIFO RTL implementation
- `tb_fifo.v` — directed testbench
- `tb_fifo_scoreboard.v` — self-checking scoreboard testbench
- `tb_fifo_random_parametrized.v` — randomized parameterized testbench

## Tools

- Verilog HDL
- Questa / ModelSim

## Simulation

Compile the RTL and the testbench you want to run in Questa/ModelSim. For example:

```tcl
vlib work
vlog fifo_implementation.v tb_fifo.v
vsim work.tb_fifo
run -all
```

Adjust the top-level testbench name to match the module declared in each testbench file.

## Results

Add verified simulation results and relevant waveform screenshots here.

## Future Improvements

- Additional corner-case testing
- Expanded functional coverage
- SystemVerilog-based verification
