module tb_link;
    reg clk, rst;
    wire done;
    wire [7:0] last_byte;

    link_top dut(.clk(clk), .rst(rst), .done(done), .last_byte(last_byte));

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_link);

        clk = 0; rst = 1;
        #20 rst = 0;

        // run long enough to see multiple bursts
        repeat (200) @(posedge clk);
        $finish;
    end
endmodule
