// ============================================================================
// 模組名稱：bst_core
// 功能描述：儲存二元搜尋樹節點數值，自動進行排序，並根據索引輸出對應節點
// ============================================================================

module bst_core (
    input  [7:0]  in0, in1, in2, in3, in4, in5, in6, // 外部輸入的 7 組數值
    input  [2:0]  index,           // 經解碼後的節點索引 (0-6)
    input         valid,           // 輸入訊號合法旗標
    output reg [7:0] node_key,     // 當前選中節點的數值
    output reg    error,           // 錯誤偵測訊號
    output [55:0] all_sorted_keys  // 打包後的排序數值 (供遊戲模式比對)
);

    reg [7:0] s [0:6];
    integer i, j;
    reg [7:0] temp;

    // 排序邏輯
    always @(*) begin
        s[0]=in0; s[1]=in1; s[2]=in2; s[3]=in3; s[4]=in4; s[5]=in5; s[6]=in6;
        for (i = 6; i > 0; i = i - 1) begin
            for (j = 0; j < i; j = j + 1) begin
                if (s[j] > s[j+1]) begin
                    temp = s[j]; s[j] = s[j+1]; s[j+1] = temp;
                end
            end
        end
    end

    // 輸出邏輯：只有在 valid 時才輸出，否則輸出 0
    always @(*) begin
        if (valid) begin
            error = 1'b0;
            case(index)
                3'd0: node_key = s[3]; // Root
                3'd1: node_key = s[1]; // L
                3'd2: node_key = s[5]; // R
                3'd3: node_key = s[0]; // LL
                3'd4: node_key = s[2]; // LR
                3'd5: node_key = s[4]; // RL
                3'd6: node_key = s[6]; // RR
                default: node_key = 8'd0;
            endcase
        end else begin
            node_key = 8'd0;
            error = 1'b0;
        end
    end

    // 將 Level Order 順序打包傳給遊戲模組
    assign all_sorted_keys = {s[6], s[4], s[2], s[0], s[5], s[1], s[3]};

endmodule