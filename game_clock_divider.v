module game_clock_divider(
    input wire clk,          // Input clock (typically 50MHz or 100MHz on FPGA)
    input wire reset,
    output reg game_clock    // Game clock (slower, e.g., 4-10Hz for snake movement)
);
    // For a 100MHz clock, to get ~4Hz:
    // 100,000,000 / 4 = 25,000,000 cycles
    // So we need a 25-bit counter (2^25 > 25,000,000)
    reg [24:0] counter;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            game_clock <= 0;
        end else begin
            if (counter == 25'd12500000) begin  // Adjust this value to change game speed
                counter <= 0;
                game_clock <= ~game_clock;
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule
