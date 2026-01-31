// ============================================================================
// 模組名稱：key_judge
// 功能描述：判斷使用者按鍵輸入 (Same/Diff) 與系統正確答案是否一致，並輸出勝負
// ============================================================================

module key_judge (
    input      key_same,   // 按鈕：判定為「相同」 (KEY1)
    input      key_diff,   // 按鈕：判定為「不同」 (KEY0)
    input      is_correct, // 系統比對結果 (1:正確, 0:不正確)
    output reg win,        // 輸出：判定勝利
    output reg lose        // 輸出：判定失敗
);

    // 勝負判定邏輯 (Combinational Logic)
    always @(*) begin
        // 預設初始狀態
        win  = 1'b0;
        lose = 1'b0;

        // 同時按下兩顆按鍵視為非法操作，直接判定失敗
        if (key_same && key_diff) begin
            win  = 1'b0;
            lose = 1'b1;
        end 
        
        // 使用者判斷為「相同」
        else if (key_same) begin
            if (is_correct) begin
                win  = 1'b1; // 猜對了
                lose = 1'b0;
            end else begin
                win  = 1'b0; // 猜錯了
                lose = 1'b1;
            end
        end 
        
        // 使用者判斷為「不同」
        else if (key_diff) begin
            if (!is_correct) begin
                win  = 1'b1; // 猜對了 (確實不同)
                lose = 1'b0;
            end else begin
                win  = 1'b0; // 猜錯了 (其實相同)
                lose = 1'b1;
            end
        end
    end

endmodule