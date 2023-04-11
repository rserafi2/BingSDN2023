module packet_arbiter #(
    parameter NUM_INTERFACES = 3,
    parameter NUM_ENTRIES = 32,
    parameter ENTRY_WIDTH = 168
) (
    input wire clk, 
    input wire rst,
    /* Input Interface 0 */
    input  wire        i_if0_ip_hdr_valid,
    output reg        i_if0_ip_hdr_ready,
    input  wire [47:0] i_if0_ip_eth_dest_mac,
    input  wire [47:0] i_if0_ip_eth_src_mac,
    input  wire [15:0] i_if0_ip_eth_type,
    input  wire [3:0]   i_if0_ip_version,
    input  wire [3:0]   i_if0_ip_ihl,
    input  wire [5:0]  i_if0_ip_dscp,
    input  wire [1:0]  i_if0_ip_ecn,
    input  wire [15:0] i_if0_ip_length,
    input  wire [15:0] i_if0_ip_identification,
    input  wire [2:0]  i_if0_ip_flags,
    input  wire [12:0] i_if0_ip_fragment_offset,
    input  wire [7:0]  i_if0_ip_ttl,
    input  wire [7:0]  i_if0_ip_protocol,
    input  wire [15:0] i_if0_ip_header_checksum,
    input  wire [31:0] i_if0_ip_source_ip,
    input  wire [31:0] i_if0_ip_dest_ip,
    input  wire [7:0]  i_if0_ip_payload_axis_tdata,
    input  wire        i_if0_ip_payload_axis_tvalid,
    output reg        i_if0_ip_payload_axis_tready,
    input  wire        i_if0_ip_payload_axis_tlast,
    input  wire        i_if0_ip_payload_axis_tuser,

    /* Input Interface 1 */
    input  wire        i_if1_ip_hdr_valid,
    output reg         i_if1_ip_hdr_ready,
    input  wire [47:0] i_if1_ip_eth_dest_mac,
    input  wire [47:0] i_if1_ip_eth_src_mac,
    input  wire [15:0] i_if1_ip_eth_type,
    input  wire [3:0]  i_if1_ip_version,
    input  wire [3:0]  i_if1_ip_ihl,
    input  wire [5:0]  i_if1_ip_dscp,
    input  wire [1:0]  i_if1_ip_ecn,
    input  wire [15:0] i_if1_ip_length,
    input  wire [15:0] i_if1_ip_identification,
    input  wire [2:0]  i_if1_ip_flags,
    input  wire [12:0] i_if1_ip_fragment_offset,
    input  wire [7:0]  i_if1_ip_ttl,
    input  wire [7:0]  i_if1_ip_protocol,
    input  wire [15:0] i_if1_ip_header_checksum,
    input  wire [31:0] i_if1_ip_source_ip,
    input  wire [31:0] i_if1_ip_dest_ip,
    input  wire [7:0]  i_if1_ip_payload_axis_tdata,
    input  wire        i_if1_ip_payload_axis_tvalid,
    output reg         i_if1_ip_payload_axis_tready,
    input  wire        i_if1_ip_payload_axis_tlast,
    input  wire        i_if1_ip_payload_axis_tuser,

    /* Output Interface 0 */
    output  reg        o_if0_ip_hdr_valid,
    input   wire       o_if0_ip_hdr_ready,
    output  reg [47:0] o_if0_ip_eth_dest_mac,
    output  reg [47:0] o_if0_ip_eth_src_mac,
    output  reg [15:0] o_if0_ip_eth_type,
    output  reg [3:0]  o_if0_ip_version,
    output  reg [3:0]  o_if0_ip_ihl,
    output  reg [5:0]  o_if0_ip_dscp,
    output  reg [1:0]  o_if0_ip_ecn,
    output  reg [15:0] o_if0_ip_length,
    output  reg [15:0] o_if0_ip_identification,
    output  reg [2:0]  o_if0_ip_flags,
    output  reg [12:0] o_if0_ip_fragment_offset,
    output  reg [7:0]  o_if0_ip_ttl,
    output  reg [7:0]  o_if0_ip_protocol,
    output  reg [15:0] o_if0_ip_header_checksum,
    output  reg [31:0] o_if0_ip_source_ip,
    output  reg [31:0] o_if0_ip_dest_ip,
    output  reg [7:0]  o_if0_ip_payload_axis_tdata,
    output  reg        o_if0_ip_payload_axis_tvalid,
    input   wire       o_if0_ip_payload_axis_tready,
    output  reg        o_if0_ip_payload_axis_tlast,
    output  reg        o_if0_ip_payload_axis_tuser
);

reg send_packet0 = 0;
reg send_packet1 = 0;

