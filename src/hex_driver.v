// ============================================================================
// 模組名稱：hex_driver
// 功能描述：顯示兩位數數字、EE (Error) 或 __ (None)。
//           DE10-Lite 顯示器為 Low-Active (0亮/1滅)。
// ============================================================================

module hex_driver ( 
    input  [7:0] value,   
    input        error,   
    input        none,    
    output reg [6:0] HEX0, 
    output reg [6:0] HEX1  
);

    // 七段顯示器編碼 {g, f, e, d, c, b, a}
    localparam SEG_0    = 7'b1000000;
    localparam SEG_1    = 7'b1111001;
    localparam SEG_2    = 7'b0100100;
    localparam SEG_3    = 7'b0110000;
    localparam SEG_4    = 7'b0011001;
    localparam SEG_5    = 7'b0010010;
    localparam SEG_6    = 7'b0000010;
    localparam SEG_7    = 7'b1111000;
    localparam SEG_8    = 7'b0000000;
    localparam SEG_9    = 7'b0010000;
    localparam SEG_E    = 7'b0000110; 
    localparam SEG_LINE = 7'b1110111; // 僅點亮底部 d 段

    reg [3:0] tens, ones;
    always @(*) begin
        tens = value / 10;
        ones = value % 10;
    end

    function [6:0] decode_digit(input [3:0] digit);
        case (digit)
            4'd0: decode_digit = SEG_0;
            4'd1: decode_digit = SEG_1;
            4'd2: decode_digit = SEG_2;
            4'd3: decode_digit = SEG_3;
            4'd4: decode_digit = SEG_4;
            4'd5: decode_digit = SEG_5;
            4'd6: decode_digit = SEG_6;
            4'd7: decode_digit = SEG_7;
            4'd8: decode_digit = SEG_8;
            4'd9: decode_digit = SEG_9;
            default: decode_digit = SEG_0;
        endcase
    endfunction

    always @(*) begin
        if (none) begin
            // 全關優先權最高
            HEX0 = SEG_LINE;
            HEX1 = SEG_LINE;
        end else if (error) begin
            // 發生非法選取 (複選或 SW8,9)
            HEX0 = SEG_E;
            HEX1 = SEG_E;
        end else begin
            // 正常顯示
            HEX0 = decode_digit(ones);
            HEX1 = decode_digit(tens);
        end
    end

endmodule