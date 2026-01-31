# FPGA-based BST Mini Game (DE10-Lite)

本專案在 Terasic DE10-Lite (Intel MAX 10) FPGA 上實作了一個二元搜尋樹 (BST) 資料結構，並結合了互動查詢與動態小遊戲功能。使用者可以透過硬體開關瀏覽樹狀結構，或進入遊戲模式測試對 BST 節點邏輯的判斷。

## 📋 系統概論 (System Overview)

系統主要分為兩種操作模式，由 **SW0** 進行切換：

* **Basic Mode (瀏覽模式)**：使用者撥動 `SW1~SW7` 選擇特定節點，七段顯示器會即時顯示該節點在 BST 中對應的數值。
* **Mini Game Mode (遊戲模式)**：系統隨機顯示「正確」或「錯誤」的節點數值，玩家需透過 `KEY1` (Same) 或 `KEY0` (Diff) 進行判定。

## 🛠 硬體控制配置 (Hardware Setup)

* **[開關 SW0] 模式切換**
* `0`: **Basic Mode** (瀏覽模式)
* `1`: **Mini Game Mode** (遊戲模式)


* **[開關 SW1 ~ SW7] 節點選擇**
* 對應 BST 的 7 個節點（採 Level-order 編碼映射）。


* **[按鈕 KEY1] Same**
* 遊戲模式：判定當前顯示數值與節點正確數值「相符」。


* **[按鈕 KEY0] Different**
* 遊戲模式：判定當前顯示數值與節點正確數值「不相符」。


* **[七段顯示器 HEX0 ~ 1] 數值顯示**
* 顯示節點數值 (00-99)；若操作無效則顯示錯誤碼 `EE`。


* **[點矩陣顯示器 Dot Matrix] 狀態回饋**
* 顯示當前模式 (`1` / `2`)。
* 遊戲結果判定：正確顯示 `O`，錯誤顯示 `X`。
* 系統異常偵測：顯示 `E` (Error)。

---

## 🔬 關鍵設計 (Key Design)

### 1. BST Core & 自動排序

系統接收 7 組 8-bit 輸入數值，`bst_core` 模組內建 **Bubble Sort (冒泡排序)** 演算法。排序後的數值會自動映射至平衡二元樹的結構中，確保符合 BST 特性（左子樹 < 根節點 < 右子樹）。

### 2. Mini Game 隨機邏輯

為了在硬體上實現題目隨機性，`mini_game_gen` 使用了一個 **26 位元的計數器 (cnt)**：

* **50% 正確機率**：利用 `cnt[1]` 的狀態。當 `cnt[1] == 0` 時，題目為正確數值；當 `cnt[1] == 1` 時，顯示鄰近節點的數值作為干擾項。
* **判定邏輯**：玩家按下按鈕後，`key_judge` 模組會比對玩家選擇與系統生成的 `is_correct` 標記，決定勝負。

### 3. 硬體防呆與偵測 (Switch Decoder Error Detect)

為了避免操作邏輯錯誤導致系統異常，`switch_decoder` 模組會檢查以下狀況：

* 同時開啟兩個（含）以上的 `SW1~SW7`。
* 開啟未定義的 `SW8` 或 `SW9`。
若觸發上述條件，**HEX** 將顯示 `EE`，**點矩陣** 則會亮起 `E` (Error) 圖樣。

---

## 📂 檔案結構

```text
Your_Project/
├── bst_mini_game.qpf      # Quartus 專案主檔
├── bst_mini_game.qsf      # 硬體腳位分配 (Pin Assignments) 與專案設定
├── .gitignore             # 排除 Quartus 編譯產生的暫存與雜項檔案
└── src/
    ├── bst_mini_game.v      # 主模組：負責串接各功能模組與時脈分配
    ├── bst_core.v           # BST 核心：處理數值排序與樹狀結構映射
    ├── mini_game_gen.v      # 遊戲產生器：負責題目隨機化與正誤判定邏輯
    ├── switch_decoder.v     # 開關解碼：檢查硬體 Switch 狀態與合法性偵測
    ├── key_judge.v          # 按鍵判定：比對玩家輸入與系統答案是否一致
    ├── hex_driver.v         # 七段顯示器驅動：顯示節點數值或錯誤代碼 (EE)
    └── dot_matrix_driver.v  # 點矩陣驅動：處理圖案掃描、旋轉與顯示邏輯

```

---

## 🚀 如何使用

1. 下載專案並使用 **Quartus Prime** 開啟 `bst_mini_game.qpf`。
2. 若需修改預設節點數值，請至 `bst_mini_game.v` 修改 `Val1 ~ Val7` 參數。
3. 編譯專案並將 `.sof` 檔燒錄至 **DE10-Lite** 開發板。

---

