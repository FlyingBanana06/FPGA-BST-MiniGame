// ============================================================================
// 模組名稱：switch_decoder
// 功能描述：解碼 SW1~SW9。
//           1. 確保只有一個開關開啟時 valid = 1。
//           2. 若 SW8 或 SW9 開啟，則判定為 invalid (error)。
//           3. 輸出對應的 BST 節點索引值 (0~6)。
// ============================================================================

module switch_decoder ( 
    input  [9:0] sw, 
    output reg [2:0] index, 
    output reg       valid
);

    integer i;
    reg [3:0] count;
    wire [8:0] sw_to_check = sw[9:1]; // 掃描 SW1~SW9

    always @(*) begin
        count = 4'd0;
        index = 3'd0;
        valid = 1'b0;
        
        for (i = 0; i < 9; i = i + 1) begin
            if (sw_to_check[i]) count = count + 1;
        end
            
        // 只有在剛好啟動「一個」開關，且該開關不在 SW8, SW9 時才算 valid
        if (count == 4'd1 && sw[9:8] == 2'b00) begin
            valid = 1'b1;
            for(i = 0; i < 7; i = i + 1) begin
                if(sw_to_check[i]) index = i[2:0];
            end
        end else begin
            valid = 1'b0;
        end
    end
endmodule