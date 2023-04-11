
# FPGA settings
FPGA_PART = xc7a35ti-csg324-1l
FPGA_TOP = fpga
FPGA_ARCH = artix7

RTL_DIR = rtl/
VERILOG_ETHERNET_RTL_DIR = rtl/lib
VERILOG_AXIS_RTL_DIR = rtl/lib/axis
VERILOG_ETHERNET_XDC_DIR = syn/

# project files
SYN_FILES =  ${RTL_DIR}/fpga.v
SYN_FILES += ${RTL_DIR}/fpga_core.v
SYN_FILES += ${RTL_DIR}/debounce_switch.v
SYN_FILES += ${RTL_DIR}/sync_signal.v
SYN_FILES += ${RTL_DIR}/mii_ip.v
SYN_FILES += ${RTL_DIR}/forwarding_table.v
SYN_FILES += ${RTL_DIR}/packet_arbiter.v
SYN_FILES += ${RTL_DIR}/forwarder.v
SYN_FILES += ${RTL_DIR}/spi_byte_if.v
SYN_FILES += ${RTL_DIR}/spi_controller.v

# verilog-ethernet lib files
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/ssio_sdr_in.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/mii_phy_if.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/eth_mac_mii_fifo.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/eth_mac_mii.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/eth_mac_1g.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/axis_gmii_rx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/axis_gmii_tx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/lfsr.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/eth_axis_rx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/eth_axis_tx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/udp_complete.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/udp_checksum_gen.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/udp.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/udp_ip_rx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/udp_ip_tx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/ip_complete.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/ip.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/ip_eth_rx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/ip_eth_tx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/ip_arb_mux.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/arp.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/arp_cache.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/arp_eth_rx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/arp_eth_tx.v
SYN_FILES += ${VERILOG_ETHERNET_RTL_DIR}/eth_arb_mux.v

# verilog-axis lib files
SYN_FILES += ${VERILOG_AXIS_RTL_DIR}/arbiter.v
SYN_FILES += ${VERILOG_AXIS_RTL_DIR}/priority_encoder.v
SYN_FILES += ${VERILOG_AXIS_RTL_DIR}/axis_fifo.v
SYN_FILES += ${VERILOG_AXIS_RTL_DIR}/axis_async_fifo.v
SYN_FILES += ${VERILOG_AXIS_RTL_DIR}/axis_async_fifo_adapter.v
SYN_FILES += ${VERILOG_AXIS_RTL_DIR}/sync_reset.v

# XDC files
XDC_FILES = fpga.xdc
#XDC_FILES += ${VERILOG_ETHERNET_XDC_DIR}/mii_phy_if.tcl
#XDC_FILES += ${VERILOG_ETHERNET_XDC_DIR}/eth_mac_fifo.tcl
#XDC_FILES += ${VERILOG_ETHERNET_XDC_DIR}/axis_async_fifo.tcl
#XDC_FILES += ${VERILOG_ETHERNET_XDC_DIR}/sync_reset.tcl

include ../common/vivado.mk

program: $(FPGA_TOP).bit
	echo "open_hw" > program.tcl
	echo "connect_hw_server" >> program.tcl
	echo "open_hw_target" >> program.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> program.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> program.tcl
	echo "set_property PROGRAM.FILE {$(FPGA_TOP).bit} [current_hw_device]" >> program.tcl
	echo "program_hw_devices [current_hw_device]" >> program.tcl
	echo "exit" >> program.tcl
	vivado -nojournal -nolog -mode batch -source program.tcl

%.mcs %.prm: %.bit
	echo "write_cfgmem -force -format mcs -size 16 -interface SPIx4 -loadbit {up 0x0000000 $*.bit} -checksum -file $*.mcs" > generate_mcs.tcl
	echo "exit" >> generate_mcs.tcl
	vivado -nojournal -nolog -mode batch -source generate_mcs.tcl
	mkdir -p rev
	COUNT=100; \
	while [ -e rev/$*_rev$$COUNT.bit ]; \
	do COUNT=$$((COUNT+1)); done; \
	COUNT=$$((COUNT-1)); \
	for x in .mcs .prm; \
	do cp $*$$x rev/$*_rev$$COUNT$$x; \
	echo "Output: rev/$*_rev$$COUNT$$x"; done;

flash: $(FPGA_TOP).mcs $(FPGA_TOP).prm
	echo "open_hw_manager" > flash.tcl
	echo "connect_hw_server" >> flash.tcl
	echo "open_hw_target" >> flash.tcl
	echo "current_hw_device [lindex [get_hw_devices] 0]" >> flash.tcl
	echo "refresh_hw_device -update_hw_probes false [current_hw_device]" >> flash.tcl
	echo "create_hw_cfgmem -hw_device [lindex [get_hw_devices xc7a35t_0] 0] [lindex [get_cfgmem_parts {s25fl128sxxxxxx0-spi-x1_x2_x4}] 0]" >> flash.tcl
	echo "current_hw_cfgmem -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM [current_hw_device]]" >> flash.tcl
	echo "set_property PROGRAM.FILES [list \"$(FPGA_TOP).mcs\"] [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.PRM_FILES [list \"$(FPGA_TOP).prm\"] [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.ERASE 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.CFG_PROGRAM 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.VERIFY 1 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.CHECKSUM 0 [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.ADDRESS_RANGE {use_file} [current_hw_cfgmem]" >> flash.tcl
	echo "set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [current_hw_cfgmem]" >> flash.tcl
	echo "create_hw_bitstream -hw_device [current_hw_device] [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]" >> flash.tcl
	echo "program_hw_devices [current_hw_device]" >> flash.tcl
	echo "refresh_hw_device [current_hw_device]" >> flash.tcl
	echo "program_hw_cfgmem -hw_cfgmem [current_hw_cfgmem]" >> flash.tcl
	echo "boot_hw_device [current_hw_device]" >> flash.tcl
	echo "exit" >> flash.tcl
	vivado -nojournal -nolog -mode batch -source flash.tcl

