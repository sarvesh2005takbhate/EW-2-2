`define COORD_WIDTH 11
`define BLOCK_SIZE 10

module button_controller(
    input wire clk,
    input wire reset,
    input wire btn_up,
    input wire btn_down,
    input wire btn_left,
    input wire btn_right,
    output reg [1:0] direction // 00: up, 01: right, 10: down, 11: left
);

    // Direction definitions
    localparam UP = 2'b00;
    localparam RIGHT = 2'b01;
    localparam DOWN = 2'b10;
    localparam LEFT = 2'b11;
    
    // Registers for debouncing
    reg [19:0] debounce_counter; // For a ~5ms debounce at ZED board clock frequency
    reg btn_up_reg, btn_down_reg, btn_left_reg, btn_right_reg;
    reg btn_up_stable, btn_down_stable, btn_left_stable, btn_right_stable;
    
    // Last direction to prevent 180-degree turns
    reg [1:0] last_direction;
    
    // Debounce logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            debounce_counter <= 0;
            btn_up_reg <= 0;
            btn_down_reg <= 0;
            btn_left_reg <= 0;
            btn_right_reg <= 0;
            btn_up_stable <= 0;
            btn_down_stable <= 0;
            btn_left_stable <= 0;
            btn_right_stable <= 0;
        end else begin
            // Sample button inputs
            btn_up_reg <= btn_up;
            btn_down_reg <= btn_down;
            btn_left_reg <= btn_left;
            btn_right_reg <= btn_right;
            
            // Check if any button is pressed
            if (btn_up_reg != btn_up_stable || btn_down_reg != btn_down_stable ||
                btn_left_reg != btn_left_stable || btn_right_reg != btn_right_stable) begin
                debounce_counter <= debounce_counter + 1;
                
                // Debounce period complete - adjusted for ZED board timing
                if (debounce_counter == 20'h4FFFF) begin
                    btn_up_stable <= btn_up_reg;
                    btn_down_stable <= btn_down_reg;
                    btn_left_stable <= btn_left_reg;
                    btn_right_stable <= btn_right_reg;
                    debounce_counter <= 0;
                end
            end else begin
                debounce_counter <= 0;
            end
        end
    end
    
    // Direction control logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            direction <= RIGHT; // Start moving right
            last_direction <= RIGHT;
        end else begin
            // Only update direction when a button is pressed and it's not a 180-degree turn
            if (btn_up_stable && last_direction != DOWN) begin
                direction <= UP;
                last_direction <= UP;
            end else if (btn_right_stable && last_direction != LEFT) begin
                direction <= RIGHT;
                last_direction <= RIGHT;
            end else if (btn_down_stable && last_direction != UP) begin
                direction <= DOWN;
                last_direction <= DOWN;
            end else if (btn_left_stable && last_direction != RIGHT) begin
                direction <= LEFT;
                last_direction <= LEFT;
            end
        end
    end
endmodule
