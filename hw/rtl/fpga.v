/*

Copyright (c) 2014-2018 Alex Forencich

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

*/

// Language: Verilog 2001

`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FPGA top-level module
 */
module fpga (
    // 100MHz clock
    input  wire       clk,
    
    // active low reset (pushbutton)
    input  wire       reset_n,

    // PMOD ports
    // JA and JB, eth interface 0
    input   wire JA1,   // crs
    input   wire JA2,   // col
    output  wire JA3,   // txd3
    output  wire JA4,   // txd2
    output  wire JA7,   // txd1
    output  wire JA8,   // txd0
    output  wire JA9,   // tx_en
    input   wire JA10,  // tx_clk (switched with JB7)

    output  wire JB1,   // unused
    input   wire JB2,   // rx_er
    input   wire JB3,   // rx_clk
    input   wire JB4,   // rx_dv
    input   wire JB7,   // rxd0 (switched with JA10)
    input   wire JB8,   // rxd1
    input   wire JB9,   // rxd2
    input   wire JB10,  // rxd3

    // JC and JD, eth interface 1
    output  wire JC1,   // unused
    input   wire JC2,   // rx_er
    output  wire JC3,   // unused
    input   wire JC4,   // rx_dv
    input   wire JC7,   // rxd[0]
    input   wire JC8,   // rxd[1]
    input   wire JC9,   // rxd[2]
    input   wire JC10,  // rxd[3]

    input   wire JD1,   // crs
    input   wire JD2,   // col
    output  wire JD3,   // txd[3]
    output  wire JD4,   // txd[2]
    output  wire JD7,   // txd[1]
    output  wire JD8,   // txd[0]
    output  wire JD9,   // tx_en
    input   wire JD10,  // tx_clk

    input  wire ck_io5, // rx_clk

    // on-board eth interface 2
    output wire       phy_ref_clk,
    input  wire       phy_rx_clk,
    input  wire [3:0] phy_rxd,
    input  wire       phy_rx_dv,
    input  wire       phy_rx_er,
    input  wire       phy_tx_clk,
    output wire [3:0] phy_txd,
    output wire       phy_tx_en,
    input  wire       phy_col,
    input  wire       phy_crs,
    output wire       phy_reset_n,

    // spi interface
    input  wire       SCLK, // SPI clock
	input  wire       MOSI, // SPI master out, slave in
	output wire       MISO, // SPI slave in, master out
	input  wire       SS    // SPI slave select
);

// SPI block i/o
//wire spi_byte_rx_valid;
//wire [7:0] spi_byte_rx;
//wire [7:0] spi_byte_tx;

// Clock and reset
wire clk_ibufg;

// Internal 125 MHz clock
wire clk_mmcm_out;
wire clk_int;
wire rst_int;

wire mmcm_rst = ~reset_n;
wire mmcm_locked;
wire mmcm_clkfb;

IBUFG
clk_ibufg_inst(
    .I(clk),
    .O(clk_ibufg)
);

wire clk_25mhz_mmcm_out;
wire clk_25mhz_int;

// MMCM instance
// 100 MHz in, 125 MHz out
// PFD range: 10 MHz to 550 MHz
// VCO range: 600 MHz to 1200 MHz
// M = 10, D = 1 sets Fvco = 1000 MHz (in range)
// Divide by 8 to get output frequency of 125 MHz
// Divide by 40 to get output frequency of 25 MHz
// 1000 / 5 = 200 MHz
MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(8),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(40),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(10),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(10.0),
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_mmcm_inst (
    .CLKIN1(clk_ibufg),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(clk_25mhz_mmcm_out),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);

BUFG
clk_bufg_inst (
    .I(clk_mmcm_out),
    .O(clk_int)
);

BUFG
clk_25mhz_bufg_inst (
    .I(clk_25mhz_mmcm_out),
    .O(clk_25mhz_int)
);

sync_reset #(
    .N(4)
)
sync_reset_inst (
    .clk(clk_int),
    .rst(~mmcm_locked),
    .out(rst_int)
);

assign phy_ref_clk = clk_25mhz_int;

fpga_core #(
    .TARGET("XILINX")
)
core_inst (
    /*
     * Clock: 125MHz
     * Synchronous reset
     */
    .clk(clk_int),
    .rst(rst_int),

    .if0_phy_rx_clk(phy_rx_clk),
    .if0_phy_rxd(phy_rxd),
    .if0_phy_rx_dv(phy_rx_dv),
    .if0_phy_rx_er(phy_rx_er),
    .if0_phy_tx_clk(phy_tx_clk),
    .if0_phy_txd(phy_txd),
    .if0_phy_tx_en(phy_tx_en),
    .if0_phy_col(phy_col),
    .if0_phy_crs(phy_crs),
    .if0_phy_reset_n(phy_reset_n),

    .if1_phy_rx_clk(JB3),
    .if1_phy_rxd({JB10, JB9, JB8, JB7}),
    .if1_phy_rx_dv(JB4),
    .if1_phy_rx_er(JB2),
    .if1_phy_tx_clk(JA10),
    .if1_phy_txd({JA3, JA4, JA7, JA8}),
    .if1_phy_tx_en(JA9),
    .if1_phy_col(JA2),
    .if1_phy_crs(JA1),
    .if1_phy_reset_n(),

    .if2_phy_rx_clk(ck_io5),
    .if2_phy_rxd({JC10, JC9, JC8, JC7}),
    .if2_phy_rx_dv(JC4),
    .if2_phy_rx_er(JC2),
    .if2_phy_tx_clk(JD10),
    .if2_phy_txd({JD3, JD4, JD7, JD8}),
    .if2_phy_tx_en(JD9),
    .if2_phy_col(JD2),
    .if2_phy_crs(JD1),
    .if2_phy_reset_n(),

    //.spi_byte_rx_valid(spi_byte_rx_valid),
    //.spi_byte_rx(spi_byte_rx),
    //.spi_byte_tx(spi_byte_tx)

    .SCLK    (SCLK),
    .MOSI    (MOSI),
    .MISO    (MISO),
    .SS      (SS)
);
/*
spi_byte_if 
byte_if(.sysClk  (clk_int), // 125MHz
        .usrReset(rst_int),
        .SCLK    (SCLK),
        .MOSI    (MOSI),
        .MISO    (MISO),
        .SS      (SS),
        .rxValid (spi_byte_rx_valid),
        .rx      (spi_byte_rx),
        .tx      (spi_byte_tx)                
);*/

endmodule

`resetall