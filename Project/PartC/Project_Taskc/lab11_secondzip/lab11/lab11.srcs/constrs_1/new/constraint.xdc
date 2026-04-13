## ============================================================================
## Clock signal
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]


## ============================================================================
## GCD HARDWARE MODULE PIN ASSIGNMENTS
## ============================================================================

## Reset - Center Button (BTNC)
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports reset]

## GCD MODE ENABLE - Slide Switch sw[15]
set_property -dict { PACKAGE_PIN R2    IOSTANDARD LVCMOS33 } [get_ports gcd_enable]

## OUTPUT ENABLE - Slide Switch sw[14]
set_property -dict { PACKAGE_PIN T1    IOSTANDARD LVCMOS33 } [get_ports output_enable]

## VALUE A LOAD BUTTON - Button Up (BTNU)
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports a_load]

## VALUE B LOAD BUTTON - Button Down (BTND)
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports b_load]

## INPUT VALUE - Shared Slide Switches sw[7:0] (Lower 8 switches)
## Set the switches, then press a_load to load variable a, change switches, then press b_load to load variable b
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {input_val[0]}]
set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports {input_val[1]}]
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports {input_val[2]}]
set_property -dict { PACKAGE_PIN W17   IOSTANDARD LVCMOS33 } [get_ports {input_val[3]}]
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports {input_val[4]}]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports {input_val[5]}]
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports {input_val[6]}]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports {input_val[7]}]

## 7-SEGMENT DISPLAY - OUTPUT

## Seven Segment Cathodes (seg[6:0]) - Active Low
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]

## Seven Segment Anodes (an[3:0]) - Active Low
set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {an[3]}]


## ============================================================================
## Configuration options, can be used for all designs
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]