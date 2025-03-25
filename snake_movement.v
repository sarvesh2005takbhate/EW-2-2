`define COORD_WIDTH 11
`define MAX_LENGTH 63
`define LENGTH_WIDTH 6
`define DISPLAY_WIDTH 136
`define DISPLAY_HEIGHT 76
`define BLOCK_SIZE 10


module snake_movement(
    input wire clk,
    input wire reset,
    input wire [1:0] direction,  // 00: up, 01: right, 10: down, 11: left
    input wire game_clock,       // Slower clock for game updates
    input wire [`COORD_WIDTH-1:0] current_head_x,
    input wire [`COORD_WIDTH-1:0] current_head_y,
    output reg [`COORD_WIDTH-1:0] next_head_x,
    output reg [`COORD_WIDTH-1:0] next_head_y
);
    // Direction definitions
    localparam UP = 2'b00;
    localparam RIGHT = 2'b01;
    localparam DOWN = 2'b10;
    localparam LEFT = 2'b11;
    
    always @(posedge game_clock or posedge reset) begin
        if (reset) begin
            // Initialize snake head to a starting position
            next_head_x <= (`DISPLAY_WIDTH / 2) * `BLOCK_SIZE;
            next_head_y <= (`DISPLAY_HEIGHT / 2) * `BLOCK_SIZE;
        end else begin
            // Update head position based on direction
            case(direction)
                UP: begin
                    next_head_x <= current_head_x;
                    next_head_y <= current_head_y - `BLOCK_SIZE;
                end
                RIGHT: begin
                    next_head_x <= current_head_x + `BLOCK_SIZE;
                    next_head_y <= current_head_y;
                end
                DOWN: begin
                    next_head_x <= current_head_x;
                    next_head_y <= current_head_y + `BLOCK_SIZE;
                end
                LEFT: begin
                    next_head_x <= current_head_x - `BLOCK_SIZE;
                    next_head_y <= current_head_y;
                end
                default: begin
                    next_head_x <= current_head_x;
                    next_head_y <= current_head_y;
                end
            endcase
        end
    end
endmodule
