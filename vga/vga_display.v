module vga_display(
    input clk,
    input rst,
    input [1:0]snake,
    input [1:0]game_status,
    input [5:0]apple_x,
    input [4:0]apple_y,
    input [11:0]VGA_reward,
    input [7:0]score,
    // Team connections
    input [7:0]team1_score,
    input [7:0]team2_score,
    input [1:0]current_team,
    input      game_complete,
    // Mine connections
    input [5:0]mine_x_0,
    input [5:0]mine_y_0,
    input [5:0]mine_x_1,
    input [5:0]mine_y_1,
    input [5:0]mine_x_2,
    input [5:0]mine_y_2,
    input [5:0]mine_x_3,
    input [5:0]mine_y_3,
    input [3:0]mine_active,
    output hsync,
    output vsync,
    output [9:0]x_pos,
    output [9:0]y_pos,
    output [11:0]color_out
);


    reg [19:0]clk_cnt;
    reg [9:0]line_cnt;
    reg clk_25M;

    wire [11:0]   VGA_data_interface;
    
    localparam NONE = 2'b00;
    localparam HEAD = 2'b01;
    localparam BODY = 2'b10;
    localparam WALL = 2'b11;
    
    localparam HEAD_COLOR = 12'b0000_1111_0000;
    localparam BODY_COLOR = 12'b0000_1111_1111;
    
    
    reg [3:0]lox;
    reg [3:0]loy;

    reg hsync_reg;
    reg vsync_reg;
    reg [9:0]x_pos_reg;
    reg [9:0]y_pos_reg;
    reg [11:0]color_out_reg;

    assign hsync = hsync_reg;
    assign vsync = vsync_reg;
    assign x_pos = x_pos_reg;
    assign y_pos = y_pos_reg;
    assign color_out = color_out_reg;
        
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_cnt <= 0;
            line_cnt <= 0;
            hsync_reg <= 1;
            vsync_reg <= 1;
        end
        else begin
            x_pos_reg <= clk_cnt - 144;
            y_pos_reg <= line_cnt - 33;    
            if (clk_cnt == 0) begin
                hsync_reg <= 0;
                clk_cnt <= clk_cnt + 1;
            end
            else if (clk_cnt == 96) begin
                hsync_reg <= 1;
                clk_cnt <= clk_cnt + 1;
            end
            else if (clk_cnt == 799) begin
                clk_cnt <= 0;
                line_cnt <= line_cnt + 1;
            end
            else clk_cnt <= clk_cnt + 1;
            if (line_cnt == 0) begin
                vsync_reg <= 0;
            end
            else if (line_cnt == 2) begin
                vsync_reg <= 1;
            end
            else if (line_cnt == 521) begin
                line_cnt <= 0;
                vsync_reg <= 0;
            end
            
            if (x_pos_reg >= 0 && x_pos_reg < 640 && y_pos_reg >= 0 && y_pos_reg < 480) begin
                color_out_reg[ 0] = VGA_data_interface[ 0] | VGA_reward[ 0];
                color_out_reg[ 1] = VGA_data_interface[ 1] | VGA_reward[ 1];
                color_out_reg[ 2] = VGA_data_interface[ 2] | VGA_reward[ 2];
                color_out_reg[ 3] = VGA_data_interface[ 3] | VGA_reward[ 3];
                color_out_reg[ 4] = VGA_data_interface[ 4] | VGA_reward[ 4];
                color_out_reg[ 5] = VGA_data_interface[ 5] | VGA_reward[ 5];
                color_out_reg[ 6] = VGA_data_interface[ 6] | VGA_reward[ 6];
                color_out_reg[ 7] = VGA_data_interface[ 7] | VGA_reward[ 7];
                color_out_reg[ 8] = VGA_data_interface[ 8] | VGA_reward[ 8];
                color_out_reg[ 9] = VGA_data_interface[ 9] | VGA_reward[ 9];
                color_out_reg[10] = VGA_data_interface[10] | VGA_reward[10];
                color_out_reg[11] = VGA_data_interface[11] | VGA_reward[11];
            end
            else
                color_out_reg = 12'b0000_0000_0000;
        end
    end

    interface_display u_interface_display
    (
        .clk    (clk),
        .x_pos  (x_pos),
        .y_pos  (y_pos),
        .apple_x(apple_x),
        .apple_y(apple_y),
        .game_status(game_status),
        .snake  (snake),
        .VGA_data_interface(VGA_data_interface),
        // Pass team-related information
        .team1_score(team1_score),
        .team2_score(team2_score),
        .current_team(current_team),
        .game_complete(game_complete),
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
        .score(score)
    );

endmodule