module score_module (
    input wire clk,
    input wire rst,
    input wire [3:0] mine_count,    // Number of mines on board (0-15)
    input wire tile_revealed,        // Pulse high when safe tile is revealed
    input wire game_over,           // High when mine is hit
    input wire cash_out,            // SW[9] for cashing out
    output reg [23:0] score,        // 24-bit score output for six digits
    output reg game_won             // High when player cashes out successfully
);

    // Parameters for score calculation
    parameter BASE_POINTS = 24'd100;     // Base points per reveal
    parameter MULTIPLIER = 24'd50;       // 50% increase per mine (0.2 * 100)

    // Temporary calculation registers
    reg [23:0] points_per_reveal;
    reg cashed_out;  // Internal register to track cash out state

    // Calculate points per reveal based on mine count
    always @(mine_count) begin
        points_per_reveal = BASE_POINTS + ((mine_count * MULTIPLIER * BASE_POINTS) / 100);
    end

    // Update score on successful tile reveal, game over, or cash out
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            score <= 24'd0;
            game_won <= 1'b0;
            cashed_out <= 1'b0;
        end
        else if (game_over) begin
            score <= 24'd0;          // Reset score to 0 when mine is hit
            game_won <= 1'b0;
        end
        else if (cash_out && !cashed_out) begin
            cashed_out <= 1'b1;      // Lock in the score
            game_won <= 1'b1;        // Signal successful cash out
        end
        else if (tile_revealed && !cashed_out) begin
            score <= score + points_per_reveal;
        end
    end

endmodule
