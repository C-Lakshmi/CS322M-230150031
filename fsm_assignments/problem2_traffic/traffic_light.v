module traffic_light(
    input  wire clk,
    input  wire rst,   // synchronous active-high reset
    input  wire tick,  // 1-cycle pulse (1Hz or faster in sim)

    output reg ns_g, ns_y, ns_r,
    output reg ew_g, ew_y, ew_r
);

    // States
    localparam S_NS_G = 2'b00;
    localparam S_NS_Y = 2'b01;
    localparam S_EW_G = 2'b10;
    localparam S_EW_Y = 2'b11;

    reg [1:0] state, next_state;
    reg [2:0] count; // counts ticks within each phase

    // State register
    always @(posedge clk) begin
        if (rst) begin
            state <= S_NS_G;
            count <= 0;
        end else begin
            state <= next_state;
            if (tick) begin
                if ((state == S_NS_G && count == 4) ||
                    (state == S_NS_Y && count == 1) ||
                    (state == S_EW_G && count == 4) ||
                    (state == S_EW_Y && count == 1))
                    count <= 0; // reset counter on transition
                else
                    count <= count + 1;
            end
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            S_NS_G: if (tick && count == 4) next_state = S_NS_Y;
            S_NS_Y: if (tick && count == 1) next_state = S_EW_G;
            S_EW_G: if (tick && count == 4) next_state = S_EW_Y;
            S_EW_Y: if (tick && count == 1) next_state = S_NS_G;
        endcase
    end

    // Output logic (Moore: based only on state)
    always @(*) begin
        ns_g=0; ns_y=0; ns_r=0;
        ew_g=0; ew_y=0; ew_r=0;

        case (state)
            S_NS_G: begin ns_g=1; ew_r=1; end
            S_NS_Y: begin ns_y=1; ew_r=1; end
            S_EW_G: begin ew_g=1; ns_r=1; end
            S_EW_Y: begin ew_y=1; ns_r=1; end
        endcase
    end
endmodule
