module number_generator(
    input wire clk,
    input wire reset,
    output reg [23:0] random_number
);

    reg [23:0] counter = 24'b0;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 24'b0;
            random_number <= 24'b100101001000110; // Initial seed value
        end else begin
            counter <= counter + 1;
            random_number <= counter; // Use counter value as pseudo-random number
        end
    end
endmodule              

