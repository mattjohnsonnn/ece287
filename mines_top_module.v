module mines_top_module (
    input wire        CLOCK_50,
    input wire [3:0]  KEY,
    input wire [9:0]  SW,
    output wire [9:0] LEDR,
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

    // Combine LED outputs
    assign LEDR = {game_over, vga_leds};

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
        .game_over(game_over)    // Add this connection
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

endmodule
