# 🐍 Snake Game on FPGA (ZedBoard Zynq-7000)

This project implements the classic **Snake Game** using **Verilog HDL**, targeting the **ZedBoard Zynq-7000 SoC FPGA**. It supports VGA graphics, score display via LEDs, and responsive user control. Additional features include **mines as obstacles**, **two-player logic (P1 vs P2)**, and a **binary scoreboard**.

---

## 🎯 Features

- Real-time Snake game with VGA display.
- Direction control using ZedBoard push buttons.
- **Two-player logic**: Switch between P1 and P2.
- **Mines randomly appear** as obstacles; collision ends the game.
- On-board **LED scoreboard** shows current score in binary.
- Optimized for minimal resource usage.

---

## 🧰 Target Hardware

- **Board**: ZedBoard Zynq-7000 (XC7Z020-1CLG484C)
- **FPGA Family**: Xilinx Zynq-7000 SoC
- **Toolchain**: Vivado Design Suite (tested on 2020.2+)
- **Display**: VGA Monitor (640x480 resolution)

---

## 🧠 Game Architecture

### 🎮 Controls

| Button | Function         |
|--------|------------------|
| BTNU   | Move Up          |
| BTND   | Move Down        |
| BTNL   | Move Left        |
| BTNR   | Move Right       |
| BTNC   | Reset Game       |

### 👥 P1 / P2 Logic

- The game supports **two-player switching** using an internal signal or optional team-select input.
- Only one player is active at a time. The scoreboard and direction input reflect the active player.
- This can be extended to alternate players on reset or timeout.

### 💣 Mine Implementation

- Mines are statically or pseudo-randomly placed on the grid.
- Each mine occupies a tile on the 20×20 game grid.
- When the snake head collides with a mine, the game ends.
- Mines are stored and rendered similar to food but never relocate.

### 💡 Score Counter

- Score is displayed on 8 on-board LEDs in binary.
- Every food consumed increases the score.
- Verilog counter logic is used to increment and update the `score` output vector mapped to the LED pins.

---

### Demonstration link

- https://youtu.be/fCc7-x8J_OQ?si=85MgjoPG0ffG0bkp