always @(posedge clk) begin
    if ((send_packet0 == 1'b0) && (send_packet1 == 1'b0)) begin
        if (i_if0_ip_hdr_valid) begin
            send_packet0 <= 1'b1;
        end else if (i_if1_ip_hdr_valid) begin
            send_packet1 <= 1'b1;
        end
    end else if ((send_packet0 == 1'b1) && (send_packet1 == 1'b0)) begin
        if (i_if0_ip_hdr_valid == 1'b0) begin
            send_packet0 <= 1'b0;
        end
    end else if ((send_packet0 == 1'b0) && (send_packet1 == 1'b1)) begin
        if (i_if1_ip_hdr_valid == 1'b0) begin
            send_packet1 <= 1'b0;
        end
    end
end

always @(*) begin
    if (send_packet0) begin
        i_if1_ip_hdr_ready <= 'b0;
        i_if1_ip_payload_axis_tready <= 'b0;
        
        o_if0_ip_hdr_valid <=            i_if0_ip_hdr_valid;
        i_if0_ip_hdr_ready <=            o_if0_ip_hdr_ready;
        o_if0_ip_eth_dest_mac <=         i_if0_ip_eth_dest_mac;
        o_if0_ip_eth_src_mac <=          i_if0_ip_eth_src_mac;
        o_if0_ip_eth_type <=             i_if0_ip_eth_type;
        o_if0_ip_version <=              i_if0_ip_version;
        o_if0_ip_ihl <=                  i_if0_ip_ihl;
        o_if0_ip_dscp <=                 i_if0_ip_dscp;
        o_if0_ip_ecn <=                  i_if0_ip_ecn;
        o_if0_ip_length <=               i_if0_ip_length;
        o_if0_ip_identification <=       i_if0_ip_identification;
        o_if0_ip_flags <=                i_if0_ip_flags;
        o_if0_ip_fragment_offset <=      i_if0_ip_fragment_offset;
        o_if0_ip_ttl <=                  i_if0_ip_ttl;
        o_if0_ip_protocol <=             i_if0_ip_protocol;
        o_if0_ip_header_checksum <=      i_if0_ip_header_checksum;
        o_if0_ip_source_ip <=            i_if0_ip_source_ip;
        o_if0_ip_dest_ip <=              i_if0_ip_dest_ip;
        o_if0_ip_payload_axis_tdata <=   i_if0_ip_payload_axis_tdata;
        o_if0_ip_payload_axis_tvalid <=  i_if0_ip_payload_axis_tvalid;
        i_if0_ip_payload_axis_tready <=  o_if0_ip_payload_axis_tready;
        o_if0_ip_payload_axis_tlast <=   i_if0_ip_payload_axis_tlast;
        o_if0_ip_payload_axis_tuser <=   i_if0_ip_payload_axis_tuser;
    end else if (send_packet1) begin
        i_if0_ip_hdr_ready <= 'b0;
        i_if0_ip_payload_axis_tready <= 'b0;

        o_if0_ip_hdr_valid <=            i_if1_ip_hdr_valid;
        i_if1_ip_hdr_ready <=            o_if0_ip_hdr_ready;
        o_if0_ip_eth_dest_mac <=         i_if1_ip_eth_dest_mac;
        o_if0_ip_eth_src_mac <=          i_if1_ip_eth_src_mac;
        o_if0_ip_eth_type <=             i_if1_ip_eth_type;
        o_if0_ip_version <=              i_if1_ip_version;
        o_if0_ip_ihl <=                  i_if1_ip_ihl;
        o_if0_ip_dscp <=                 i_if1_ip_dscp;
        o_if0_ip_ecn <=                  i_if1_ip_ecn;
        o_if0_ip_length <=               i_if1_ip_length;
        o_if0_ip_identification <=       i_if1_ip_identification;
        o_if0_ip_flags <=                i_if1_ip_flags;
        o_if0_ip_fragment_offset <=      i_if1_ip_fragment_offset;
        o_if0_ip_ttl <=                  i_if1_ip_ttl;
        o_if0_ip_protocol <=             i_if1_ip_protocol;
        o_if0_ip_header_checksum <=      i_if1_ip_header_checksum;
        o_if0_ip_source_ip <=            i_if1_ip_source_ip;
        o_if0_ip_dest_ip <=              i_if1_ip_dest_ip;
        o_if0_ip_payload_axis_tdata <=   i_if1_ip_payload_axis_tdata;
        o_if0_ip_payload_axis_tvalid <=  i_if1_ip_payload_axis_tvalid;
        i_if1_ip_payload_axis_tready <=  o_if0_ip_payload_axis_tready;
        o_if0_ip_payload_axis_tlast <=   i_if1_ip_payload_axis_tlast;
        o_if0_ip_payload_axis_tuser <=   i_if1_ip_payload_axis_tuser;
    end else begin
        i_if1_ip_hdr_ready <= 'b0;
        i_if1_ip_payload_axis_tready <= 'b0;
        i_if0_ip_hdr_ready <= 'b0;
        i_if0_ip_payload_axis_tready <= 'b0;

        o_if0_ip_hdr_valid <=            'b0;
        o_if0_ip_payload_axis_tvalid <= 'b0;

    end
end

endmodule