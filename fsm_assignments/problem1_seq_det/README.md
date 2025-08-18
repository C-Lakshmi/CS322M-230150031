# Problem 1: Overlapping Sequence Detector (Mealy FSM)

### Goal
Detect the bit sequence `1101` on a serial input `din`.  
The FSM is **Mealy type** with synchronous active-high reset.  
Output `y` pulses high **for one clock cycle** when the pattern is detected.  
Overlaps are supported (e.g., in `1101101`, the second pattern starts inside the first).

---

### Repository Contents
- `seq_detect_mealy.v` → FSM RTL
- `tb_seq_detect_mealy.v` → Testbench
- `waves/dump.vcd` → Waveform file (generated after simulation)

---

### How to Run

From inside the `problem1_seqdet` folder:

```bash
# Compile
iverilog -o sim.out seq_detect_mealy.v tb_seq_detect_mealy.v

# Run simulation
vvp sim.out

# Move waveform into waves/ folder
move dump.vcd waves\     # (Windows)

# View in GTKWave
gtkwave waves/dump.vcd
