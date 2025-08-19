module vending_mealy(
    input  wire clk,
    input  wire rst,          // sync active-high reset
    input  wire [1:0] coin,   // 01=5, 10=10, 00=idle

    output reg  dispense,     // 1-cycle pulse
    output reg  chg5          // 1-cycle pulse when 25
);

    localparam S0  = 2'b00;   // total = 0
    localparam S5  = 2'b01;   // total = 5
    localparam S10 = 2'b10;   // total = 10
    localparam S15 = 2'b11;   // total = 15

    reg [1:0] state, next_state;

    // State register
    always @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state logic + Mealy outputs
    always @(*) begin
        next_state = state;
        dispense = 0;
        chg5 = 0;

        case (state)
            S0: begin
                if (coin == 2'b01) next_state = S5;       // +5
                else if (coin == 2'b10) next_state = S10; // +10
            end

            S5: begin
                if (coin == 2'b01) next_state = S10;      // 5+5=10
                else if (coin == 2'b10) next_state = S15; // 5+10=15
            end

            S10: begin
                if (coin == 2'b01) next_state = S15;      // 10+5=15
                else if (coin == 2'b10) begin             // 10+10=20 → vend
                    dispense = 1;
                    next_state = S0;
                end
            end

            S15: begin
                if (coin == 2'b01) begin                  // 15+5=20 → vend+chg
                    dispense = 1;
                    chg5 = 1;
                    next_state = S0;
                end
                else if (coin == 2'b10) begin             // 15+10=25 → vend
                    dispense = 1;
                    next_state = S0;
                end
            end
        endcase
    end
endmodule
