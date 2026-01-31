// ============================================================================
// 模組名稱：mini_game_gen
// 功能描述：產生隨機題目。當使用者選定節點時，隨機決定顯示正確值或錯誤值（鄰近節點）
// ============================================================================

module mini_game_gen (
    input            clk,         // 系統時脈 50MHz
    input      [2:0] index,       // 當前選中的節點索引
    input            valid,       // 索引有效訊號
    input      [55:0] all_keys,    // 來自 bst_core 排序後的完整資料總線
    input      [7:0]  node_key,    // 當前索引對應的正確數值
    output     [7:0]  game_value,  // 輸出：顯示在七段顯示器上的題目數值
    output            is_correct   // 輸出：系統記錄該題目是否為正確答案
);

    // ------------------------------------------------------------------------
    // 1. 資料解包 (Level Order Unpacking)
    // ------------------------------------------------------------------------
    wire [7:0] s [0:6];
    assign s[0] = all_keys[7:0];   // BST Node 0
    assign s[1] = all_keys[15:8];  // BST Node 1
    assign s[2] = all_keys[23:16]; // BST Node 2
    assign s[3] = all_keys[31:24]; // BST Node 3
    assign s[4] = all_keys[39:32]; // BST Node 4
    assign s[5] = all_keys[47:40]; // BST Node 5
    assign s[6] = all_keys[55:48]; // BST Node 6

    // ------------------------------------------------------------------------
    // 2. 內部暫存器與計數器
    // ------------------------------------------------------------------------
    reg [25:0] cnt;                // 高速計數器，用於模擬隨機機率
    reg [7:0]  reg_game_value;     // 儲存當前題目數值
    reg        reg_is_correct;     // 儲存當前題目正誤狀態
    reg        last_valid;         // 用於偵測 valid 訊號的邊緣 (Edge Detection)

    // 取得下一個節點索引作為錯誤干擾項 (0->1, 1->2 ... 6->0)
    wire [2:0] next_idx = (index == 3'd6) ? 3'd0 : (index + 3'd1);

    // ------------------------------------------------------------------------
    // 3. 題目產生邏輯 (Sequential Logic)
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        cnt <= cnt + 1;            // 計數器持續運行
        last_valid <= valid;       // 延遲一個時鐘週期以偵測邊緣

        // 偵測 valid 的上升邊緣 (Positive Edge)：當使用者按下開關的瞬間
        if (valid && !last_valid) begin
            // 根據計數器最後一位的值隨機決定題目性質
            if (cnt[1] == 1'b0) begin 
                reg_game_value <= node_key;    // 顯示正確答案
                reg_is_correct <= 1'b1;
            end else begin
                reg_game_value <= s[next_idx]; // 顯示鄰近錯誤答案
                reg_is_correct <= 1'b0;
            end
        end
    end

    // ------------------------------------------------------------------------
    // 4. 輸出賦值
    // ------------------------------------------------------------------------
    assign game_value = reg_game_value;
    assign is_correct = reg_is_correct;

endmodule