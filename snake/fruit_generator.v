//so we are using three kinds of fruits in the game
//one is to increase the length of the snake
//another is to decrease the length of the snake
//and the third one is to give an extra life to the snake
//we have to generate food inside the boundary conditions and not where the snake is present


//these are for the fpga board thing for display we can change as we need it
`define COORD_WIDTH 11
`define MAX_LENGTH 63
`define LENGTH_WIDTH 6
`define DISPLAY_WIDTH 136
`define DISPLAY_HEIGHT 76
`define BLOCK_SIZE 10


module fruit_generator_counter(
    input wire clk,
    input wire reset,
    input wire [`COORD_WIDTH-1:0] snakehead_x,
    input wire [`COORD_WIDTH-1:0] snakehead_y,
    // Convert unpacked arrays to flat ports
    input wire [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] snakebody_x_flat,
    input wire [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] snakebody_y_flat,
    input wire [`LENGTH_WIDTH-1:0] snake_length_in,
    input wire [2:0] lives_in,
    output reg [`COORD_WIDTH-1:0] fruit_x,
    output reg [`COORD_WIDTH-1:0] fruit_y,
    output reg food_eaten,
    output reg [1:0] fruit_type,
    // Convert unpacked arrays to flat ports
    output reg [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] new_snakebody_x_flat,
    output reg [(`COORD_WIDTH*(`MAX_LENGTH+1))-1:0] new_snakebody_y_flat,
    output reg [`LENGTH_WIDTH-1:0] snake_length_out,
    output reg [2:0] lives_out
);
    //why we take 16 bit number
    // we divide this into three parts 2 for x and y coordinate and another for fruit type
    wire [23:0] random_number;
    number_generator rng_inst (
        .clk(clk),
        .reset(reset),
        .random_number(random_number)
    );

    // Declare unpacked arrays for local use only
    reg [`COORD_WIDTH-1:0] snakebody_x [0:`MAX_LENGTH];
    reg [`COORD_WIDTH-1:0] snakebody_y [0:`MAX_LENGTH];
    reg [`COORD_WIDTH-1:0] new_snakebody_x [0:`MAX_LENGTH];
    reg [`COORD_WIDTH-1:0] new_snakebody_y [0:`MAX_LENGTH];

    integer i, j;
    reg valid_position;
    reg found_valid_position;  // Flag to replace break statement

    // Convert flat ports to arrays
    always @(*) begin
        for (i = 0; i <= `MAX_LENGTH; i = i + 1) begin
            snakebody_x[i] = snakebody_x_flat[(`COORD_WIDTH*i) +: `COORD_WIDTH];
            snakebody_y[i] = snakebody_y_flat[(`COORD_WIDTH*i) +: `COORD_WIDTH];
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin //setting initial value as 100 of the fruit and type as increase length
            fruit_x <= 100; 
            fruit_y <= 100;
            fruit_type <= 2'b01;
            food_eaten <= 0;
            snake_length_out <= snake_length_in;
            lives_out <= lives_in;
            for (i = 0; i < 64; i = i + 1) begin
                new_snakebody_x[i] <= snakebody_x[i];
                new_snakebody_y[i] <= snakebody_y[i];
            end
        end else begin
            if (snakehead_x == fruit_x && snakehead_y == fruit_y) begin
                food_eaten <= 1;
                if (fruit_type == 2'b01 && snake_length_in < `MAX_LENGTH) 
                    snake_length_out <= snake_length_in + 1;
                else if (fruit_type == 2'b10 && snake_length_in > 1)
                    snake_length_out <= snake_length_in - 1;
                else if (fruit_type == 2'b11 && lives_in < 3) //max live given are only 3
                    lives_out <= lives_in + 1;
                else begin
                    snake_length_out <= snake_length_in;
                    lives_out <= lives_in;
                end 
                
                // Shift the snake body only up to the current length
                for (i = snake_length_in; i > 0; i = i - 1) begin
                    new_snakebody_x[i] <= new_snakebody_x[i - 1];
                    new_snakebody_y[i] <= new_snakebody_y[i - 1];
                end // Add head as the first segment
                new_snakebody_x[0] <= snakehead_x;
                new_snakebody_y[0] <= snakehead_y;
                
                // Instead of using break, use a loop with a flag
                found_valid_position = 0;
                for (j = 0; j < 10 && !found_valid_position; j = j + 1) begin
                    valid_position = 1;
                    fruit_x = (random_number[11:0] % `DISPLAY_WIDTH) * `BLOCK_SIZE;  
                    fruit_y = (random_number[23:12] % `DISPLAY_HEIGHT) * `BLOCK_SIZE;
                    
                    for (i = 0; i < snake_length_out; i = i + 1) begin
                        if (fruit_x == new_snakebody_x[i] && fruit_y == new_snakebody_y[i]) 
                            valid_position = 0;
                    end
                    
                    if (valid_position) begin
                        fruit_type = random_number[2:1];
                        found_valid_position = 1;
                    end
                end
            end else begin
                food_eaten <= 0;
                snake_length_out <= snake_length_in;
                lives_out <= lives_in;
                for (i = 0; i < 64; i = i + 1) begin
                    new_snakebody_x[i] <= snakebody_x[i];
                    new_snakebody_y[i] <= snakebody_y[i];
                end
            end
        end
    end
    
    // Convert arrays back to flat ports
    always @(*) begin
        for (i = 0; i <= `MAX_LENGTH; i = i + 1) begin
            new_snakebody_x_flat[(`COORD_WIDTH*i) +: `COORD_WIDTH] = new_snakebody_x[i];
            new_snakebody_y_flat[(`COORD_WIDTH*i) +: `COORD_WIDTH] = new_snakebody_y[i];
        end
    end
endmodule


