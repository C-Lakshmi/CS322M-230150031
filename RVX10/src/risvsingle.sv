// riscvsingle.v (Classic Verilog-2001 version)

// RISC-V single-cycle processor
// Modified to include RVX10 custom instruction set extension.
// Converted to classic Verilog for maximum compatibility.

module testbench();
  reg          clk;
  reg          reset;
  wire [31:0]  WriteData;
  wire [31:0]  DataAdr;
  wire         MemWrite;

  // instantiate device to be tested
  top dut(clk, reset, WriteData, DataAdr, MemWrite);

  // initialize test
  initial
    begin
      reset = 1; #22;
      reset = 0;
    end

  // generate clock
  always
    begin
      clk = 1; #5;
      clk = 0; #5;
    end

  // check results
  always @(negedge clk)
    begin
      if(MemWrite) begin
        if(DataAdr === 100 && WriteData === 25) begin
          $display("Simulation succeeded");
          $stop;
        end else if (DataAdr !== 96) begin
          $display("Simulation failed: incorrect write address or data");
          $stop;
        end
      end
    end
endmodule

module top(clk, reset, WriteData, DataAdr, MemWrite);
  input         clk;
  input         reset;
  output [31:0] WriteData;
  output [31:0] DataAdr;
  output        MemWrite;

  wire [31:0] PC, Instr, ReadData;

  // instantiate processor and memories
  riscvsingle rvsingle(clk, reset, PC, Instr, MemWrite, DataAdr,
                       WriteData, ReadData);
  imem imem(PC, Instr);
  dmem dmem(clk, MemWrite, DataAdr, WriteData, ReadData);
endmodule

module riscvsingle(clk, reset, PC, Instr, MemWrite, ALUResult, WriteData, ReadData);
  input         clk;
  input         reset;
  output [31:0] PC;
  input  [31:0] Instr;
  output        MemWrite;
  output [31:0] ALUResult;
  output [31:0] WriteData;
  input  [31:0] ReadData;

  wire        ALUSrc, RegWrite, Jump, Zero, PCSrc;
  wire [1:0]  ResultSrc, ImmSrc;
  wire [3:0]  ALUControl;

  controller c(Instr[6:0], Instr[14:12], Instr[31:25], Instr[30], Zero,
               ResultSrc, MemWrite, PCSrc,
               ALUSrc, RegWrite, Jump,
               ImmSrc, ALUControl);

  datapath dp(clk, reset, ResultSrc, PCSrc,
              ALUSrc, RegWrite,
              ImmSrc, ALUControl,
              Zero, PC, Instr,
              ALUResult, WriteData, ReadData);
endmodule

module controller(op, funct3, funct7, funct7b5, Zero,
                  ResultSrc, MemWrite, PCSrc, ALUSrc,
                  RegWrite, Jump, ImmSrc, ALUControl);
  input  [6:0] op;
  input  [2:0] funct3;
  input  [6:0] funct7;
  input        funct7b5;
  input        Zero;
  output [1:0] ResultSrc;
  output       MemWrite;
  output       PCSrc;
  output       ALUSrc;
  output       RegWrite;
  output       Jump;
  output [1:0] ImmSrc;
  output [3:0] ALUControl;

  wire [1:0] ALUOp;
  wire       Branch;

  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
  aludec  ad(op[5], funct3, funct7, ALUOp, ALUControl);

  assign PCSrc = (Branch & Zero) | Jump;
endmodule

module maindec(op, ResultSrc, MemWrite, Branch, ALUSrc,
               RegWrite, Jump, ImmSrc, ALUOp);
  input  [6:0] op;
  output [1:0] ResultSrc;
  output       MemWrite;
  output       Branch;
  output       ALUSrc;
  output       RegWrite;
  output       Jump;
  output [1:0] ImmSrc;
  output [1:0] ALUOp;

  reg [10:0] controls;

  assign {RegWrite, ImmSrc, ALUSrc, MemWrite,
          ResultSrc, Branch, ALUOp, Jump} = controls;

  always @(*)
    case(op)
      // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
      7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
      7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw
      7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type
      7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq
      7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU
      7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
      7'b0001011: controls = 11'b1_xx_0_0_00_0_11_0; // RVX10 Custom R-type
      default:    controls = 11'bx_xx_x_x_xx_x_xx_x;
    endcase
