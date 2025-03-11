`timescale 1ns / 1ps
`include "../src/hdmi_display.v"

module snake_game_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [1:0] x_axis;
    reg [1:0] y_axis;

    // Outputs
    wire hsync;
    wire vsync;
    wire [23:0] pixel;

    // Instantiate the Unit Under Test (UUT)
    hdmi_display uut (
        .clk(clk),
        .reset(reset),
        .x_axis(x_axis),
        .y_axis(y_axis),
        .hsync(hsync),
        .vsync(vsync),
        .pixel(pixel)
    );

    // Clock generation
    always #5 clk = ~clk; // 100MHz clock

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        x_axis = 2'b00;
        y_axis = 2'b00;

        // Wait for global reset to finish
        #100;
        reset = 0;

        // Test different joystick positions
        #100;
        x_axis = 2'b01; y_axis = 2'b00; // Move joystick to the right
        #100;
        x_axis = 2'b10; y_axis = 2'b00; // Move joystick to the left
        #100;
        x_axis = 2'b00; y_axis = 2'b01; // Move joystick up
        #100;
        x_axis = 2'b00; y_axis = 2'b10; // Move joystick down
        #100;
        x_axis = 2'b11; y_axis = 2'b11; // Move joystick to bottom-right corner

        // Finish simulation
        #100;
        $finish;
    end

    initial begin
        // Monitor the outputs
        $monitor("Time: %0d, hsync: %b, vsync: %b, pixel: %h", $time, hsync, vsync, pixel);
    end

endmodule