module interface_display
(
    input           clk,
    input   [9:0]   x_pos,
    input   [9:0]   y_pos,
    input   [5:0]   apple_x,
    input   [4:0]   apple_y,
    input   [1:0]   snake,
    input   [1:0]   game_status,
    input   [5:0]   mine_x_0,
    input   [5:0]   mine_y_0,
    input   [5:0]   mine_x_1,
    input   [5:0]   mine_y_1,
    input   [5:0]   mine_x_2,
    input   [5:0]   mine_y_2,
    input   [5:0]   mine_x_3,
    input   [5:0]   mine_y_3,
    input   [3:0]   mine_active,
    input   [7:0]   score,     // Current score input
    output reg [11:0]   VGA_data_interface
);

    localparam NONE = 2'b00;
    localparam HEAD = 2'b01;
    localparam BODY = 2'b10;
    localparam WALL = 2'b11;
    localparam HEAD_COLOR = 12'b0000_1111_0000;
    localparam BODY_COLOR = 12'b1111_1111_0000;
    localparam MINE_COLOR = 12'b1111_0000_0000; // Bright red color

    localparam RESTART = 2'b00;
	localparam START = 2'b01;
	localparam PLAY = 2'b10;
	localparam DIE = 2'b11;

    // Parameters for displaying digits
    localparam DIGIT_WIDTH = 24;
    localparam DIGIT_HEIGHT = 32;
    localparam SCORE_X = 280; // X position for score display
    localparam SCORE_Y = 200; // Y position for score display
    localparam SCORE_COLOR = 12'b1111_1111_0000; // Yellow color for score

    // Function to determine if current pixel is part of a specific digit
    function is_digit;
        input [3:0] digit;
        input [4:0] x;
        input [5:0] y;
        begin
            case(digit)
                4'd0: is_digit = (x > 0 && x < DIGIT_WIDTH-1 && (y == 0 || y == DIGIT_HEIGHT-1)) || 
                                ((x == 0 || x == DIGIT_WIDTH-1) && y > 0 && y < DIGIT_HEIGHT-1);
                4'd1: is_digit = (x == DIGIT_WIDTH/2) || (y == DIGIT_HEIGHT-1 && x > DIGIT_WIDTH/4 && x < 3*DIGIT_WIDTH/4);
                4'd2: is_digit = (y == 0 || y == DIGIT_HEIGHT/2 || y == DIGIT_HEIGHT-1) && (x > 0 && x < DIGIT_WIDTH-1) || 
                                 (x == DIGIT_WIDTH-1 && y > 0 && y < DIGIT_HEIGHT/2) || 
                                 (x == 0 && y > DIGIT_HEIGHT/2 && y < DIGIT_HEIGHT-1);
                4'd3: is_digit = (y == 0 || y == DIGIT_HEIGHT/2 || y == DIGIT_HEIGHT-1) && (x > 0 && x < DIGIT_WIDTH-1) || 
                                 (x == DIGIT_WIDTH-1 && y > 0 && y < DIGIT_HEIGHT-1);
                4'd4: is_digit = (x == 0 && y < DIGIT_HEIGHT/2) || (x == DIGIT_WIDTH-1) || 
                                 (y == DIGIT_HEIGHT/2 && x > 0 && x < DIGIT_WIDTH-1);
                4'd5: is_digit = (y == 0 || y == DIGIT_HEIGHT/2 || y == DIGIT_HEIGHT-1) && (x > 0 && x < DIGIT_WIDTH-1) || 
                                 (x == 0 && y > 0 && y < DIGIT_HEIGHT/2) || 
                                 (x == DIGIT_WIDTH-1 && y > DIGIT_HEIGHT/2 && y < DIGIT_HEIGHT-1);
                4'd6: is_digit = (y == 0 || y == DIGIT_HEIGHT/2 || y == DIGIT_HEIGHT-1) && (x > 0 && x < DIGIT_WIDTH-1) || 
                                 (x == 0 && y > 0 && y < DIGIT_HEIGHT-1) || 
                                 (x == DIGIT_WIDTH-1 && y > DIGIT_HEIGHT/2 && y < DIGIT_HEIGHT-1);
                4'd7: is_digit = (y == 0 && x > 0) || (x == DIGIT_WIDTH-1 && y > 0);
                4'd8: is_digit = (y == 0 || y == DIGIT_HEIGHT/2 || y == DIGIT_HEIGHT-1) && (x > 0 && x < DIGIT_WIDTH-1) || 
                                 ((x == 0 || x == DIGIT_WIDTH-1) && y > 0 && y < DIGIT_HEIGHT-1);
                4'd9: is_digit = (y == 0 || y == DIGIT_HEIGHT/2 || y == DIGIT_HEIGHT-1) && (x > 0 && x < DIGIT_WIDTH-1) || 
                                 (x == 0 && y > 0 && y < DIGIT_HEIGHT/2) || 
                                 (x == DIGIT_WIDTH-1 && y > 0 && y < DIGIT_HEIGHT-1);
                default: is_digit = 0;
            endcase
        end
    endfunction

    wire	[2:0]		dout_pic;
    reg		[16:0]	addr_pic;

    reg [3:0] lox;
    reg [3:0] loy; 
    
    // Wire declarations for score digits
    wire [3:0] tens;
    wire [3:0] ones;
    
    // Calculate score digits
    assign tens = score / 10;
    assign ones = score % 10;

    always@(posedge clk)
    begin
        lox = x_pos[3:0];
        loy = y_pos[3:0];						
        if(x_pos[9:4] == apple_x && y_pos[9:4] == apple_y)
            case({loy,lox})
                8'b0000_0000:VGA_data_interface = 12'b0000_0000_0000;
                default:VGA_data_interface = 12'b0000_0000_1111;
            endcase
        else if((mine_active[0] && x_pos[9:4] == mine_x_0 && y_pos[9:4] == mine_y_0) ||
                (mine_active[1] && x_pos[9:4] == mine_x_1 && y_pos[9:4] == mine_y_1) ||
                (mine_active[2] && x_pos[9:4] == mine_x_2 && y_pos[9:4] == mine_y_2) ||
                (mine_active[3] && x_pos[9:4] == mine_x_3 && y_pos[9:4] == mine_y_3))
            case({loy,lox})
                8'b0000_0000:VGA_data_interface = 12'b0000_0000_0000;
                default:VGA_data_interface = MINE_COLOR;
            endcase						
        else if(snake == NONE)
            VGA_data_interface = 12'b0000_0000_0000;
        else if(snake == WALL)
            VGA_data_interface = 12'b1111_0000_0000;
        else if(snake == HEAD|snake == BODY) begin
            case({lox,loy})
                8'b0000_0000:VGA_data_interface = 12'b0000_0000_0000;
                default:VGA_data_interface = (snake == HEAD) ?  HEAD_COLOR : BODY_COLOR;
            endcase
        end

        if(game_status == START)
        begin
            if(x_pos > 130 && x_pos <= 510 && y_pos > 120 && y_pos <= 300)
            begin
                addr_pic <= (x_pos - 130)  + 380 * (y_pos - 120) ;
                VGA_data_interface <= {dout_pic[0],dout_pic[0],dout_pic[0],dout_pic[0],dout_pic[1],dout_pic[1],dout_pic[1],dout_pic[1],dout_pic[2],dout_pic[2],dout_pic[2],dout_pic[2]};
            end
            else
                VGA_data_interface <= 12'b0000_0000_0000;
        end
        
        // Display score when game is over (DIE state)
        if(game_status == DIE) begin
            // Display "GAME OVER" text
            if(y_pos >= 120 && y_pos < 160 && x_pos >= 220 && x_pos < 420) begin
                VGA_data_interface = 12'b1111_0000_0000; // Red color for Game Over
            end
            
            // Display "SCORE:" text
            if(y_pos >= SCORE_Y && y_pos < SCORE_Y+32 && x_pos >= SCORE_X-100 && x_pos < SCORE_X-10) begin
                VGA_data_interface = SCORE_COLOR;
            end
            
            // Display score digits
            if(y_pos >= SCORE_Y && y_pos < SCORE_Y+DIGIT_HEIGHT) begin
                // Display tens digit
                if(x_pos >= SCORE_X && x_pos < SCORE_X+DIGIT_WIDTH) begin
                    if(is_digit(tens, x_pos-SCORE_X, y_pos-SCORE_Y))
                        VGA_data_interface = SCORE_COLOR;
                end
                // Display ones digit
                else if(x_pos >= SCORE_X+DIGIT_WIDTH+5 && x_pos < SCORE_X+2*DIGIT_WIDTH+5) begin
                    if(is_digit(ones, x_pos-(SCORE_X+DIGIT_WIDTH+5), y_pos-SCORE_Y))
                        VGA_data_interface = SCORE_COLOR;
                end
            end
        end
        
        // Display current score during gameplay
        if(game_status == PLAY) begin
            // Display small "SCORE:" indicator in top left
            if(y_pos >= 20 && y_pos < 40 && x_pos >= 20 && x_pos < 80) begin
                VGA_data_interface = 12'b1111_1111_1111; // White for score label
            end
            
            // Display current score digits
            if(y_pos >= 20 && y_pos < 20+DIGIT_HEIGHT/2) begin
                // Display tens digit (scaled down)
                if(x_pos >= 90 && x_pos < 90+DIGIT_WIDTH/2) begin
                    if(is_digit(tens, (x_pos-90)*2, (y_pos-20)*2))
                        VGA_data_interface = 12'b1111_1111_1111; // White
                end
                // Display ones digit (scaled down)
                else if(x_pos >= 90+DIGIT_WIDTH/2+3 && x_pos < 90+DIGIT_WIDTH+3) begin
                    if(is_digit(ones, (x_pos-(90+DIGIT_WIDTH/2+3))*2, (y_pos-20)*2))
                        VGA_data_interface = 12'b1111_1111_1111; // White
                end
            end
        end
    end
endmodule