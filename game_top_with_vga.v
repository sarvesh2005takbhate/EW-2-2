`include "snake_game_top.v"
`include "VGA_controller.v"

module game_top_with_vga(
    input wire clk,         // FPGA clock
    input wire reset,       // Reset button
    input wire btn_up,      // UP button
    input wire btn_down,    // DOWN button
    input wire btn_left,    // LEFT button
    input wire btn_right,   // RIGHT button
    
    // VGA outputs
    output wire hsync,
    output wire vsync,
    output wire [3:0] red,
    output wire [3:0] green,
    output wire [3:0] blue
);
    // Wire connections between snake game and VGA controller
    wire [`COORD_WIDTH-1:0] snake_head_x;
    wire [`COORD_WIDTH-1:0] snake_head_y;
    wire [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] snake_body_flat;
    wire [`LENGTH_WIDTH-1:0] snake_length;
    wire [`COORD_WIDTH-1:0] fruit_x;
    wire [`COORD_WIDTH-1:0] fruit_y;
    wire [1:0] fruit_type;
    wire [2:0] lives;
    wire [15:0] score;
    wire [15:0] high_score;
    wire game_over;
    
    // Instantiate the snake game module
    snake_game_top snake_game(
        .clk(clk),
        .reset(reset),
        .btn_up(btn_up),
        .btn_down(btn_down),
        .btn_left(btn_left),
        .btn_right(btn_right),
        .snake_head_x(snake_head_x),
        .snake_head_y(snake_head_y),
        .snake_body_flat(snake_body_flat),
        .snake_length(snake_length),
        .fruit_display_x(fruit_x),
        .fruit_display_y(fruit_y),
        .fruit_display_type(fruit_type),
        .lives_display(lives),
        .score_display(score),
        .high_score_display(high_score),
        .game_over(game_over)
    );
    
    // Instantiate the VGA controller
    VGA_controller vga_ctrl(
        .clk(clk),
        .reset(reset),
        .snake_head_x(snake_head_x),
        .snake_head_y(snake_head_y),
        .snake_body_flat(snake_body_flat),
        .snake_length(snake_length),
        .fruit_x(fruit_x),
        .fruit_y(fruit_y),
        .fruit_type(fruit_type),
        .lives(lives),
        .score(score),
        .high_score(high_score),
        .game_over(game_over),
        .hsync(hsync),
        .vsync(vsync),
        .red(red),
        .green(green),
        .blue(blue)
    );
    
endmodule
