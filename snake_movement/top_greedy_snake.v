module top_greedy_snake
(
    input clk,
	input rst,
	
	input left,
	input right,
	input up,
	input down,
	output[7:0]	score,

	output hsync,
	output vsync,
	output [11:0]color_out
);


	wire left_key_press;
	wire right_key_press;
	wire up_key_press;
	wire down_key_press;
	wire [1:0]snake;
	wire [9:0]x_pos;
	wire [9:0]y_pos;
	wire [5:0]apple_x;
	wire [4:0]apple_y;
	wire [5:0]head_x;
	wire [5:0]head_y;
	
	wire add_cube;
	wire[1:0]game_status;
	wire hit_wall;
	wire hit_body;
	wire die_flash;
	wire restart;
	wire [6:0]cube_num;

	wire reward_protected;
	wire reward_slowly;
	wire reward_grade;
	wire speedRecover;

	// Mine-related signals
	wire [5:0] mine_x_0, mine_y_0;
	wire [5:0] mine_x_1, mine_y_1;
	wire [5:0] mine_x_2, mine_y_2;
	wire [5:0] mine_x_3, mine_y_3;
	wire [3:0] mine_active;
	wire hit_mine;
	wire reduce_length;

	wire rst_n;
	assign rst_n = ~rst;

	wire clk_4Hz;
	wire [11:0]		VGA_reward;

	clock u_clock
	(
		.clk		(clk),
		.clk_4Hz	(clk_4Hz),
		.clk_8Hz	(),
		.clk_2Hz	()
	);

    game_status_control u_game_status_control (
        .clk(clk),
	    .rst(rst_n),
	    .key1_press(left_key_press),
	    .key2_press(right_key_press),
	    .key3_press(up_key_press),
	    .key4_press(down_key_press),
        .game_status(game_status),
		.hit_wall(hit_wall),
		.hit_body(hit_body),
		.die_flash(die_flash),
		.restart(restart)		
	);
	
	apple_generator u_apple_generator (
        .clk(clk),
		.rst(rst_n),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.head_x(head_x),
		.head_y(head_y),
		.score(score),
		.add_cube(add_cube)	
	);
	
	// Instantiate the mine generator
	mine_generator u_mine_generator (
		.clk(clk),
		.rst(rst_n),
		.game_status(game_status),
		.head_x(head_x),
		.head_y(head_y),
		.mine_x_0(mine_x_0),
		.mine_y_0(mine_y_0),
		.mine_x_1(mine_x_1),
		.mine_y_1(mine_y_1),
		.mine_x_2(mine_x_2),
		.mine_y_2(mine_y_2),
		.mine_x_3(mine_x_3),
		.mine_y_3(mine_y_3),
		.mine_active(mine_active),
		.hit_mine(hit_mine),
		.reduce_length(reduce_length)
	);

	snake_moving u_snake_moving (
	    .clk(clk),
		.rst(rst_n),
		.left_press(left_key_press),
		.right_press(right_key_press),
		.up_press(up_key_press),
		.down_press(down_key_press),
		.snake(snake),
		.x_pos(x_pos),
		.reward_protected(reward_protected),
		.reward_slowly(reward_slowly),
		.y_pos(y_pos),
		.head_x(head_x),
		.head_y(head_y),
		.add_cube(add_cube),
		.game_status(game_status),
		.speedRecover(speedRecover),
		.cube_num(cube_num),
		.hit_body(hit_body),
		.hit_wall(hit_wall),
		.die_flash(die_flash),
		// Mine connections
		.mine_x_0(mine_x_0),
		.mine_y_0(mine_y_0),
		.mine_x_1(mine_x_1),
		.mine_y_1(mine_y_1), 
		.mine_x_2(mine_x_2),
		.mine_y_2(mine_y_2),
		.mine_x_3(mine_x_3),
		.mine_y_3(mine_y_3),
		.mine_active(mine_active),
		.hit_mine(hit_mine),
		.reduce_length(reduce_length)
	);

	vga_control u_vga_control (
		.clk(clk),
		.rst(rst),
		.hsync(hsync),
		.vsync(vsync),
		.snake(snake),
        .color_out(color_out),
		.game_status(game_status),
		.x_pos(x_pos),
		.y_pos(y_pos),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.VGA_reward(VGA_reward),
		.score(score), // Pass score to vga_control
		// Add mine-related connections
		.mine_x_0(mine_x_0),
		.mine_y_0(mine_y_0),
		.mine_x_1(mine_x_1),
		.mine_y_1(mine_y_1), 
		.mine_x_2(mine_x_2),
		.mine_y_2(mine_y_2),
		.mine_x_3(mine_x_3),
		.mine_y_3(mine_y_3),
		.mine_active(mine_active)
	);
	
	buttons u_buttons (
		.clk(clk),
		.rst(rst_n),
		.left(left),
		.right(right),
		.up(up),
		.down(down),
		.left_key_press(left_key_press),
		.right_key_press(right_key_press),
		.up_key_press(up_key_press),
		.down_key_press(down_key_press)		
	);
	
endmodule