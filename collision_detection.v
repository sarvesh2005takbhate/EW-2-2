`include "number_generator.v"

`define COORD_WIDTH 10  
`define MAX_LENGTH 63   
`define LENGTH_WIDTH 6  

// Display dimensions based on actual display board we can change it
`define DISPLAY_WIDTH 64  
`define DISPLAY_HEIGHT 48  
`define BLOCK_SIZE 10      

module fruit_generator_counter(
    input wire clk,
    input wire reset,
    input wire [`COORD_WIDTH-1:0] snakehead_x,
    input wire [`COORD_WIDTH-1:0] snakehead_y,
    input wire [`COORD_WIDTH-1:0] snakebody_x[0:`MAX_LENGTH],
    input wire [`COORD_WIDTH-1:0] snakebody_y[0:`MAX_LENGTH],
    input wire [`LENGTH_WIDTH-1:0] snake_length_in,
    input wire [2:0] lives_in,
    output reg [2:0] lives_out,
    output reg [`LENGTH_WIDTH-1:0] snake_length_out,
    output reg [`COORD_WIDTH-1:0] new_head_x,
    output reg [`COORD_WIDTH-1:0] new_head_y
);

    integer i;
    reg valid_position;
    reg collision_detected;
    wire [15:0] random_number;
    
    // Instantiate the number generator
    number_generator rng(
        .clk(clk),
        .reset(reset),
        .random_number(random_number)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lives_out <= lives_in;
            snake_length_out <= snake_length_in;
            new_head_x <= snakehead_x;
            new_head_y <= snakehead_y;
            collision_detected <= 0;
        end else begin
            // Default values
            collision_detected <= 0;
            lives_out <= lives_in;
            snake_length_out <= snake_length_in;
            new_head_x <= snakehead_x;
            new_head_y <= snakehead_y;
            
            // Check for boundary collision
            if (snakehead_x >= `DISPLAY_WIDTH || snakehead_y >= `DISPLAY_HEIGHT || 
                snakehead_x == 0 || snakehead_y == 0) begin
                collision_detected <= 1;
            end
            
            // Check for collision with own body (starting from index 1)
            for (i = 1; i < snake_length_in; i = i + 1) begin
                if (snakehead_x == snakebody_x[i] && snakehead_y == snakebody_y[i]) begin
                    collision_detected <= 1;
                end
            end
            
            // Handle collision
            if (collision_detected) begin
                lives_out <= lives_in - 1;
                snake_length_out <= 1;  // Reset snake length to 1
                
                // Generate new position ensuring it's within valid screen bounds
                // Using modulo to stay within display dimensions (minus margins for safety)
                // For display size 64x48, we'd generate positions between 2-61 for x and 2-45 for y
                new_head_x <= (random_number[7:0] % (`DISPLAY_WIDTH - 4)) + 2;  
                new_head_y <= (random_number[15:8] % (`DISPLAY_HEIGHT - 4)) + 2;
                
                // We don't need to do anything special for length 1,
                // as snake_length_out <= 1 already handles this
            end
        end
    end

endmodule