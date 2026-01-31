// ============================================================================
// 模組名稱：bst_mini_game (Top Module)
// ============================================================================

module bst_mini_game (
    input        clk,      // 系統時脈 50MHz
    input  [9:0] sw,       // SW0:模式, SW1-7:節點
    input  [1:0] key,      // KEY1:Same, KEY0:Diff
    output [6:0] HEX0,     // 七段顯示器(個位)
    output [6:0] HEX1,     // 七段顯示器(十位)
    output [7:0] dot_row,  // 點矩陣列
    output [7:0] dot_col0, // 點矩陣左
    output [7:0] dot_col1  // 點矩陣右
);

    // ------------------------------------------------------------------------
    // 1. BST 數值參數設定 (在這裡修改數字，改完後重新編譯燒錄)
    // ------------------------------------------------------------------------
    parameter Val1 = 8'd1;
    parameter Val2 = 8'd2;
    parameter Val3 = 8'd3;
    parameter Val4 = 8'd4;
    parameter Val5 = 8'd5;
    parameter Val6 = 8'd6;
    parameter Val7 = 8'd7;

    // ------------------------------------------------------------------------
    // 2. 內部訊號定義
    // ------------------------------------------------------------------------
    wire [2:0]  dec_index;
    wire        dec_valid;
    wire [7:0]  bst_node_key;
    wire        bst_error;
    wire [7:0]  game_value;
    wire        game_is_correct;
    wire        user_win, user_lose;
    wire [55:0] keys_bus; 

    wire mode_mini_game = sw[0];
    wire all_sw_off     = (sw[9:1] == 9'b0);

    // 模式切換提示計時器 (150,000,000 / 50MHz = 3秒)
    reg [27:0] mode_timer;
    reg        last_mode;
    wire [1:0] current_mode_num = mode_mini_game ? 2'd2 : 2'd1;
    
    always @(posedge clk) begin
        last_mode <= sw[0];
        if (sw[0] != last_mode) 
            mode_timer <= 28'd150_000_000; 
        else if (mode_timer > 0)
            mode_timer <= mode_timer - 1'b1;
    end
    wire is_showing_mode = (mode_timer > 0);

    // ------------------------------------------------------------------------
    // 3. 子模組實例化
    // ------------------------------------------------------------------------
    
    // 開關解碼器
    switch_decoder u_dec (
        .sw(sw), 
        .index(dec_index), 
        .valid(dec_valid) 
    );

    // BST 核心邏輯 (將參數連入)
    bst_core u_bst (
        .in0(Val1), .in1(Val2), .in2(Val3), .in3(Val4), 
        .in4(Val5), .in5(Val6), .in6(Val7), 
        .index(dec_index), 
        .valid(dec_valid), 
        .node_key(bst_node_key), 
        .error(bst_error),
        .all_sorted_keys(keys_bus)
    );

    // 遊戲題目產生器
    mini_game_gen u_game (
        .clk(clk), 
        .index(dec_index),
        .valid(dec_valid),        // 接入有效訊號
        .all_keys(keys_bus),
        .node_key(bst_node_key),
        .game_value(game_value), 
        .is_correct(game_is_correct)
    );

    // 勝負判定邏輯
    key_judge u_judge (
        .key_same(~key[1]), // Key 是 Low-Active
        .key_diff(~key[0]), 
        .is_correct(game_is_correct), 
        .win(user_win), 
        .lose(user_lose)
    );

    // ------------------------------------------------------------------------
    // 4. 七段顯示器內容切換 MUX
    // ------------------------------------------------------------------------
    reg [7:0] display_value;
    reg       display_error;
    reg       display_none;

    always @(*) begin
        display_value = 8'd0;
        display_error = 1'b0;
        display_none  = 1'b0;
        
        if (all_sw_off) 
            display_none = 1'b1;
        else if (!dec_valid) 
            display_error = 1'b1;
        else begin
            if (mode_mini_game) 
                display_value = game_value;
            else 
                display_value = bst_node_key;
        end
    end

    // ------------------------------------------------------------------------
    // 5. 外設驅動模組
    // ------------------------------------------------------------------------    
    hex_driver u_hex (
        .value(display_value), 
        .error(display_error), 
        .none(display_none), 
        .HEX0(HEX0), 
        .HEX1(HEX1)
    );

    dot_matrix_driver u_dot (
        .clk(clk), 
        .mode(mode_mini_game),
        .all_off(all_sw_off),
        .basic_error(display_error), 
        .game_win(user_win),
        .game_lose(user_lose),
        .show_mode_num(is_showing_mode ? current_mode_num : 2'd0),
        .row(dot_row), 
        .col0(dot_col0), 
        .col1(dot_col1)
    );

endmodule