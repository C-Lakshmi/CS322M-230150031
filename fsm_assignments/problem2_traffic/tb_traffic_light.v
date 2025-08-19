module tb_traffic_light;
    reg clk, rst, tick;
    wire ns_g, ns_y, ns_r, ew_g, ew_y, ew_r;

    traffic_light dut(
        .clk(clk), .rst(rst), .tick(tick),
        .ns_g(ns_g), .ns_y(ns_y), .ns_r(ns_r),
        .ew_g(ew_g), .ew_y(ew_y), .ew_r(ew_r)
    );

    always #5 clk = ~clk;  // clock

    integer cyc;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);

        clk = 0; rst = 1; tick = 0;
        cyc = 0;
        #12 rst = 0;

        // Generate fast tick: one tick every 20 cycles
        forever begin
            @(posedge clk);
            cyc = cyc + 1;
            if (cyc % 20 == 0) tick = 1;
            else tick = 0;
        end
    end

    initial begin
        #2000; // run enough cycles
        $finish;
    end
endmodule
