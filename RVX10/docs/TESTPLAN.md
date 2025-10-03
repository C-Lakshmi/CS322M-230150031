# RVX10 Test Plan

### Self-Checking Strategy

[cite_start]The test is performed by running a single assembly program, `rvx10.hex`, which is loaded into the processor's instruction memory[cite: 183]. The program executes a series of tests on the new RVX10 instructions. The final result is accumulated into a register and stored to a specific memory address.

The testbench (`testbench` module in `riscvsingle.v`) monitors the memory bus. [cite_start]The simulation is considered successful if and only if the value **25** is written to memory address **100**[cite: 100]. [cite_start]Any other memory write will cause the simulation to fail[cite: 14, 15].

### Per-Operation Test Cases

The `rvx10.hex` program executes the following sequence to validate the hardware implementation.

| Step | Instruction          | Input Register Values | Expected Result          |
| :--- | :------------------- | :-------------------- | :----------------------- |
| 1    | `max x7, x5, x6`     | `x5=5`, `x6=10`       | `x7` will hold **10** |
| 2    | `abs x8, x9, x0`     | `x9=-3`, `x0=0`       | `x8` will hold **3** |
| 3    | `add x10, x7, x8`    | `x7=10`, `x8=3`       | `x10` will hold **13** |
| 4    | `add x10, x10, x7`   | `x10=13`, `x7=10`     | `x10` will hold **23** |
| 5    | `addi x10, x10, 2`   | `x10=23`              | `x10` will hold **25** |
| 6    | `sw x10, 100(x0)`    | `x10=25`, `x0=0`      | Memory at addr **100** is set to **25** |

The final `sw` instruction triggers the success condition in the testbench, causing the simulation to stop and report success.