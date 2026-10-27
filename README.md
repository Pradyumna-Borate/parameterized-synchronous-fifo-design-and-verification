# Synchronous FIFO — Verilog RTL and Verification

## Overview

A synchronous First-In, First-Out (FIFO) buffer implemented in Verilog HDL, with multiple testbenches to explore functional verification techniques.

## Design Specifications

- Data width: 8 bits (default)
- FIFO depth: 8 entries (default)
- Synchronous read and write operations
- Circular read and write pointers
- Full and empty status flags

## Verification Approach

### 1. Directed Testing
Tests normal operation, boundary conditions, and invalid read/write requests.

### 2. Scoreboard-Based Verification
Uses a reference model to check DUT behavior and identify mismatches.

### 3. Randomized Parameterized Testing
Exercises different read/write sequences and tracks functional coverage.

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
