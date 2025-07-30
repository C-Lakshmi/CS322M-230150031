// XNOR gate (used for equality)
module MyXnor(input A, B, output Z);
  assign Z = ~(A ^ B);
endmodule