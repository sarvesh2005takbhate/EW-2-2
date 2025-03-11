module joystick_interface (
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal
    input wire [1:0] x_axis,   // Joystick X-axis input (2-bit for simplicity)
    input wire [1:0] y_axis,   // Joystick Y-axis input (2-bit for simplicity)
    output reg [1:0] direction // Output direction based on joystick position
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            direction <= 2'b00; // Default direction (no movement)
        end else begin
            // Determine direction based on joystick position
            if (x_axis == 2'b01) direction <= 2'b01; // Right
            else if (x_axis == 2'b10) direction <= 2'b10; // Left
            else if (y_axis == 2'b01) direction <= 2'b11; // Up
            else if (y_axis == 2'b10) direction <= 2'b00; // Down
            else direction <= 2'b00; // No movement
        end
    end

endmodule