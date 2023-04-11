# Copyright (c) 2020 Alex Forencich
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

TOPLEVEL_LANG = verilog

RTL_DIR = ../rtl/
VERILOG_ETHERNET_RTL_DIR = ../rtl/lib
VERILOG_AXIS_RTL_DIR = ../rtl/lib/axis

SIM ?= icarus
WAVES ?= 1

COCOTB_HDL_TIMEUNIT = 1ns
COCOTB_HDL_TIMEPRECISION = 1ps

DUT      = fpga_core
TOPLEVEL = $(DUT)
MODULE   = test_$(DUT)

VERILOG_SOURCES += ${RTL_DIR}/fpga_core.v
VERILOG_SOURCES += ${RTL_DIR}/debounce_switch.v
VERILOG_SOURCES += ${RTL_DIR}/sync_signal.v
VERILOG_SOURCES += ${RTL_DIR}/mii_ip.v
VERILOG_SOURCES += ${RTL_DIR}/forwarding_table.v
VERILOG_SOURCES += ${RTL_DIR}/packet_arbiter.v
VERILOG_SOURCES += ${RTL_DIR}/forwarder.v
VERILOG_SOURCES += ${RTL_DIR}/spi_byte_if.v
VERILOG_SOURCES += ${RTL_DIR}/spi_controller.v

# verilog-ethernet lib files
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/ssio_sdr_in.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/mii_phy_if.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/eth_mac_mii_fifo.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/eth_mac_mii.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/eth_mac_1g.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/axis_gmii_rx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/axis_gmii_tx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/lfsr.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/eth_axis_rx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/eth_axis_tx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/udp_complete.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/udp_checksum_gen.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/udp.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/udp_ip_rx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/udp_ip_tx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/ip_complete.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/ip.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/ip_eth_rx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/ip_eth_tx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/ip_arb_mux.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/arp.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/arp_cache.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/arp_eth_rx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/arp_eth_tx.v
VERILOG_SOURCES += ${VERILOG_ETHERNET_RTL_DIR}/eth_arb_mux.v

# verilog-axis lib files
VERILOG_SOURCES += ${VERILOG_AXIS_RTL_DIR}/arbiter.v
VERILOG_SOURCES += ${VERILOG_AXIS_RTL_DIR}/priority_encoder.v
VERILOG_SOURCES += ${VERILOG_AXIS_RTL_DIR}/axis_fifo.v
VERILOG_SOURCES += ${VERILOG_AXIS_RTL_DIR}/axis_async_fifo.v
VERILOG_SOURCES += ${VERILOG_AXIS_RTL_DIR}/axis_async_fifo_adapter.v
VERILOG_SOURCES += ${VERILOG_AXIS_RTL_DIR}/sync_reset.v
# module parameters
#export PARAM_A ?= value

ifeq ($(SIM), icarus)
	PLUSARGS += -fst

#	COMPILE_ARGS += -P $(TOPLEVEL).A=$(PARAM_A)

	ifeq ($(WAVES), 1)
		VERILOG_SOURCES += iverilog_dump.v
		COMPILE_ARGS += -s iverilog_dump
	endif
else ifeq ($(SIM), verilator)
	COMPILE_ARGS += -Wno-SELRANGE -Wno-WIDTH

#	COMPILE_ARGS += -GA=$(PARAM_A)

	ifeq ($(WAVES), 1)
		COMPILE_ARGS += --trace-fst
	endif
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

iverilog_dump.v:
	echo 'module iverilog_dump();' > $@
	echo 'initial begin' >> $@
	echo '    $$dumpfile("$(TOPLEVEL).fst");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL));' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@

clean::
	@rm -rf iverilog_dump.v
	@rm -rf dump.fst $(TOPLEVEL).fst