endmodule

module aludec(opb5, funct3, funct7, ALUOp, ALUControl);
  input        opb5;
  input  [2:0] funct3;
  input  [6:0] funct7;
  input  [1:0] ALUOp;
  output [3:0] ALUControl;
  reg    [3:0] ALUControl;

  wire RtypeSub;
  assign RtypeSub = funct7[5] & opb5;

  always @(*)
    case(ALUOp)
      2'b00:      ALUControl = 4'b0000; // lw/sw/jal -> add
      2'b01:      ALUControl = 4'b0001; // beq -> sub
      2'b10:      // R-type or I-type ALU
        case(funct3)
          3'b000: if (RtypeSub) ALUControl = 4'b0001; // sub
                  else          ALUControl = 4'b0000; // add, addi
          3'b010: ALUControl = 4'b0101; // slt, slti
          3'b110: ALUControl = 4'b0011; // or, ori
          3'b111: ALUControl = 4'b0010; // and, andi
          default: ALUControl = 4'bxxxx;
        endcase
      2'b11:      // RVX10 R-type Decode
        case(funct7)
          7'b0000000: // ANDN, ORN, XNOR
            case(funct3)
              3'b000:  ALUControl = 4'b1000; // ANDN
              3'b001:  ALUControl = 4'b1001; // ORN
              3'b010:  ALUControl = 4'b1010; // XNOR
              default: ALUControl = 4'bxxxx;
            endcase
          7'b0000001: // MIN, MAX, MINU, MAXU
            case(funct3)
              3'b000:  ALUControl = 4'b1011; // MIN
              3'b001:  ALUControl = 4'b1100; // MAX
              3'b010:  ALUControl = 4'b1101; // MINU
              3'b011:  ALUControl = 4'b1110; // MAXU
              default: ALUControl = 4'bxxxx;
            endcase
          7'b0000010: // ROL, ROR
            case(funct3)
              3'b000:  ALUControl = 4'b1111; // ROL
              3'b001:  ALUControl = 4'b0110; // ROR
              default: ALUControl = 4'bxxxx;
            endcase
          7'b0000011: // ABS
            case(funct3)
              3'b000:  ALUControl = 4'b0111; // ABS
              default: ALUControl = 4'bxxxx;
            endcase
          default: ALUControl = 4'bxxxx;
        endcase
      default: ALUControl = 4'bxxxx;
    endcase
endmodule

