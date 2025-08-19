module master_fsm(
    input  wire       clk,
    input  wire       rst,
    input  wire       ack,
    output reg        req,
    output reg  [7:0] data,
    output reg        done
);
    localparam IDLE=3'd0, LOAD=3'd1, WAIT_ACK1=3'd2, WAIT_ACK0=3'd3, NEXT=3'd4, DONE=3'd5;

    reg [2:0] state, next_state;
    reg [1:0] idx;

    // simple 4-byte ROM
    wire [7:0] rom0 = 8'hA1;
    wire [7:0] rom1 = 8'hB2;
    wire [7:0] rom2 = 8'hC3;
    wire [7:0] rom3 = 8'hD4;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            idx   <= 2'd0;
            data  <= 8'd0;
            req   <= 1'b0;
            done  <= 1'b0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        req  = 1'b0;
        done = 1'b0;

        case (state)
            IDLE:       next_state = LOAD;
            LOAD: begin
                req = 1'b1;
                next_state = WAIT_ACK1;
            end
            WAIT_ACK1: begin
                req = 1'b1;
                if (ack) next_state = WAIT_ACK0;
            end
            WAIT_ACK0: begin
                req = 1'b1;
                if (!ack) next_state = NEXT;
            end
            NEXT: begin
                if (idx == 2'd3) next_state = DONE;
                else              next_state = LOAD;
            end
            DONE: begin
                done = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

    // data/idx updates
    always @(posedge clk) begin
        if (rst) begin
            idx  <= 2'd0;
            data <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    idx  <= 2'd0;
                    data <= 8'd0;
                end
                LOAD: begin
                    case (idx)
                        2'd0: data <= rom0;
                        2'd1: data <= rom1;
                        2'd2: data <= rom2;
                        2'd3: data <= rom3;
                    endcase
                end
                NEXT: begin
                    if (idx != 2'd3) idx <= idx + 2'd1;
                end
            endcase
        end
    end
endmodule
