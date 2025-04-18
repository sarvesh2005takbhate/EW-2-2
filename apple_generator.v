module apple_generator(
    input clk,
    input rst,
    input [5:0] head_x,
    input [4:0] head_y,
    input score_reset, // New input to reset score when switching players
    output [5:0] apple_x,
    output [4:0] apple_y,
    output reg [7:0] score,
    output add_cube
);
    
    // Apple position registers
    reg [5:0] apple_x_reg;
    reg [4:0] apple_y_reg;
    assign apple_x = apple_x_reg;
    assign apple_y = apple_y_reg;
    
    // Random seed registers for apple position
    reg [5:0] random_x;
    reg [4:0] random_y;
    
    // Detection for when snake eats apple
    assign add_cube = (head_x == apple_x) && (head_y == apple_y);
    
    // Update random seed on every clock cycle
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            random_x <= 6'd0;
            random_y <= 5'd0;
        end
        else begin
            random_x <= random_x + 6'd1;
            if(random_x == 6'd39)
                random_x <= 6'd0;
            
            random_y <= random_y + 5'd1;
            if(random_y == 5'd29)
                random_y <= 5'd0;
        end
    end
    
    // Update apple position when eaten
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            apple_x_reg <= 6'd20;
            apple_y_reg <= 5'd15;
        end
        else if(add_cube) begin
            apple_x_reg <= random_x;
            apple_y_reg <= random_y;
        end
    end
    
    // Score counter with reset capability
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            score <= 8'd0;
        end
        else if(score_reset) begin
            // Reset score when switching to player 2
            score <= 8'd0;
        end
        else if(add_cube) begin
            // Increment score when snake eats apple
            score <= score + 8'd1;
        end
    end
    
endmodule
