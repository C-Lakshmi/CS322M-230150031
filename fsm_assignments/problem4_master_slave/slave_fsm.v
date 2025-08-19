module slave_fsm(
    input  wire       clk,
    input  wire       rst,
    input  wire       req,
    input  wire [7:0] data_in,
    output reg        ack,
    output reg  [7:0] last_byte
);
    localparam WAIT=2'd0, ACK=2'd1;

    reg [1:0] state, next_state;
    reg [1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            state <= WAIT;
            cnt   <= 2'd0;
            ack   <= 1'b0;
            last_byte <= 8'd0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        ack = (state == ACK);
        case (state)
            WAIT: if (req) next_state = ACK;
            ACK:  if (cnt == 2'd1) next_state = WAIT; // 2 cycles high
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 2'd0;
        end else begin
            case (state)
                WAIT: begin
                    cnt <= 2'd0;
                    if (req) last_byte <= data_in; // latch on req
                end
                ACK:  cnt <= cnt + 2'd1;
            endcase
        end
    end
endmodule
