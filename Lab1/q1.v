
module comparator_1bit (
  input A,
  input B,
  output o1,  // A > B
  output o2,  // A == B
  output o3   // A < B
);
  wire notB, notA, A_gt_B, A_lt_B, A_eq_B;

  // A > B: A & ~B
  MyNot invB(.A(B), .Z(notB));
  MyAnd gt(.A(A), .B(notB), .Z(o1));

  // A < B: ~A & B
  MyNot invA(.A(A), .Z(notA));
  MyAnd lt(.A(notA), .B(B), .Z(o3));

  // A == B: ~(A ^ B)
  MyXnor eq(.A(A), .B(B), .Z(o2));

endmodule
