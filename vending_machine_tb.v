`timescale 1ns/1ps

module vending_machine_tb;

    reg clk;
    reg reset;
    reg [1:0] coin;       // 00=no coin, 01=5Rs, 10=10Rs, 11=invalid
    wire dispense;
    wire return5;
    wire [2:0] state;

    // DUT instantiation
    vending_machine dut (
        .clk(clk),
        .reset(reset),
        .coin(coin),
        .dispense(dispense),
        .return5(return5),
        .current_state(state)
    );

    // Clock generator
    always #5 clk = ~clk;   // 10ns clock period

    // Task to insert coin
    task insert_coin(input [1:0] c);
    begin
        coin = c;
        #10;
        coin = 2'b00;  // remove coin signal after 1 cycle
        #10;
    end
    endtask

    // Display state names (for readability)
    task print_state;
    begin
        case (state)
            3'b000: $display("Time=%0t : State = S0 (Rs 0)", $time);
            3'b001: $display("Time=%0t : State = S5 (Rs 5)", $time);
            3'b010: $display("Time=%0t : State = S10 (Rs 10)", $time);
            3'b011: $display("Time=%0t : State = S15 (Rs 15)", $time);
            3'b100: $display("Time=%0t : State = DISPENSE", $time);
            3'b101: $display("Time=%0t : State = RETURN 5Rs", $time);
            default: $display("Time=%0t : State = UNKNOWN", $time);
        endcase
    end
    endtask

    // Main Test Sequence
    initial begin
        $dumpfile("vending_machine_tb.vcd");
        $dumpvars(0, vending_machine_tb);

        clk = 0;
        coin = 0;

        // 1. Apply reset
        reset = 1;
        #20;
        reset = 0;
        print_state();

        // 2. Scenario 1: 5 + 5 + 5 => DISPENSE
        $display("\n=== TEST 1: 5 + 5 + 5 ===");
        insert_coin(2'b01); print_state();
        insert_coin(2'b01); print_state();
        insert_coin(2'b01); print_state();
        #20; print_state();

        // 3. Scenario 2: 10 + 5 => DISPENSE
        $display("\n=== TEST 2: 10 + 5 ===");
        insert_coin(2'b10); print_state();
        insert_coin(2'b01); print_state();
        #20; print_state();

        // 4. Scenario 3: 5 + 10 => DISPENSE
        $display("\n=== TEST 3: 5 + 10 ===");
        insert_coin(2'b01); print_state();
        insert_coin(2'b10); print_state();
        #20; print_state();

        // 5. Scenario 4: 10 + 10 => RETURN ?5
        $display("\n=== TEST 4: 10 + 10 => RETURN 5 ===");
        insert_coin(2'b10); print_state();
        insert_coin(2'b10); print_state();
        #20; print_state();

        // 6. Scenario 5: Invalid coin
        $display("\n=== TEST 5: INVALID COIN ===");
        insert_coin(2'b11); print_state();
        #20; print_state();

        // 7. Scenario 6: Reset in middle of operation
        $display("\n=== TEST 6: Reset test ===");
        insert_coin(2'b01); print_state();   // Go to 5
        reset = 1; #10; reset = 0;
        print_state();

        $display("\n=== TEST COMPLETED ===");
        #100;
        $finish;
    end

endmodule
