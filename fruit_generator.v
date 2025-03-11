module fruit_generator (
    input wire clk,
    input wire reset,
    output reg [9:0] fruit_x,
    output reg [8:0] fruit_y,
    output reg [1:0] fruit_type // 00: no fruit, 01: increase length, 10: decrease length, 11: extra life
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fruit_x <= 10'd320; // Initial fruit position
            fruit_y <= 9'd240;
            fruit_type <= 2'b01; // Initial fruit type
        end else begin
            // Randomly generate fruit position and type
            fruit_x <= $random % 640;
            fruit_y <= $random % 480;
            fruit_type <= $random % 3 + 1; // Random fruit type (01, 10, 11)
        end
    end

endmodule