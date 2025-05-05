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

    // Define game status constants to match those in game_status_control
    localparam RESTART = 2'b00;
    localparam START = 2'b01;
    localparam PLAY = 2'b10;
    localparam DIE = 2'b11;

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
	wire hit_min_length; // New wire for minimum snake length hit
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
	
	// Team management signals
	reg [1:0] current_team_reg;
	reg [7:0] team1_score_reg;
	reg [7:0] team2_score_reg;
	reg       game_complete_reg;
	reg       team_select_done;
	
	wire [1:0] current_team;
	wire [7:0] team1_score;
	wire [7:0] team2_score;
	wire       game_complete;
	
	assign current_team = current_team_reg;
	assign team1_score = team1_score_reg;
	assign team2_score = team2_score_reg;
	assign game_complete = game_complete_reg;

	wire rst_n;
	assign rst_n = ~rst;

	wire clk_4Hz;
	wire [11:0] VGA_reward;
	
	// Add a new wire for score reset when switching players
	wire score_reset;

	// Team selection and scoring logic
	always @(posedge clk or negedge rst_n) begin
	    if (!rst_n) begin
	        current_team_reg <= 2'd1; // Start with team 1
	        team1_score_reg <= 8'd0;
	        team2_score_reg <= 8'd0;
	        game_complete_reg <= 1'b0;
	        team_select_done <= 1'b0;
	    end
	    else begin
	        // Team selection on START screen
	        if (game_status == START && !team_select_done) begin
	            // Left/Right buttons select Team 1
	            if (left_key_press || right_key_press) begin
	                current_team_reg <= 2'd1; // Select team 1
	            end
	            // Up/Down buttons select Team 2
	            else if (up_key_press || down_key_press) begin
	                current_team_reg <= 2'd2; // Select team 2
	            end
	            
	            // Any button press confirms selection after team is highlighted
	            if ((current_team_reg == 2'd1 || current_team_reg == 2'd2) && 
	                (left_key_press || right_key_press || up_key_press || down_key_press)) begin
	                team_select_done <= 1'b1;
	            end
	        end
	        
	        // When first team's game ends (DIE state), save their score
	        if (game_status == DIE) begin
	            if (current_team_reg == 2'd1 && !game_complete_reg) begin
	                team1_score_reg <= score;
	                
	                // After delay, prepare for team 2
	                if (die_flash) begin // Use die_flash as timing reference
	                    current_team_reg <= 2'd2;
	                    team_select_done <= 1'b0; // Allow re-selection for team 2
	                end
	            end
	            else if (current_team_reg == 2'd2) begin
	                team2_score_reg <= score;
	                game_complete_reg <= 1'b1; // Both teams have played
	            end
	        end
	        
	        // Reset team selection when restarting game
	        if (game_status == RESTART) begin
	            if (game_complete_reg) begin
	                // Don't reset if both teams have played - keep showing results
	            end
	            else begin
	                team_select_done <= 1'b0;
	            end
	        end
	    end
	end
	
	// Generate score_reset signal when switching from player 1 to player 2
	assign score_reset = (game_status == DIE && current_team_reg == 2'd1 && die_flash) || 
	                     (game_status == START && current_team_reg == 2'd2 && !team_select_done);

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
		.hit_min_length(hit_min_length), // Connect new signal
		.die_flash(die_flash),
		.restart(restart),
		.game_complete(game_complete)		
	);
	
	apple_generator u_apple_generator (
        .clk(clk),
		.rst(rst_n),
		.apple_x(apple_x),
		.apple_y(apple_y),
		.head_x(head_x),
		.head_y(head_y),
		.score(score),
		.add_cube(add_cube),
		.score_reset(score_reset), // Connect the score_reset signal here
		.reduce_length(reduce_length) // New connection for mine hit
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
		.cube_num(cube_num),
		.hit_body(hit_body),
		.hit_wall(hit_wall),
		.hit_min_length(hit_min_length), // Connect new signal
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
		.score(score),
		// Add team-related connections
		.team1_score(team1_score),
		.team2_score(team2_score),
		.current_team(current_team),
		.game_complete(game_complete),
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