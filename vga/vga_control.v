`timescale 1ns / 1ps

module vga_control(
    input clk,
    input rst,

    input [1:0]snake,
    input [5:0]apple_x,
    input [4:0]apple_y,
    input [11:0] VGA_reward,
    input [1:0] game_status,
    input [7:0] score,  
    // Team-related inputs
    input [7:0] team1_score,
    input [7:0] team2_score,
    input [1:0] current_team,
    input       game_complete,
    // Mine-related inputs
    input [5:0] mine_x_0,
    input [5:0] mine_y_0,
    input [5:0] mine_x_1,
    input [5:0] mine_y_1,
    input [5:0] mine_x_2,
    input [5:0] mine_y_2,
    input [5:0] mine_x_3,
    input [5:0] mine_y_3,
    input [3:0] mine_active,
    output [9:0]x_pos,
    output [9:0]y_pos,    
    output hsync,
    output vsync,
    output [11:0] color_out
    );
    
    wire clk_n;
    
    clk_unit myclk(
        .clk(clk),
        .rst(rst),
        .clk_n(clk_n)
    );

    vga_display VGA(
        .clk(clk_n),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .snake(snake),
        .color_out(color_out),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .game_status(game_status),
        .apple_x(apple_x),
        .apple_y(apple_y),
        .VGA_reward(VGA_reward),
        .score(score),
        // Team connections
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
        .mine_active(mine_active)
    );
endmodule