`timescale 1ns/1ps

module testbench_q1;

  // Declare test inputs and outputs
  reg A, B;
  wire o1, o2, o3;

  // Instantiate your design
  comparator_1bit uut (
    .A(A),
    .B(B),
    .o1(o1),
    .o2(o2),
    .o3(o3)
  );

  initial begin
    // Print header
    $display("A B | A>B o1 | A==B o2 | A<B o3");
    $display("------------------------------");

    // Monitor values
    $monitor("%b %b |   %b     |    %b     |   %b", A, B, o1, o2, o3);

    // Apply test vectors
    A = 0; B = 0; #10;
    A = 0; B = 1; #10;
    A = 1; B = 0; #10;
    A = 1; B = 1; #10;

    $finish;
  end

endmodule
