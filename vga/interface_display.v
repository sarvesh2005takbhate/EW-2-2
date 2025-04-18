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
    input   [7:0]   score,
    input   [7:0]   team1_score,
    input   [7:0]   team2_score,
    input   [1:0]   current_team,
    input           game_complete,
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

    localparam TEAM1_COLOR = 12'b1111_0000_0000; // Red
    localparam TEAM2_COLOR = 12'b0000_0000_1111; // Blue
    localparam WINNER_COLOR = 12'b1111_1111_0000; // Yellow

    // Parameters for displaying digits
    localparam DIGIT_WIDTH = 24;
    localparam DIGIT_HEIGHT = 32;
    localparam SCORE_X = 280; // X position for score display
    localparam SCORE_Y = 200; // Y position for score display
    localparam SCORE_COLOR = 12'b1111_1111_0000; // Yellow color for score

    // Updated parameters for text positioning with better spacing
    parameter TITLE_X = 240;  // Center "SNAKE GAME" horizontally
    parameter TITLE_Y = 80;   // Position near the top
    parameter PLAYER1_X = 190; // Position for P1 indicator
    parameter PLAYER2_X = 410; // Position for P2 indicator
    parameter PLAYER_Y = 140; // Below the title

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

    // Helper function to determine who won
    function [1:0] get_winner;
        input [7:0] team1_score;
        input [7:0] team2_score;
        begin
            if (team1_score > team2_score)
                get_winner = 2'd1; // Team 1 wins
            else if (team2_score > team1_score)
                get_winner = 2'd2; // Team 2 wins
            else
                get_winner = 2'd0; // Tie
        end
    endfunction

    wire	[2:0]		dout_pic;
    reg		[16:0]	addr_pic;

    reg [3:0] lox;
    reg [3:0] loy; 
    
    // Wire declarations for score digits
    wire [3:0] tens;
    wire [3:0] ones;
    wire [3:0] team1_tens, team1_ones;
    wire [3:0] team2_tens, team2_ones;
    wire [1:0] winner;
    
    // Calculate score digits
    assign tens = score / 10;
    assign ones = score % 10;
    assign team1_tens = team1_score / 10;
    assign team1_ones = team1_score % 10;
    assign team2_tens = team2_score / 10;
    assign team2_ones = team2_score % 10;
    assign winner = get_winner(team1_score, team2_score);

    wire [7:0] pixel_data;
    reg  [7:0] current_char;
    reg  [2:0] font_row;
    reg  [2:0] font_col;

    // Font ROM instance
    font_rom font (
        .char(current_char),
        .row(font_row),
        .pixels(pixel_data)
    );

    always@(posedge clk)
    begin
        lox = x_pos[3:0];
        loy = y_pos[3:0];						
        
        // Default to black
        VGA_data_interface = 12'b0000_0000_0000;

        // Only show the SNAKE GAME title on the START screen
        if (game_status == START && !game_complete && 
            y_pos >= TITLE_Y && y_pos < TITLE_Y + 16) begin
            font_row = y_pos - TITLE_Y;
            if (font_row < 8) begin
                case ((x_pos - TITLE_X) / 8)
                    0: current_char = "S";
                    1: current_char = "N";
                    2: current_char = "A";
                    3: current_char = "K";
                    4: current_char = "E";
                    5: current_char = " ";
                    6: current_char = "G";
                    7: current_char = "A";
                    8: current_char = "M";
                    9: current_char = "E";
                    default: current_char = " ";
                endcase

                // Only process pixels within the text range
                if (x_pos >= TITLE_X && x_pos < TITLE_X + 10*8) begin
                    font_col = x_pos[2:0];  // 0 to 7
                    if (pixel_data[7 - font_col])
                        VGA_data_interface = 12'b1111_1111_1111;  // white text
                end
            end
        end
        
        // Display "P1" and "P2" indicators with proper separation
        else if (game_status == START && y_pos >= PLAYER_Y && y_pos < PLAYER_Y + 16) begin
            font_row = y_pos - PLAYER_Y;
            
            // P1 text (left side)
            if (x_pos >= PLAYER1_X && x_pos < PLAYER1_X + 16) begin
                case ((x_pos - PLAYER1_X) / 8)
                    0: current_char = "P";
                    1: current_char = "1";
                    default: current_char = " ";
                endcase
                font_col = x_pos[2:0];
                if (pixel_data[7 - font_col])
                    VGA_data_interface = TEAM1_COLOR;  // red for P1
            end
            
            // P2 text (right side) - Make sure this is always rendered regardless of current_team
            else if (x_pos >= PLAYER2_X && x_pos < PLAYER2_X + 16) begin
                case ((x_pos - PLAYER2_X) / 8)
                    0: current_char = "P";
                    1: current_char = "2";
                    default: current_char = " ";
                endcase
                font_col = x_pos[2:0];
                if (pixel_data[7 - font_col])
                    VGA_data_interface = TEAM2_COLOR;  // blue for P2
            end
        end
        
        // Regular display logic continues
        else if(x_pos[9:4] == apple_x && y_pos[9:4] == apple_y) begin
            case({loy,lox})
                8'b0000_0000: VGA_data_interface = 12'b0000_0000_0000;
                default: VGA_data_interface = 12'b0000_0000_1111;
            endcase
        end
        // Display for mines
        else if((mine_active[0] && x_pos[9:4] == mine_x_0 && y_pos[9:4] == mine_y_0) ||
                (mine_active[1] && x_pos[9:4] == mine_x_1 && y_pos[9:4] == mine_y_1) ||
                (mine_active[2] && x_pos[9:4] == mine_x_2 && y_pos[9:4] == mine_y_2) ||
                (mine_active[3] && x_pos[9:4] == mine_x_3 && y_pos[9:4] == mine_y_3)) begin
            case({loy,lox})
                8'b0000_0000: VGA_data_interface = 12'b0000_0000_0000;
                default: VGA_data_interface = MINE_COLOR;
            endcase
        end
        else if(snake == NONE)
            VGA_data_interface = 12'b0000_0000_0000;
        else if(snake == WALL)
            VGA_data_interface = 12'b1111_0000_0000;
        else if(snake == HEAD|snake == BODY) begin
            case({lox,loy})
                8'b0000_0000: VGA_data_interface = 12'b0000_0000_0000;
                default: VGA_data_interface = (snake == HEAD) ? 
                        (current_team == 2'd1 ? TEAM1_COLOR : TEAM2_COLOR) : // Color head based on team
                        (current_team == 2'd1 ? 12'b1010_0000_0000 : 12'b0000_0000_1010); // Lighter body based on team
            endcase
        end

        // START screen with team selection - updating to work with font rendering
        if(game_status == START && !game_complete)
        begin
            // Don't clear background completely to allow font to display
            if (!(y_pos >= TITLE_Y && y_pos < TITLE_Y + 16) && 
                !(y_pos >= PLAYER_Y && y_pos < PLAYER_Y + 16 && 
                ((x_pos >= PLAYER1_X && x_pos < PLAYER1_X + 16) || 
                (x_pos >= PLAYER2_X && x_pos < PLAYER2_X + 16)))) begin
                
                VGA_data_interface = 12'b0000_0000_0000;
            end
            
            // Display Team 1 box (left)
            if(y_pos >= 160 && y_pos < 240 && x_pos >= 150 && x_pos < 270) begin
                if(y_pos == 160 || y_pos == 239 || x_pos == 150 || x_pos == 269) begin
                    VGA_data_interface = TEAM1_COLOR;
                end
                else if(y_pos >= 190 && y_pos < 210 && x_pos >= 180 && x_pos < 240) begin
                    VGA_data_interface = TEAM1_COLOR;
                end
            end
            
            // Don't redraw "P1" - handled by font rendering
            
            // Display Team 2 box (right)
            if(y_pos >= 160 && y_pos < 240 && x_pos >= 370 && x_pos < 490) begin
                if(y_pos == 160 || y_pos == 239 || x_pos == 370 || x_pos == 489) begin
                    VGA_data_interface = TEAM2_COLOR;
                end
                else if(y_pos >= 190 && y_pos < 210 && x_pos >= 400 && x_pos < 460) begin
                    VGA_data_interface = TEAM2_COLOR;
                end
            end
            
            // Don't redraw "P2" - handled by font rendering
            
            // Display control instructions text
            if(y_pos >= 280 && y_pos < 300) begin
                // "USE LEFT/RIGHT FOR TEAM 1"
                if(x_pos >= 150 && x_pos < 340) begin
                    VGA_data_interface = TEAM1_COLOR;
                end
                // "USE UP/DOWN FOR TEAM 2"
                else if(x_pos >= 350 && x_pos < 540) begin
                    VGA_data_interface = TEAM2_COLOR;
                end
            end
            
            // Display "PRESS ANY BUTTON TO CONFIRM" text
            if(y_pos >= 320 && y_pos < 340 && x_pos >= 170 && x_pos < 470) begin
                VGA_data_interface = 12'b1111_1111_1111; // White
            end
            
            // Highlight current selection with a clearer indicator
            if(current_team == 2'd1) begin
                if(y_pos >= 250 && y_pos < 270 && x_pos >= 180 && x_pos < 240) begin
                    VGA_data_interface = 12'b1111_1111_0000; // Yellow selection indicator
                end
            end
            else if(current_team == 2'd2) begin
                if(y_pos >= 250 && y_pos < 270 && x_pos >= 400 && x_pos < 460) begin
                    VGA_data_interface = 12'b1111_1111_0000; // Yellow selection indicator
                end
            end
        end

        // Display who's playing currently while in play mode
        else if(game_status == PLAY) begin
            // Display current team indicator in top left
            if(y_pos >= 10 && y_pos < 30) begin
                // Show "P1" or "P2" based on current team
                if(x_pos >= 10 && x_pos < 50) begin
                    if(current_team == 2'd1)
                        VGA_data_interface = TEAM1_COLOR; // P1 in red
                    else
                        VGA_data_interface = TEAM2_COLOR; // P2 in blue
                end
            end
        end
        // Results screen when both teams have played
        else if(game_complete) begin
            // Display "GAME OVER" text
            if(y_pos >= 100 && y_pos < 140 && x_pos >= 220 && x_pos < 420) begin
                VGA_data_interface = 12'b1111_0000_0000; // Red
            end
            
            // Display "WINNER:" text
            if(y_pos >= 180 && y_pos < 200 && x_pos >= 220 && x_pos < 320) begin
                VGA_data_interface = WINNER_COLOR;
            end
            
            // Display winner based on scores
            if(y_pos >= 200 && y_pos < 240) begin
                if(winner == 2'd1 && x_pos >= 330 && x_pos < 420) begin
                    VGA_data_interface = TEAM1_COLOR;
                end
                else if(winner == 2'd2 && x_pos >= 330 && x_pos < 420) begin
                    VGA_data_interface = TEAM2_COLOR;
                end
                else if(winner == 2'd0 && x_pos >= 330 && x_pos < 380) begin
                    VGA_data_interface = 12'b1111_1111_1111; // White for tie
                end
            end
            
            // Display scores
            // Team 1 score
            if(y_pos >= 280 && y_pos < 310) begin
                if(x_pos >= 200 && x_pos < 270) begin
                    VGA_data_interface = TEAM1_COLOR; // "TEAM 1:"
                end
                
                // Score digits for team 1
                if(x_pos >= 290 && x_pos < 290+DIGIT_WIDTH) begin
                    if(is_digit(team1_tens, x_pos-290, y_pos-280))
                        VGA_data_interface = TEAM1_COLOR;
                end
                if(x_pos >= 290+DIGIT_WIDTH+5 && x_pos < 290+2*DIGIT_WIDTH+5) begin
                    if(is_digit(team1_ones, x_pos-(290+DIGIT_WIDTH+5), y_pos-280))
                        VGA_data_interface = TEAM1_COLOR;
                end
            end
            
            // Team 2 score
            if(y_pos >= 320 && y_pos < 350) begin
                if(x_pos >= 200 && x_pos < 270) begin
                    VGA_data_interface = TEAM2_COLOR; // "TEAM 2:"
                end
                
                // Score digits for team 2
                if(x_pos >= 290 && x_pos < 290+DIGIT_WIDTH) begin
                    if(is_digit(team2_tens, x_pos-290, y_pos-320))
                        VGA_data_interface = TEAM2_COLOR;
                end
                if(x_pos >= 290+DIGIT_WIDTH+5 && x_pos < 290+2*DIGIT_WIDTH+5) begin
                    if(is_digit(team2_ones, x_pos-(290+DIGIT_WIDTH+5), y_pos-320))
                        VGA_data_interface = TEAM2_COLOR;
                end
            end
            
            // "PRESS ANY KEY TO PLAY AGAIN" text at bottom
            if(y_pos >= 400 && y_pos < 420 && x_pos >= 170 && x_pos < 470) begin
                VGA_data_interface = 12'b1111_1111_1111; // White
            end
        end
        
        // Display "GAME OVER" for individual team when they die
        if(game_status == DIE && !game_complete) begin
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
            
            // Display team information
            if(y_pos >= 320 && y_pos < 350) begin
                if(x_pos >= 220 && x_pos < 420) begin
                    VGA_data_interface = (current_team == 2'd1) ? TEAM1_COLOR : TEAM2_COLOR;
                end
            end
        end
        
        // During gameplay, display current score
        if(game_status == PLAY) begin
            // Display small "SCORE:" indicator in top right
            if(y_pos >= 20 && y_pos < 40 && x_pos >= 520 && x_pos < 580) begin
                VGA_data_interface = 12'b1111_1111_1111; // White for score label
            end
            
            // Display current score digits
            if(y_pos >= 20 && y_pos < 20+DIGIT_HEIGHT/2) begin
                // Display tens digit (scaled down)
                if(x_pos >= 590 && x_pos < 590+DIGIT_WIDTH/2) begin
                    if(is_digit(tens, (x_pos-590)*2, (y_pos-20)*2))
                        VGA_data_interface = 12'b1111_1111_1111; // White
                end
                // Display ones digit (scaled down)
                else if(x_pos >= 590+DIGIT_WIDTH/2+3 && x_pos < 590+DIGIT_WIDTH+3) begin
                    if(is_digit(ones, (x_pos-(590+DIGIT_WIDTH/2+3))*2, (y_pos-20)*2))
                        VGA_data_interface = 12'b1111_1111_1111; // White
                end
            end
        end
    end
endmodule