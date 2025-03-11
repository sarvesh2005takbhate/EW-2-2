`include "joystick_interface.v"
`include "fruit_generator.v"
`include "collision_detection.v"

module hdmi_display (
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal
    input wire [1:0] x_axis,   // Joystick X-axis input
    input wire [1:0] y_axis,   // Joystick Y-axis input
    output wire hsync,         // Horizontal sync signal
    output wire vsync,         // Vertical sync signal
    output wire [23:0] pixel   // Pixel data output (8 bits each for R, G, B)
);

    wire [1:0] direction;
    wire [9:0] fruit_x;
    wire [8:0] fruit_y;
    wire [1:0] fruit_type;
    wire collision;
    wire [1:0] fruit_collision_type;

    // Instantiate joystick interface
    joystick_interface joystick (
        .clk(clk),
        .reset(reset),
        .x_axis(x_axis),
        .y_axis(y_axis),
        .direction(direction)
    );

    // Instantiate fruit generator
    fruit_generator fruit_gen (
        .clk(clk),
        .reset(reset),
        .fruit_x(fruit_x),
        .fruit_y(fruit_y),
        .fruit_type(fruit_type)
    );

    // Instantiate collision detection
    collision_detection collision_det (
        .clk(clk),
        .reset(reset),
        .snake_x(snake_x),
        .snake_y(snake_y),
        .fruit_x(fruit_x),
        .fruit_y(fruit_y),
        .fruit_type(fruit_type),
        .collision(collision),
        .fruit_collision_type(fruit_collision_type)
    );

    // HDMI timing parameters (example values for 640x480 @ 60Hz)
    parameter H_ACTIVE = 640;
    parameter H_FRONT_PORCH = 16;
    parameter H_SYNC_PULSE = 96;
    parameter H_BACK_PORCH = 48;
    parameter V_ACTIVE = 480;
    parameter V_FRONT_PORCH = 10;
    parameter V_SYNC_PULSE = 2;
    parameter V_BACK_PORCH = 33;

    // Calculated total counts
    parameter H_TOTAL = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    parameter V_TOTAL = V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    reg [11:0] h_count = 0;
    reg [11:0] v_count = 0;

    // Snake parameters
    reg [9:0] snake_x = H_ACTIVE / 2;
    reg [8:0] snake_y = V_ACTIVE / 2;
    reg [23:0] snake_color = 24'h00FF00; // Green
    reg [2:0] lives = 3; // Initial lives

    // Horizontal and vertical sync generation
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            h_count <= 0;
            v_count <= 0;
            snake_x <= H_ACTIVE / 2;
            snake_y <= V_ACTIVE / 2;
            lives <= 3;
        end else begin
            if (h_count < H_TOTAL - 1) begin
                h_count <= h_count + 1;
            end else begin
                h_count <= 0;
                if (v_count < V_TOTAL - 1) begin
                    v_count <= v_count + 1;
                end else begin
                    v_count <= 0;
                end
            end

            // Update snake position based on direction
            if (h_count == 0 && v_count == 0) begin
                case (direction)
                    2'b01: if (snake_x < H_ACTIVE - 1) snake_x <= snake_x + 1; // Right
                    2'b10: if (snake_x > 0) snake_x <= snake_x - 1; // Left
                    2'b11: if (snake_y > 0) snake_y <= snake_y - 1; // Up
                    2'b00: if (snake_y < V_ACTIVE - 1) snake_y <= snake_y + 1; // Down
                endcase

                // Check for collision with fruit
                if (collision) begin
                    case (fruit_collision_type)
                        2'b01: ; // Increase length (not implemented in this example)
                        2'b10: ; // Decrease length (not implemented in this example)
                        2'b11: if (lives < 3) lives <= lives + 1; // Extra life
                    endcase
                end

                // Check for collision with walls
                if (snake_x == 0 || snake_x == H_ACTIVE - 1 || snake_y == 0 || snake_y == V_ACTIVE - 1) begin
                    if (lives > 0) lives <= lives - 1;
                end
            end
        end
    end

    // Generate sync signals
    assign hsync = (h_count >= H_ACTIVE + H_FRONT_PORCH) && (h_count < H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE);
    assign vsync = (v_count >= V_ACTIVE + V_FRONT_PORCH) && (v_count < V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE);

    // Generate pixel data
    assign pixel = (h_count < H_ACTIVE && v_count < V_ACTIVE && h_count == snake_x && v_count == snake_y) ? snake_color : 24'h000000; // Snake or black

endmodule