# 🐍 Snake Game on FPGA (EW-2-2)

This project demonstrates the classic **Snake Game** implemented using **Verilog HDL** and deployed on an **FPGA** board. The game visuals are rendered on a **VGA display**, and the score is shown via **onboard LEDs**. Controls are managed using **push buttons** or keyboard inputs, depending on the hardware setup.

---

## 🎯 Objectives

- Implement Snake Game logic using hardware description (Verilog)
- Generate VGA output for game display (640×480 resolution)
- Use push buttons for user input (Up, Down, Left, Right)
- Display live score using onboard LEDs
- Deploy and run the game on an FPGA board using Xilinx Vivado

---

## 🧱 System Architecture

The game system is modular and includes:

- `snake_controller.v` – Controls movement, direction, and growth logic
- `vga_generator.v` – Generates VGA synchronization signals
- `interface_display.v` – Manages the display of the snake, food, and grid
- `scoreboard.v` – Updates the score and interfaces with LEDs
- `top_module.v` – Instantiates and connects all modules

---

## 📦 Hardware Platform

- **FPGA Board**: (e.g., Basys 3, Nexys A7 — update accordingly)
- **Clock Input**: 100 MHz
- **Buttons Used**: BTNL, BTNR, BTNU, BTND, BTNC (center for reset)
- **VGA Monitor**: 640×480 @ 60Hz resolution
- **Onboard LEDs**: Show score in binary

---

## 🛠️ Tools Used

- **Xilinx Vivado** (Synthesis, Implementation, Bitstream generation)
- **Verilog HDL** (for logic design)
- **FPGA Simulation Tools** (optional: GTKWave, ModelSim)

---

## 🚦 Vivado Flow

1. **Synthesis** – Converts Verilog into gate-level logic
2. **Implementation** – Maps design onto FPGA fabric
3. **Bitstream Generation** – Produces `.bit` file for programming the board
4. **Device Programming** – Deploys design to hardware

All constraint files (`.xdc`) are configured to map the VGA, LEDs, push buttons, and clock properly.

---

## 📊 Results

- **FPS**: ~5 frames per second
- **Grid Size**: 20×20 tiles (each 20×20 pixels)
- **Max Snake Length**: 15 segments
- **Input Latency**: Instantaneous
- **VGA Display**: Clean rendering of game state
- **Scoreboard**: LEDs show binary score

A snapshot of Vivado synthesis is available in the `/images` folder.

---

## 🎥 Demo

Watch the game in action:  
🔗 [YouTube Demo](https://www.youtube.com/watch?v=05jZkSMZmzs)

---

## 📁 Folder Structure

