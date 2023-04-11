`resetall
`timescale 1ns / 1ps
`default_nettype none

/*
 * FPGA core logic
 */
module fpga_core #
(
    parameter TARGET = "GENERIC",
    parameter NUM_INTERFACES = 3
)
(
    input  wire       clk, // 125 MHz
    input  wire       rst,

    // Interface 0
    input  wire       if0_phy_rx_clk,
    input  wire [3:0] if0_phy_rxd,
    input  wire       if0_phy_rx_dv,
    input  wire       if0_phy_rx_er,
    input  wire       if0_phy_tx_clk,
    output wire [3:0] if0_phy_txd,
    output wire       if0_phy_tx_en,
    input  wire       if0_phy_col,
    input  wire       if0_phy_crs,
    output wire       if0_phy_reset_n,

    // Interface 1
    input  wire       if1_phy_rx_clk,
    input  wire [3:0] if1_phy_rxd,
    input  wire       if1_phy_rx_dv,
    input  wire       if1_phy_rx_er,
    input  wire       if1_phy_tx_clk,
    output wire [3:0] if1_phy_txd,
    output wire       if1_phy_tx_en,
    input  wire       if1_phy_col,
    input  wire       if1_phy_crs,
    output wire       if1_phy_reset_n,

    // Interface 2
    input  wire       if2_phy_rx_clk,
    input  wire [3:0] if2_phy_rxd,
    input  wire       if2_phy_rx_dv,
    input  wire       if2_phy_rx_er,
    input  wire       if2_phy_tx_clk,
    output wire [3:0] if2_phy_txd,
    output wire       if2_phy_tx_en,
    input  wire       if2_phy_col,
    input  wire       if2_phy_crs,
    output wire       if2_phy_reset_n,

    // SPI interface
    //input  wire spi_byte_rx_valid,
    //input  wire [7:0] spi_byte_rx,
    //output wire spi_byte_tx_valid,
    //output wire [7:0] spi_byte_tx,
    input wire SCLK,
    input wire MOSI,
    output wire MISO,
    input wire SS
);

assign if0_phy_reset_n = !rst;
assign if1_phy_reset_n = !rst;
assign if2_phy_reset_n = !rst;

wire spi_byte_rx_valid;
wire [7:0] spi_byte_rx;
wire [7:0] spi_byte_tx;

// Connections from mii_ip.v to forwarder.v modules
// Three IP_ETH interfaces
wire        if0_to_forwarder0_ip_hdr_valid;
wire        if0_to_forwarder0_ip_hdr_ready;
wire [47:0] if0_to_forwarder0_ip_eth_dest_mac;
wire [47:0] if0_to_forwarder0_ip_eth_src_mac;
wire [15:0] if0_to_forwarder0_ip_eth_type;
wire [3:0]  if0_to_forwarder0_ip_version;
wire [3:0]  if0_to_forwarder0_ip_ihl;
wire [5:0]  if0_to_forwarder0_ip_dscp;
wire [1:0]  if0_to_forwarder0_ip_ecn;
wire [15:0] if0_to_forwarder0_ip_length;
wire [15:0] if0_to_forwarder0_ip_identification;
wire [2:0]  if0_to_forwarder0_ip_flags;
wire [12:0] if0_to_forwarder0_ip_fragment_offset;
wire [7:0]  if0_to_forwarder0_ip_ttl;
wire [7:0]  if0_to_forwarder0_ip_protocol;
wire [15:0] if0_to_forwarder0_ip_header_checksum;
wire [31:0] if0_to_forwarder0_ip_source_ip;
wire [31:0] if0_to_forwarder0_ip_dest_ip;
wire [7:0]  if0_to_forwarder0_ip_payload_axis_tdata;
wire        if0_to_forwarder0_ip_payload_axis_tvalid;
wire        if0_to_forwarder0_ip_payload_axis_tready;
wire        if0_to_forwarder0_ip_payload_axis_tlast;
wire        if0_to_forwarder0_ip_payload_axis_tuser;

wire        if1_to_forwarder1_ip_hdr_valid;
wire        if1_to_forwarder1_ip_hdr_ready;
wire [47:0] if1_to_forwarder1_ip_eth_dest_mac;
wire [47:0] if1_to_forwarder1_ip_eth_src_mac;
wire [15:0] if1_to_forwarder1_ip_eth_type;
wire [3:0]  if1_to_forwarder1_ip_version;
wire [3:0]  if1_to_forwarder1_ip_ihl;
wire [5:0]  if1_to_forwarder1_ip_dscp;
wire [1:0]  if1_to_forwarder1_ip_ecn;
wire [15:0] if1_to_forwarder1_ip_length;
wire [15:0] if1_to_forwarder1_ip_identification;
wire [2:0]  if1_to_forwarder1_ip_flags;
wire [12:0] if1_to_forwarder1_ip_fragment_offset;
wire [7:0]  if1_to_forwarder1_ip_ttl;
wire [7:0]  if1_to_forwarder1_ip_protocol;
wire [15:0] if1_to_forwarder1_ip_header_checksum;
wire [31:0] if1_to_forwarder1_ip_source_ip;
wire [31:0] if1_to_forwarder1_ip_dest_ip;
wire [7:0]  if1_to_forwarder1_ip_payload_axis_tdata;
wire        if1_to_forwarder1_ip_payload_axis_tvalid;
wire        if1_to_forwarder1_ip_payload_axis_tready;
wire        if1_to_forwarder1_ip_payload_axis_tlast;
wire        if1_to_forwarder1_ip_payload_axis_tuser;

wire        if2_to_forwarder2_ip_hdr_valid;
wire        if2_to_forwarder2_ip_hdr_ready;
wire [47:0] if2_to_forwarder2_ip_eth_dest_mac;
wire [47:0] if2_to_forwarder2_ip_eth_src_mac;
wire [15:0] if2_to_forwarder2_ip_eth_type;
wire [3:0]  if2_to_forwarder2_ip_version;
wire [3:0]  if2_to_forwarder2_ip_ihl;
wire [5:0]  if2_to_forwarder2_ip_dscp;
wire [1:0]  if2_to_forwarder2_ip_ecn;
wire [15:0] if2_to_forwarder2_ip_length;
wire [15:0] if2_to_forwarder2_ip_identification;
wire [2:0]  if2_to_forwarder2_ip_flags;
wire [12:0] if2_to_forwarder2_ip_fragment_offset;
wire [7:0]  if2_to_forwarder2_ip_ttl;
wire [7:0]  if2_to_forwarder2_ip_protocol;
wire [15:0] if2_to_forwarder2_ip_header_checksum;
wire [31:0] if2_to_forwarder2_ip_source_ip;
wire [31:0] if2_to_forwarder2_ip_dest_ip;
wire [7:0]  if2_to_forwarder2_ip_payload_axis_tdata;
wire        if2_to_forwarder2_ip_payload_axis_tvalid;
wire        if2_to_forwarder2_ip_payload_axis_tready;
wire        if2_to_forwarder2_ip_payload_axis_tlast;
wire        if2_to_forwarder2_ip_payload_axis_tuser;

// Connections from arbiter.v to mii_ip.v modules
// Three IP_ETH interfaces
wire        arbiter0_to_if0_ip_hdr_valid;
wire        arbiter0_to_if0_ip_hdr_ready;
wire [47:0] arbiter0_to_if0_ip_eth_dest_mac;
wire [47:0] arbiter0_to_if0_ip_eth_src_mac;
wire [15:0] arbiter0_to_if0_ip_eth_type;
wire [3:0]  arbiter0_to_if0_ip_version;
wire [3:0]  arbiter0_to_if0_ip_ihl;
wire [5:0]  arbiter0_to_if0_ip_dscp;
wire [1:0]  arbiter0_to_if0_ip_ecn;
wire [15:0] arbiter0_to_if0_ip_length;
wire [15:0] arbiter0_to_if0_ip_identification;
wire [2:0]  arbiter0_to_if0_ip_flags;
wire [12:0] arbiter0_to_if0_ip_fragment_offset;
wire [7:0]  arbiter0_to_if0_ip_ttl;
wire [7:0]  arbiter0_to_if0_ip_protocol;
wire [15:0] arbiter0_to_if0_ip_header_checksum;
wire [31:0] arbiter0_to_if0_ip_source_ip;
wire [31:0] arbiter0_to_if0_ip_dest_ip;
wire [7:0]  arbiter0_to_if0_ip_payload_axis_tdata;
wire        arbiter0_to_if0_ip_payload_axis_tvalid;
wire        arbiter0_to_if0_ip_payload_axis_tready;
wire        arbiter0_to_if0_ip_payload_axis_tlast;
wire        arbiter0_to_if0_ip_payload_axis_tuser;

wire        arbiter1_to_if1_ip_hdr_valid;
wire        arbiter1_to_if1_ip_hdr_ready;
wire [47:0] arbiter1_to_if1_ip_eth_dest_mac;
wire [47:0] arbiter1_to_if1_ip_eth_src_mac;
wire [15:0] arbiter1_to_if1_ip_eth_type;
wire [3:0]  arbiter1_to_if1_ip_version;
wire [3:0]  arbiter1_to_if1_ip_ihl;
wire [5:0]  arbiter1_to_if1_ip_dscp;
wire [1:0]  arbiter1_to_if1_ip_ecn;
wire [15:0] arbiter1_to_if1_ip_length;
wire [15:0] arbiter1_to_if1_ip_identification;
wire [2:0]  arbiter1_to_if1_ip_flags;
wire [12:0] arbiter1_to_if1_ip_fragment_offset;
wire [7:0]  arbiter1_to_if1_ip_ttl;
wire [7:0]  arbiter1_to_if1_ip_protocol;
wire [15:0] arbiter1_to_if1_ip_header_checksum;
wire [31:0] arbiter1_to_if1_ip_source_ip;
wire [31:0] arbiter1_to_if1_ip_dest_ip;
wire [7:0]  arbiter1_to_if1_ip_payload_axis_tdata;
wire        arbiter1_to_if1_ip_payload_axis_tvalid;
wire        arbiter1_to_if1_ip_payload_axis_tready;
wire        arbiter1_to_if1_ip_payload_axis_tlast;
wire        arbiter1_to_if1_ip_payload_axis_tuser;

wire        arbiter2_to_if2_ip_hdr_valid;
wire        arbiter2_to_if2_ip_hdr_ready;
wire [47:0] arbiter2_to_if2_ip_eth_dest_mac;
wire [47:0] arbiter2_to_if2_ip_eth_src_mac;
wire [15:0] arbiter2_to_if2_ip_eth_type;
wire [3:0]  arbiter2_to_if2_ip_version;
wire [3:0]  arbiter2_to_if2_ip_ihl;
wire [5:0]  arbiter2_to_if2_ip_dscp;
wire [1:0]  arbiter2_to_if2_ip_ecn;
wire [15:0] arbiter2_to_if2_ip_length;
wire [15:0] arbiter2_to_if2_ip_identification;
wire [2:0]  arbiter2_to_if2_ip_flags;
wire [12:0] arbiter2_to_if2_ip_fragment_offset;
wire [7:0]  arbiter2_to_if2_ip_ttl;
wire [7:0]  arbiter2_to_if2_ip_protocol;
wire [15:0] arbiter2_to_if2_ip_header_checksum;
wire [31:0] arbiter2_to_if2_ip_source_ip;
wire [31:0] arbiter2_to_if2_ip_dest_ip;
wire [7:0]  arbiter2_to_if2_ip_payload_axis_tdata;
wire        arbiter2_to_if2_ip_payload_axis_tvalid;
wire        arbiter2_to_if2_ip_payload_axis_tready;
wire        arbiter2_to_if2_ip_payload_axis_tlast;
wire        arbiter2_to_if2_ip_payload_axis_tuser;

// Connections from forwarder.v to arbiter.v modules
// Six IP_ETH interfaces

// FORWARDER0
wire        forwarder0_to_arbiter1_ip_hdr_valid;
wire        forwarder0_to_arbiter1_ip_hdr_ready;
wire [47:0] forwarder0_to_arbiter1_ip_eth_dest_mac;
wire [47:0] forwarder0_to_arbiter1_ip_eth_src_mac;
wire [15:0] forwarder0_to_arbiter1_ip_eth_type;
wire [3:0]  forwarder0_to_arbiter1_ip_version;
wire [3:0]  forwarder0_to_arbiter1_ip_ihl;
wire [5:0]  forwarder0_to_arbiter1_ip_dscp;
wire [1:0]  forwarder0_to_arbiter1_ip_ecn;
wire [15:0] forwarder0_to_arbiter1_ip_length;
wire [15:0] forwarder0_to_arbiter1_ip_identification;
wire [2:0]  forwarder0_to_arbiter1_ip_flags;
wire [12:0] forwarder0_to_arbiter1_ip_fragment_offset;
wire [7:0]  forwarder0_to_arbiter1_ip_ttl;
wire [7:0]  forwarder0_to_arbiter1_ip_protocol;
wire [15:0] forwarder0_to_arbiter1_ip_header_checksum;
wire [31:0] forwarder0_to_arbiter1_ip_source_ip;
wire [31:0] forwarder0_to_arbiter1_ip_dest_ip;
wire [7:0]  forwarder0_to_arbiter1_ip_payload_axis_tdata;
wire        forwarder0_to_arbiter1_ip_payload_axis_tvalid;
wire        forwarder0_to_arbiter1_ip_payload_axis_tready;
wire        forwarder0_to_arbiter1_ip_payload_axis_tlast;
wire        forwarder0_to_arbiter1_ip_payload_axis_tuser;

wire        forwarder0_to_arbiter2_ip_hdr_valid;
wire        forwarder0_to_arbiter2_ip_hdr_ready;
wire [47:0] forwarder0_to_arbiter2_ip_eth_dest_mac;
wire [47:0] forwarder0_to_arbiter2_ip_eth_src_mac;
wire [15:0] forwarder0_to_arbiter2_ip_eth_type;
wire [3:0]  forwarder0_to_arbiter2_ip_version;
wire [3:0]  forwarder0_to_arbiter2_ip_ihl;
wire [5:0]  forwarder0_to_arbiter2_ip_dscp;
wire [1:0]  forwarder0_to_arbiter2_ip_ecn;
wire [15:0] forwarder0_to_arbiter2_ip_length;
wire [15:0] forwarder0_to_arbiter2_ip_identification;
wire [2:0]  forwarder0_to_arbiter2_ip_flags;
wire [12:0] forwarder0_to_arbiter2_ip_fragment_offset;
wire [7:0]  forwarder0_to_arbiter2_ip_ttl;
wire [7:0]  forwarder0_to_arbiter2_ip_protocol;
wire [15:0] forwarder0_to_arbiter2_ip_header_checksum;
wire [31:0] forwarder0_to_arbiter2_ip_source_ip;
wire [31:0] forwarder0_to_arbiter2_ip_dest_ip;
wire [7:0]  forwarder0_to_arbiter2_ip_payload_axis_tdata;
wire        forwarder0_to_arbiter2_ip_payload_axis_tvalid;
wire        forwarder0_to_arbiter2_ip_payload_axis_tready;
wire        forwarder0_to_arbiter2_ip_payload_axis_tlast;
wire        forwarder0_to_arbiter2_ip_payload_axis_tuser;

wire        forwarder0_to_unused_ip_hdr_valid;
wire        forwarder0_to_unused_ip_hdr_ready;
wire [47:0] forwarder0_to_unused_ip_eth_dest_mac;
wire [47:0] forwarder0_to_unused_ip_eth_src_mac;
wire [15:0] forwarder0_to_unused_ip_eth_type;
wire [3:0]  forwarder0_to_unused_ip_version;
wire [3:0]  forwarder0_to_unused_ip_ihl;
wire [5:0]  forwarder0_to_unused_ip_dscp;
wire [1:0]  forwarder0_to_unused_ip_ecn;
wire [15:0] forwarder0_to_unused_ip_length;
wire [15:0] forwarder0_to_unused_ip_identification;
wire [2:0]  forwarder0_to_unused_ip_flags;
wire [12:0] forwarder0_to_unused_ip_fragment_offset;
wire [7:0]  forwarder0_to_unused_ip_ttl;
wire [7:0]  forwarder0_to_unused_ip_protocol;
wire [15:0] forwarder0_to_unused_ip_header_checksum;
wire [31:0] forwarder0_to_unused_ip_source_ip;
wire [31:0] forwarder0_to_unused_ip_dest_ip;
wire [7:0]  forwarder0_to_unused_ip_payload_axis_tdata;
wire        forwarder0_to_unused_ip_payload_axis_tvalid;
wire        forwarder0_to_unused_ip_payload_axis_tready;
wire        forwarder0_to_unused_ip_payload_axis_tlast;
wire        forwarder0_to_unused_ip_payload_axis_tuser;

// FORWARDER1

wire        forwarder1_to_arbiter0_ip_hdr_valid;
wire        forwarder1_to_arbiter0_ip_hdr_ready;
wire [47:0] forwarder1_to_arbiter0_ip_eth_dest_mac;
wire [47:0] forwarder1_to_arbiter0_ip_eth_src_mac;
wire [15:0] forwarder1_to_arbiter0_ip_eth_type;
wire [3:0]  forwarder1_to_arbiter0_ip_version;
wire [3:0]  forwarder1_to_arbiter0_ip_ihl;
wire [5:0]  forwarder1_to_arbiter0_ip_dscp;
wire [1:0]  forwarder1_to_arbiter0_ip_ecn;
wire [15:0] forwarder1_to_arbiter0_ip_length;
wire [15:0] forwarder1_to_arbiter0_ip_identification;
wire [2:0]  forwarder1_to_arbiter0_ip_flags;
wire [12:0] forwarder1_to_arbiter0_ip_fragment_offset;
wire [7:0]  forwarder1_to_arbiter0_ip_ttl;
wire [7:0]  forwarder1_to_arbiter0_ip_protocol;
wire [15:0] forwarder1_to_arbiter0_ip_header_checksum;
wire [31:0] forwarder1_to_arbiter0_ip_source_ip;
wire [31:0] forwarder1_to_arbiter0_ip_dest_ip;
wire [7:0]  forwarder1_to_arbiter0_ip_payload_axis_tdata;
wire        forwarder1_to_arbiter0_ip_payload_axis_tvalid;
wire        forwarder1_to_arbiter0_ip_payload_axis_tready;
wire        forwarder1_to_arbiter0_ip_payload_axis_tlast;
wire        forwarder1_to_arbiter0_ip_payload_axis_tuser;

wire        forwarder1_to_arbiter2_ip_hdr_valid;
wire        forwarder1_to_arbiter2_ip_hdr_ready;
wire [47:0] forwarder1_to_arbiter2_ip_eth_dest_mac;
wire [47:0] forwarder1_to_arbiter2_ip_eth_src_mac;
wire [15:0] forwarder1_to_arbiter2_ip_eth_type;
wire [3:0]  forwarder1_to_arbiter2_ip_version;
wire [3:0]  forwarder1_to_arbiter2_ip_ihl;
wire [5:0]  forwarder1_to_arbiter2_ip_dscp;
wire [1:0]  forwarder1_to_arbiter2_ip_ecn;
wire [15:0] forwarder1_to_arbiter2_ip_length;
wire [15:0] forwarder1_to_arbiter2_ip_identification;
wire [2:0]  forwarder1_to_arbiter2_ip_flags;
wire [12:0] forwarder1_to_arbiter2_ip_fragment_offset;
wire [7:0]  forwarder1_to_arbiter2_ip_ttl;
wire [7:0]  forwarder1_to_arbiter2_ip_protocol;
wire [15:0] forwarder1_to_arbiter2_ip_header_checksum;
wire [31:0] forwarder1_to_arbiter2_ip_source_ip;
wire [31:0] forwarder1_to_arbiter2_ip_dest_ip;
wire [7:0]  forwarder1_to_arbiter2_ip_payload_axis_tdata;
wire        forwarder1_to_arbiter2_ip_payload_axis_tvalid;
wire        forwarder1_to_arbiter2_ip_payload_axis_tready;
wire        forwarder1_to_arbiter2_ip_payload_axis_tlast;
wire        forwarder1_to_arbiter2_ip_payload_axis_tuser;

wire        forwarder1_to_unused_ip_hdr_valid;
wire        forwarder1_to_unused_ip_hdr_ready;
wire [47:0] forwarder1_to_unused_ip_eth_dest_mac;
wire [47:0] forwarder1_to_unused_ip_eth_src_mac;
wire [15:0] forwarder1_to_unused_ip_eth_type;
wire [3:0]  forwarder1_to_unused_ip_version;
wire [3:0]  forwarder1_to_unused_ip_ihl;
wire [5:0]  forwarder1_to_unused_ip_dscp;
wire [1:0]  forwarder1_to_unused_ip_ecn;
wire [15:0] forwarder1_to_unused_ip_length;
wire [15:0] forwarder1_to_unused_ip_identification;
wire [2:0]  forwarder1_to_unused_ip_flags;
wire [12:0] forwarder1_to_unused_ip_fragment_offset;
wire [7:0]  forwarder1_to_unused_ip_ttl;
wire [7:0]  forwarder1_to_unused_ip_protocol;
wire [15:0] forwarder1_to_unused_ip_header_checksum;
wire [31:0] forwarder1_to_unused_ip_source_ip;
wire [31:0] forwarder1_to_unused_ip_dest_ip;
wire [7:0]  forwarder1_to_unused_ip_payload_axis_tdata;
wire        forwarder1_to_unused_ip_payload_axis_tvalid;
wire        forwarder1_to_unused_ip_payload_axis_tready;
wire        forwarder1_to_unused_ip_payload_axis_tlast;
wire        forwarder1_to_unused_ip_payload_axis_tuser;

// FORWARDER2
wire        forwarder2_to_arbiter0_ip_hdr_valid;
wire        forwarder2_to_arbiter0_ip_hdr_ready;
wire [47:0] forwarder2_to_arbiter0_ip_eth_dest_mac;
wire [47:0] forwarder2_to_arbiter0_ip_eth_src_mac;
wire [15:0] forwarder2_to_arbiter0_ip_eth_type;
wire [3:0]  forwarder2_to_arbiter0_ip_version;
wire [3:0]  forwarder2_to_arbiter0_ip_ihl;
wire [5:0]  forwarder2_to_arbiter0_ip_dscp;
wire [1:0]  forwarder2_to_arbiter0_ip_ecn;
wire [15:0] forwarder2_to_arbiter0_ip_length;
wire [15:0] forwarder2_to_arbiter0_ip_identification;
wire [2:0]  forwarder2_to_arbiter0_ip_flags;
wire [12:0] forwarder2_to_arbiter0_ip_fragment_offset;
wire [7:0]  forwarder2_to_arbiter0_ip_ttl;
wire [7:0]  forwarder2_to_arbiter0_ip_protocol;
wire [15:0] forwarder2_to_arbiter0_ip_header_checksum;
wire [31:0] forwarder2_to_arbiter0_ip_source_ip;
wire [31:0] forwarder2_to_arbiter0_ip_dest_ip;
wire [7:0]  forwarder2_to_arbiter0_ip_payload_axis_tdata;
wire        forwarder2_to_arbiter0_ip_payload_axis_tvalid;
wire        forwarder2_to_arbiter0_ip_payload_axis_tready;
wire        forwarder2_to_arbiter0_ip_payload_axis_tlast;
wire        forwarder2_to_arbiter0_ip_payload_axis_tuser;

wire        forwarder2_to_arbiter1_ip_hdr_valid;
wire        forwarder2_to_arbiter1_ip_hdr_ready;
wire [47:0] forwarder2_to_arbiter1_ip_eth_dest_mac;
wire [47:0] forwarder2_to_arbiter1_ip_eth_src_mac;
wire [15:0] forwarder2_to_arbiter1_ip_eth_type;
wire [3:0]  forwarder2_to_arbiter1_ip_version;
wire [3:0]  forwarder2_to_arbiter1_ip_ihl;
wire [5:0]  forwarder2_to_arbiter1_ip_dscp;
wire [1:0]  forwarder2_to_arbiter1_ip_ecn;
wire [15:0] forwarder2_to_arbiter1_ip_length;
wire [15:0] forwarder2_to_arbiter1_ip_identification;
wire [2:0]  forwarder2_to_arbiter1_ip_flags;
wire [12:0] forwarder2_to_arbiter1_ip_fragment_offset;
wire [7:0]  forwarder2_to_arbiter1_ip_ttl;
wire [7:0]  forwarder2_to_arbiter1_ip_protocol;
wire [15:0] forwarder2_to_arbiter1_ip_header_checksum;
wire [31:0] forwarder2_to_arbiter1_ip_source_ip;
wire [31:0] forwarder2_to_arbiter1_ip_dest_ip;
wire [7:0]  forwarder2_to_arbiter1_ip_payload_axis_tdata;
wire        forwarder2_to_arbiter1_ip_payload_axis_tvalid;
wire        forwarder2_to_arbiter1_ip_payload_axis_tready;
wire        forwarder2_to_arbiter1_ip_payload_axis_tlast;
wire        forwarder2_to_arbiter1_ip_payload_axis_tuser;

wire        forwarder2_to_unused_ip_hdr_valid;
wire        forwarder2_to_unused_ip_hdr_ready;
wire [47:0] forwarder2_to_unused_ip_eth_dest_mac;
wire [47:0] forwarder2_to_unused_ip_eth_src_mac;
wire [15:0] forwarder2_to_unused_ip_eth_type;
wire [3:0]  forwarder2_to_unused_ip_version;
wire [3:0]  forwarder2_to_unused_ip_ihl;
wire [5:0]  forwarder2_to_unused_ip_dscp;
wire [1:0]  forwarder2_to_unused_ip_ecn;
wire [15:0] forwarder2_to_unused_ip_length;
wire [15:0] forwarder2_to_unused_ip_identification;
wire [2:0]  forwarder2_to_unused_ip_flags;
wire [12:0] forwarder2_to_unused_ip_fragment_offset;
wire [7:0]  forwarder2_to_unused_ip_ttl;
wire [7:0]  forwarder2_to_unused_ip_protocol;
wire [15:0] forwarder2_to_unused_ip_header_checksum;
wire [31:0] forwarder2_to_unused_ip_source_ip;
wire [31:0] forwarder2_to_unused_ip_dest_ip;
wire [7:0]  forwarder2_to_unused_ip_payload_axis_tdata;
wire        forwarder2_to_unused_ip_payload_axis_tvalid;
wire        forwarder2_to_unused_ip_payload_axis_tready;
wire        forwarder2_to_unused_ip_payload_axis_tlast;
wire        forwarder2_to_unused_ip_payload_axis_tuser;

// Assign unused valid signals
assign forwarder0_to_unused_ip_hdr_ready = 'b1;
assign forwarder0_to_unused_ip_payload_axis_tready = 'b1;

assign forwarder1_to_unused_ip_hdr_ready = 'b1;
assign forwarder1_to_unused_ip_payload_axis_tready = 'b1;

assign forwarder2_to_unused_ip_hdr_ready = 'b1;
assign forwarder2_to_unused_ip_payload_axis_tready = 'b1;

// Connections from forwarder.v to forwarding_table.v modules
wire        forwarder0_to_ft_hdr_valid;
wire [47:0] forwarder0_to_ft_dest_mac;
wire [47:0] forwarder0_to_ft_src_mac;
wire [31:0] forwarder0_to_ft_dest_ip;
wire [31:0] forwarder0_to_ft_source_ip;

wire                               ft_to_fowarder0_resp_valid;
wire  [$clog2(NUM_INTERFACES)-1:0] ft_to_fowarder0_resp;
wire                               ft_to_fowarder0_drop_packet;

wire        forwarder1_to_ft_hdr_valid;
wire [47:0] forwarder1_to_ft_dest_mac;
wire [47:0] forwarder1_to_ft_src_mac;
wire [31:0] forwarder1_to_ft_dest_ip;
wire [31:0] forwarder1_to_ft_source_ip;

wire                               ft_to_fowarder1_resp_valid;
wire  [$clog2(NUM_INTERFACES)-1:0] ft_to_fowarder1_resp;
wire                               ft_to_fowarder1_drop_packet;

wire        forwarder2_to_ft_hdr_valid;
wire [47:0] forwarder2_to_ft_dest_mac;
wire [47:0] forwarder2_to_ft_src_mac;
wire [31:0] forwarder2_to_ft_dest_ip;
wire [31:0] forwarder2_to_ft_source_ip;

wire                               ft_to_fowarder2_resp_valid;
wire  [$clog2(NUM_INTERFACES)-1:0] ft_to_fowarder2_resp;
wire                               ft_to_fowarder2_drop_packet;

// Connections from forwarding_table.v to spi_controller.v module
wire                   ft_rd_valid;
wire [$clog2(32)-1:0]  ft_rd_index;
wire [167:0]           ft_rd_data;

wire         ft_wr_valid;
wire [$clog2(32)-1:0] ft_wr_index;
wire [167:0] ft_wr_data;

forwarding_table #(
    .NUM_INTERFACES(3)
) 
forwarding_table_inst (
    .clk(clk), 
    .rst(rst),
    
    // from forwarder.v modules
    .i_ft_hdr_valid     ({forwarder2_to_ft_hdr_valid, forwarder1_to_ft_hdr_valid, forwarder0_to_ft_hdr_valid}),
    .i_ft_dest_mac      ({forwarder2_to_ft_dest_mac, forwarder1_to_ft_dest_mac, forwarder0_to_ft_dest_mac}),
    .i_ft_src_mac       ({forwarder2_to_ft_src_mac, forwarder1_to_ft_src_mac, forwarder0_to_ft_src_mac}),
    .i_ft_dest_ip       ({forwarder2_to_ft_dest_ip, forwarder1_to_ft_dest_ip, forwarder0_to_ft_dest_ip}),
    .i_ft_src_ip        ({forwarder2_to_ft_source_ip, forwarder1_to_ft_source_ip, forwarder0_to_ft_source_ip}),

    // to forwarder.v modules
    .o_ft_resp_valid    ({ft_to_fowarder2_resp_valid, ft_to_fowarder1_resp_valid, ft_to_fowarder0_resp_valid}),
    .o_ft_resp          ({ft_to_fowarder2_resp, ft_to_fowarder1_resp, ft_to_fowarder0_resp}),
    .o_ft_drop_packet   ({ft_to_fowarder2_drop_packet, ft_to_fowarder1_drop_packet, ft_to_fowarder0_drop_packet}),

    // table read interface
    .rd_valid           (ft_rd_valid),
    .rd_index           (ft_rd_index),
    .rd_data            (ft_rd_data),

    // table write interface
    .wr_valid           (ft_wr_valid),
    .wr_index           (ft_wr_index),
    .wr_data            (ft_wr_data)
);

spi_controller #(
    .NUM_ENTRIES(32)
) 
spi_controller_inst (
    .clk(clk), 
    .rst(rst),

    .spi_byte_rx_valid(spi_byte_rx_valid),
    .spi_byte_rx(spi_byte_rx),
    .spi_byte_tx(spi_byte_tx),

    .entry_rd_index(ft_rd_index),
    .entry_rd_valid(ft_rd_valid),
    .entry_rd_data(ft_rd_data),

	.entry_wr_index(ft_wr_index),
    .entry_wr_valid(ft_wr_valid),
    .entry_wr_data(ft_wr_data)
);

/* ****************************************************** */
/* FIRST TX AND RX INTERFACE */

mii_ip #(
    .TARGET(TARGET)
)
if0_mii_ip_inst (
    .rst(rst),
    .clk(clk),

    .mii_rx_clk(if0_phy_rx_clk),
    .mii_rxd(if0_phy_rxd),
    .mii_rx_dv(if0_phy_rx_dv),
    .mii_rx_er(if0_phy_rx_er),
    .mii_tx_clk(if0_phy_tx_clk),
    .mii_txd(if0_phy_txd),
    .mii_tx_en(if0_phy_tx_en),

    // Rx Frame Output
    .rx_ip_hdr_valid           (if0_to_forwarder0_ip_hdr_valid),
    .rx_ip_hdr_ready           (if0_to_forwarder0_ip_hdr_ready),
    .rx_ip_eth_dest_mac        (if0_to_forwarder0_ip_eth_dest_mac),
    .rx_ip_eth_src_mac         (if0_to_forwarder0_ip_eth_src_mac),
    .rx_ip_eth_type            (if0_to_forwarder0_ip_eth_type),
    .rx_ip_version             (if0_to_forwarder0_ip_version),
    .rx_ip_ihl                 (if0_to_forwarder0_ip_ihl),
    .rx_ip_dscp                (if0_to_forwarder0_ip_dscp),
    .rx_ip_ecn                 (if0_to_forwarder0_ip_ecn),
    .rx_ip_length              (if0_to_forwarder0_ip_length),
    .rx_ip_identification      (if0_to_forwarder0_ip_identification),
    .rx_ip_flags               (if0_to_forwarder0_ip_flags),
    .rx_ip_fragment_offset     (if0_to_forwarder0_ip_fragment_offset),
    .rx_ip_ttl                 (if0_to_forwarder0_ip_ttl),
    .rx_ip_protocol            (if0_to_forwarder0_ip_protocol),
    .rx_ip_header_checksum     (if0_to_forwarder0_ip_header_checksum),
    .rx_ip_source_ip           (if0_to_forwarder0_ip_source_ip),
    .rx_ip_dest_ip             (if0_to_forwarder0_ip_dest_ip),
    .rx_ip_payload_axis_tdata  (if0_to_forwarder0_ip_payload_axis_tdata),
    .rx_ip_payload_axis_tvalid (if0_to_forwarder0_ip_payload_axis_tvalid),
    .rx_ip_payload_axis_tready (if0_to_forwarder0_ip_payload_axis_tready),
    .rx_ip_payload_axis_tlast  (if0_to_forwarder0_ip_payload_axis_tlast),
    .rx_ip_payload_axis_tuser  (if0_to_forwarder0_ip_payload_axis_tuser),

    // Tx Frame Input
    .tx_ip_hdr_valid           (arbiter0_to_if0_ip_hdr_valid),
    .tx_ip_hdr_ready           (arbiter0_to_if0_ip_hdr_ready),
    .tx_ip_eth_dest_mac        (arbiter0_to_if0_ip_eth_dest_mac),
    .tx_ip_eth_src_mac         (arbiter0_to_if0_ip_eth_src_mac),
    .tx_ip_eth_type            (arbiter0_to_if0_ip_eth_type),
    .tx_ip_dscp                (arbiter0_to_if0_ip_dscp),
    .tx_ip_ecn                 (arbiter0_to_if0_ip_ecn),
    .tx_ip_length              (arbiter0_to_if0_ip_length),
    .tx_ip_identification      (arbiter0_to_if0_ip_identification),
    .tx_ip_flags               (arbiter0_to_if0_ip_flags),
    .tx_ip_fragment_offset     (arbiter0_to_if0_ip_fragment_offset),
    .tx_ip_ttl                 (arbiter0_to_if0_ip_ttl),
    .tx_ip_protocol            (arbiter0_to_if0_ip_protocol),
    .tx_ip_source_ip           (arbiter0_to_if0_ip_source_ip),
    .tx_ip_dest_ip             (arbiter0_to_if0_ip_dest_ip),
    .tx_ip_payload_axis_tdata  (arbiter0_to_if0_ip_payload_axis_tdata),
    .tx_ip_payload_axis_tvalid (arbiter0_to_if0_ip_payload_axis_tvalid),
    .tx_ip_payload_axis_tready (arbiter0_to_if0_ip_payload_axis_tready),
    .tx_ip_payload_axis_tlast  (arbiter0_to_if0_ip_payload_axis_tlast),
    .tx_ip_payload_axis_tuser  (arbiter0_to_if0_ip_payload_axis_tuser)
);

forwarder #(
    .NUM_INTERFACES(3),
    .RX_INTERFACE_NUM(0)
)
forwarder0_inst (
    .clk(clk), 
    .rst(rst),
    /* single input interface */
    .i_if0_ip_hdr_valid             (if0_to_forwarder0_ip_hdr_valid),
    .i_if0_ip_hdr_ready             (if0_to_forwarder0_ip_hdr_ready),
    .i_if0_ip_eth_dest_mac          (if0_to_forwarder0_ip_eth_dest_mac),
    .i_if0_ip_eth_src_mac           (if0_to_forwarder0_ip_eth_src_mac),
    .i_if0_ip_eth_type              (if0_to_forwarder0_ip_eth_type),
    .i_if0_ip_version               (if0_to_forwarder0_ip_version),
    .i_if0_ip_ihl                   (if0_to_forwarder0_ip_ihl),
    .i_if0_ip_dscp                  (if0_to_forwarder0_ip_dscp),
    .i_if0_ip_ecn                   (if0_to_forwarder0_ip_ecn),
    .i_if0_ip_length                (if0_to_forwarder0_ip_length),
    .i_if0_ip_identification        (if0_to_forwarder0_ip_identification),
    .i_if0_ip_flags                 (if0_to_forwarder0_ip_flags),
    .i_if0_ip_fragment_offset       (if0_to_forwarder0_ip_fragment_offset),
    .i_if0_ip_ttl                   (if0_to_forwarder0_ip_ttl),
    .i_if0_ip_protocol              (if0_to_forwarder0_ip_protocol),
    .i_if0_ip_header_checksum       (if0_to_forwarder0_ip_header_checksum),
    .i_if0_ip_source_ip             (if0_to_forwarder0_ip_source_ip),
    .i_if0_ip_dest_ip               (if0_to_forwarder0_ip_dest_ip),
    .i_if0_ip_payload_axis_tdata    (if0_to_forwarder0_ip_payload_axis_tdata),
    .i_if0_ip_payload_axis_tvalid   (if0_to_forwarder0_ip_payload_axis_tvalid),
    .i_if0_ip_payload_axis_tready   (if0_to_forwarder0_ip_payload_axis_tready),
    .i_if0_ip_payload_axis_tlast    (if0_to_forwarder0_ip_payload_axis_tlast),
    .i_if0_ip_payload_axis_tuser    (if0_to_forwarder0_ip_payload_axis_tuser),

    /* NUM_INTERFACES output interfaces */
    .o_if0_ip_hdr_valid             ({forwarder0_to_arbiter2_ip_hdr_valid          , forwarder0_to_arbiter1_ip_hdr_valid          , forwarder0_to_unused_ip_hdr_valid          }),
    .o_if0_ip_hdr_ready             ({forwarder0_to_arbiter2_ip_hdr_ready          , forwarder0_to_arbiter1_ip_hdr_ready          , forwarder0_to_unused_ip_hdr_ready          }),
    .o_if0_ip_eth_dest_mac          ({forwarder0_to_arbiter2_ip_eth_dest_mac       , forwarder0_to_arbiter1_ip_eth_dest_mac       , forwarder0_to_unused_ip_eth_dest_mac       }),
    .o_if0_ip_eth_src_mac           ({forwarder0_to_arbiter2_ip_eth_src_mac        , forwarder0_to_arbiter1_ip_eth_src_mac        , forwarder0_to_unused_ip_eth_src_mac        }),
    .o_if0_ip_eth_type              ({forwarder0_to_arbiter2_ip_eth_type           , forwarder0_to_arbiter1_ip_eth_type           , forwarder0_to_unused_ip_eth_type           }),
    .o_if0_ip_version               ({forwarder0_to_arbiter2_ip_version            , forwarder0_to_arbiter1_ip_version            , forwarder0_to_unused_ip_version            }), 
    .o_if0_ip_ihl                   ({forwarder0_to_arbiter2_ip_ihl                , forwarder0_to_arbiter1_ip_ihl                , forwarder0_to_unused_ip_ihl                }), 
    .o_if0_ip_dscp                  ({forwarder0_to_arbiter2_ip_dscp               , forwarder0_to_arbiter1_ip_dscp               , forwarder0_to_unused_ip_dscp               }),
    .o_if0_ip_ecn                   ({forwarder0_to_arbiter2_ip_ecn                , forwarder0_to_arbiter1_ip_ecn                , forwarder0_to_unused_ip_ecn                }),
    .o_if0_ip_length                ({forwarder0_to_arbiter2_ip_length             , forwarder0_to_arbiter1_ip_length             , forwarder0_to_unused_ip_length             }),
    .o_if0_ip_identification        ({forwarder0_to_arbiter2_ip_identification     , forwarder0_to_arbiter1_ip_identification     , forwarder0_to_unused_ip_identification     }),
    .o_if0_ip_flags                 ({forwarder0_to_arbiter2_ip_flags              , forwarder0_to_arbiter1_ip_flags              , forwarder0_to_unused_ip_flags              }),
    .o_if0_ip_fragment_offset       ({forwarder0_to_arbiter2_ip_fragment_offset    , forwarder0_to_arbiter1_ip_fragment_offset    , forwarder0_to_unused_ip_fragment_offset    }),
    .o_if0_ip_ttl                   ({forwarder0_to_arbiter2_ip_ttl                , forwarder0_to_arbiter1_ip_ttl                , forwarder0_to_unused_ip_ttl                }),
    .o_if0_ip_protocol              ({forwarder0_to_arbiter2_ip_protocol           , forwarder0_to_arbiter1_ip_protocol           , forwarder0_to_unused_ip_protocol           }),
    .o_if0_ip_header_checksum       ({forwarder0_to_arbiter2_ip_header_checksum    , forwarder0_to_arbiter1_ip_header_checksum    , forwarder0_to_unused_ip_header_checksum    }),
    .o_if0_ip_source_ip             ({forwarder0_to_arbiter2_ip_source_ip          , forwarder0_to_arbiter1_ip_source_ip          , forwarder0_to_unused_ip_source_ip          }),
    .o_if0_ip_dest_ip               ({forwarder0_to_arbiter2_ip_dest_ip            , forwarder0_to_arbiter1_ip_dest_ip            , forwarder0_to_unused_ip_dest_ip            }),
    .o_if0_ip_payload_axis_tdata    ({forwarder0_to_arbiter2_ip_payload_axis_tdata , forwarder0_to_arbiter1_ip_payload_axis_tdata , forwarder0_to_unused_ip_payload_axis_tdata }),
    .o_if0_ip_payload_axis_tvalid   ({forwarder0_to_arbiter2_ip_payload_axis_tvalid, forwarder0_to_arbiter1_ip_payload_axis_tvalid, forwarder0_to_unused_ip_payload_axis_tvalid}),
    .o_if0_ip_payload_axis_tready   ({forwarder0_to_arbiter2_ip_payload_axis_tready, forwarder0_to_arbiter1_ip_payload_axis_tready, forwarder0_to_unused_ip_payload_axis_tready}),
    .o_if0_ip_payload_axis_tlast    ({forwarder0_to_arbiter2_ip_payload_axis_tlast , forwarder0_to_arbiter1_ip_payload_axis_tlast , forwarder0_to_unused_ip_payload_axis_tlast }),
    .o_if0_ip_payload_axis_tuser    ({forwarder0_to_arbiter2_ip_payload_axis_tuser , forwarder0_to_arbiter1_ip_payload_axis_tuser , forwarder0_to_unused_ip_payload_axis_tuser }),

    .o_ft_hdr_valid     (forwarder0_to_ft_hdr_valid),
    .o_ft_dest_mac      (forwarder0_to_ft_dest_mac),
    .o_ft_src_mac       (forwarder0_to_ft_src_mac),
    .o_ft_dest_ip       (forwarder0_to_ft_dest_ip),
    .o_ft_source_ip     (forwarder0_to_ft_source_ip),

    .i_ft_resp_valid    (ft_to_fowarder0_resp_valid),
    .i_ft_resp          (ft_to_fowarder0_resp),
    .i_ft_drop_packet   (ft_to_fowarder0_drop_packet)
);

packet_arbiter #(
    .NUM_INTERFACES(3)
) arbiter0_inst (
    .clk(clk), 
    .rst(rst),
    /* single input interface */
    .i_if0_ip_hdr_valid             (forwarder1_to_arbiter0_ip_hdr_valid),
    .i_if0_ip_hdr_ready             (forwarder1_to_arbiter0_ip_hdr_ready),
    .i_if0_ip_eth_dest_mac          (forwarder1_to_arbiter0_ip_eth_dest_mac),
    .i_if0_ip_eth_src_mac           (forwarder1_to_arbiter0_ip_eth_src_mac),
    .i_if0_ip_eth_type              (forwarder1_to_arbiter0_ip_eth_type),
    .i_if0_ip_version               (forwarder1_to_arbiter0_ip_version),
    .i_if0_ip_ihl                   (forwarder1_to_arbiter0_ip_ihl),
    .i_if0_ip_dscp                  (forwarder1_to_arbiter0_ip_dscp),
    .i_if0_ip_ecn                   (forwarder1_to_arbiter0_ip_ecn),
    .i_if0_ip_length                (forwarder1_to_arbiter0_ip_length),
    .i_if0_ip_identification        (forwarder1_to_arbiter0_ip_identification),
    .i_if0_ip_flags                 (forwarder1_to_arbiter0_ip_flags),
    .i_if0_ip_fragment_offset       (forwarder1_to_arbiter0_ip_fragment_offset),
    .i_if0_ip_ttl                   (forwarder1_to_arbiter0_ip_ttl),
    .i_if0_ip_protocol              (forwarder1_to_arbiter0_ip_protocol),
    .i_if0_ip_header_checksum       (forwarder1_to_arbiter0_ip_header_checksum),
    .i_if0_ip_source_ip             (forwarder1_to_arbiter0_ip_source_ip),
    .i_if0_ip_dest_ip               (forwarder1_to_arbiter0_ip_dest_ip),
    .i_if0_ip_payload_axis_tdata    (forwarder1_to_arbiter0_ip_payload_axis_tdata),
    .i_if0_ip_payload_axis_tvalid   (forwarder1_to_arbiter0_ip_payload_axis_tvalid),
    .i_if0_ip_payload_axis_tready   (forwarder1_to_arbiter0_ip_payload_axis_tready),
    .i_if0_ip_payload_axis_tlast    (forwarder1_to_arbiter0_ip_payload_axis_tlast),
    .i_if0_ip_payload_axis_tuser    (forwarder1_to_arbiter0_ip_payload_axis_tuser),

    .i_if1_ip_hdr_valid             (forwarder2_to_arbiter0_ip_hdr_valid),
    .i_if1_ip_hdr_ready             (forwarder2_to_arbiter0_ip_hdr_ready),
    .i_if1_ip_eth_dest_mac          (forwarder2_to_arbiter0_ip_eth_dest_mac),
    .i_if1_ip_eth_src_mac           (forwarder2_to_arbiter0_ip_eth_src_mac),
    .i_if1_ip_eth_type              (forwarder2_to_arbiter0_ip_eth_type),
    .i_if1_ip_version               (forwarder2_to_arbiter0_ip_version),
    .i_if1_ip_ihl                   (forwarder2_to_arbiter0_ip_ihl),
    .i_if1_ip_dscp                  (forwarder2_to_arbiter0_ip_dscp),
    .i_if1_ip_ecn                   (forwarder2_to_arbiter0_ip_ecn),
    .i_if1_ip_length                (forwarder2_to_arbiter0_ip_length),
    .i_if1_ip_identification        (forwarder2_to_arbiter0_ip_identification),
    .i_if1_ip_flags                 (forwarder2_to_arbiter0_ip_flags),
    .i_if1_ip_fragment_offset       (forwarder2_to_arbiter0_ip_fragment_offset),
    .i_if1_ip_ttl                   (forwarder2_to_arbiter0_ip_ttl),
    .i_if1_ip_protocol              (forwarder2_to_arbiter0_ip_protocol),
    .i_if1_ip_header_checksum       (forwarder2_to_arbiter0_ip_header_checksum),
    .i_if1_ip_source_ip             (forwarder2_to_arbiter0_ip_source_ip),
    .i_if1_ip_dest_ip               (forwarder2_to_arbiter0_ip_dest_ip),
    .i_if1_ip_payload_axis_tdata    (forwarder2_to_arbiter0_ip_payload_axis_tdata),
    .i_if1_ip_payload_axis_tvalid   (forwarder2_to_arbiter0_ip_payload_axis_tvalid),
    .i_if1_ip_payload_axis_tready   (forwarder2_to_arbiter0_ip_payload_axis_tready),
    .i_if1_ip_payload_axis_tlast    (forwarder2_to_arbiter0_ip_payload_axis_tlast),
    .i_if1_ip_payload_axis_tuser    (forwarder2_to_arbiter0_ip_payload_axis_tuser),

    .o_if0_ip_hdr_valid             (arbiter0_to_if0_ip_hdr_valid),
    .o_if0_ip_hdr_ready             (arbiter0_to_if0_ip_hdr_ready),
    .o_if0_ip_eth_dest_mac          (arbiter0_to_if0_ip_eth_dest_mac),
    .o_if0_ip_eth_src_mac           (arbiter0_to_if0_ip_eth_src_mac),
    .o_if0_ip_eth_type              (arbiter0_to_if0_ip_eth_type),
    .o_if0_ip_version               (arbiter0_to_if0_ip_version),
    .o_if0_ip_ihl                   (arbiter0_to_if0_ip_ihl),
    .o_if0_ip_dscp                  (arbiter0_to_if0_ip_dscp),
    .o_if0_ip_ecn                   (arbiter0_to_if0_ip_ecn),
    .o_if0_ip_length                (arbiter0_to_if0_ip_length),
    .o_if0_ip_identification        (arbiter0_to_if0_ip_identification),
    .o_if0_ip_flags                 (arbiter0_to_if0_ip_flags),
    .o_if0_ip_fragment_offset       (arbiter0_to_if0_ip_fragment_offset),
    .o_if0_ip_ttl                   (arbiter0_to_if0_ip_ttl),
    .o_if0_ip_protocol              (arbiter0_to_if0_ip_protocol),
    .o_if0_ip_header_checksum       (arbiter0_to_if0_ip_header_checksum),
    .o_if0_ip_source_ip             (arbiter0_to_if0_ip_source_ip),
    .o_if0_ip_dest_ip               (arbiter0_to_if0_ip_dest_ip),
    .o_if0_ip_payload_axis_tdata    (arbiter0_to_if0_ip_payload_axis_tdata),
    .o_if0_ip_payload_axis_tvalid   (arbiter0_to_if0_ip_payload_axis_tvalid),
    .o_if0_ip_payload_axis_tready   (arbiter0_to_if0_ip_payload_axis_tready),
    .o_if0_ip_payload_axis_tlast    (arbiter0_to_if0_ip_payload_axis_tlast),
    .o_if0_ip_payload_axis_tuser    (arbiter0_to_if0_ip_payload_axis_tuser)
);

/* ****************************************************** */
/* SECOND TX AND RX INTERFACE */
mii_ip #(
    .TARGET(TARGET)
)
if1_mii_ip_inst (
    .rst(rst),
    .clk(clk),

    .mii_rx_clk (if1_phy_rx_clk),
    .mii_rxd    (if1_phy_rxd),
    .mii_rx_dv  (if1_phy_rx_dv),
    .mii_rx_er  (if1_phy_rx_er),
    .mii_tx_clk (if1_phy_tx_clk),
    .mii_txd    (if1_phy_txd),
    .mii_tx_en  (if1_phy_tx_en),

    // Rx Frame Output
    .rx_ip_hdr_valid           (if1_to_forwarder1_ip_hdr_valid),
    .rx_ip_hdr_ready           (if1_to_forwarder1_ip_hdr_ready),
    .rx_ip_eth_dest_mac        (if1_to_forwarder1_ip_eth_dest_mac),
    .rx_ip_eth_src_mac         (if1_to_forwarder1_ip_eth_src_mac),
    .rx_ip_eth_type            (if1_to_forwarder1_ip_eth_type),
    .rx_ip_version             (if1_to_forwarder1_ip_version),
    .rx_ip_ihl                 (if1_to_forwarder1_ip_ihl),
    .rx_ip_dscp                (if1_to_forwarder1_ip_dscp),
    .rx_ip_ecn                 (if1_to_forwarder1_ip_ecn),
    .rx_ip_length              (if1_to_forwarder1_ip_length),
    .rx_ip_identification      (if1_to_forwarder1_ip_identification),
    .rx_ip_flags               (if1_to_forwarder1_ip_flags),
    .rx_ip_fragment_offset     (if1_to_forwarder1_ip_fragment_offset),
    .rx_ip_ttl                 (if1_to_forwarder1_ip_ttl),
    .rx_ip_protocol            (if1_to_forwarder1_ip_protocol),
    .rx_ip_header_checksum     (if1_to_forwarder1_ip_header_checksum),
    .rx_ip_source_ip           (if1_to_forwarder1_ip_source_ip),
    .rx_ip_dest_ip             (if1_to_forwarder1_ip_dest_ip),
    .rx_ip_payload_axis_tdata  (if1_to_forwarder1_ip_payload_axis_tdata),
    .rx_ip_payload_axis_tvalid (if1_to_forwarder1_ip_payload_axis_tvalid),
    .rx_ip_payload_axis_tready (if1_to_forwarder1_ip_payload_axis_tready),
    .rx_ip_payload_axis_tlast  (if1_to_forwarder1_ip_payload_axis_tlast),
    .rx_ip_payload_axis_tuser  (if1_to_forwarder1_ip_payload_axis_tuser),

    // Tx Frame Input
    .tx_ip_hdr_valid           (arbiter1_to_if1_ip_hdr_valid),
    .tx_ip_hdr_ready           (arbiter1_to_if1_ip_hdr_ready),
    .tx_ip_eth_dest_mac        (arbiter1_to_if1_ip_eth_dest_mac),
    .tx_ip_eth_src_mac         (arbiter1_to_if1_ip_eth_src_mac),
    .tx_ip_eth_type            (arbiter1_to_if1_ip_eth_type),
    .tx_ip_dscp                (arbiter1_to_if1_ip_dscp),
    .tx_ip_ecn                 (arbiter1_to_if1_ip_ecn),
    .tx_ip_length              (arbiter1_to_if1_ip_length),
    .tx_ip_identification      (arbiter1_to_if1_ip_identification),
    .tx_ip_flags               (arbiter1_to_if1_ip_flags),
    .tx_ip_fragment_offset     (arbiter1_to_if1_ip_fragment_offset),
    .tx_ip_ttl                 (arbiter1_to_if1_ip_ttl),
    .tx_ip_protocol            (arbiter1_to_if1_ip_protocol),
    .tx_ip_source_ip           (arbiter1_to_if1_ip_source_ip),
    .tx_ip_dest_ip             (arbiter1_to_if1_ip_dest_ip),
    .tx_ip_payload_axis_tdata  (arbiter1_to_if1_ip_payload_axis_tdata),
    .tx_ip_payload_axis_tvalid (arbiter1_to_if1_ip_payload_axis_tvalid),
    .tx_ip_payload_axis_tready (arbiter1_to_if1_ip_payload_axis_tready),
    .tx_ip_payload_axis_tlast  (arbiter1_to_if1_ip_payload_axis_tlast),
    .tx_ip_payload_axis_tuser  (arbiter1_to_if1_ip_payload_axis_tuser)
);

forwarder #(
    .NUM_INTERFACES(3),
    .RX_INTERFACE_NUM(1)
)
forwarder1_inst (
    .clk(clk), 
    .rst(rst),
    /* single input interface */
    .i_if0_ip_hdr_valid             (if1_to_forwarder1_ip_hdr_valid),
    .i_if0_ip_hdr_ready             (if1_to_forwarder1_ip_hdr_ready),
    .i_if0_ip_eth_dest_mac          (if1_to_forwarder1_ip_eth_dest_mac),
    .i_if0_ip_eth_src_mac           (if1_to_forwarder1_ip_eth_src_mac),
    .i_if0_ip_eth_type              (if1_to_forwarder1_ip_eth_type),
    .i_if0_ip_version               (if1_to_forwarder1_ip_version),
    .i_if0_ip_ihl                   (if1_to_forwarder1_ip_ihl),
    .i_if0_ip_dscp                  (if1_to_forwarder1_ip_dscp),
    .i_if0_ip_ecn                   (if1_to_forwarder1_ip_ecn),
    .i_if0_ip_length                (if1_to_forwarder1_ip_length),
    .i_if0_ip_identification        (if1_to_forwarder1_ip_identification),
    .i_if0_ip_flags                 (if1_to_forwarder1_ip_flags),
    .i_if0_ip_fragment_offset       (if1_to_forwarder1_ip_fragment_offset),
    .i_if0_ip_ttl                   (if1_to_forwarder1_ip_ttl),
    .i_if0_ip_protocol              (if1_to_forwarder1_ip_protocol),
    .i_if0_ip_header_checksum       (if1_to_forwarder1_ip_header_checksum),
    .i_if0_ip_source_ip             (if1_to_forwarder1_ip_source_ip),
    .i_if0_ip_dest_ip               (if1_to_forwarder1_ip_dest_ip),
    .i_if0_ip_payload_axis_tdata    (if1_to_forwarder1_ip_payload_axis_tdata),
    .i_if0_ip_payload_axis_tvalid   (if1_to_forwarder1_ip_payload_axis_tvalid),
    .i_if0_ip_payload_axis_tready   (if1_to_forwarder1_ip_payload_axis_tready),
    .i_if0_ip_payload_axis_tlast    (if1_to_forwarder1_ip_payload_axis_tlast),
    .i_if0_ip_payload_axis_tuser    (if1_to_forwarder1_ip_payload_axis_tuser),

    /* NUM_INTERFACES output interfaces */
    .o_if0_ip_hdr_valid             ({forwarder1_to_arbiter2_ip_hdr_valid          , forwarder1_to_unused_ip_hdr_valid          , forwarder1_to_arbiter0_ip_hdr_valid          }),
    .o_if0_ip_hdr_ready             ({forwarder1_to_arbiter2_ip_hdr_ready          , forwarder1_to_unused_ip_hdr_ready          , forwarder1_to_arbiter0_ip_hdr_ready          }),
    .o_if0_ip_eth_dest_mac          ({forwarder1_to_arbiter2_ip_eth_dest_mac       , forwarder1_to_unused_ip_eth_dest_mac       , forwarder1_to_arbiter0_ip_eth_dest_mac       }),
    .o_if0_ip_eth_src_mac           ({forwarder1_to_arbiter2_ip_eth_src_mac        , forwarder1_to_unused_ip_eth_src_mac        , forwarder1_to_arbiter0_ip_eth_src_mac        }),
    .o_if0_ip_eth_type              ({forwarder1_to_arbiter2_ip_eth_type           , forwarder1_to_unused_ip_eth_type           , forwarder1_to_arbiter0_ip_eth_type           }),
    .o_if0_ip_version               ({forwarder1_to_arbiter2_ip_version            , forwarder1_to_unused_ip_version            , forwarder1_to_arbiter0_ip_version            }), 
    .o_if0_ip_ihl                   ({forwarder1_to_arbiter2_ip_ihl                , forwarder1_to_unused_ip_ihl                , forwarder1_to_arbiter0_ip_ihl                }), 
    .o_if0_ip_dscp                  ({forwarder1_to_arbiter2_ip_dscp               , forwarder1_to_unused_ip_dscp               , forwarder1_to_arbiter0_ip_dscp               }),
    .o_if0_ip_ecn                   ({forwarder1_to_arbiter2_ip_ecn                , forwarder1_to_unused_ip_ecn                , forwarder1_to_arbiter0_ip_ecn                }),
    .o_if0_ip_length                ({forwarder1_to_arbiter2_ip_length             , forwarder1_to_unused_ip_length             , forwarder1_to_arbiter0_ip_length             }),
    .o_if0_ip_identification        ({forwarder1_to_arbiter2_ip_identification     , forwarder1_to_unused_ip_identification     , forwarder1_to_arbiter0_ip_identification     }),
    .o_if0_ip_flags                 ({forwarder1_to_arbiter2_ip_flags              , forwarder1_to_unused_ip_flags              , forwarder1_to_arbiter0_ip_flags              }),
    .o_if0_ip_fragment_offset       ({forwarder1_to_arbiter2_ip_fragment_offset    , forwarder1_to_unused_ip_fragment_offset    , forwarder1_to_arbiter0_ip_fragment_offset    }),
    .o_if0_ip_ttl                   ({forwarder1_to_arbiter2_ip_ttl                , forwarder1_to_unused_ip_ttl                , forwarder1_to_arbiter0_ip_ttl                }),
    .o_if0_ip_protocol              ({forwarder1_to_arbiter2_ip_protocol           , forwarder1_to_unused_ip_protocol           , forwarder1_to_arbiter0_ip_protocol           }),
    .o_if0_ip_header_checksum       ({forwarder1_to_arbiter2_ip_header_checksum    , forwarder1_to_unused_ip_header_checksum    , forwarder1_to_arbiter0_ip_header_checksum    }),
    .o_if0_ip_source_ip             ({forwarder1_to_arbiter2_ip_source_ip          , forwarder1_to_unused_ip_source_ip          , forwarder1_to_arbiter0_ip_source_ip          }),
    .o_if0_ip_dest_ip               ({forwarder1_to_arbiter2_ip_dest_ip            , forwarder1_to_unused_ip_dest_ip            , forwarder1_to_arbiter0_ip_dest_ip            }),
    .o_if0_ip_payload_axis_tdata    ({forwarder1_to_arbiter2_ip_payload_axis_tdata , forwarder1_to_unused_ip_payload_axis_tdata , forwarder1_to_arbiter0_ip_payload_axis_tdata }),
    .o_if0_ip_payload_axis_tvalid   ({forwarder1_to_arbiter2_ip_payload_axis_tvalid, forwarder1_to_unused_ip_payload_axis_tvalid, forwarder1_to_arbiter0_ip_payload_axis_tvalid}),
    .o_if0_ip_payload_axis_tready   ({forwarder1_to_arbiter2_ip_payload_axis_tready, forwarder1_to_unused_ip_payload_axis_tready, forwarder1_to_arbiter0_ip_payload_axis_tready}),
    .o_if0_ip_payload_axis_tlast    ({forwarder1_to_arbiter2_ip_payload_axis_tlast , forwarder1_to_unused_ip_payload_axis_tlast , forwarder1_to_arbiter0_ip_payload_axis_tlast }),
    .o_if0_ip_payload_axis_tuser    ({forwarder1_to_arbiter2_ip_payload_axis_tuser , forwarder1_to_unused_ip_payload_axis_tuser , forwarder1_to_arbiter0_ip_payload_axis_tuser }),

    .o_ft_hdr_valid     (forwarder1_to_ft_hdr_valid),
    .o_ft_dest_mac      (forwarder1_to_ft_dest_mac),
    .o_ft_src_mac       (forwarder1_to_ft_src_mac),
    .o_ft_dest_ip       (forwarder1_to_ft_dest_ip),
    .o_ft_source_ip     (forwarder1_to_ft_source_ip),

    .i_ft_resp_valid    (ft_to_fowarder1_resp_valid),
    .i_ft_resp          (ft_to_fowarder1_resp),
    .i_ft_drop_packet   (ft_to_fowarder1_drop_packet)
);

packet_arbiter #(
    .NUM_INTERFACES(3)
) arbiter1_inst (
    .clk(clk), 
    .rst(rst),
    /* single input interface */
    .i_if0_ip_hdr_valid             (forwarder0_to_arbiter1_ip_hdr_valid),
    .i_if0_ip_hdr_ready             (forwarder0_to_arbiter1_ip_hdr_ready),
    .i_if0_ip_eth_dest_mac          (forwarder0_to_arbiter1_ip_eth_dest_mac),
    .i_if0_ip_eth_src_mac           (forwarder0_to_arbiter1_ip_eth_src_mac),
    .i_if0_ip_eth_type              (forwarder0_to_arbiter1_ip_eth_type),
    .i_if0_ip_version               (forwarder0_to_arbiter1_ip_version),
    .i_if0_ip_ihl                   (forwarder0_to_arbiter1_ip_ihl),
    .i_if0_ip_dscp                  (forwarder0_to_arbiter1_ip_dscp),
    .i_if0_ip_ecn                   (forwarder0_to_arbiter1_ip_ecn),
    .i_if0_ip_length                (forwarder0_to_arbiter1_ip_length),
    .i_if0_ip_identification        (forwarder0_to_arbiter1_ip_identification),
    .i_if0_ip_flags                 (forwarder0_to_arbiter1_ip_flags),
    .i_if0_ip_fragment_offset       (forwarder0_to_arbiter1_ip_fragment_offset),
    .i_if0_ip_ttl                   (forwarder0_to_arbiter1_ip_ttl),
    .i_if0_ip_protocol              (forwarder0_to_arbiter1_ip_protocol),
    .i_if0_ip_header_checksum       (forwarder0_to_arbiter1_ip_header_checksum),
    .i_if0_ip_source_ip             (forwarder0_to_arbiter1_ip_source_ip),
    .i_if0_ip_dest_ip               (forwarder0_to_arbiter1_ip_dest_ip),
    .i_if0_ip_payload_axis_tdata    (forwarder0_to_arbiter1_ip_payload_axis_tdata),
    .i_if0_ip_payload_axis_tvalid   (forwarder0_to_arbiter1_ip_payload_axis_tvalid),
    .i_if0_ip_payload_axis_tready   (forwarder0_to_arbiter1_ip_payload_axis_tready),
    .i_if0_ip_payload_axis_tlast    (forwarder0_to_arbiter1_ip_payload_axis_tlast),
    .i_if0_ip_payload_axis_tuser    (forwarder0_to_arbiter1_ip_payload_axis_tuser),

    .i_if1_ip_hdr_valid             (forwarder2_to_arbiter1_ip_hdr_valid),
    .i_if1_ip_hdr_ready             (forwarder2_to_arbiter1_ip_hdr_ready),
    .i_if1_ip_eth_dest_mac          (forwarder2_to_arbiter1_ip_eth_dest_mac),
    .i_if1_ip_eth_src_mac           (forwarder2_to_arbiter1_ip_eth_src_mac),
    .i_if1_ip_eth_type              (forwarder2_to_arbiter1_ip_eth_type),
    .i_if1_ip_version               (forwarder2_to_arbiter1_ip_version),
    .i_if1_ip_ihl                   (forwarder2_to_arbiter1_ip_ihl),
    .i_if1_ip_dscp                  (forwarder2_to_arbiter1_ip_dscp),
    .i_if1_ip_ecn                   (forwarder2_to_arbiter1_ip_ecn),
    .i_if1_ip_length                (forwarder2_to_arbiter1_ip_length),
    .i_if1_ip_identification        (forwarder2_to_arbiter1_ip_identification),
    .i_if1_ip_flags                 (forwarder2_to_arbiter1_ip_flags),
    .i_if1_ip_fragment_offset       (forwarder2_to_arbiter1_ip_fragment_offset),
    .i_if1_ip_ttl                   (forwarder2_to_arbiter1_ip_ttl),
    .i_if1_ip_protocol              (forwarder2_to_arbiter1_ip_protocol),
    .i_if1_ip_header_checksum       (forwarder2_to_arbiter1_ip_header_checksum),
    .i_if1_ip_source_ip             (forwarder2_to_arbiter1_ip_source_ip),
    .i_if1_ip_dest_ip               (forwarder2_to_arbiter1_ip_dest_ip),
    .i_if1_ip_payload_axis_tdata    (forwarder2_to_arbiter1_ip_payload_axis_tdata),
    .i_if1_ip_payload_axis_tvalid   (forwarder2_to_arbiter1_ip_payload_axis_tvalid),
    .i_if1_ip_payload_axis_tready   (forwarder2_to_arbiter1_ip_payload_axis_tready),
    .i_if1_ip_payload_axis_tlast    (forwarder2_to_arbiter1_ip_payload_axis_tlast),
    .i_if1_ip_payload_axis_tuser    (forwarder2_to_arbiter1_ip_payload_axis_tuser),

    .o_if0_ip_hdr_valid             (arbiter1_to_if1_ip_hdr_valid),
    .o_if0_ip_hdr_ready             (arbiter1_to_if1_ip_hdr_ready),
    .o_if0_ip_eth_dest_mac          (arbiter1_to_if1_ip_eth_dest_mac),
    .o_if0_ip_eth_src_mac           (arbiter1_to_if1_ip_eth_src_mac),
    .o_if0_ip_eth_type              (arbiter1_to_if1_ip_eth_type),
    .o_if0_ip_version               (arbiter1_to_if1_ip_version),
    .o_if0_ip_ihl                   (arbiter1_to_if1_ip_ihl),
    .o_if0_ip_dscp                  (arbiter1_to_if1_ip_dscp),
    .o_if0_ip_ecn                   (arbiter1_to_if1_ip_ecn),
    .o_if0_ip_length                (arbiter1_to_if1_ip_length),
    .o_if0_ip_identification        (arbiter1_to_if1_ip_identification),
    .o_if0_ip_flags                 (arbiter1_to_if1_ip_flags),
    .o_if0_ip_fragment_offset       (arbiter1_to_if1_ip_fragment_offset),
    .o_if0_ip_ttl                   (arbiter1_to_if1_ip_ttl),
    .o_if0_ip_protocol              (arbiter1_to_if1_ip_protocol),
    .o_if0_ip_header_checksum       (arbiter1_to_if1_ip_header_checksum),
    .o_if0_ip_source_ip             (arbiter1_to_if1_ip_source_ip),
    .o_if0_ip_dest_ip               (arbiter1_to_if1_ip_dest_ip),
    .o_if0_ip_payload_axis_tdata    (arbiter1_to_if1_ip_payload_axis_tdata),
    .o_if0_ip_payload_axis_tvalid   (arbiter1_to_if1_ip_payload_axis_tvalid),
    .o_if0_ip_payload_axis_tready   (arbiter1_to_if1_ip_payload_axis_tready),
    .o_if0_ip_payload_axis_tlast    (arbiter1_to_if1_ip_payload_axis_tlast),
    .o_if0_ip_payload_axis_tuser    (arbiter1_to_if1_ip_payload_axis_tuser)
);

/* ****************************************************** */
/* THIRD TX AND RX INTERFACE */
mii_ip #(
    .TARGET(TARGET)
)
if2_mii_ip_inst (
    .rst(rst),
    .clk(clk),

    .mii_rx_clk (if2_phy_rx_clk),
    .mii_rxd    (if2_phy_rxd),
    .mii_rx_dv  (if2_phy_rx_dv),
    .mii_rx_er  (if2_phy_rx_er),
    .mii_tx_clk (if2_phy_tx_clk),
    .mii_txd    (if2_phy_txd),
    .mii_tx_en  (if2_phy_tx_en),

    // Rx Frame Output
    .rx_ip_hdr_valid           (if2_to_forwarder2_ip_hdr_valid),
    .rx_ip_hdr_ready           (if2_to_forwarder2_ip_hdr_ready),
    .rx_ip_eth_dest_mac        (if2_to_forwarder2_ip_eth_dest_mac),
    .rx_ip_eth_src_mac         (if2_to_forwarder2_ip_eth_src_mac),
    .rx_ip_eth_type            (if2_to_forwarder2_ip_eth_type),
    .rx_ip_version             (if2_to_forwarder2_ip_version),
    .rx_ip_ihl                 (if2_to_forwarder2_ip_ihl),
    .rx_ip_dscp                (if2_to_forwarder2_ip_dscp),
    .rx_ip_ecn                 (if2_to_forwarder2_ip_ecn),
    .rx_ip_length              (if2_to_forwarder2_ip_length),
    .rx_ip_identification      (if2_to_forwarder2_ip_identification),
    .rx_ip_flags               (if2_to_forwarder2_ip_flags),
    .rx_ip_fragment_offset     (if2_to_forwarder2_ip_fragment_offset),
    .rx_ip_ttl                 (if2_to_forwarder2_ip_ttl),
    .rx_ip_protocol            (if2_to_forwarder2_ip_protocol),
    .rx_ip_header_checksum     (if2_to_forwarder2_ip_header_checksum),
    .rx_ip_source_ip           (if2_to_forwarder2_ip_source_ip),
    .rx_ip_dest_ip             (if2_to_forwarder2_ip_dest_ip),
    .rx_ip_payload_axis_tdata  (if2_to_forwarder2_ip_payload_axis_tdata),
    .rx_ip_payload_axis_tvalid (if2_to_forwarder2_ip_payload_axis_tvalid),
    .rx_ip_payload_axis_tready (if2_to_forwarder2_ip_payload_axis_tready),
    .rx_ip_payload_axis_tlast  (if2_to_forwarder2_ip_payload_axis_tlast),
    .rx_ip_payload_axis_tuser  (if2_to_forwarder2_ip_payload_axis_tuser),

    // Tx Frame Input
    .tx_ip_hdr_valid           (arbiter2_to_if2_ip_hdr_valid),
    .tx_ip_hdr_ready           (arbiter2_to_if2_ip_hdr_ready),
    .tx_ip_eth_dest_mac        (arbiter2_to_if2_ip_eth_dest_mac),
    .tx_ip_eth_src_mac         (arbiter2_to_if2_ip_eth_src_mac),
    .tx_ip_eth_type            (arbiter2_to_if2_ip_eth_type),
    .tx_ip_dscp                (arbiter2_to_if2_ip_dscp),
    .tx_ip_ecn                 (arbiter2_to_if2_ip_ecn),
    .tx_ip_length              (arbiter2_to_if2_ip_length),
    .tx_ip_identification      (arbiter2_to_if2_ip_identification),
    .tx_ip_flags               (arbiter2_to_if2_ip_flags),
    .tx_ip_fragment_offset     (arbiter2_to_if2_ip_fragment_offset),
    .tx_ip_ttl                 (arbiter2_to_if2_ip_ttl),
    .tx_ip_protocol            (arbiter2_to_if2_ip_protocol),
    .tx_ip_source_ip           (arbiter2_to_if2_ip_source_ip),
    .tx_ip_dest_ip             (arbiter2_to_if2_ip_dest_ip),
    .tx_ip_payload_axis_tdata  (arbiter2_to_if2_ip_payload_axis_tdata),
    .tx_ip_payload_axis_tvalid (arbiter2_to_if2_ip_payload_axis_tvalid),
    .tx_ip_payload_axis_tready (arbiter2_to_if2_ip_payload_axis_tready),
    .tx_ip_payload_axis_tlast  (arbiter2_to_if2_ip_payload_axis_tlast),
    .tx_ip_payload_axis_tuser  (arbiter2_to_if2_ip_payload_axis_tuser)
);

forwarder #(
    .NUM_INTERFACES(3),
    .RX_INTERFACE_NUM(2)
)
forwarder2_inst (
    .clk(clk), 
    .rst(rst),
    /* single input interface */
    .i_if0_ip_hdr_valid             (if2_to_forwarder2_ip_hdr_valid),
    .i_if0_ip_hdr_ready             (if2_to_forwarder2_ip_hdr_ready),
    .i_if0_ip_eth_dest_mac          (if2_to_forwarder2_ip_eth_dest_mac),
    .i_if0_ip_eth_src_mac           (if2_to_forwarder2_ip_eth_src_mac),
    .i_if0_ip_eth_type              (if2_to_forwarder2_ip_eth_type),
    .i_if0_ip_version               (if2_to_forwarder2_ip_version),
    .i_if0_ip_ihl                   (if2_to_forwarder2_ip_ihl),
    .i_if0_ip_dscp                  (if2_to_forwarder2_ip_dscp),
    .i_if0_ip_ecn                   (if2_to_forwarder2_ip_ecn),
    .i_if0_ip_length                (if2_to_forwarder2_ip_length),
    .i_if0_ip_identification        (if2_to_forwarder2_ip_identification),
    .i_if0_ip_flags                 (if2_to_forwarder2_ip_flags),
    .i_if0_ip_fragment_offset       (if2_to_forwarder2_ip_fragment_offset),
    .i_if0_ip_ttl                   (if2_to_forwarder2_ip_ttl),
    .i_if0_ip_protocol              (if2_to_forwarder2_ip_protocol),
    .i_if0_ip_header_checksum       (if2_to_forwarder2_ip_header_checksum),
    .i_if0_ip_source_ip             (if2_to_forwarder2_ip_source_ip),
    .i_if0_ip_dest_ip               (if2_to_forwarder2_ip_dest_ip),
    .i_if0_ip_payload_axis_tdata    (if2_to_forwarder2_ip_payload_axis_tdata),
    .i_if0_ip_payload_axis_tvalid   (if2_to_forwarder2_ip_payload_axis_tvalid),
    .i_if0_ip_payload_axis_tready   (if2_to_forwarder2_ip_payload_axis_tready),
    .i_if0_ip_payload_axis_tlast    (if2_to_forwarder2_ip_payload_axis_tlast),
    .i_if0_ip_payload_axis_tuser    (if2_to_forwarder2_ip_payload_axis_tuser),

    /* NUM_INTERFACES output interfaces */
    .o_if0_ip_hdr_valid             ({forwarder2_to_unused_ip_hdr_valid          , forwarder2_to_arbiter1_ip_hdr_valid          , forwarder2_to_arbiter0_ip_hdr_valid          }),
    .o_if0_ip_hdr_ready             ({forwarder2_to_unused_ip_hdr_ready          , forwarder2_to_arbiter1_ip_hdr_ready          , forwarder2_to_arbiter0_ip_hdr_ready          }),
    .o_if0_ip_eth_dest_mac          ({forwarder2_to_unused_ip_eth_dest_mac       , forwarder2_to_arbiter1_ip_eth_dest_mac       , forwarder2_to_arbiter0_ip_eth_dest_mac       }),
    .o_if0_ip_eth_src_mac           ({forwarder2_to_unused_ip_eth_src_mac        , forwarder2_to_arbiter1_ip_eth_src_mac        , forwarder2_to_arbiter0_ip_eth_src_mac        }),
    .o_if0_ip_eth_type              ({forwarder2_to_unused_ip_eth_type           , forwarder2_to_arbiter1_ip_eth_type           , forwarder2_to_arbiter0_ip_eth_type           }),
    .o_if0_ip_version               ({forwarder2_to_unused_ip_version            , forwarder2_to_arbiter1_ip_version            , forwarder2_to_arbiter0_ip_version            }), 
    .o_if0_ip_ihl                   ({forwarder2_to_unused_ip_ihl                , forwarder2_to_arbiter1_ip_ihl                , forwarder2_to_arbiter0_ip_ihl                }), 
    .o_if0_ip_dscp                  ({forwarder2_to_unused_ip_dscp               , forwarder2_to_arbiter1_ip_dscp               , forwarder2_to_arbiter0_ip_dscp               }),
    .o_if0_ip_ecn                   ({forwarder2_to_unused_ip_ecn                , forwarder2_to_arbiter1_ip_ecn                , forwarder2_to_arbiter0_ip_ecn                }),
    .o_if0_ip_length                ({forwarder2_to_unused_ip_length             , forwarder2_to_arbiter1_ip_length             , forwarder2_to_arbiter0_ip_length             }),
    .o_if0_ip_identification        ({forwarder2_to_unused_ip_identification     , forwarder2_to_arbiter1_ip_identification     , forwarder2_to_arbiter0_ip_identification     }),
    .o_if0_ip_flags                 ({forwarder2_to_unused_ip_flags              , forwarder2_to_arbiter1_ip_flags              , forwarder2_to_arbiter0_ip_flags              }),
    .o_if0_ip_fragment_offset       ({forwarder2_to_unused_ip_fragment_offset    , forwarder2_to_arbiter1_ip_fragment_offset    , forwarder2_to_arbiter0_ip_fragment_offset    }),
    .o_if0_ip_ttl                   ({forwarder2_to_unused_ip_ttl                , forwarder2_to_arbiter1_ip_ttl                , forwarder2_to_arbiter0_ip_ttl                }),
    .o_if0_ip_protocol              ({forwarder2_to_unused_ip_protocol           , forwarder2_to_arbiter1_ip_protocol           , forwarder2_to_arbiter0_ip_protocol           }),
    .o_if0_ip_header_checksum       ({forwarder2_to_unused_ip_header_checksum    , forwarder2_to_arbiter1_ip_header_checksum    , forwarder2_to_arbiter0_ip_header_checksum    }),
    .o_if0_ip_source_ip             ({forwarder2_to_unused_ip_source_ip          , forwarder2_to_arbiter1_ip_source_ip          , forwarder2_to_arbiter0_ip_source_ip          }),
    .o_if0_ip_dest_ip               ({forwarder2_to_unused_ip_dest_ip            , forwarder2_to_arbiter1_ip_dest_ip            , forwarder2_to_arbiter0_ip_dest_ip            }),
    .o_if0_ip_payload_axis_tdata    ({forwarder2_to_unused_ip_payload_axis_tdata , forwarder2_to_arbiter1_ip_payload_axis_tdata , forwarder2_to_arbiter0_ip_payload_axis_tdata }),
    .o_if0_ip_payload_axis_tvalid   ({forwarder2_to_unused_ip_payload_axis_tvalid, forwarder2_to_arbiter1_ip_payload_axis_tvalid, forwarder2_to_arbiter0_ip_payload_axis_tvalid}),
    .o_if0_ip_payload_axis_tready   ({forwarder2_to_unused_ip_payload_axis_tready, forwarder2_to_arbiter1_ip_payload_axis_tready, forwarder2_to_arbiter0_ip_payload_axis_tready}),
    .o_if0_ip_payload_axis_tlast    ({forwarder2_to_unused_ip_payload_axis_tlast , forwarder2_to_arbiter1_ip_payload_axis_tlast , forwarder2_to_arbiter0_ip_payload_axis_tlast }),
    .o_if0_ip_payload_axis_tuser    ({forwarder2_to_unused_ip_payload_axis_tuser , forwarder2_to_arbiter1_ip_payload_axis_tuser , forwarder2_to_arbiter0_ip_payload_axis_tuser }),

    .o_ft_hdr_valid     (forwarder2_to_ft_hdr_valid),
    .o_ft_dest_mac      (forwarder2_to_ft_dest_mac),
    .o_ft_src_mac       (forwarder2_to_ft_src_mac),
    .o_ft_dest_ip       (forwarder2_to_ft_dest_ip),
    .o_ft_source_ip     (forwarder2_to_ft_source_ip),

    .i_ft_resp_valid    (ft_to_fowarder2_resp_valid),
    .i_ft_resp          (ft_to_fowarder2_resp),
    .i_ft_drop_packet   (ft_to_fowarder2_drop_packet)
);

packet_arbiter #(
    .NUM_INTERFACES(3)
) arbiter2_inst (
    .clk(clk), 
    .rst(rst),
    /* single input interface */
    .i_if0_ip_hdr_valid             (forwarder0_to_arbiter2_ip_hdr_valid),
    .i_if0_ip_hdr_ready             (forwarder0_to_arbiter2_ip_hdr_ready),
    .i_if0_ip_eth_dest_mac          (forwarder0_to_arbiter2_ip_eth_dest_mac),
    .i_if0_ip_eth_src_mac           (forwarder0_to_arbiter2_ip_eth_src_mac),
    .i_if0_ip_eth_type              (forwarder0_to_arbiter2_ip_eth_type),
    .i_if0_ip_version               (forwarder0_to_arbiter2_ip_version),
    .i_if0_ip_ihl                   (forwarder0_to_arbiter2_ip_ihl),
    .i_if0_ip_dscp                  (forwarder0_to_arbiter2_ip_dscp),
    .i_if0_ip_ecn                   (forwarder0_to_arbiter2_ip_ecn),
    .i_if0_ip_length                (forwarder0_to_arbiter2_ip_length),
    .i_if0_ip_identification        (forwarder0_to_arbiter2_ip_identification),
    .i_if0_ip_flags                 (forwarder0_to_arbiter2_ip_flags),
    .i_if0_ip_fragment_offset       (forwarder0_to_arbiter2_ip_fragment_offset),
    .i_if0_ip_ttl                   (forwarder0_to_arbiter2_ip_ttl),
    .i_if0_ip_protocol              (forwarder0_to_arbiter2_ip_protocol),
    .i_if0_ip_header_checksum       (forwarder0_to_arbiter2_ip_header_checksum),
    .i_if0_ip_source_ip             (forwarder0_to_arbiter2_ip_source_ip),
    .i_if0_ip_dest_ip               (forwarder0_to_arbiter2_ip_dest_ip),
    .i_if0_ip_payload_axis_tdata    (forwarder0_to_arbiter2_ip_payload_axis_tdata),
    .i_if0_ip_payload_axis_tvalid   (forwarder0_to_arbiter2_ip_payload_axis_tvalid),
    .i_if0_ip_payload_axis_tready   (forwarder0_to_arbiter2_ip_payload_axis_tready),
    .i_if0_ip_payload_axis_tlast    (forwarder0_to_arbiter2_ip_payload_axis_tlast),
    .i_if0_ip_payload_axis_tuser    (forwarder0_to_arbiter2_ip_payload_axis_tuser),

    .i_if1_ip_hdr_valid             (forwarder1_to_arbiter2_ip_hdr_valid),
    .i_if1_ip_hdr_ready             (forwarder1_to_arbiter2_ip_hdr_ready),
    .i_if1_ip_eth_dest_mac          (forwarder1_to_arbiter2_ip_eth_dest_mac),
    .i_if1_ip_eth_src_mac           (forwarder1_to_arbiter2_ip_eth_src_mac),
    .i_if1_ip_eth_type              (forwarder1_to_arbiter2_ip_eth_type),
    .i_if1_ip_version               (forwarder1_to_arbiter2_ip_version),
    .i_if1_ip_ihl                   (forwarder1_to_arbiter2_ip_ihl),
    .i_if1_ip_dscp                  (forwarder1_to_arbiter2_ip_dscp),
    .i_if1_ip_ecn                   (forwarder1_to_arbiter2_ip_ecn),
    .i_if1_ip_length                (forwarder1_to_arbiter2_ip_length),
    .i_if1_ip_identification        (forwarder1_to_arbiter2_ip_identification),
    .i_if1_ip_flags                 (forwarder1_to_arbiter2_ip_flags),
    .i_if1_ip_fragment_offset       (forwarder1_to_arbiter2_ip_fragment_offset),
    .i_if1_ip_ttl                   (forwarder1_to_arbiter2_ip_ttl),
    .i_if1_ip_protocol              (forwarder1_to_arbiter2_ip_protocol),
    .i_if1_ip_header_checksum       (forwarder1_to_arbiter2_ip_header_checksum),
    .i_if1_ip_source_ip             (forwarder1_to_arbiter2_ip_source_ip),
    .i_if1_ip_dest_ip               (forwarder1_to_arbiter2_ip_dest_ip),
    .i_if1_ip_payload_axis_tdata    (forwarder1_to_arbiter2_ip_payload_axis_tdata),
    .i_if1_ip_payload_axis_tvalid   (forwarder1_to_arbiter2_ip_payload_axis_tvalid),
    .i_if1_ip_payload_axis_tready   (forwarder1_to_arbiter2_ip_payload_axis_tready),
    .i_if1_ip_payload_axis_tlast    (forwarder1_to_arbiter2_ip_payload_axis_tlast),
    .i_if1_ip_payload_axis_tuser    (forwarder1_to_arbiter2_ip_payload_axis_tuser),

    .o_if0_ip_hdr_valid             (arbiter2_to_if2_ip_hdr_valid),
    .o_if0_ip_hdr_ready             (arbiter2_to_if2_ip_hdr_ready),
    .o_if0_ip_eth_dest_mac          (arbiter2_to_if2_ip_eth_dest_mac),
    .o_if0_ip_eth_src_mac           (arbiter2_to_if2_ip_eth_src_mac),
    .o_if0_ip_eth_type              (arbiter2_to_if2_ip_eth_type),
    .o_if0_ip_version               (arbiter2_to_if2_ip_version),
    .o_if0_ip_ihl                   (arbiter2_to_if2_ip_ihl),
    .o_if0_ip_dscp                  (arbiter2_to_if2_ip_dscp),
    .o_if0_ip_ecn                   (arbiter2_to_if2_ip_ecn),
    .o_if0_ip_length                (arbiter2_to_if2_ip_length),
    .o_if0_ip_identification        (arbiter2_to_if2_ip_identification),
    .o_if0_ip_flags                 (arbiter2_to_if2_ip_flags),
    .o_if0_ip_fragment_offset       (arbiter2_to_if2_ip_fragment_offset),
    .o_if0_ip_ttl                   (arbiter2_to_if2_ip_ttl),
    .o_if0_ip_protocol              (arbiter2_to_if2_ip_protocol),
    .o_if0_ip_header_checksum       (arbiter2_to_if2_ip_header_checksum),
    .o_if0_ip_source_ip             (arbiter2_to_if2_ip_source_ip),
    .o_if0_ip_dest_ip               (arbiter2_to_if2_ip_dest_ip),
    .o_if0_ip_payload_axis_tdata    (arbiter2_to_if2_ip_payload_axis_tdata),
    .o_if0_ip_payload_axis_tvalid   (arbiter2_to_if2_ip_payload_axis_tvalid),
    .o_if0_ip_payload_axis_tready   (arbiter2_to_if2_ip_payload_axis_tready),
    .o_if0_ip_payload_axis_tlast    (arbiter2_to_if2_ip_payload_axis_tlast),
    .o_if0_ip_payload_axis_tuser    (arbiter2_to_if2_ip_payload_axis_tuser)
);

spi_byte_if 
byte_if(.sysClk  (clk), // 125MHz
        .usrReset(rst),
        .SCLK    (SCLK),
        .MOSI    (MOSI),
        .MISO    (MISO),
        .SS      (SS),
        .rxValid (spi_byte_rx_valid),
        .rx      (spi_byte_rx),
        .tx      (spi_byte_tx)                
);

endmodule
`resetall