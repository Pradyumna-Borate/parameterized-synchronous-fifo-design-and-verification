# Synchronous FIFO — Verilog RTL and Verification

## Overview

A synchronous First-In, First-Out (FIFO) buffer implemented in Verilog HDL, with multiple testbenches to explore functional verification techniques.

## Design Specifications

- Data width: 8 bits (default)
- FIFO depth: 8 entries (default)
- Read and write operations are controlled by a common clock
- Circular read and write pointers
- Full and empty status flags
- Simultaneous read and write operations supported
- An additional pointer bit distinguishes wraparound phases for full/empty detection.
- FIFO depth must be a power of 2

## Verification Approach

### 1. Directed Testing
Directed testing uses explicitly defined stimulus to exercise predefined scenarios. The engineer identifies the scenarios to test and checks whether the DUT behaves as expected.

### 2. Scoreboard-Based Verification
This testbench introduces an independent reference model that receives the same stimulus as the DUT. It predicts the expected FIFO behavior. The scoreboard compares the expected results against the DUT's outputs, including read data and status flags. This makes the testbench self-checking and automates error detection. The testbench also maintains counters for different checks and errors and displays a summary at the end.

### 3. Randomized Parameterized Testing
The randomized testbench generates varied read/write stimulus and compares the DUT's behavior against the reference model. This helps explore sequences and interactions that may be difficult to enumerate manually, but it may not hit all cases. Functional coverage flags track whether selected important scenarios have occurred, helping identify gaps in the randomly tested scenarios. The testbench is parameterized to support different data widths and FIFO depths.

The project evolved incrementally: I began with directed testing to establish basic FIFO functionality, then developed a scoreboard-based testbench, and finally extended the verification approach with randomized stimulus and functional coverage.

## Repository Structure



## Repository Structure

```text
synchronous-fifo-verification/
├── rtl/
│   └── fifo_implementation.v
├── tb/
│   ├── tb_fifo.v
│   ├── tb_fifo_scoreboard.v
│   └── tb_fifo_random_parametrized.v
├── docs/
│   ├── basic_fifo_operation_waveform.jpeg
│   ├── signal_monitoring.jpeg
│   ├── directed_testing_summary.jpeg
│   ├── dut_and_model_comparison_waveform.jpeg
│   ├── scoreboard_summary.jpeg
│   ├── randomised_and_parameterised_waveform.jpeg
│   ├── parameters_changed.jpeg
│   └── coverage_and_error_report.jpeg
└── README.md
```


## Tools

- Verilog HDL
- Questa / ModelSim

## Simulation

Compile the RTL and the testbench you want to run in Questa/ModelSim. Use the following commands for the respective testbenches:

### 1. Directed Testbench

```tcl
vlib work
vlog rtl/fifo_implementation.v tb/tb_fifo.v
vsim -voptargs=+acc work.tb_fifo
add wave -r sim:/tb_fifo/*
run -all
```

### 2. Scoreboard-Based Testbench

```tcl
vlib work
vlog rtl/fifo_implementation.v tb/tb_fifo_scoreboard.v
vsim -voptargs=+acc work.tb_fifo_scoreboard
add wave -r sim:/tb_fifo_scoreboard/*
run -all
```

### 3. Randomized Parameterized Testbench

```tcl
vlib work
vlog rtl/fifo_implementation.v tb/tb_fifo_random_parametrized.v
vsim -voptargs=+acc work.tb_fifo_random_parametrized
add wave -r sim:/tb_fifo_random_parametrized/*
run -all
```
The +acc option preserves access to internal signals during simulation, while add wave -r recursively adds signals under the specified testbench hierarchy to the waveform viewer. This makes it easier to monitor and debug the DUT and testbench behavior. Unnecessary signals can be removed from the waveform viewer to improve readability.

## Results

### 1. Basic FIFO Operations (Directed Testing)

The waveform demonstrates synchronous write and read transactions, showing that data is read in FIFO order and illustrating the behavior of the full and empty flags. The read and write pointers are changed as the data is read or written in the memory.

![Basic FIFO operations waveform](docs/basic_fifo_operation_waveform.jpeg)

### 2. Signal Monitoring

The testbench monitors every signal of DUT each time an operation is performed to make debugging easier. This is practiced for all the three testbenches.

![Signal Monitoring](docs/signal_monitoring.jpeg)

### 3. Directed Testing Summary

The report summarises how many checks were done for each type of test, and how many errors were reported.

![Directed Testing Summary](docs/directed_testing_summary.jpeg)

### 4. DUT-Model comparison (Scoreboard based Verification)

The waveform illustrates how the DUT operation compares to the operation of an independent reference model under the same stimulus. Scoreboard based verification is used to compare the DUT to the model and verify the DUT.

![DUT-Model Comparison](docs/dut_and_model_comparison_waveform.jpeg)

### 5. Scoreboard Summary

The scoreboard summary gives us the final verdict of the verification. It also shows how many total checks were performed and then shows how many checks were performed for each test and how many errors were reported.

![Scoreboard Summary](docs/scoreboard_summary.jpeg)

### 5. Randomized and Parameterized Waveform

This waveform shows us the result of a randomized and parameterized FIFO. It shows the parameters- DATA_WIDTH, DATA_DEPTH, and POINTER_WIDTH on the top, followed by the DUT signals and the model signals. Randomized testing poses a challenge that we can't guarantee that all possible test cases are covered, so the coverage flags track whether the important cases are covered, thus we can test the FIFO for various random testcases, while also making sure that important testcases are covered.

![Randomized and Parameterized Waveform](docs/randomised_and_parameterised_waveform.jpeg)

In the next waveform, values of the parameters are changed: DATA_WIDTH to 16 bits, DATA_DEPTH to 4. POINTER_WIDTH is calculated automatically. 

![Parameters changed](docs/parameters_changed.jpeg)


### 5. Coverage and Error Report

This report summarises what all cases were covered in the randomised testing, to ensure that randomised testing doesn't miss important tests. The error report gives the verdict of the tests and shows how many checks were performed for each test and how many errors occurred in them.

![Coverage and Error Report](docs/coverage_and_error_report.jpeg)


| Verification Stage | What It Demonstrates |
|---|---|
| Directed Testing | Verification of predefined functional scenarios and boundary conditions. |
| Scoreboard-Based Verification | Automated comparison of DUT behavior against an independent reference model. |
| Randomized Verification | Exploration of varied read/write sequences with functional coverage tracking of selected scenarios. |
| Parameterized Simulation | Demonstration of the design with different supported data widths and FIFO depths. |


## Future Improvements

- Additional corner-case testing
- Expanded functional coverage
- SystemVerilog-based verification
- Making randomised tests reproducible
