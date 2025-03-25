#############################################################################
# Constraints for Snake Game on Zynq-7000 board (ZC702/ZC706/ZedBoard)
#############################################################################

# Clock signal (100 MHz)
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

# Reset button
set_property PACKAGE_PIN P16 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Directional control buttons
# Up button
set_property PACKAGE_PIN R16 [get_ports btn_up]
set_property IOSTANDARD LVCMOS33 [get_ports btn_up]

# Down button
set_property PACKAGE_PIN N15 [get_ports btn_down]
set_property IOSTANDARD LVCMOS33 [get_ports btn_down]

# Left button
set_property PACKAGE_PIN R18 [get_ports btn_left]
set_property IOSTANDARD LVCMOS33 [get_ports btn_left]

# Right button
set_property PACKAGE_PIN T18 [get_ports btn_right]
set_property IOSTANDARD LVCMOS33 [get_ports btn_right]

# VGA Connector
# VGA Horizontal Sync
set_property PACKAGE_PIN V20 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]

# VGA Vertical Sync
set_property PACKAGE_PIN W19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

# VGA Red Channel
set_property PACKAGE_PIN W18 [get_ports {red[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {red[0]}]
set_property PACKAGE_PIN W17 [get_ports {red[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {red[1]}]
set_property PACKAGE_PIN V16 [get_ports {red[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {red[2]}]
set_property PACKAGE_PIN V15 [get_ports {red[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {red[3]}]

# VGA Green Channel
set_property PACKAGE_PIN W15 [get_ports {green[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {green[0]}]
set_property PACKAGE_PIN V14 [get_ports {green[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {green[1]}]
set_property PACKAGE_PIN U15 [get_ports {green[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {green[2]}]
set_property PACKAGE_PIN U14 [get_ports {green[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {green[3]}]

# VGA Blue Channel
set_property PACKAGE_PIN V13 [get_ports {blue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {blue[0]}]
set_property PACKAGE_PIN U13 [get_ports {blue[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {blue[1]}]
set_property PACKAGE_PIN V12 [get_ports {blue[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {blue[2]}]
set_property PACKAGE_PIN U12 [get_ports {blue[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {blue[3]}]

# False path constraints
set_false_path -from [get_ports {btn_up btn_down btn_left btn_right reset}]

# Configuration options
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]

# Timing constraints
create_clock -period 11.765 -name vga_clk -waveform {0.000 5.882} [get_pins {vga_ctrl/clock_divider_reg[2]/Q}]
set_clock_groups -asynchronous -group [get_clocks {sys_clk_pin}] -group [get_clocks {vga_clk}]
