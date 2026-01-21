
module vending_machine(
    input clk,
    input reset,
    input [1:0] coin,   // 00=none, 01=5Rs, 10=10Rs, 11=invalid
    output reg dispense,
    output reg return5,
    output reg [2:0] current_state
);

    // State encoding
    localparam S0   = 3'b000;
    localparam S5   = 3'b001;
    localparam S10  = 3'b010;
    localparam S15  = 3'b011;
    localparam DISP = 3'b100;
    localparam CHG  = 3'b101;

    reg [2:0] next_state;

    // Sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Output logic
    always @(*) begin
        dispense = 0;
        return5 = 0;

        case (current_state)
            DISP: dispense = 1;
            CHG : return5 = 1;
        endcase
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;

        case (current_state)

            S0 : begin
                case (coin)
                    2'b01: next_state = S5;          // +5
                    2'b10: next_state = S10;         // +10
                    default: next_state = S0;        // invalid/no coin
                endcase
            end

            S5 : begin
                case (coin)
                    2'b01: next_state = S10;         // +5 ? 10
                    2'b10: next_state = S15;         // +10 ? 15
                    default: next_state = S5;
                endcase
            end

            S10 : begin
                case (coin)
                    2'b01: next_state = S15;         // +5 ? 15
                    2'b10: next_state = CHG;         // +10 ? 20 ? return 5
                    default: next_state = S10;
                endcase
            end

            S15 : next_state = DISP;                 // automatic

            DISP: next_state = S0;                   // auto-reset

            CHG : next_state = S0;                   // auto-reset

        endcase
    end

endmodule
