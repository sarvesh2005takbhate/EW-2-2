module font_rom (
    input  [7:0] char,     // ASCII code
    input  [2:0] row,      // Row index (0 to 7)
    output reg [7:0] pixels  // 8 bits per row
);
    always @(*) begin
        case (char)
            "S": case(row)
                0: pixels = 8'b00111110;
                1: pixels = 8'b01000000;
                2: pixels = 8'b01000000;
                3: pixels = 8'b00111100;
                4: pixels = 8'b00000010;
                5: pixels = 8'b00000010;
                6: pixels = 8'b01111100;
                7: pixels = 8'b00000000;
            endcase
            "N": case(row)
                0: pixels = 8'b01000010;
                1: pixels = 8'b01100010;
                2: pixels = 8'b01010010;
                3: pixels = 8'b01001010;
                4: pixels = 8'b01000110;
                5: pixels = 8'b01000010;
                6: pixels = 8'b01000010;
                7: pixels = 8'b00000000;
            endcase
            "A": case(row)
                0: pixels = 8'b00111100;
                1: pixels = 8'b01000010;
                2: pixels = 8'b01000010;
                3: pixels = 8'b01111110;
                4: pixels = 8'b01000010;
                5: pixels = 8'b01000010;
                6: pixels = 8'b01000010;
                7: pixels = 8'b00000000;
            endcase
            "K": case(row)
                0: pixels = 8'b01000100;
                1: pixels = 8'b01001000;
                2: pixels = 8'b01010000;
                3: pixels = 8'b01100000;
                4: pixels = 8'b01010000;
                5: pixels = 8'b01001000;
                6: pixels = 8'b01000100;
                7: pixels = 8'b00000000;
            endcase
            "E": case(row)
                0: pixels = 8'b01111110;
                1: pixels = 8'b01000000;
                2: pixels = 8'b01000000;
                3: pixels = 8'b01111100;
                4: pixels = 8'b01000000;
                5: pixels = 8'b01000000;
                6: pixels = 8'b01111110;
                7: pixels = 8'b00000000;
            endcase
            "G": case(row)
                0: pixels = 8'b00111100;
                1: pixels = 8'b01000010;
                2: pixels = 8'b01000000;
                3: pixels = 8'b01001110;
                4: pixels = 8'b01000010;
                5: pixels = 8'b01000010;
                6: pixels = 8'b00111100;
                7: pixels = 8'b00000000;
            endcase
            "M": case(row)
                0: pixels = 8'b01000010;
                1: pixels = 8'b01100110;
                2: pixels = 8'b01011010;
                3: pixels = 8'b01000010;
                4: pixels = 8'b01000010;
                5: pixels = 8'b01000010;
                6: pixels = 8'b01000010;
                7: pixels = 8'b00000000;
            endcase
            "P": case(row)
                0: pixels = 8'b01111100;
                1: pixels = 8'b01000010;
                2: pixels = 8'b01000010;
                3: pixels = 8'b01111100;
                4: pixels = 8'b01000000;
                5: pixels = 8'b01000000;
                6: pixels = 8'b01000000;
                7: pixels = 8'b00000000;
            endcase
            "1": case(row)
                0: pixels = 8'b00010000;
                1: pixels = 8'b00110000;
                2: pixels = 8'b00010000;
                3: pixels = 8'b00010000;
                4: pixels = 8'b00010000;
                5: pixels = 8'b00010000;
                6: pixels = 8'b00111000;
                7: pixels = 8'b00000000;
            endcase
            "2": case(row)
                0: pixels = 8'b00111100;
                1: pixels = 8'b01000010;
                2: pixels = 8'b00000010;
                3: pixels = 8'b00000100;
                4: pixels = 8'b00001000;
                5: pixels = 8'b00010000;
                6: pixels = 8'b01111110;
                7: pixels = 8'b00000000;
            endcase
            " ": pixels = 8'b00000000;
            default: pixels = 8'b00000000;
        endcase
    end
endmodule
