module collision_detection (
    input wire clk,
    input wire reset,
    input wire [9:0] snake_x,
    input wire [8:0] snake_y,
    input wire [9:0] fruit_x,
    input wire [8:0] fruit_y,
    input wire [1:0] fruit_type,
    output reg collision,
    output reg [1:0] fruit_collision_type // 00: no collision, 01: increase length, 10: decrease length, 11: extra life
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            collision <= 0;
            fruit_collision_type <= 2'b00;
        end else begin
            // Check for collision with fruit
            if (snake_x == fruit_x && snake_y == fruit_y) begin
                collision <= 1;
                fruit_collision_type <= fruit_type;
            end else begin
                collision <= 0;
                fruit_collision_type <= 2'b00;
            end
        end
    end

endmodule