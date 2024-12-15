module three_decimal_vals_w_neg (
    input [23:0] val,
    output [6:0] seg7_dig0,
    output [6:0] seg7_dig1,
    output [6:0] seg7_dig2,
    output [6:0] seg7_dig3,
    output [6:0] seg7_dig4,
    output [6:0] seg7_dig5
);

    reg [3:0] result_one_digit;
    reg [3:0] result_ten_digit;
    reg [3:0] result_hundred_digit;
    reg [3:0] result_thousand_digit;
    reg [3:0] result_ten_thousand_digit;
    reg [3:0] result_hundred_thousand_digit;

    always @(*) begin
        // Calculate each digit using modulo and division
        result_hundred_thousand_digit = (val / 100000) % 10;
        result_ten_thousand_digit = (val / 10000) % 10;
        result_thousand_digit = (val / 1000) % 10;
        result_hundred_digit = (val / 100) % 10;
        result_ten_digit = (val / 10) % 10;
        result_one_digit = val % 10;
    end

    seven_segment dig0 (
        .i(result_one_digit),
        .o(seg7_dig0)
    );

    seven_segment dig1 (
        .i(result_ten_digit),
        .o(seg7_dig1)
    );

    seven_segment dig2 (
        .i(result_hundred_digit),
        .o(seg7_dig2)
    );

    seven_segment dig3 (
        .i(result_thousand_digit),
        .o(seg7_dig3)
    );

    seven_segment dig4 (
        .i(result_ten_thousand_digit),
        .o(seg7_dig4)
    );

    seven_segment dig5 (
        .i(result_hundred_thousand_digit),
        .o(seg7_dig5)
    );

endmodule
