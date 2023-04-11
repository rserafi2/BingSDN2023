"""

Copyright (c) 2020 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""

import logging
import os
from scapy.layers.l2 import Ether, ARP
from scapy.layers.inet import IP, UDP

import cocotb_test.simulator
import cocotb
from cocotb.log import SimLog
from cocotb.clock import Clock
from cocotb.triggers import *
from cocotbext.eth import GmiiFrame, MiiPhy

from cocotbext.spi import *

import warnings
warnings.filterwarnings("ignore") 

class TB:
    def __init__(self, dut, speed=100e6):
        self.dut = dut

        self.log = SimLog("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk, 8, units="ns").start())

        self.if0_mii_phy = MiiPhy(dut.if0_phy_txd, None, dut.if0_phy_tx_en, dut.if0_phy_tx_clk,
            dut.if0_phy_rxd, dut.if0_phy_rx_er, dut.if0_phy_rx_dv, dut.if0_phy_rx_clk, speed=speed)
        
        self.if1_mii_phy = MiiPhy(dut.if1_phy_txd, None, dut.if1_phy_tx_en, dut.if1_phy_tx_clk,
            dut.if1_phy_rxd, dut.if1_phy_rx_er, dut.if1_phy_rx_dv, dut.if1_phy_rx_clk, speed=speed)
        
        self.if2_mii_phy = MiiPhy(dut.if2_phy_txd, None, dut.if2_phy_tx_en, dut.if2_phy_tx_clk,
            dut.if2_phy_rxd, dut.if2_phy_rx_er, dut.if2_phy_rx_dv, dut.if2_phy_rx_clk, speed=speed)

        self.spi_signals = SpiSignals(
            sclk = dut.SCLK,
            mosi = dut.MOSI,
            miso = dut.MISO,
            cs   = dut.SS,
        )

        dut.if0_phy_crs.setimmediatevalue(0)
        dut.if0_phy_col.setimmediatevalue(0)

        dut.if1_phy_crs.setimmediatevalue(0)
        dut.if1_phy_col.setimmediatevalue(0)

        dut.if2_phy_crs.setimmediatevalue(0)
        dut.if2_phy_col.setimmediatevalue(0)

        #dut.spi_byte_rx.setimmediatevalue(255)
        #dut.spi_byte_rx_valid.setimmediatevalue(0)

    async def init(self):

        self.dut.rst.setimmediatevalue(0)

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst <= 1

        for k in range(10):
            await RisingEdge(self.dut.clk)

        self.dut.rst <= 0


def send_spi_message(tb, hex_val):
    

@cocotb.test()
async def run_test(dut):

    tb = TB(dut)

    await tb.init()

    # Construct and send packet to interface 0 Rx
    tb.log.info("Send packet to interface 0 Rx")
    payload = bytes([x % 256 for x in range(1000)])
    #eth = Ether(src='5a:51:52:53:54:55', dst='b0:25:aa:2d:d3:7e')
    eth = Ether(src='e4:5f:01:f0:34:97', dst='b0:25:aa:2d:d3:7e')
    ip = IP(src='192.168.1.100', dst='192.168.1.128')
    udp = UDP(sport=5678, dport=1234)
    test_pkt = eth / ip / udp / payload
    test_frame = GmiiFrame.from_payload(test_pkt.build())
    await tb.if1_mii_phy.rx.send(test_frame)
    
    payload2 = bytes([x % 256 for x in range(1000)])
    eth2 = Ether(src='b0:25:aa:2d:d3:7e', dst='e4:5f:01:f0:34:97')
    ip2 = IP(src='192.168.1.100', dst='192.168.1.128')
    udp2 = UDP(sport=5678, dport=1234)
    test_pkt2 = eth2 / ip2 / udp2 / payload2
    test_frame2 = GmiiFrame.from_payload(test_pkt2.build())
    await tb.if0_mii_phy.rx.send(test_frame2)

    # Receive packet from interface 1 Tx
    #tb.log.info("Receive packet from Interface 2 Tx")
    tx_frame = await tb.if0_mii_phy.tx.recv()
    tx_pkt = Ether(bytes(tx_frame.get_payload()))
    #tb.log.info("test_pkt = %s", repr(test_pkt))
    #tb.log.info("tx_pkt = %s", repr(tx_pkt))
    
    #await Timer(250, units='us')
    
    assert tx_pkt.dst == test_pkt.dst
    assert tx_pkt.src == test_pkt.src
    assert tx_pkt[IP].dst == test_pkt[IP].dst
    assert tx_pkt[IP].src == test_pkt[IP].src
    assert tx_pkt[UDP].dport == test_pkt[UDP].dport
    assert tx_pkt[UDP].sport == test_pkt[UDP].sport
    assert tx_pkt[UDP].payload == test_pkt[UDP].payload
    
    tx_frame2 = await tb.if1_mii_phy.tx.recv()
    tx_pkt2 = Ether(bytes(tx_frame2.get_payload()))

    assert tx_pkt2.dst == test_pkt2.dst
    assert tx_pkt2.src == test_pkt2.src
    assert tx_pkt2[IP].dst == test_pkt2[IP].dst
    assert tx_pkt2[IP].src == test_pkt2[IP].src
    assert tx_pkt2[UDP].dport == test_pkt2[UDP].dport
    assert tx_pkt2[UDP].sport == test_pkt2[UDP].sport
    assert tx_pkt2[UDP].payload == test_pkt2[UDP].payload
    
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    
# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', 'lib'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'eth', 'lib', 'axis', 'rtl'))
eth_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'eth', 'rtl'))


def test_fpga_core(request):
    dut = "fpga_core"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "forwarder.v"),
        os.path.join(rtl_dir, "packet_arbiter.v"),
        os.path.join(rtl_dir, "forwarding_table.v"),
        os.path.join(rtl_dir, "spi_controller.v"),
        os.path.join(rtl_dir, "spi_byte_if.v"),
        os.path.join(eth_rtl_dir, "eth_mac_mii_fifo.v"),
        os.path.join(eth_rtl_dir, "eth_mac_mii.v"),
        os.path.join(eth_rtl_dir, "ssio_sdr_in.v"),
        os.path.join(eth_rtl_dir, "mii_phy_if.v"),
        os.path.join(eth_rtl_dir, "eth_mac_1g.v"),
        os.path.join(eth_rtl_dir, "axis_gmii_rx.v"),
        os.path.join(eth_rtl_dir, "axis_gmii_tx.v"),
        os.path.join(eth_rtl_dir, "lfsr.v"),
        os.path.join(eth_rtl_dir, "eth_axis_rx.v"),
        os.path.join(eth_rtl_dir, "eth_axis_tx.v"),
        os.path.join(eth_rtl_dir, "udp_complete.v"),
        os.path.join(eth_rtl_dir, "udp_checksum_gen.v"),
        os.path.join(eth_rtl_dir, "udp.v"),
        os.path.join(eth_rtl_dir, "udp_ip_rx.v"),
        os.path.join(eth_rtl_dir, "udp_ip_tx.v"),
        os.path.join(eth_rtl_dir, "ip_complete.v"),
        os.path.join(eth_rtl_dir, "ip.v"),
        os.path.join(eth_rtl_dir, "ip_eth_rx.v"),
        os.path.join(eth_rtl_dir, "ip_eth_tx.v"),
        os.path.join(eth_rtl_dir, "ip_arb_mux.v"),
        os.path.join(eth_rtl_dir, "arp.v"),
        os.path.join(eth_rtl_dir, "arp_cache.v"),
        os.path.join(eth_rtl_dir, "arp_eth_rx.v"),
        os.path.join(eth_rtl_dir, "arp_eth_tx.v"),
        os.path.join(eth_rtl_dir, "eth_arb_mux.v"),
        os.path.join(axis_rtl_dir, "arbiter.v"),
        os.path.join(axis_rtl_dir, "priority_encoder.v"),
        os.path.join(axis_rtl_dir, "axis_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo.v"),
        os.path.join(axis_rtl_dir, "axis_async_fifo_adapter.v"),
    ]

    parameters = {}

    # parameters['A'] = val

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
