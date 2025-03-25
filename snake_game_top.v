`include "snake/number_generator.v"
`include "snake/fruit_generator.v"
`include "snake/collision_detection.v"
`include "button_controller.v"
`include "snake_movement.v"
`include "game_clock_divider.v"
`include "scoreboard.v"

`define COORD_WIDTH 11
`define MAX_LENGTH 63
`define LENGTH_WIDTH 6
`define DISPLAY_WIDTH 136
`define DISPLAY_HEIGHT 76
`define BLOCK_SIZE 10



module snake_game_top(
    input wire clk,         // FPGA clock (e.g., 100MHz)
    input wire reset,       // Reset button
    input wire btn_up,      // UP button
    input wire btn_down,    // DOWN button
    input wire btn_left,    // LEFT button
    input wire btn_right,   // RIGHT button
    
    // Output signals for display interface
    output wire [`COORD_WIDTH-1:0] snake_head_x,
    output wire [`COORD_WIDTH-1:0] snake_head_y,
    output wire [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] snake_body_flat,
    output wire [`LENGTH_WIDTH-1:0] snake_length,
    output wire [`COORD_WIDTH-1:0] fruit_display_x,
    output wire [`COORD_WIDTH-1:0] fruit_display_y,
    output wire [1:0] fruit_display_type,
    output wire [2:0] lives_display,
    output wire [15:0] score_display,
    output wire [15:0] high_score_display,
    output wire game_over
);
    // Internal signals
    wire game_clock;
    wire [1:0] direction;
    wire [`COORD_WIDTH-1:0] next_head_x, next_head_y;
    wire [2:0] lives_after_collision, lives_after_fruit;
    wire [`LENGTH_WIDTH-1:0] length_after_collision, length_after_fruit;
    wire [`COORD_WIDTH-1:0] new_head_x_after_collision, new_head_y_after_collision;
    wire food_eaten;
    
    // Game state signal
    reg game_over_state;

    // Flattened arrays for snake body
    reg [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] snake_body_x_flat;
    reg [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] snake_body_y_flat;
    wire [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] new_snake_body_x_flat;
    wire [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] new_snake_body_y_flat;
    
    // Current state
    reg [`COORD_WIDTH-1:0] current_head_x;
    reg [`COORD_WIDTH-1:0] current_head_y;
    reg [`LENGTH_WIDTH-1:0] current_length;
    reg [2:0] current_lives;
    
    // Random number generator for various game elements
    wire [23:0] random_number;
    
    // Module instantiations
    
    // Clock divider for game timing
    game_clock_divider clk_div (
        .clk(clk),
        .reset(reset),
        .game_clock(game_clock)
    );
    
    // Button controller for direction input
    button_controller btn_ctrl (
        .clk(clk),
        .reset(reset),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .direction(direction)
    );
    
    // Random number generator
    number_generator rng (
        .clk(clk),
        .reset(reset),
        .random_number(random_number)
    );
    
    // Snake movement logic
    snake_movement move_ctrl (
        .clk(clk),
        .reset(reset),
        .direction(direction),
        .game_clock(game_clock),
        .current_head_x(current_head_x),
        .current_head_y(current_head_y),
        .next_head_x(next_head_x),
        .next_head_y(next_head_y)
    );
    
    // Collision detection
    collision_detection collision_ctrl (
        .clk(clk),
        .reset(reset),
        .snakehead_x(next_head_x),
        .snakehead_y(next_head_y),
        .snakebody_x_flat(snake_body_x_flat),
        .snakebody_y_flat(snake_body_y_flat),
        .snake_length_in(current_length),
        .lives_in(current_lives),
        .lives_out(lives_after_collision),
        .snake_length_out(length_after_collision),
        .new_head_x(new_head_x_after_collision),
        .new_head_y(new_head_y_after_collision)
    );
    
    // Fruit generation and handling
    fruit_generator_counter fruit_ctrl (
        .clk(clk),
        .reset(reset),
        .snakehead_x(current_head_x),
        .snakehead_y(current_head_y),
        .snakebody_x_flat(snake_body_x_flat),
        .snakebody_y_flat(snake_body_y_flat),
        .snake_length_in(current_length),
        .lives_in(current_lives),
        .fruit_x(fruit_display_x),
        .fruit_y(fruit_display_y),
        .food_eaten(food_eaten),
        .fruit_type(fruit_display_type),
        .new_snakebody_x_flat(new_snake_body_x_flat),
        .new_snakebody_y_flat(new_snake_body_y_flat),
        .snake_length_out(length_after_fruit),
        .lives_out(lives_after_fruit)
    );
    
    // Scoreboard module
    scoreboard score_tracker (
        .clk(clk),
        .reset(reset),
        .food_eaten(food_eaten),
        .fruit_type(fruit_display_type),
        .game_over(game_over_state),
        .score(score_display),
        .high_score(high_score_display)
    );
    
    // Game state update logic
    always @(posedge game_clock or posedge reset) begin
        if (reset) begin
            current_head_x <= (`DISPLAY_WIDTH / 2) * `BLOCK_SIZE;
            current_head_y <= (`DISPLAY_HEIGHT / 2) * `BLOCK_SIZE;
            current_length <= 1;
            current_lives <= 3;
            // Initialize snake body - just the head at first
            snake_body_x_flat <= 0;
            snake_body_y_flat <= 0;
            game_over_state <= 0;
        end else begin
            // Check for collision first
            if (lives_after_collision < current_lives) begin
                // Collision occurred, reset snake position and length
                current_head_x <= new_head_x_after_collision;
                current_head_y <= new_head_y_after_collision;
                current_length <= length_after_collision;
                current_lives <= lives_after_collision;
                // Clear body (except new head position)
                snake_body_x_flat <= 0;
                snake_body_y_flat <= 0;
                
                // Check if lives are zero (game over)
                if (lives_after_collision == 0) begin
                    game_over_state <= 1;
                end
            end 
            // Check if food was eaten
            else if (food_eaten) begin
                current_length <= length_after_fruit;
                current_lives <= lives_after_fruit;
                current_head_x <= next_head_x;
                current_head_y <= next_head_y;
                snake_body_x_flat <= new_snake_body_x_flat;
                snake_body_y_flat <= new_snake_body_y_flat;
                game_over_state <= 0;
            end 
            // Normal movement
            else begin
                current_head_x <= next_head_x;
                current_head_y <= next_head_y;
                // Shift the snake body
                // This would be handled by updating the flattened snake body arrays
                // Note: In a real implementation, this would update all segments
                snake_body_x_flat <= new_snake_body_x_flat;
                snake_body_y_flat <= new_snake_body_y_flat;
                game_over_state <= 0;
            end
        end
    end
    
    // Connect outputs
    assign snake_head_x = current_head_x;
    assign snake_head_y = current_head_y;
    assign snake_body_flat = snake_body_x_flat; // In a real implementation, you might need to combine x and y
    assign snake_length = current_length;
    assign lives_display = current_lives;
    assign game_over = game_over_state;

endmodule
