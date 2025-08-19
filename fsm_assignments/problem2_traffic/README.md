# Problem 2: Two-Road Traffic Light (Moore FSM)

### Goal
Control NS/EW traffic lights with a shared 1 Hz tick.  
Durations:  
- NS Green = 5 ticks  
- NS Yellow = 2 ticks  
- EW Green = 5 ticks  
- EW Yellow = 2 ticks  
Repeat indefinitely.

FSM type: **Moore**  
Reset: **synchronous, active-high**

---

Outputs:
- **S_NS_G**: ns_g=1, ew_r=1  
- **S_NS_Y**: ns_y=1, ew_r=1  
- **S_EW_G**: ew_g=1, ns_r=1  
- **S_EW_Y**: ew_y=1, ns_r=1  

---

### Tick Generation

- The FSM runs on a fast `clk` (e.g., 50 MHz).  
- A prescaler module divides `clk` to produce a **1-cycle-wide `tick` every 1 second**.  
- In hardware: use a counter (`CLK_FREQ_HZ / TICK_HZ`).  
- In simulation: generate a faster tick for convenience.  

Example (from testbench):
```verilog
always @(posedge clk) begin
    cyc <= cyc + 1;
    tick <= (cyc % 20 == 0); // 1-cycle pulse every 20 clk cycles
end

