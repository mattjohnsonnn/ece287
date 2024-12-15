module mines_top_module (
    input wire        CLOCK_50,
    input wire [3:0]  KEY,
    input wire [9:0]  SW,
    output wire [9:0] LEDR,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5,
    output wire       VGA_BLANK_N,
    output wire [7:0] VGA_B,
    output wire       VGA_CLK,
    output wire [7:0] VGA_G,
    output wire       VGA_HS,
    output wire [7:0] VGA_R,
    output wire       VGA_SYNC_N,
    output wire       VGA_VS
);

    // Internal signals
    wire [15:0] mine_map;
    wire placement_done;
    wire [14:0] current_location;
    wire game_over;
    wire [8:0] vga_leds;
    wire [23:0] score;  // Added for score tracking
    reg flag1;          // Added for tile reveal detection
	 wire game_won;

    // Combine LED outputs
    assign LEDR = {game_over, vga_leds};

    // Score module instantiation
    score_module score_tracker (
        .clk(CLOCK_50),
        .rst(KEY[0]),
        .mine_count(SW[3:0]),
        .tile_revealed(~KEY[1] & ~flag1),
        .game_over(game_over),
        .cash_out(SW[9]),           // Add cash out switch
        .score(score),
        .game_won(game_won)         // Add game won output
    );

    // Six digit display instantiation
    three_decimal_vals_w_neg score_display (
        .val(score),
        .seg7_dig0(HEX0),
        .seg7_dig1(HEX1),
        .seg7_dig2(HEX2),
        .seg7_dig3(HEX3),
        .seg7_dig4(HEX4),
        .seg7_dig5(HEX5)
    );

    // VGA driver instance
    vga_driver_to_frame_buf vga_display (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .LEDR(vga_leds),
        .SW(SW),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_B(VGA_B),
        .VGA_CLK(VGA_CLK),
        .VGA_G(VGA_G),
        .VGA_HS(VGA_HS),
        .VGA_R(VGA_R),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_VS(VGA_VS),
        .current_location(current_location),
        .mine_map(mine_map),
        .game_over(game_over)
    );

    // Mine placement instance
    mine_placement mine_placer (
        .clk(CLOCK_50),
        .rst(KEY[0]),
        .sw(SW[3:0]),
        .init_game(~KEY[1]),
        .current_location(current_location),
        .mine_map(mine_map),
        .placement_done(placement_done)
    );

    // Tile checker instance
    tile_checker tile_check (
        .pixel_location(current_location),
        .mine_map(mine_map),
        .game_over(game_over)
    );

    // Flag logic for tile reveal detection
    always @(posedge CLOCK_50 or negedge KEY[0]) begin
        if (!KEY[0]) begin
            flag1 <= 1'b0;
        end
        else begin
            if (!KEY[1]) begin
                flag1 <= 1'b1;
            end
            else begin
                flag1 <= 1'b0;
            end
        end
    end

endmodule
