module tb_vending_mealy;
    reg clk, rst;
    reg [1:0] coin;
    wire dispense, chg5;

    vending_mealy dut(.clk(clk), .rst(rst), .coin(coin),
                      .dispense(dispense), .chg5(chg5));

    always #5 clk = ~clk;  // clock

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_vending_mealy);

        clk = 0; rst = 1; coin = 2'b00;
        #12 rst = 0;

        // Test cases
        put10(); put10();          // 10+10 = vend
        put5(); put5(); put10();   // 5+5+10 = vend
        put10(); put5(); put10();  // 10+5+10 = vend+chg

        repeat (5) @(posedge clk);
        $finish;
    end

    // Helper tasks
    task put5; begin
        @(posedge clk) coin = 2'b01;
        @(posedge clk) coin = 2'b00;
    end endtask

    task put10; begin
        @(posedge clk) coin = 2'b10;
        @(posedge clk) coin = 2'b00;
    end endtask
endmodule
