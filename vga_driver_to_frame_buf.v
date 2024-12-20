module vga_driver_to_frame_buf (
    input               CLOCK_50,
    input        [3:0]  KEY,
    output       [6:0]  HEX0,
    output       [6:0]  HEX1,
    output       [6:0]  HEX2,
    output       [6:0]  HEX3,
    output       [8:0]  LEDR,
    input        [9:0]  SW,
    output             VGA_BLANK_N,
    output       [7:0]  VGA_B,
    output             VGA_CLK,
    output       [7:0]  VGA_G,
    output             VGA_HS,
    output       [7:0]  VGA_R,
    output             VGA_SYNC_N,
    output             VGA_VS,
    output reg  [14:0] current_location,
    input wire  [15:0] mine_map,
    input wire         game_over    // Added game_over input
);

    // Color parameters
    parameter RED_COLOR = 24'hFF0000;
    parameter WHITE_COLOR = 24'hFFFFFF;
    parameter GREEN_COLOR = 24'h00FF00;
    parameter BLACK_COLOR = 24'h000000;

    assign HEX0 = 7'h00;
    assign HEX1 = 7'h00;
    assign HEX2 = 7'h00;
    assign HEX3 = 7'h00;

    wire clk;
    wire rst;
    assign clk = CLOCK_50;
    assign rst = KEY[0];

    wire [9:0]SW_db;
    debounce_switches db(
        .clk(clk),
        .rst(rst),
        .SW(SW), 
        .SW_db(SW_db)
    );

    wire active_pixels;
    wire frame_done;
    wire [9:0]x;
    wire [9:0]y;

    reg [14:0] the_vga_draw_frame_write_mem_address;
    reg [23:0] the_vga_draw_frame_write_mem_data;
    reg the_vga_draw_frame_write_a_pixel;
    reg [14:0] prev_location;
    reg [23:0] current_color;
    reg [23:0] tile_colors [0:15];

    wire [3:0] current_tile;
    assign current_tile = idx_location % 16;

    vga_frame_driver my_frame_driver(
        .clk(clk),
        .rst(rst),
        .active_pixels(active_pixels),
        .frame_done(frame_done),
        .x(x),
        .y(y),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_VS(VGA_VS),
        .VGA_B(VGA_B),
        .VGA_G(VGA_G),
        .VGA_R(VGA_R),
        .the_vga_draw_frame_write_mem_address(the_vga_draw_frame_write_mem_address),
        .the_vga_draw_frame_write_mem_data(the_vga_draw_frame_write_mem_data),
        .the_vga_draw_frame_write_a_pixel(the_vga_draw_frame_write_a_pixel)
    );

    reg [15:0]i;
    reg [7:0]S;
    reg [7:0]NS;
    parameter 
        START           = 8'd0,
        W2M_INIT       = 8'd1,
        W2M_COND       = 8'd2,
        W2M_INC        = 8'd3,
        W2M_DONE       = 8'd4,
        RFM_INIT_START = 8'd5,
        RFM_INIT_WAIT  = 8'd6,
        RFM_DRAWING    = 8'd7,
        ERROR          = 8'hFF;

    parameter MEMORY_SIZE = 16'd19200;
    parameter PIXEL_VIRTUAL_SIZE = 16'd4;
    parameter VGA_WIDTH = 16'd640;
    parameter VGA_HEIGHT = 16'd480;
    parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE;
    parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE;

    reg [14:0] idx_location;
    reg flag1;
    reg flag2;
    reg flag3;

    assign LEDR = idx_location[8:0];

    integer k;
    always @(posedge clk or negedge rst) begin    
        if (!rst) begin
            flag1 <= 1'b0;
            flag2 <= 1'b0;
            flag3 <= 1'b0;
            idx_location <= 15'd2180;
            current_location <= 15'd2180;
            prev_location <= 15'd2180;
            current_color <= BLACK_COLOR;
            the_vga_draw_frame_write_mem_address <= 15'd0;
            the_vga_draw_frame_write_mem_data <= BLACK_COLOR;
            the_vga_draw_frame_write_a_pixel <= 1'b0;
            for (k = 0; k < 16; k = k + 1) begin
                tile_colors[k] <= BLACK_COLOR;
            end
        end
        else begin
            current_location <= idx_location;

            if (active_pixels) begin
                if (game_over) begin
                    // Fill entire screen red when game_over is high
                    the_vga_draw_frame_write_mem_address <= x + y * VGA_WIDTH;
                    the_vga_draw_frame_write_mem_data <= RED_COLOR;
                    the_vga_draw_frame_write_a_pixel <= 1'b1;
                end
                else if (x/PIXEL_VIRTUAL_SIZE + (y/PIXEL_VIRTUAL_SIZE)*VIRTUAL_PIXEL_WIDTH == idx_location) begin
                    the_vga_draw_frame_write_mem_address <= idx_location;
                    the_vga_draw_frame_write_mem_data <= WHITE_COLOR;
                    the_vga_draw_frame_write_a_pixel <= 1'b1;
                end
                else if (x/PIXEL_VIRTUAL_SIZE + (y/PIXEL_VIRTUAL_SIZE)*VIRTUAL_PIXEL_WIDTH == prev_location) begin
                    the_vga_draw_frame_write_mem_address <= prev_location;
                    the_vga_draw_frame_write_mem_data <= tile_colors[prev_location % 16];
                    the_vga_draw_frame_write_a_pixel <= 1'b1;
                end
                else if (KEY[1] == 1'b0 && flag1 == 1'b0) begin
                    the_vga_draw_frame_write_mem_address <= idx_location;
                    the_vga_draw_frame_write_mem_data <= GREEN_COLOR;
                    tile_colors[current_tile] <= GREEN_COLOR;
                    the_vga_draw_frame_write_a_pixel <= 1'b1;
                end
                else begin
                    the_vga_draw_frame_write_a_pixel <= 1'b0;
                end
            end
            else begin
                the_vga_draw_frame_write_a_pixel <= 1'b0;
            end

            if (KEY[1] == 1'b0) begin
                flag1 <= 1'b1;
            end
            else begin
                flag1 <= 1'b0;
            end

            if (KEY[2] == 1'b0 && flag2 == 1'b0) begin
                flag2 <= 1'b1;
                prev_location <= idx_location;
                if (SW[8] == 1'b0)
                    idx_location <= idx_location + 15'd2880;
                else
                    idx_location <= idx_location - 15'd2880;
            end
            else if (KEY[2] == 1'b1) begin
                flag2 <= 1'b0;
            end

            if (KEY[3] == 1'b0 && flag3 == 1'b0) begin
                flag3 <= 1'b1;
                prev_location <= idx_location;
                if (SW[8] == 1'b0)
                    idx_location <= idx_location + 15'd26;
                else
                    idx_location <= idx_location - 15'd26;
            end
            else if (KEY[3] == 1'b1) begin
                flag3 <= 1'b0;
            end
        end
    end

endmodule
