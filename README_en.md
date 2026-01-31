# FPGA-based BST Mini Game (DE10-Lite)

This project implements a **Binary Search Tree (BST)** data structure on the Intel MAX 10 FPGA (DE10-Lite). It combines hardware-level sorting logic with an interactive "Mini-Game" to provide a tangible way to explore and test understanding of tree structures.

## 📋 System Overview

The system operates in two primary modes, toggled by **SW0**:

* **Basic Mode (Browsing)**: Allows users to inspect the key value of specific nodes in the BST.
* **Mini Game Mode (Challenge)**: The system generates a "challenge value" which might be correct or incorrect for a chosen node. The user must judge its validity using hardware buttons.

## 🎮 Hardware Configuration

### Control Inputs

* **[Switch SW0] Mode Select**
* `0`: Basic Mode (BST Browser)
* `1`: Mini Game Mode (Challenge)


* **[Switches SW1 ~ SW7] Node Selection**
* Maps to 7 BST nodes using **Level-order** indexing.


* **[Button KEY1] Same**
* In Game Mode: Confirms the displayed value is **correct** for the selected node.


* **[Button KEY0] Different**
* In Game Mode: Confirms the displayed value is **incorrect** for the selected node.



### Visual Feedback

* **[7-Segment Displays HEX0~1]**: Displays node values (00-99) or the error code `EE`.
* **[8x8 Dot Matrix]**:
* Mode Indicator: Displays `1` or `2` upon mode entry.
* Game Result: Displays `O` for success and `X` for failure.
* Error Detection: Displays `E` when invalid switch combinations are detected.



---

## 🔬 Key Design Features

### 1. Automated BST Sorting Engine

The `bst_core` module accepts 7 unsigned 8-bit integers. It utilizes a **Bubble Sort** algorithm to organize inputs and automatically maps them to a balanced BST structure (ensuring Left Child < Root < Right Child).

### 2. Randomized Challenge Logic

To implement randomness in hardware, the `mini_game_gen` module uses a high-speed 26-bit counter (`cnt`):

* **50% Probability**: The system checks `cnt[1]` at the moment of node selection.
* **True/False Generation**: If `cnt[1]` is `0`, the true value is shown; if `1`, a neighboring node's value is displayed as a distractor.

### 3. Hardware Error Detection (Switch Decoder)

The `switch_decoder` monitors all input switches to prevent logical conflicts:

* Triggers an error if multiple node switches (`SW1-SW7`) are active simultaneously.
* Triggers an error if undefined switches (`SW8` or `SW9`) are toggled.
* Displays `EE` on HEX and `E` on the Dot Matrix to alert the user.

---

## 📂 Project Structure

```text
Your_Project/
├── bst_mini_game.qpf      # Quartus Project File
├── bst_mini_game.qsf      # Pin Assignments & Project Settings
├── .gitignore             # Excludes compilation artifacts (db, output_files, etc.)
└── src/
    ├── bst_mini_game.v      # Top Module: Interconnects all sub-modules
    ├── bst_core.v           # BST Core: Handles sorting and node mapping
    ├── mini_game_gen.v      # Game Generator: Logic for randomizing challenges
    ├── switch_decoder.v     # Decoder: Input validation and error detection
    ├── key_judge.v          # Judge: Compares user input vs. system answer
    ├── hex_driver.v         # HEX Driver: Controls 7-segment output
    └── dot_matrix_driver.v  # Matrix Driver: Handles pattern scanning and 90° rotation

```

---

## 🚀 Getting Started

1. Open `bst_mini_game.qpf` in **Quartus Prime 18.1** or later.
2. To customize the BST data, modify the `Val1` through `Val7` parameters in `bst_mini_game.v`.
3. Compile the project.
4. Program the `.sof` file to your **DE10-Lite** development board.

---
