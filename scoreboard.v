module scoreboard (
    input wire clk,
    input wire reset,
    input wire food_eaten,
    input wire [1:0] fruit_type,
    input wire game_over,
    output reg [15:0] score,
    output reg [15:0] high_score
);

    // Scoring constants based on fruit type
    // 01: increase length (10 points)
    // 10: decrease length (5 points)
    // 11: extra life (20 points)
    
    // Update score based on fruit consumption
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            score <= 16'd0;
            // High score is not reset
        end else if (game_over) begin
            // Update high score if current score is higher
            if (score > high_score) begin
                high_score <= score;
            end
            // Reset current score
            score <= 16'd0;
        end else if (food_eaten) begin
            // Increase score based on fruit type
            case (fruit_type)
                2'b01: score <= score + 16'd10;  // Increase length fruit
                2'b10: score <= score + 16'd5;   // Decrease length fruit
                2'b11: score <= score + 16'd20;  // Extra life fruit
                default: score <= score + 16'd1; // Default case
            endcase
        end
    end
    
    // Initialize high score to 0 at first reset
    initial begin
        high_score = 16'd0;
    end
    
endmodule
