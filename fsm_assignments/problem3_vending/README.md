# Problem 3: Vending Machine with Change (Mealy FSM)

### Goal
Design a vending machine controller with the following rules:

- Price = 20
- Coins accepted:  
  - `01` = 5  
  - `10` = 10  
  - `00` = idle (ignore `11`)
- When total ≥ 20 → `dispense = 1` (1-cycle pulse)
- If total = 25 → also `chg5 = 1` (1-cycle pulse)
- Reset total after vend
- FSM type: **Mealy**
- Reset: **synchronous, active-high**

---

### FSM State Diagram (Concept)

States represent accumulated total:
S0 (0) → S5 (5) → S10 (10) → S15 (15)

Transitions:

From S10 with coin=10 → Vend (20), go S0

From S15 with coin=5 → Vend+Change (25), go S0

From S15 with coin=10 → Vend (≥25), go S0


---

### Testbench Scenarios

The testbench uses helper tasks (`put5`, `put10`) to insert coins.  
Tested cases:

1. `10 + 10` → Vend  
2. `5 + 5 + 10` → Vend  
3. `10 + 5 + 10` → Vend + Change  

---

### How to Run

From inside `problem3_vending`:

```bash
# Compile
iverilog -o sim.out vending_mealy.v tb_vending_mealy.v

# Run simulation
vvp sim.out

# Move waveform into waves/ folder
move dump.vcd waves\     # Windows
# mv dump.vcd waves/     # Linux/Mac

# View waveform
gtkwave waves/dump.vcd
