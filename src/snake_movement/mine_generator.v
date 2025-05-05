module mine_generator(
    input clk,
    input rst,
    
    input [1:0] game_status,
    input [5:0] head_x,
    input [5:0] head_y,
    
    output reg [5:0] mine_x_0,
    output reg [5:0] mine_y_0,
    output reg [5:0] mine_x_1,
    output reg [5:0] mine_y_1,
    output reg [5:0] mine_x_2,
    output reg [5:0] mine_y_2,
    output reg [5:0] mine_x_3,
    output reg [5:0] mine_y_3,
    
    output reg [3:0] mine_active,
    output reg hit_mine,           
    output reg reduce_length        
);

    localparam RESTART = 2'b00;
    localparam START = 2'b01;
    localparam PLAY = 2'b10;

    parameter MINE_INTERVAL = 25_000_000;  
    parameter MINE_RECOVERY = 5_000_000;   
    

    reg [31:0] mine_timer;  
    reg [31:0] random_num;
    reg [1:0] mine_state;
    
    always @(posedge clk) begin
        random_num <= random_num + 1237;  // Different increment than apple for variety
    end
    
    // Main mine control logic
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            // Initialize mines to off-screen
            mine_x_0 <= 0;
            mine_y_0 <= 0;
            mine_x_1 <= 0;
            mine_y_1 <= 0;
            mine_x_2 <= 0;
            mine_y_2 <= 0;
            mine_x_3 <= 0;
            mine_y_3 <= 0;
            mine_active <= 4'b0000;
            mine_timer <= 0;
            hit_mine <= 0;
            mine_state <= 0;
            reduce_length <= 0;
        end
        else if(game_status == RESTART) begin
            // Reset mines
            mine_x_0 <= 0;
            mine_y_0 <= 0;
            mine_x_1 <= 0;
            mine_y_1 <= 0;
            mine_x_2 <= 0;
            mine_y_2 <= 0;
            mine_x_3 <= 0;
            mine_y_3 <= 0;
            mine_active <= 4'b0000;
            mine_timer <= 0;
            hit_mine <= 0;
            mine_state <= 0;
            reduce_length <= 0;
        end
        else if(game_status == PLAY) begin
            mine_timer <= mine_timer + 1;
            
            // Place a new mine periodically if not all mines are active
            if(mine_timer >= MINE_INTERVAL && !(&mine_active)) begin
                mine_timer <= 0;
                case(mine_active)
                    4'b0000: begin
                        mine_active[0] <= 1;
                        // Random position (use bits of counter for pseudo-random)
                        mine_x_0 <= (random_num[9:4] % 37) + 1; // 1-37 range (avoid walls)
                        mine_y_0 <= (random_num[15:10] % 27) + 1; // 1-27 range (avoid walls)
                    end
                    4'b0001: begin
                        mine_active[1] <= 1;
                        mine_x_1 <= (random_num[12:7] % 37) + 1;
                        mine_y_1 <= (random_num[18:13] % 27) + 1;
                    end
                    4'b0011: begin
                        mine_active[2] <= 1;
                        mine_x_2 <= (random_num[15:10] % 37) + 1;
                        mine_y_2 <= (random_num[21:16] % 27) + 1;
                    end
                    4'b0111: begin
                        mine_active[3] <= 1;
                        mine_x_3 <= (random_num[18:13] % 37) + 1;
                        mine_y_3 <= (random_num[24:19] % 27) + 1;
                    end
                    default: ; 
                endcase
            end
            
            if(!hit_mine) begin
                if((mine_active[0] && head_x == mine_x_0 && head_y == mine_y_0) ||
                   (mine_active[1] && head_x == mine_x_1 && head_y == mine_y_1) ||
                   (mine_active[2] && head_x == mine_x_2 && head_y == mine_y_2) ||
                   (mine_active[3] && head_x == mine_x_3 && head_y == mine_y_3)) begin
                    
                    hit_mine <= 1;
                    mine_timer <= 0;
                    mine_state <= 0;
                    reduce_length <= 1;
                    
                    // Deactivate the mine that was hit
                    if(head_x == mine_x_0 && head_y == mine_y_0)
                        mine_active[0] <= 0;
                    else if(head_x == mine_x_1 && head_y == mine_y_1)
                        mine_active[1] <= 0;
                    else if(head_x == mine_x_2 && head_y == mine_y_2)
                        mine_active[2] <= 0;
                    else if(head_x == mine_x_3 && head_y == mine_y_3)
                        mine_active[3] <= 0;
                end
            end
            else begin
                if(mine_state == 0) begin
                    mine_state <= 1;
                    reduce_length <= 0;  
                end
                else if(mine_state == 1 && mine_timer >= MINE_RECOVERY) begin
                    hit_mine <= 0; 
                    mine_state <= 0;
                end
            end
        end
    end
endmodule
