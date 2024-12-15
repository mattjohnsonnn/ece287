module tile_checker (
    input wire [14:0] pixel_location,
    input wire [15:0] mine_map,
    output wire game_over    // Changed from is_mine to game_over
);

    parameter TILE_WIDTH = 21;
    parameter TILE_HEIGHT = 24;
    parameter TILE_GAP = 3;
    parameter TOP_OFFSET = 8;
    parameter LEFT_OFFSET = 9;
    parameter PIXELS_PER_COL = 120;
    
    wire [1:0] tile_x;
    wire [1:0] tile_y;
    wire [3:0] tile_pos;
    
    assign tile_x = (pixel_location % PIXELS_PER_COL - LEFT_OFFSET) / (TILE_WIDTH + TILE_GAP);
    assign tile_y = ((pixel_location / PIXELS_PER_COL) - TOP_OFFSET) / (TILE_HEIGHT + TILE_GAP);
    assign tile_pos = {tile_y, tile_x};
    
    assign game_over = mine_map[tile_pos];    // Changed from is_mine to game_over

endmodule
