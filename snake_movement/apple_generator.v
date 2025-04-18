module apple_generator
(
    input clk,
    input rst,
    input [5:0] head_x,
    input [4:0] head_y,
    input score_reset,  // Reset signal when switching players
    input reduce_length, // New input signal for mine hit
    
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
    
    // Safe boundaries for apple generation (inside the walls)
    parameter MIN_X = 6'd2;    // Stay away from left wall
    parameter MAX_X = 6'd37;   // Stay away from right wall
    parameter MIN_Y = 5'd2;    // Stay away from top wall
    parameter MAX_Y = 5'd27;   // Stay away from bottom wall
    
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
            // Reset score when switching players
            score <= 8'd0;
            add_cube <= 0;
        end
        else begin
            if (apple_eaten) begin
                score <= score + 1;
                add_cube <= 1;
            end
            else if (reduce_length && score > 0) begin
                // Decrease score when mine is hit, but don't go below 0
                score <= score - 1;
                add_cube <= 0;
            end
            else begin
                add_cube <= 0;
            end
        end
    end
    
    // Apple generation state machine
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            gen_apple <= 1;  // Generate initial apple
            gen_apple_pre <= 0;
            
            // Initialize apple position within bounds
            apple_x <= MIN_X + 10;
            apple_y <= MIN_Y + 5;
        end
        else begin
            // Detect apple being eaten
            if (apple_eaten && !gen_apple_pre) begin
                gen_apple_pre <= 1;
                gen_apple <= 1;  // Generate a new apple
            end
            else begin
                gen_apple <= 0;
            end
            
            // Reset state after apple is handled
            if (!apple_eaten && gen_apple_pre) begin
                gen_apple_pre <= 0;
            end
            
            // Generate new apple position when triggered
            if (gen_apple == 1) begin
                apple_x <= MIN_X + (rand_x % (MAX_X - MIN_X + 1));
                apple_y <= MIN_Y + (rand_y % (MAX_Y - MIN_Y + 1));
            end
        end
    end
    
    // Random number generation
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cnt <= 0;
            rand_x <= 32'hABCD1234; // Seed for random generator
            rand_y <= 32'h1234ABCD; // Different seed for Y
        end
        else begin
            cnt <= cnt + 1;
            
            // Improve randomness by combining head position, counter, and previous value
            rand_x <= {rand_x[30:0], rand_x[31] ^ rand_x[21] ^ rand_x[1]} + head_x + cnt[15:0];
            rand_y <= {rand_y[30:0], rand_y[31] ^ rand_y[21] ^ rand_y[1]} + head_y + cnt[20:5];
        end
    end

endmodule
