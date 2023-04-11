# XDC constraints for the Digilent Arty board

# General configuration
set_property CFGBVS VCCO                     [current_design]
set_property CONFIG_VOLTAGE 3.3              [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50  [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

# 100 MHz clock
set_property -dict {LOC E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 10.000 -name clk [get_ports clk]

# LEDs
#set_property -dict {LOC G6   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led0_r]
#set_property -dict {LOC F6   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led0_g]
#set_property -dict {LOC E1   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led0_b]
#set_property -dict {LOC G3   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led1_r]
#set_property -dict {LOC J4   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led1_g]
#set_property -dict {LOC G4   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led1_b]
#set_property -dict {LOC J3   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led2_r]
#set_property -dict {LOC J2   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led2_g]
#set_property -dict {LOC H4   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led2_b]
#set_property -dict {LOC K1   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led3_r]
#set_property -dict {LOC H6   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led3_g]
#set_property -dict {LOC K2   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led3_b]
#set_property -dict {LOC H5   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led4]
#set_property -dict {LOC J5   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led5]
#set_property -dict {LOC T9   IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led6]
#set_property -dict {LOC T10  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports led7]

#set_false_path -to [get_ports {led0_r led0_g led0_b led1_r led1_g led1_b led2_r led2_g led2_b led3_r led3_g led3_b led4 led5 led6 led7}]
#set_output_delay 0 [get_ports {led0_r led0_g led0_b led1_r led1_g led1_b led2_r led2_g led2_b led3_r led3_g led3_b led4 led5 led6 led7}]

# Reset button
set_property -dict {LOC C2   IOSTANDARD LVCMOS33} [get_ports reset_n]

set_false_path -from [get_ports {reset_n}]
set_input_delay 0 [get_ports {reset_n}]

# Push buttons
#set_property -dict {LOC D9   IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
#set_property -dict {LOC C9   IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
#set_property -dict {LOC B9   IOSTANDARD LVCMOS33} [get_ports {btn[2]}]
#set_property -dict {LOC B8   IOSTANDARD LVCMOS33} [get_ports {btn[3]}]

#set_false_path -from [get_ports {btn[*]}]
#set_input_delay 0 [get_ports {btn[*]}]

# Toggle switches
#set_property -dict {LOC A8   IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
#set_property -dict {LOC C11  IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
#set_property -dict {LOC C10  IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
#set_property -dict {LOC A10  IOSTANDARD LVCMOS33} [get_ports {sw[3]}]

#set_false_path -from [get_ports {sw[*]}]
#set_input_delay 0 [get_ports {sw[*]}]

# GPIO
# PMOD JA
set_property -dict {LOC G13  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JA1] ;# PMOD JA pin 1
set_property -dict {LOC B11  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JA2] ;# PMOD JA pin 2
set_property -dict {LOC A11  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JA3] ;# PMOD JA pin 3
set_property -dict {LOC D12  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JA4] ;# PMOD JA pin 4
set_property -dict {LOC D13  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JA7] ;# PMOD JA pin 7
set_property -dict {LOC B18  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JA8] ;# PMOD JA pin 8
set_property -dict {LOC A18  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JA9] ;# PMOD JA pin 9
set_property -dict {LOC K16  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JA10] ;# PMOD JA pin 10
# PMOD JB
set_property -dict {LOC E15  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JB1] ;# PMOD JB pin 1
set_property -dict {LOC E16  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JB2] ;# PMOD JB pin 2
set_property -dict {LOC D15  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JB3] ;# PMOD JB pin 3
set_property -dict {LOC C15  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JB4] ;# PMOD JB pin 4
set_property -dict {LOC J17  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JB7] ;# PMOD JB pin 7
set_property -dict {LOC J18  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JB8] ;# PMOD JB pin 8
set_property -dict {LOC K15  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JB9] ;# PMOD JB pin 9
set_property -dict {LOC J15  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JB10] ;# PMOD JB pin 10
# PMOD JC
set_property -dict {LOC U12  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JC1] ;# PMOD JC pin 1
set_property -dict {LOC V12  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JC2] ;# PMOD JC pin 2
set_property -dict {LOC V10  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JC3] ;# PMOD JC pin 3
set_property -dict {LOC V11  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JC4] ;# PMOD JC pin 4
set_property -dict {LOC U14  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JC7] ;# PMOD JC pin 7
set_property -dict {LOC V14  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JC8] ;# PMOD JC pin 8
set_property -dict {LOC T13  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JC9] ;# PMOD JC pin 9
set_property -dict {LOC U13  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JC10] ;# PMOD JC pin 10
# PMOD JD
set_property -dict {LOC D4   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JD1] ;# PMOD JD pin 1
set_property -dict {LOC D3   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JD2] ;# PMOD JD pin 2
set_property -dict {LOC F4   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JD3] ;# PMOD JD pin 3
set_property -dict {LOC F3   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JD4] ;# PMOD JD pin 4
set_property -dict {LOC E2   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JD7] ;# PMOD JD pin 7
set_property -dict {LOC D2   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JD8] ;# PMOD JD pin 8
set_property -dict {LOC H2   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JD9] ;# PMOD JD pin 9
set_property -dict {LOC G2   IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports JD10] ;# PMOD JD pin 10

set_property -dict { LOC T14   IOSTANDARD LVCMOS33 } [get_ports ck_io5]; #IO_L14P_T2_SRCC_14           Sch=ck_io[5]

# Ethernet MII PHY
set_property -dict {LOC F15  IOSTANDARD LVCMOS33} [get_ports phy_rx_clk]
set_property -dict {LOC D18  IOSTANDARD LVCMOS33} [get_ports {phy_rxd[0]}]
set_property -dict {LOC E17  IOSTANDARD LVCMOS33} [get_ports {phy_rxd[1]}]
set_property -dict {LOC E18  IOSTANDARD LVCMOS33} [get_ports {phy_rxd[2]}]
set_property -dict {LOC G17  IOSTANDARD LVCMOS33} [get_ports {phy_rxd[3]}]
set_property -dict {LOC G16  IOSTANDARD LVCMOS33} [get_ports phy_rx_dv]
set_property -dict {LOC C17  IOSTANDARD LVCMOS33} [get_ports phy_rx_er]
set_property -dict {LOC H16  IOSTANDARD LVCMOS33} [get_ports phy_tx_clk]
set_property -dict {LOC H14  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports {phy_txd[0]}]
set_property -dict {LOC J14  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports {phy_txd[1]}]
set_property -dict {LOC J13  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports {phy_txd[2]}]
set_property -dict {LOC H17  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports {phy_txd[3]}]
set_property -dict {LOC H15  IOSTANDARD LVCMOS33 SLEW FAST DRIVE 12} [get_ports phy_tx_en]
set_property -dict {LOC D17  IOSTANDARD LVCMOS33} [get_ports phy_col]
set_property -dict {LOC G14  IOSTANDARD LVCMOS33} [get_ports phy_crs]
set_property -dict {LOC G18  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_ref_clk]
set_property -dict {LOC C16  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_reset_n]
set_property -dict {LOC K13  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_mdio]
set_property -dict {LOC F16  IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports phy_mdc]

create_clock -period 40.000 -name phy_rx_clk [get_ports phy_rx_clk]
create_clock -period 40.000 -name phy_tx_clk [get_ports phy_tx_clk]

create_clock -period 40.000 -name JA10 [get_ports JA10];#txclk
create_clock -period 40.000 -name JD10 [get_ports JD10]

create_clock -period 40.000 -name ck_io5 [get_ports ck_io5];#rxclk
create_clock -period 40.000 -name JC3 [get_ports JC3]

set_false_path -to [get_ports {phy_ref_clk phy_reset_n}]
set_output_delay 0 [get_ports {phy_ref_clk phy_reset_n}]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets JD10_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets JA10_IBUF]
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ck_io5_IBUF]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets phy_tx_clk_IBUF]

#set_false_path -to [get_ports {phy_mdio phy_mdc}]
#set_output_delay 0 [get_ports {phy_mdio phy_mdc}]
#set_false_path -from [get_ports {phy_mdio}]
#set_input_delay 0 [get_ports {phy_mdio}]

set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { MISO }]; #IO_L17N_T2_35 Sch=ck_miso
set_property -dict { PACKAGE_PIN H1    IOSTANDARD LVCMOS33 } [get_ports { MOSI }]; #IO_L17P_T2_35 Sch=ck_mosi
set_property -dict { PACKAGE_PIN F1    IOSTANDARD LVCMOS33 } [get_ports { SCLK }]; #IO_L18P_T2_35 Sch=ck_sck
set_property -dict { PACKAGE_PIN C1    IOSTANDARD LVCMOS33 } [get_ports { SS }]; #IO_L16N_T2_35 Sch=ck_ss