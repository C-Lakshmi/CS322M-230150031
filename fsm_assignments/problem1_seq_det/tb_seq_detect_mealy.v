module tb_seq_detect_mealy;
    reg clk, rst, din;
    wire y;

    seq_detect_mealy dut(.clk(clk), .rst(rst), .din(din), .y(y));

    always #5 clk = ~clk;  // 10ns clock

    integer i;
    reg [0:20] stream; // test stream (bit vector, MSB first)

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seq_detect_mealy);

        clk = 0; rst = 1; din = 0;
        #12 rst = 0;

        // Define the test stream: 11011011101
        stream = 11'b11011011101;

        // Apply each bit per clock
        for (i = 0; i < 11; i = i + 1) begin
            @(posedge clk);
            din = stream[i];
        end

        repeat (5) @(posedge clk);
        $finish;
    end
endmodule
