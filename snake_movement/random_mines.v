module random_mines(
    input clk,
    input rst,
    input [5:0] head_x,
    input [5:0] head_y,
    input [15:0] is_exist, // Snake body existence
    input [5:0] cube_x0, input [5:0] cube_y0, // Snake body x-coordinates and y-coordinates
    input [5:0] cube_x1, input [5:0] cube_y1,
    input [5:0] cube_x2, input [5:0] cube_y2,
    input [5:0] cube_x3, input [5:0] cube_y3,
    input [5:0] cube_x4, input [5:0] cube_y4,
    input [5:0] cube_x5, input [5:0] cube_y5,
    input [5:0] cube_x6, input [5:0] cube_y6,
    input [5:0] cube_x7, input [5:0] cube_y7,
    input [5:0] cube_x8, input [5:0] cube_y8,
    input [5:0] cube_x9, input [5:0] cube_y9,
    input [5:0] cube_x10, input [5:0] cube_y10,
    input [5:0] cube_x11, input [5:0] cube_y11,
    input [5:0] cube_x12, input [5:0] cube_y12,
    input [5:0] cube_x13, input [5:0] cube_y13,
    input [5:0] cube_x14, input [5:0] cube_y14,
    input [5:0] cube_x15, input [5:0] cube_y15,
    output reg [5:0] mine_x0, output reg [4:0] mine_y0, // Mine x-coordinates and y-coordinates
    output reg [5:0] mine_x1, output reg [4:0] mine_y1,
    output reg [5:0] mine_x2, output reg [4:0] mine_y2,
    output reg [6:0] cube_num, // Updated snake length
    output reg [11:0] mine_color // Color of the mines
);

    reg [31:0] clk_cnt;
    reg [10:0] random_num;
    reg [2:0] mine_active; // Indicates active mines

    localparam RED_COLOR = 12'b1111_0000_0000;

    integer i; // Declare the loop variable outside the always block

    initial begin
        mine_color = RED_COLOR;
        mine_active = 3'b111; // All mines active initially
    end

    // Generate random numbers for mine positions
    always @(posedge clk) begin
        random_num <= random_num + 998;
    end

    // Initialize or update mine positions
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            clk_cnt <= 0;
            mine_x0 <= 10;
            mine_y0 <= 5;
            mine_x1 <= 20;
            mine_y1 <= 10;
            mine_x2 <= 30;
            mine_y2 <= 15;
        end else begin
            clk_cnt <= clk_cnt + 1;
            if (clk_cnt == 500_000) begin
                clk_cnt <= 0;
                if (!mine_active[0]) begin
                    mine_x0 <= {1'b0, (random_num[9:5] == 0 ? 2 : random_num[9:5])};
                    mine_y0 <= (random_num[4:0] > 24) ? (random_num[4:0] - 10) : (random_num[4:0] == 0 ? 1 : random_num[4:0]);
                    mine_active[0] <= 1;
                end
                if (!mine_active[1]) begin
                    mine_x1 <= {1'b0, (random_num[9:5] == 0 ? 2 : random_num[9:5])};
                    mine_y1 <= (random_num[4:0] > 24) ? (random_num[4:0] - 10) : (random_num[4:0] == 0 ? 1 : random_num[4:0]);
                    mine_active[1] <= 1;
                end
                if (!mine_active[2]) begin
                    mine_x2 <= {1'b0, (random_num[9:5] == 0 ? 2 : random_num[9:5])};
                    mine_y2 <= (random_num[4:0] > 24) ? (random_num[4:0] - 10) : (random_num[4:0] == 0 ? 1 : random_num[4:0]);
                    mine_active[2] <= 1;
                end
            end
        end
    end

    // Check for collision with mines
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cube_num <= 3; // Default snake length
        end else begin
            for (i = 0; i < 3; i = i + 1) begin
                if (mine_active[i]) begin
                    // Check if the snake's head touches the mine
                    if ((head_x == mine_x0 && head_y == mine_y0 && i == 0) ||
                        (head_x == mine_x1 && head_y == mine_y1 && i == 1) ||
                        (head_x == mine_x2 && head_y == mine_y2 && i == 2)) begin
                        mine_active[i] <= 0; // Deactivate the mine
                        if (cube_num > 1) begin
                            cube_num <= cube_num - 1; // Decrease snake length
                        end
                    end
                end
            end
        end
    end

    // Display mines on the screen
    always @(posedge clk) begin
        mine_color <= RED_COLOR; // Ensure mines are displayed in red
    end

endmodule