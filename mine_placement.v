module mine_placement (
    input wire clk,               
    input wire rst,               
    input wire [3:0] sw,          // SW[3:0] for binary mine count (1-15)
    input wire init_game,         
    input wire [14:0] current_location,
    output reg [15:0] mine_map,   
    output reg placement_done    
);

    reg [3:0] mine_count;
    reg [4:0] lfsr;
    wire feedback;
    
    // Convert switch input to number of mines (1-15)
    wire [3:0] desired_mines = (sw == 4'b0000) ? 4'b0001 : sw;
    
    assign feedback = lfsr[4] ^ lfsr[2];
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            lfsr <= 5'h1F;
            mine_count <= 4'b0;
            mine_map <= 16'b0;
            placement_done <= 1'b0;
        end
        else if (init_game && !placement_done) begin
            if (mine_count < desired_mines) begin
                lfsr <= {lfsr[3:0], feedback};
                
                if (!mine_map[lfsr[3:0]] && lfsr[3:0] < 16) begin
                    mine_map[lfsr[3:0]] <= 1'b1;
                    mine_count <= mine_count + 1'b1;
                end
            end
            else begin
                placement_done <= 1'b1;
            end
        end
        else if (!init_game) begin
            placement_done <= 1'b0;
            mine_count <= 4'b0;
            mine_map <= 16'b0;
        end
    end

endmodule
