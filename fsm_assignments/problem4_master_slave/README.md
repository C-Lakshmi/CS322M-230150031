# Problem 4: Master–Slave Handshake (Two FSMs)

### Goal
Implement a 4-phase handshake protocol between two FSMs: **Master** and **Slave**.  
The system transfers 4 bytes of data (A1, B2, C3, D4) from Master to Slave.  

Protocol per byte:
1. Master drives `data`, asserts `req`
2. Slave latches `data`, asserts `ack` for 2 cycles
3. Master detects `ack`, then deasserts `req`
4. Slave drops `ack`
5. Repeat for next byte
6. After 4 bytes, Master asserts `done` for 1 cycle

---

### FSMs

**Master FSM states:**
- `IDLE` → initial/reset
- `LOAD` → drive new data, assert `req`
- `WAIT_ACK1` → wait until Slave asserts `ack`
- `WAIT_ACK0` → wait until Slave deasserts `ack`
- `NEXT` → advance byte index
- `DONE` → assert `done` once, return to IDLE

**Slave FSM states:**
- `WAIT` → wait for `req`
- `ACK` → assert `ack` for 2 cycles, latch `data`

---

### Top-Level Connections
- Master drives `req`, `data[7:0]`
- Slave drives `ack`, `last_byte[7:0]`
- Both share `clk`, `rst`
- `done` is asserted by Master at the end of the 4-byte burst

---

### How to Run

From inside `problem4_link`:

```bash
# Compile
iverilog -o sim.out master_fsm.v slave_fsm.v link_top.v tb_link.v

# Run simulation
vvp sim.out

# Move waveform into waves/ folder
move dump.vcd waves\     # Windows
# mv dump.vcd waves/     # Linux/Mac

# View waveform
gtkwave waves/dump.vcd
