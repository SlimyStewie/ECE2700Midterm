
`timescale 1ns / 1ps

module calculator_basys3 (
    input  wire        clk,
    input  wire [9:0]  sw,
    output reg  [7:0]  led,
    output reg  [6:0]  seg,
    output wire        dp,
    output reg  [3:0]  an
);

    // Range: -8 to +7
    wire [3:0] x = sw[3:0];
    wire [1:0] operator = sw[5:4];
    wire [3:0] y = sw[9:6];

    assign dp = 1'b1;  // Decimal point 

    wire signed [7:0] sx = {{4{x[3]}}, x};
    wire signed [7:0] sy = {{4{y[3]}}, y};

    reg signed [7:0] result;
    reg [7:0] magnitude;

    // Decimal digits
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;
    reg       negative;

    reg [1:0] digit_select;
    reg [16:0] refresh_counter;

    // Calculator
    always @* begin
        result = 8'sd0;

        case (operator)
            2'b00: result = 8'sd0;
            2'b01: result = sx + sy;  // Addition
            2'b10: result = sx - sy;  // Subtraction
            2'b11: result = sx * sy;  // Multiplication
            default: result = 8'sd0;
        endcase

        led = result;

        // Convert signed result to a positive 
        negative = result[7];

        if (result[7])
            magnitude = -result;
        else
            magnitude = result;

        // Convert magnitude to decimal
        hundreds = magnitude / 100;
        tens = (magnitude / 10) % 10;
        ones = magnitude % 10;
    end

    // Seven-segment decoder (active-low segments)
    // seg[6:0] = {a,b,c,d,e,f,g}
    function [6:0] sevenSeg;
        input [3:0] in;
        begin
            case (in)
                4'd0: sevenSeg = 7'b1000000;
                4'd1: sevenSeg = 7'b1111001;
                4'd2: sevenSeg = 7'b0100100;
                4'd3: sevenSeg = 7'b0110000;
                4'd4: sevenSeg = 7'b0011001;
                4'd5: sevenSeg = 7'b0010010;
                4'd6: sevenSeg = 7'b0000010;
                4'd7: sevenSeg = 7'b1111000;
                4'd8: sevenSeg = 7'b0000000;
                4'd9: sevenSeg = 7'b0010000;

                // Minus sign: middle segment only
                4'hA: sevenSeg = 7'b0111111;

                // Blank digit
                default: sevenSeg = 7'b1111111;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1'b1;
    end

    always @* begin
        digit_select = refresh_counter[16:15];

        an = 4'b1111;
        seg = 7'b1111111;

        case (digit_select)

            //  ones
            2'b00: begin
                an = 4'b1110;
                seg = sevenSeg(ones);
            end

            //  tens, or minus sign
            2'b01: begin
                an = 4'b1101;

                if (negative)
                    seg = sevenSeg(4'hA);
                else if (magnitude >= 10)
                    seg = sevenSeg(tens);
                else
                    seg = sevenSeg(4'hF);
            end

            //  hundreds, tens, or minus sign
            2'b10: begin
                an = 4'b1011;

                if (negative && magnitude >= 100)
                    seg = sevenSeg(4'hA);
                else if (magnitude >= 100)
                    seg = sevenSeg(hundreds);
                else if (negative && magnitude < 10)
                    seg = sevenSeg(4'hF);
                else if (magnitude >= 10)
                    seg = sevenSeg(4'hF);
                else
                    seg = sevenSeg(4'hF);
            end

            //  hundreds, or minus sign
            2'b11: begin
                an = 4'b0111;

                if (negative && magnitude >= 100)
                    seg = sevenSeg(4'hF);
                else if (magnitude >= 100)
                    seg = sevenSeg(4'hF);
                else if (negative)
                    seg = sevenSeg(4'hA);
                else
                    seg = sevenSeg(4'hF);
            end

        endcase
    end

endmodule

