// ============================================================================
// 模組名稱：dot_matrix_driver
// 功能描述：控制 8x8 點矩陣顯示圖案
//           圖案顯示前會先「左右翻轉 + 逆時針旋轉 90 度」
//           優先級：模式編號(1/2) > 錯誤(E) > 勝負(O/X) > 清除
// ============================================================================

module dot_matrix_driver (
    input clk,                  // 50MHz
    input mode,                 // 0: Basic, 1: Mini Game
    input all_off,              // SW1~7 是否全關
    input basic_error,          // 選擇錯誤
    input game_win,             // 遊戲答對
    input game_lose,            // 遊戲答錯
    input [1:0] show_mode_num,  // 0: 不顯示, 1: 顯示"1", 2: 顯示"2"
    output reg [7:0] row,       // Active Low
    output reg [7:0] col0,      // 左側點矩陣 (Active High)
    output reg [7:0] col1       // 右側點矩陣 (Active High)
);

    // ------------------------------------------------------------------------
    // 1. 圖案轉換函數
    //    功能：左右翻轉 → 逆時針旋轉 90 度
    //    new[r][c] = old[c][7-r]
    // ------------------------------------------------------------------------
    function automatic [63:0] flip_lr_and_rot_cw;
        input [63:0] in;
        integer r, c;
        reg [63:0] out;
    begin
        out = 64'd0;
        for (r = 0; r < 8; r = r + 1) begin
            for (c = 0; c < 8; c = c + 1) begin
                // 這裡實現的是「左右翻轉 + 順時針 90 度」
                // 邏輯：輸出(r, c) 來自 輸入的(7-c, 7-r)
                out[r*8 + c] = in[(7-c)*8 + (7-r)];
            end
        end
        flip_lr_and_rot_cw = out;
    end
    endfunction

    // ------------------------------------------------------------------------
    // 2. 原始圖案定義 (未旋轉)
    // ------------------------------------------------------------------------

    localparam [63:0] PATTERN_1_RAW = {
        8'b00001000,
        8'b00011000,
        8'b00101000,
        8'b00001000,
        8'b00001000,
        8'b00001000,
        8'b00111110,
        8'b00000000
    };

    localparam [63:0] PATTERN_2_RAW = {
        8'b00111100, 
		  8'b01000010, 
		  8'b00000010, 
		  8'b00011100,
        8'b00100000, 
		  8'b01000000, 
		  8'b01111110, 
		  8'b00000000
    };

    localparam [63:0] PATTERN_X_RAW = {
        8'b10000001, 
		  8'b01000010, 
		  8'b00100100, 
		  8'b00011000,
        8'b00011000, 
		  8'b00100100, 
		  8'b01000010, 
		  8'b10000001
    };

    localparam [63:0] PATTERN_O_RAW = {
        8'b00111100, 
		  8'b01000010, 
		  8'b10000001, 
		  8'b10000001,
        8'b10000001, 
		  8'b10000001, 
		  8'b01000010, 
		  8'b00111100
    };

    localparam [63:0] PATTERN_E_RAW = {
        8'b01111110, 
		  8'b01000000, 
		  8'b01000000, 
		  8'b01111100,
		  8'b01000000, 
		  8'b01000000, 
		  8'b01111110,
		  8'b00000000
    };

    localparam [63:0] PATTERN_CLEAR = 64'd0;

    // ------------------------------------------------------------------------
    // 3. 轉換後圖案（實際顯示用）
    // ------------------------------------------------------------------------
    localparam [63:0] PATTERN_1 = flip_lr_and_rot_cw(PATTERN_1_RAW);
    localparam [63:0] PATTERN_2 = flip_lr_and_rot_cw(PATTERN_2_RAW);
    localparam [63:0] PATTERN_X = flip_lr_and_rot_cw(PATTERN_X_RAW);
    localparam [63:0] PATTERN_O = flip_lr_and_rot_cw(PATTERN_O_RAW);
    localparam [63:0] PATTERN_E = flip_lr_and_rot_cw(PATTERN_E_RAW);

    // ------------------------------------------------------------------------
    // 4. 顯示邏輯判定 (MUX)
    // ------------------------------------------------------------------------
    reg [63:0] current_pattern;

    always @(*) begin
        if (show_mode_num == 2'd1) begin
            current_pattern = PATTERN_1;
        end else if (show_mode_num == 2'd2) begin
            current_pattern = PATTERN_2;
        end else if (!mode) begin
            // Basic Mode
            if (all_off)          current_pattern = PATTERN_CLEAR;
            else if (basic_error) current_pattern = PATTERN_E;
            else                  current_pattern = PATTERN_CLEAR;
        end else begin
            // Mini Game Mode
            if (all_off)          current_pattern = PATTERN_CLEAR;
            else if (basic_error) current_pattern = PATTERN_E;
            else if (game_win)    current_pattern = PATTERN_O;
            else if (game_lose)   current_pattern = PATTERN_X;
            else                  current_pattern = PATTERN_CLEAR;
        end
    end

    // ------------------------------------------------------------------------
    // 5. 掃描與輸出控制
    // ------------------------------------------------------------------------
    reg [15:0] clk_div;
    reg [2:0]  row_sel;

    always @(posedge clk) begin
        if (clk_div >= 16'd4999) begin
            clk_div <= 0;
            row_sel <= row_sel + 1;
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    always @(*) begin
        // Row 掃描 (Active Low)
        row = 8'b11111111;
        row[row_sel] = 1'b0;

        // Column 輸出 (Active High)
        case (row_sel)
            3'd0: begin col0 = current_pattern[63:56]; col1 = current_pattern[63:56]; end
            3'd1: begin col0 = current_pattern[55:48]; col1 = current_pattern[55:48]; end
            3'd2: begin col0 = current_pattern[47:40]; col1 = current_pattern[47:40]; end
            3'd3: begin col0 = current_pattern[39:32]; col1 = current_pattern[39:32]; end
            3'd4: begin col0 = current_pattern[31:24]; col1 = current_pattern[31:24]; end
            3'd5: begin col0 = current_pattern[23:16]; col1 = current_pattern[23:16]; end
            3'd6: begin col0 = current_pattern[15:8];  col1 = current_pattern[15:8];  end
            3'd7: begin col0 = current_pattern[7:0];   col1 = current_pattern[7:0];   end
            default: begin col0 = 8'h00; col1 = 8'h00; end
        endcase
    end

endmodule
