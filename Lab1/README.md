# Lab 1

**Course:** Digital Logic and Computer Architecture – CS322M  
**Name:** Lakshmi C  
**Roll No.:** 230150031
**Instructor:** Satyajit Das  

---

## Objective

This lab implements:
- **Q1**: A 1-bit comparator that outputs logic-1 on one of three ports depending on whether A > B, A == B, or A < B.
- **Q2**: A 4-bit equality comparator that outputs logic-1 only if both inputs are equal.

The implementation uses **structural modeling**, as taught in the lecture, by instantiating custom gate modules.

---

## File Structure

| File Name        | Description                                  |
|------------------|----------------------------------------------|
| `MyAnd.v`        | AND gate module                              |
| `MyNot.v`        | NOT gate module                              |
| `MyXor.v`        | XOR gate module                              |
| `MyXnor.v`       | XNOR gate module                             |
| `q1.v`           | 1-bit comparator (Q1)                         |
| `q2.v`           | 4-bit equality comparator (Q2)               |
| `testbench1.v`   | Testbench for 1-bit comparator               |
| `testbench2.v`   | Testbench for 4-bit comparator               |
| `output_q1.txt`  | Simulation output for Q1                     |
| `output_q2.txt`  | Simulation output for Q2                     |

---

## How to Run

Make sure Icarus Verilog is installed and run the following commands from your project folder:

### For Q1 (1-bit Comparator)
```bash
iverilog -o sim_q1 MyAnd.v MyNot.v MyXor.v MyXnor.v q1.v testbench1.v
vvp sim_q1 > output_q1.txt
```

### For Q2 (4-bit Equality Comparator)
```bash
iverilog -o sim_q2 MyAnd.v MyNot.v MyXor.v MyXnor.v q2.v testbench2.v
vvp sim_q2 > output_q2.txt
```
PS: Apologies for the unnecessary extra commits. Didn't create Lab1 folder initially, and accidentally created another branch named 'master' while trying to change that, which I subsequently deleted. So there were some complications in restoring that.