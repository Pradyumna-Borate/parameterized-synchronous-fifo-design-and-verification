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
- Parameterisation for DATA_WIDTH and DATA_DEPTH works only for values that can be expressed as powers of 2

## Verification Approach

### 1. Directed Testing
In this type of testing, the verification engineer has to give the stimulus to the DUT manually.

### 2. Scoreboard-Based Verification
This testing adds a layer that simplifies directed testing. We use a separate independent model and provide the same stimulus to the model as well as the DUT and compare the outputs of the two to test the DUT. This makes the testbench self-testing and automated. Each type of check and error are counted and displayed in the summary, at the end.

### 3. Randomized Parameterized Testing
This testing adds yet another layer to the testbench. Earlier, we were giving stimulus directly and the scoreboard performed automated verification. Now, we give randomised stimulus to the DUT and then compare it with our model. This enables the testbench to test a variety of scenarios which cannot all be specified manually. But, we also check the coverage of the random testing to ensure that it covers all the important scenarios.

When I first created my FIFO RTL, I used directed testing to primarily check the DUT's basic working. Then, as I learnt more about verification, I improved my testbench to make the DUT's verification more robust.

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
