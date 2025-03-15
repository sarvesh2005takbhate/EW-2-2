`timescale 1ns/1ps

`define COORD_WIDTH 10  
`define MAX_LENGTH 63   
`define LENGTH_WIDTH 6  
`define DISPLAY_WIDTH 64  
`define DISPLAY_HEIGHT 48  
`define BLOCK_SIZE 10

module testbench;
    // Common signals
    reg clk;
    reg reset;
    
    // number_generator signals
    wire [15:0] random_number;
    
    // Snake state signals
    reg [`COORD_WIDTH-1:0] snakehead_x;
    reg [`COORD_WIDTH-1:0] snakehead_y;
    reg [`COORD_WIDTH-1:0] snakebody_x[0:`MAX_LENGTH];
    reg [`COORD_WIDTH-1:0] snakebody_y[0:`MAX_LENGTH];
    reg [`LENGTH_WIDTH-1:0] snake_length;
    reg [2:0] lives;
    
    // fruit_generator outputs
    wire [`COORD_WIDTH-1:0] fruit_x;
    wire [`COORD_WIDTH-1:0] fruit_y;
    wire food_eaten;
    wire [1:0] fruit_type;
    wire [`COORD_WIDTH-1:0] new_snakebody_x[0:`MAX_LENGTH];
    wire [`COORD_WIDTH-1:0] new_snakebody_y[0:`MAX_LENGTH];
    wire [`LENGTH_WIDTH-1:0] fruit_snake_length_out;
    wire [2:0] fruit_lives_out;
    
    // collision_detection outputs
    wire [2:0] collision_lives_out;
    wire [`LENGTH_WIDTH-1:0] collision_snake_length_out;
    wire [`COORD_WIDTH-1:0] new_head_x;
    wire [`COORD_WIDTH-1:0] new_head_y;

    // Module instantiations
    number_generator rng_inst (
        .clk(clk),
        .reset(reset),
        .random_number(random_number)
    );
    
    fruit_generator_counter fruit_inst (
        .clk(clk),
        .reset(reset),
        .snakehead_x(snakehead_x),
        .snakehead_y(snakehead_y),
        .snakebody_x(snakebody_x),
        .snakebody_y(snakebody_y),
        .snake_length_in(snake_length),
        .lives_in(lives),
        .fruit_x(fruit_x),
        .fruit_y(fruit_y),
        .food_eaten(food_eaten),
        .fruit_type(fruit_type),
        .new_snakebody_x(new_snakebody_x),
        .new_snakebody_y(new_snakebody_y),
        .snake_length_out(fruit_snake_length_out),
        .lives_out(fruit_lives_out)
    );
    
    // Using the properly named collision_detection module
    collision_detection collision_inst (
        .clk(clk),
        .reset(reset),
        .snakehead_x(snakehead_x),
        .snakehead_y(snakehead_y),
        .snakebody_x(snakebody_x),
        .snakebody_y(snakebody_y),
        .snake_length_in(snake_length),
        .lives_in(lives),
        .lives_out(collision_lives_out),
        .snake_length_out(collision_snake_length_out),
        .new_head_x(new_head_x),
        .new_head_y(new_head_y)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end
    
    // Test process
    integer i;
    initial begin
        // Initialize VCD file for waveform visualization
        $dumpfile("snake_game_tb.vcd");
        $dumpvars(0, testbench);
        
        // Initialize test inputs
        reset = 1;
        snakehead_x = 10;
        snakehead_y = 10;
        snake_length = 3;
        lives = 3;
        
        // Initialize snake body positions
        for (i = 0; i < `MAX_LENGTH; i = i + 1) begin
            if (i < snake_length) begin
                snakebody_x[i] = snakehead_x - i;
                snakebody_y[i] = snakehead_y;
            end else begin
                snakebody_x[i] = 0;
                snakebody_y[i] = 0;
            end
        end
        
        // Apply reset
        #20 reset = 0;
        $display("Reset done, starting simulation at time %0t", $time);
        
        // Test Case 1: Normal movement without collision or food
        #50;
        $display("Test Case 1: Snake head at (%0d, %0d), fruit at (%0d, %0d)",
                 snakehead_x, snakehead_y, fruit_x, fruit_y);
        
        // Test Case 2: Move snake to fruit position
        #20;
        snakehead_x = fruit_x;
        snakehead_y = fruit_y;
        #10;
        $display("Test Case 2: Snake reached fruit at (%0d, %0d), Type: %0d, Food eaten: %0d",
                 fruit_x, fruit_y, fruit_type, food_eaten);
        $display("Snake length before: %0d, after: %0d", snake_length, fruit_snake_length_out);
        
        // Update snake length based on fruit interaction
        snake_length = fruit_snake_length_out;
        lives = fruit_lives_out;
        
        #20;
        
        // Test Case 3: Test collision with boundary
        snakehead_x = `DISPLAY_WIDTH; // Boundary collision
        snakehead_y = 20;
        #10;
        $display("Test Case 3: Boundary collision detected, lives before: %0d, after: %0d",
                 lives, collision_lives_out);
        $display("New head position: (%0d, %0d)", new_head_x, new_head_y);
        
        // Update values after collision
        snakehead_x = new_head_x;
        snakehead_y = new_head_y;
        snake_length = collision_snake_length_out;
        lives = collision_lives_out;
        
        // Test Case 4: Test collision with body
        #20;
        // First move away from boundary
        snakehead_x = 20;
        snakehead_y = 20;
        #10;
        // Setup body for collision
        snakebody_x[0] = snakehead_x;
        snakebody_y[0] = snakehead_y;
        snakebody_x[1] = snakehead_x + 10;
        snakebody_y[1] = snakehead_y;
        snake_length = 3;
        #10;
        // Move head to body position to create collision
        snakehead_x = snakebody_x[1];
        snakehead_y = snakebody_y[1];
        #10;
        $display("Test Case 4: Self collision test, lives before: %0d, after: %0d",
                 lives, collision_lives_out);
                 
        // Run simulation for a bit longer to see outputs
        #100;
        
        $display("Simulation finished at time %0t", $time);
        $finish;
    end
    
    // Monitor random numbers
    always @(posedge clk) begin
        if (!reset && $time > 20)
            $display("Time %0t: Random number: %h", $time, random_number);
    end
    
    // Monitor fruit generation and collisions
    always @(posedge food_eaten) begin
        $display("Time %0t: Food eaten! Type: %0d, Snake length: %0d -> %0d", 
                 $time, fruit_type, snake_length, fruit_snake_length_out);
    end
    
    always @(collision_lives_out) begin
        if (collision_lives_out < lives)
            $display("Time %0t: Collision detected! Lives: %0d -> %0d", 
                     $time, lives, collision_lives_out);
    end
endmodule
