`timescale 1ns / 1ps

module calculator_basys3_tb;
    reg clk = 0;
    reg [15:0] sw = 0;
    wire [7:0] led;
    wire [6:0] seg;
    

    calculator_basys3 dut (
        .clk(clk), .sw(sw), .led(led), .seg(seg)
    );

    always #5 clk = ~clk; // 100 MHz simulated clock

    task check_result;
        input [3:0] a;
        input [3:0] b;
        input [1:0] op;
        input integer expected;
        begin
            sw = {6'b0, op, b, a};
            #20;
            // Hierarchical check of the internal arithmetic result.
            if ($signed(dut.result) !== expected)
                $display("FAIL: A=%0d B=%0d op=%b expected=%0d got=%0d",
                         a, b, op, expected, $signed(dut.result));
            else
                $display("PASS: A=%0d B=%0d op=%b result=%0d",
                         a, b, op, $signed(dut.result));
        end
    endtask

    initial begin
        check_result(4'd3, 4'd5, 2'b00, 8);
        check_result(4'd3, 4'd5, 2'b01, -2);
        check_result(4'd15, 4'd15, 2'b10, 225);
        check_result(4'd2, 4'd7, 2'b01, -5);
        check_result(4'd0, 4'd9, 2'b10, 0);
        check_result(4'd15, 4'd15, 2'b00, 30);
        $finish;
    end
endmodule
