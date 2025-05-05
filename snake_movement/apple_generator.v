module apple_generator
(
    input clk,
    input rst,
    input [5:0] head_x,
    input [4:0] head_y,
    input score_reset,  
    input reduce_length, 
    
    output reg [5:0] apple_x,
    output reg [4:0] apple_y,
    output reg add_cube,
    output reg [7:0] score
);
    
    reg gen_apple;
    reg gen_apple_pre;
    
    reg [31:0] cnt;
    reg [31:0] rand_x;
    reg [31:0] rand_y;
    
    // boundary condition for walls
    parameter MIN_X = 6'd2;    
    parameter MAX_X = 6'd37;   
    parameter MIN_Y = 5'd2;    
    parameter MAX_Y = 5'd27;   
    
    // Apple collision detection
    wire apple_eaten;
    assign apple_eaten = (head_x == apple_x && head_y == apple_y);
    
    // Score handling
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            score <= 8'd0;
            add_cube <= 0;
        end
        else if (score_reset) begin
            score <= 8'd0;
            add_cube <= 0;
        end
        else begin
            if (apple_eaten) begin
                score <= score + 1;
                add_cube <= 1;
            end
            else if (reduce_length && score > 0) begin
                score <= score - 1;
                add_cube <= 0;
            end
            else begin
                add_cube <= 0;
            end
        end
    end
    
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            gen_apple <= 1;  
            gen_apple_pre <= 0;
            
            apple_x <= MIN_X + 10;
            apple_y <= MIN_Y + 5;
        end
        else begin
            if (apple_eaten && !gen_apple_pre) begin
                gen_apple_pre <= 1;
                gen_apple <= 1;  
            end
            else begin
                gen_apple <= 0;
            end

            if (!apple_eaten && gen_apple_pre) begin
                gen_apple_pre <= 0;
            end
            
            if (gen_apple == 1) begin
                apple_x <= MIN_X + (rand_x % (MAX_X - MIN_X + 1));
                apple_y <= MIN_Y + (rand_y % (MAX_Y - MIN_Y + 1));
            end
        end
    end
    
    // Random number generation LFSR (linear feedback shift register) algorithm
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 0;
            rand_x <= 32'hABCD1234; 
            rand_y <= 32'h1234ABCD; 
        end
        else begin
            cnt <= cnt + 1;
            
            rand_x <= {rand_x[30:0], rand_x[31] ^ rand_x[21] ^ rand_x[1]} + head_x + cnt[15:0];
            rand_y <= {rand_y[30:0], rand_y[31] ^ rand_y[21] ^ rand_y[1]} + head_y + cnt[20:5];
        end
    end

endmodule
