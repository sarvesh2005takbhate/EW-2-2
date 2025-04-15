module apple_generator
(
	input clk,
	input rst,
	
	input [5:0]head_x,
	input [5:0]head_y,
	output reg [5:0]apple_x,
	output reg [4:0]apple_y,
	output reg [7:0]score, //number of apples the snake has eaten
	output reg add_cube //this is used to increase the length of the snake
);
	reg [31:0]clk_cnt;
	reg [10:0]random_num; //to generate position of apple 
	reg apple_eaten_state; //state to track if current apple has been counted
	always@(posedge clk)  //here no reset because we don't want to reset the random number generator
	begin
		random_num <= random_num + 998; 
	end	
	
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			score <= 8'h00;
			apple_eaten_state <= 0;
		end
		else begin
			case(apple_eaten_state)
			0: // WAITING state
			begin
				if(add_cube) begin
					score <= score + 8'h01; // Increment score once when apple is eaten
					apple_eaten_state <= 1;   // Move to "already counted" state
				end
			end
			1: // ALREADY_COUNTED state
			begin
				if(!add_cube)
					apple_eaten_state <= 0;   // Return to waiting state when apple collision ends
			end
			endcase
		end
	end
	
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			clk_cnt <= 0;
			apple_x <= 15; //this is the start position of apple 
			apple_y <= 15;
			add_cube <= 0;
		end
		else begin
			clk_cnt <= clk_cnt+1;
			if(clk_cnt == 250_000) begin //this is for clk collisions to check the position of apple after every 0.5 sec
				clk_cnt <= 0;
				if(apple_x == head_x && apple_y == head_y) 
				begin
					add_cube <= 1; //if the head of snake meets apple then we increase the length of snake and generate apple at random poistion
					apple_x <= {1'b0, (random_num[9:5] == 0 ? 2 : random_num[9:5])};
					apple_y <= (random_num[4:0] > 15) ? (random_num[4:0] - 15) : (random_num[4:0] == 0) ? 1:random_num[4:0];
				end
				else
					add_cube <= 0; //if not meet then don't add cube
			end
		end
	end
endmodule