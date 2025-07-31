`timescale 1ns/1ps

module testbench_q2;

  // Inputs and output
  reg [3:0] A, B;
  wire equal;

  // Instantiate the module
  comparator_4bit uut (
    .A(A),
    .B(B),
    .equal(equal)
  );

  initial begin
    $display("     A      B  | Equal");
    $display("------------------------");
    $monitor("%b %b |   %b", A, B, equal);

    // Apply test vectors
    A = 4'b0000; B = 4'b0000; #10;
    A = 4'b1010; B = 4'b1010; #10;
    A = 4'b1111; B = 4'b0000; #10;
    A = 4'b1100; B = 4'b1101; #10;
    A = 4'b1001; B = 4'b1001; #10;

    $finish;
  end

endmodule