module datapath(clk, reset, ResultSrc, PCSrc, ALUSrc, RegWrite,
                ImmSrc, ALUControl, Zero, PC, Instr,
                ALUResult, WriteData, ReadData);
  input         clk;
  input         reset;
  input  [1:0]  ResultSrc;
  input         PCSrc;
  input         ALUSrc;
  input         RegWrite;
  input  [1:0]  ImmSrc;
  input  [3:0]  ALUControl;
  output        Zero;
  output [31:0] PC;
  input  [31:0] Instr;
  output [31:0] ALUResult;
  output [31:0] WriteData;
  input  [31:0] ReadData;

  wire [31:0] PCNext, PCPlus4, PCTarget;
  wire [31:0] ImmExt;
  wire [31:0] SrcA, SrcB;
  wire [31:0] Result;

  flopr #(32) pcreg(clk, reset, PCNext, PC);
  adder       pcadd4(PC, 32'd4, PCPlus4);
  adder       pcaddbranch(PC, ImmExt, PCTarget);
  mux2 #(32)  pcmux(PCPlus4, PCTarget, PCSrc, PCNext);

  regfile     rf(clk, RegWrite, Instr[19:15], Instr[24:20],
                 Instr[11:7], Result, SrcA, WriteData);
  extend      ext(Instr[31:7], ImmSrc, ImmExt);

  mux2 #(32)  srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
  alu         alu(SrcA, SrcB, ALUControl, ALUResult, Zero);
  mux3 #(32)  resultmux(ALUResult, ReadData, PCPlus4, ResultSrc, Result);
endmodule

module alu(a, b, alucontrol, result, zero);
  input  [31:0] a;
  input  [31:0] b;
  input  [3:0]  alucontrol;
  output [31:0] result;
  output        zero;
  reg    [31:0] result;

  wire [31:0] condinvb, sum;
  wire        v, isAddSub;
  wire signed [31:0] signed_a = a;
  wire signed [31:0] signed_b = b;

  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum = a + condinvb + alucontrol[0];
  assign isAddSub = (alucontrol == 4'b0000) || (alucontrol == 4'b0001);
  assign zero = (result == 32'b0);
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;

  always @(*)
    case (alucontrol)
      4'b0000:  result = sum;
      4'b0001:  result = sum;
      4'b0010:  result = a & b;
      4'b0011:  result = a | b;
      4'b0101:  result = signed_a < signed_b;
      4'b1000:  result = a & ~b;
      4'b1001:  result = a | ~b;
      4'b1010:  result = ~(a ^ b);
      4'b1011:  result = (signed_a < signed_b) ? a : b;
      4'b1100:  result = (signed_a > signed_b) ? a : b;
      4'b1101:  result = (a < b) ? a : b;
      4'b1110:  result = (a > b) ? a : b;
      4'b1111:  result = (b[4:0] == 5'd0) ? a : (a << b[4:0]) | (a >> (32 - b[4:0]));
      4'b0110:  result = (b[4:0] == 5'd0) ? a : (a >> b[4:0]) | (a << (32 - b[4:0]));
      4'b0111:  result = (signed_a >= 0) ? a : -a;
      default:  result = 32'bx;
    endcase
endmodule

module imem(a, rd);
  input  [31:0] a;
  output [31:0] rd;
  reg [31:0] RAM[63:0];

  initial
      $readmemh("rvx10.hex", RAM);

  assign rd = RAM[a[31:2]];
endmodule

module regfile(clk, we3, a1, a2, a3, wd3, rd1, rd2);
  input        clk;
  input        we3;
  input  [4:0] a1, a2, a3;
  input  [31:0] wd3;
  output [31:0] rd1;
  output [31:0] rd2;

  reg [31:0] rf[31:0];

  always @(posedge clk)
    if (we3) rf[a3] <= wd3;

  assign rd1 = (a1 != 0) ? rf[a1] : 0;
  assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module adder(a, b, y);
  input  [31:0] a, b;
  output [31:0] y;
  assign y = a + b;
endmodule

module extend(instr, immsrc, immext);
  input  [31:7] instr;
  input  [1:0]  immsrc;
  output [31:0] immext;
  reg    [31:0] immext;

  always @(*)
    case(immsrc)
      2'b00:   immext = {{20{instr[31]}}, instr[31:20]}; // I-type
      2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
      2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
      2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
      default: immext = 32'bx;
    endcase
endmodule

module flopr(clk, reset, d, q);
  parameter WIDTH = 8;
  input              clk;
  input              reset;
  input  [WIDTH-1:0] d;
  output [WIDTH-1:0] q;
  reg    [WIDTH-1:0] q;

  always @(posedge clk or posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule

module mux2(d0, d1, s, y);
  parameter WIDTH = 8;
  input  [WIDTH-1:0] d0, d1;
  input              s;
  output [WIDTH-1:0] y;
  assign y = s ? d1 : d0;
endmodule

module mux3(d0, d1, d2, s, y);
  parameter WIDTH = 8;
  input  [WIDTH-1:0] d0, d1, d2;
  input  [1:0]       s;
  output [WIDTH-1:0] y;
  assign y = s[1] ? d2 : (s[0] ? d1 : d0);
endmodule

module dmem(clk, we, a, wd, rd);
  input        clk;
  input        we;
  input  [31:0] a;
  input  [31:0] wd;
  output [31:0] rd;

  reg [31:0] RAM[63:0];
  assign rd = RAM[a[31:2]];

  always @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
endmodule