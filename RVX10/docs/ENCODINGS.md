# RVX10 Instruction Encodings

This file details the machine code format for the new RVX10 instructions and provides worked examples from the test program[cite: 188].

All 10 RVX10 instructions use the R-type format and share the `CUSTOM-0` opcode `0x0B` (`7'b0001011`)[cite: 102]. The specific operation is determined by the `funct7` and `funct3` fields.

### R-Type Bitfield Layout

| 31:25  | 24:20 | 19:15 | 14:12  | 11:7 | 6:0    |
| :----- | :---- | :---- | :----- | :--- | :----- |
| funct7 | rs2   | rs1   | funct3 | rd   | opcode |

### RVX10 Encoding Table

| Instruction | `opcode` | `funct7`  | `funct3` |
| :---------- | :------- | :-------- | :------- |
| **ANDN** | `0x0B`   | `0000000` | `000`    |
| **ORN** | `0x0B`   | `0000000` | `001`    |
| **XNOR** | `0x0B`   | `0000000` | `010`    |
| **MIN** | `0x0B`   | `0000001` | `000`    |
| **MAX** | `0x0B`   | `0000001` | `001`    |
| **MINU** | `0x0B`   | `0000001` | `010`    |
| **MAXU** | `0x0B`   | `0000001` | `011`    |
| **ROL** | `0x0B`   | `0000010` | `000`    |
| **ROR** | `0x0B`   | `0000010` | `001`    |
| **ABS** | `0x0B`   | `0000011` | `000`    |

[cite: 171]

### Worked Encoding Examples

These examples are taken from the `rvx10.hex` test program.

#### 1. `max x7, x5, x6`

-   **`funct7`**: `0b0000001` [cite: 115]
-   **`rs2`**: `x6` = 6 (`00110`)
-   **`rs1`**: `x5` = 5 (`00101`)
-   **`funct3`**: `0b001` [cite: 115]
-   **`rd`**: `x7` = 7 (`00111`)
-   **`opcode`**: `0b0001011` [cite: 102]

**Binary**: `0000001` `00110` `00101` `001` `00111` `0001011`
**Hex**: `0x0262938B`

#### 2. `abs x8, x9, x0`

For unary operations like `ABS`, `rs2` is set to `x0`[cite: 118].

-   **`funct7`**: `0b0000011` [cite: 115]
-   **`rs2`**: `x0` = 0 (`00000`)
-   **`rs1`**: `x9` = 9 (`01001`)
-   **`funct3`**: `0b000` [cite: 115]
-   **`rd`**: `x8` = 8 (`01000`)
-   **`opcode`**: `0b0001011` [cite: 102]

**Binary**: `0000011` `00000` `01001` `000` `01000` `0001011`
**Hex**: `0x0604840B`