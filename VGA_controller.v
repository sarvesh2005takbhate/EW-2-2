`define COORD_WIDTH 11
`define MAX_LENGTH 63
`define LENGTH_WIDTH 6
`define DISPLAY_WIDTH 136
`define DISPLAY_HEIGHT 76
`define BLOCK_SIZE 10

module VGA_controller(
    input wire clk,          // 100MHz clock
    input wire reset,
    
    // Game state inputs
    input wire [`COORD_WIDTH-1:0] snake_head_x,
    input wire [`COORD_WIDTH-1:0] snake_head_y,
    input wire [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] snake_body_flat,
    input wire [`LENGTH_WIDTH-1:0] snake_length,
    input wire [`COORD_WIDTH-1:0] fruit_x,
    input wire [`COORD_WIDTH-1:0] fruit_y,
    input wire [1:0] fruit_type,
    input wire [2:0] lives,
    input wire [15:0] score,
    input wire [15:0] high_score,
    input wire game_over,
    
    // VGA outputs
    output reg hsync,
    output reg vsync,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);
    // VGA 1366x768 @ 60Hz timing parameters
    parameter H_DISPLAY = 1366;
    parameter H_FRONT_PORCH = 70;
    parameter H_SYNC_PULSE = 143;
    parameter H_BACK_PORCH = 213;
    parameter H_TOTAL = H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;

    parameter V_DISPLAY = 768;
    parameter V_FRONT_PORCH = 3;
    parameter V_SYNC_PULSE = 3;
    parameter V_BACK_PORCH = 24;
    parameter V_TOTAL = V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    // Internal counters
    reg [10:0] h_counter;
    reg [9:0] v_counter;

    // Pixel clock divider (approx. 85.5MHz from 100MHz clock)
    reg [2:0] clock_divider;
    wire pixel_clock_enable;

    // Scaling factors for game to display coordinates
    parameter X_SCALE_FACTOR = H_DISPLAY / `DISPLAY_WIDTH;
    parameter Y_SCALE_FACTOR = V_DISPLAY / `DISPLAY_HEIGHT;
    
    // Display area definitions
    parameter SCORE_AREA_TOP = 20;
    parameter SCORE_AREA_HEIGHT = 50;
    parameter BORDER_WIDTH = 2;
    parameter GAME_AREA_TOP = SCORE_AREA_TOP + SCORE_AREA_HEIGHT;

    assign pixel_clock_enable = (clock_divider != 3'b110);

    always @(posedge clk or posedge reset) begin
        if (reset)
            clock_divider <= 0;
        else if (clock_divider == 3'b110)
            clock_divider <= 0;
        else
            clock_divider <= clock_divider + 1;
    end

    // Snake body segment arrays
    reg [`COORD_WIDTH-1:0] snake_body_x [0:`MAX_LENGTH];
    reg [`COORD_WIDTH-1:0] snake_body_y [0:`MAX_LENGTH];

    integer i;
    always @(*) begin
        for (i = 0; i <= `MAX_LENGTH; i = i + 1) begin
            snake_body_x[i] = snake_body_flat[(`COORD_WIDTH*i) +: `COORD_WIDTH];
            snake_body_y[i] = 0; // Assuming missing `snake_body_y_flat` input
        end
    end

    // Horizontal and vertical counters
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_counter <= 0;
            v_counter <= 0;
        end else if (pixel_clock_enable) begin
            if (h_counter == H_TOTAL - 1) begin
                h_counter <= 0;
                if (v_counter == V_TOTAL - 1)
                    v_counter <= 0;
                else
                    v_counter <= v_counter + 1;
            end else begin
                h_counter <= h_counter + 1;
            end
        end
    end

    // Generate sync signals
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            hsync <= 1;
            vsync <= 1;
        end else if (pixel_clock_enable) begin
            hsync <= ~(h_counter >= H_DISPLAY + H_FRONT_PORCH && h_counter < H_DISPLAY + H_FRONT_PORCH + H_SYNC_PULSE);
            vsync <= ~(v_counter >= V_DISPLAY + V_FRONT_PORCH && v_counter < V_DISPLAY + V_FRONT_PORCH + V_SYNC_PULSE);
        end
    end

    // Convert scaled game coordinates to screen coordinates
    function [10:0] scale_x;
        input [`COORD_WIDTH-1:0] game_x;
        begin
            scale_x = game_x * X_SCALE_FACTOR;
        end
    endfunction

    function [9:0] scale_y;
        input [`COORD_WIDTH-1:0] game_y;
        begin
            scale_y = game_y * Y_SCALE_FACTOR + GAME_AREA_TOP;
        end
    endfunction

    // RGB output
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            red <= 4'h0;
            green <= 4'h0;
            blue <= 4'h0;
        end else if (pixel_clock_enable) begin
            // Default: black background
            red <= 4'h0;
            green <= 4'h0;
            blue <= 4'h0;

            if (h_counter < H_DISPLAY && v_counter < V_DISPLAY) begin
                // Score area
                if (v_counter < GAME_AREA_TOP) begin
                    // Score display - left side
                    if (v_counter >= SCORE_AREA_TOP && v_counter < SCORE_AREA_TOP + 20 &&
                        h_counter >= 20 && h_counter < 20 + (score << 1)) begin
                        red <= 4'h0;
                        green <= 4'hF;
                        blue <= 4'h5;
                    end
                    
                    // High score display - right side
                    if (v_counter >= SCORE_AREA_TOP && v_counter < SCORE_AREA_TOP + 20 &&
                        h_counter >= H_DISPLAY - 20 - (high_score << 1) && h_counter < H_DISPLAY - 20) begin
                        red <= 4'h0;
                        green <= 4'h5;
                        blue <= 4'hF;
                    end
                    
                    // Lives display
                    for (i = 0; i < 3; i = i + 1) begin
                        if (i < lives && v_counter >= SCORE_AREA_TOP + 25 && v_counter < SCORE_AREA_TOP + 45 &&
                            h_counter >= 20 + i*30 && h_counter < 20 + i*30 + 20) begin
                            // Heart shape
                            red <= 4'hF;
                            green <= 4'h0;
                            blue <= 4'h0;
                        end
                    end
                    
                    // Game over message
                    if (game_over && v_counter >= SCORE_AREA_TOP + 10 && v_counter < SCORE_AREA_TOP + 40 &&
                        h_counter >= H_DISPLAY/2 - 100 && h_counter < H_DISPLAY/2 + 100) begin
                        red <= 4'hF;
                        green <= 4'h0;
                        blue <= 4'h0;
                    end
                } 
                
                // Game border
                else if (v_counter == GAME_AREA_TOP || v_counter == V_DISPLAY - 1 || 
                         v_counter == GAME_AREA_TOP + BORDER_WIDTH || v_counter == V_DISPLAY - 1 - BORDER_WIDTH ||
                         h_counter == 0 || h_counter == H_DISPLAY - 1 ||
                         h_counter == BORDER_WIDTH || h_counter == H_DISPLAY - 1 - BORDER_WIDTH) begin
                    red <= 4'hF;
                    green <= 4'hF;
                    blue <= 4'hF;
                }
                
                // Game area
                else if (v_counter > GAME_AREA_TOP && v_counter < V_DISPLAY - 1) begin
                    // Convert current pixel position to game coordinates
                    reg [10:0] game_coord_x;
                    reg [9:0] game_coord_y;
                    game_coord_x = (h_counter * `DISPLAY_WIDTH) / H_DISPLAY;
                    game_coord_y = ((v_counter - GAME_AREA_TOP) * `DISPLAY_HEIGHT) / (V_DISPLAY - GAME_AREA_TOP);
                    
                    // Display snake head
                    if (game_coord_x >= snake_head_x && game_coord_x < snake_head_x + `BLOCK_SIZE &&
                        game_coord_y >= snake_head_y && game_coord_y < snake_head_y + `BLOCK_SIZE) begin
                        red <= 4'h8;
                        green <= 4'hF;
                        blue <= 4'h0;
                    end
                    
                    // Display snake body
                    for (i = 1; i < snake_length; i = i + 1) begin
                        if (game_coord_x >= snake_body_x[i] && game_coord_x < snake_body_x[i] + `BLOCK_SIZE &&
                            game_coord_y >= snake_body_y[i] && game_coord_y < snake_body_y[i] + `BLOCK_SIZE) begin
                            red <= 4'h0;
                            green <= 4'hF;
                            blue <= 4'h0;
                        end
                    end
                    
                    // Display fruit
                    if (game_coord_x >= fruit_x && game_coord_x < fruit_x + `BLOCK_SIZE &&
                        game_coord_y >= fruit_y && game_coord_y < fruit_y + `BLOCK_SIZE) begin
                        case (fruit_type)
                            2'b01: begin // Grow fruit (Red)
                                red <= 4'hF;
                                green <= 4'h0;
                                blue <= 4'h0;
                            end
                            2'b10: begin // Shrink fruit (Purple)
                                red <= 4'hF;
                                green <= 4'h0;
                                blue <= 4'hF;
                            end
                            2'b11: begin // Life fruit (Blue)
                                red <= 4'h0;
                                green <= 4'h0;
                                blue <= 4'hF;
                            end
                            default: begin // Default fruit (Red)
                                red <= 4'hF;
                                green <= 4'h0;
                                blue <= 4'h0;
                            end
                        endcase
                    end
                    
                    // Add grid lines for better visibility (optional)
                    if ((h_counter % (H_DISPLAY / `DISPLAY_WIDTH * 10)) == 0 || 
                        (v_counter % ((V_DISPLAY - GAME_AREA_TOP) / `DISPLAY_HEIGHT * 10)) == 0) begin
                        red <= 4'h2;
                        green <= 4'h2;
                        blue <= 4'h2;
                    end
                end
            end
        end
    end
endmodule
