module forwarder #(
    parameter NUM_INTERFACES = 3,
    parameter RX_INTERFACE_NUM = 0 // the interface corresponding to this forwarder.v module
) (
    input wire clk, rst,
    /* single input interface */
    input  wire        i_if0_ip_hdr_valid,
    output reg         i_if0_ip_hdr_ready,
    input  wire [47:0] i_if0_ip_eth_dest_mac,
    input  wire [47:0] i_if0_ip_eth_src_mac,
    input  wire [15:0] i_if0_ip_eth_type,
    input  wire [3:0]  i_if0_ip_version,
    input  wire [3:0]  i_if0_ip_ihl,
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
    output reg         i_if0_ip_payload_axis_tready,
    input  wire        i_if0_ip_payload_axis_tlast,
    input  wire        i_if0_ip_payload_axis_tuser,
    
    /* NUM_INTERFACES output interfaces */
    output reg [NUM_INTERFACES-1:0]      o_if0_ip_hdr_valid,
    input  wire [NUM_INTERFACES-1:0]     o_if0_ip_hdr_ready,
    output reg [48*NUM_INTERFACES-1:0] o_if0_ip_eth_dest_mac,// 48 bits per interface
    output reg [48*NUM_INTERFACES-1:0] o_if0_ip_eth_src_mac, // 48 bits each
    output reg [16*NUM_INTERFACES-1:0] o_if0_ip_eth_type,    // 16 bits each
    output reg [4*NUM_INTERFACES-1:0]  o_if0_ip_version,     // 3 bits each
    output reg [4*NUM_INTERFACES-1:0]  o_if0_ip_ihl,         // etc
    output reg [6*NUM_INTERFACES-1:0]  o_if0_ip_dscp,
    output reg [2*NUM_INTERFACES-1:0]  o_if0_ip_ecn,
    output reg [16*NUM_INTERFACES-1:0] o_if0_ip_length,
    output reg [16*NUM_INTERFACES-1:0] o_if0_ip_identification,
    output reg [3*NUM_INTERFACES-1:0]  o_if0_ip_flags,
    output reg [13*NUM_INTERFACES-1:0] o_if0_ip_fragment_offset,
    output reg [8*NUM_INTERFACES-1:0]  o_if0_ip_ttl,
    output reg [8*NUM_INTERFACES-1:0]  o_if0_ip_protocol,
    output reg [16*NUM_INTERFACES-1:0] o_if0_ip_header_checksum,
    output reg [32*NUM_INTERFACES-1:0] o_if0_ip_source_ip,
    output reg [32*NUM_INTERFACES-1:0] o_if0_ip_dest_ip,
    output reg [8*NUM_INTERFACES-1:0]    o_if0_ip_payload_axis_tdata,
    output reg [NUM_INTERFACES-1:0]      o_if0_ip_payload_axis_tvalid,
    input  wire [NUM_INTERFACES-1:0]     o_if0_ip_payload_axis_tready,
    output reg [NUM_INTERFACES-1:0]      o_if0_ip_payload_axis_tlast,
    output reg [NUM_INTERFACES-1:0]      o_if0_ip_payload_axis_tuser,

    // Connections to forwarding_table.v (ft = forwarding_table)
    output reg        o_ft_hdr_valid, // set high when the dest MAC and IP outputs are valid
    output reg [47:0] o_ft_dest_mac,
    output reg [47:0] o_ft_src_mac,
    output reg [31:0] o_ft_dest_ip,
    output reg [31:0] o_ft_source_ip,

    input wire                         i_ft_resp_valid, // set high when the dest MAC and IP outputs are valid
    input wire  [$clog2(NUM_INTERFACES)-1:0] i_ft_resp, // selects an output
    input wire                         i_ft_drop_packet
);

// FSM states
localparam S_WAIT_FOR_PACKET = 3'b000;
localparam S_SEND_TO_FORWARDING_TABLE = 3'b001;
localparam S_DROP_PACKET = 3'b010;
localparam S_FORWARD_PACKET = 3'b011;

reg [NUM_INTERFACES-1:0] ft_resp_reg;
reg update_ft_resp_reg;

always @(posedge clk) begin
    if (update_ft_resp_reg) begin
        ft_resp_reg <= i_ft_resp;
    end
end

reg [2:0] state, next_state;
always @(posedge clk) begin
    if (rst == 1'b1) begin
        state <= S_WAIT_FOR_PACKET;
    end
    else begin
        state <= next_state;
    end
end

always @(*) begin
    next_state = state; // default
    i_if0_ip_hdr_ready = 'b0;
    o_ft_hdr_valid = 'b0;
    o_ft_dest_mac = 'b0;
    o_ft_src_mac = 'b0;
    o_ft_dest_ip = 'b0;
    o_ft_source_ip = 'b0;
    
    o_if0_ip_hdr_valid = 'b0;
    o_if0_ip_eth_dest_mac = 'b0;
    o_if0_ip_eth_src_mac = 'b0;
    o_if0_ip_eth_type = 'b0;
    o_if0_ip_version = 'b0;
    o_if0_ip_ihl = 'b0;
    o_if0_ip_dscp = 'b0;
    o_if0_ip_ecn = 'b0;
    o_if0_ip_length = 'b0;
    o_if0_ip_identification = 'b0;
    o_if0_ip_flags = 'b0;
    o_if0_ip_fragment_offset = 'b0;
    o_if0_ip_ttl = 'b0;
    o_if0_ip_protocol = 'b0;
    o_if0_ip_header_checksum = 'b0;
    o_if0_ip_source_ip = 'b0;
    o_if0_ip_dest_ip = 'b0;

    o_if0_ip_payload_axis_tdata = 'b0;
    o_if0_ip_payload_axis_tvalid = 'b0;
    i_if0_ip_payload_axis_tready = 'b0;
    o_if0_ip_payload_axis_tlast = 'b0;
    o_if0_ip_payload_axis_tuser = 'b0;

    //ft_resp_reg = 'b0;
    update_ft_resp_reg = 1'b0;
    case (state)
        S_WAIT_FOR_PACKET: begin
            // Asserts that we are ready for a new header
            // Sends necessary header info to the 
            i_if0_ip_hdr_ready = 1'b1;

            if (i_if0_ip_hdr_valid == 1'b1) begin
                o_ft_dest_mac = i_if0_ip_eth_dest_mac;
                o_ft_src_mac = i_if0_ip_eth_src_mac;
                o_ft_dest_ip = i_if0_ip_dest_ip;
                o_ft_source_ip = i_if0_ip_source_ip;
                o_ft_hdr_valid = 1'b1;

                next_state = S_SEND_TO_FORWARDING_TABLE;
            end
        end
        S_SEND_TO_FORWARDING_TABLE: begin
            // Waits untilt the response from the forwarding table is valid
            // Then, loads the response into a register
            // If the forwarding table asserted i_ft_drop_packet, then go to the drop packet state
            // Otherwise, go to the forward packet state
            if (i_ft_resp_valid == 1'b1) begin
                //ft_resp_reg = i_ft_resp;
                update_ft_resp_reg = 1'b1;

                if (i_ft_drop_packet == 1'b1) begin
                    next_state = S_DROP_PACKET;
                end else begin
                    next_state = S_FORWARD_PACKET;
                end
            end
        end
        S_DROP_PACKET: begin
            // Effectively drops the incoming packet
            // Tells incoming AXI-S interface that we are ready for data
            // Transitions to S_WAIT_FOR_PACKET when the packet ends (tlast == 1)
            i_if0_ip_payload_axis_tready = 1'b1;
            if (i_if0_ip_payload_axis_tlast == 1'b1) begin
                next_state = S_WAIT_FOR_PACKET;
            end
        end
        S_FORWARD_PACKET: begin
            // Connects the incoming packet to the correct output packet interface (indicated by ft_resp_reg)
            // Transitions to S_WAIT_FOR_PACKET when the packet ends (tlast == 1)
            i_if0_ip_hdr_ready                                 = o_if0_ip_hdr_ready[ft_resp_reg];
            //o_if0_ip_hdr_valid          [ft_resp_reg]          = i_if0_ip_hdr_valid;
                o_if0_ip_hdr_valid      [ft_resp_reg]          = 'b1;
            o_if0_ip_eth_dest_mac       [48*ft_resp_reg +: 48] = i_if0_ip_eth_dest_mac;
            o_if0_ip_eth_src_mac        [48*ft_resp_reg +: 48] = i_if0_ip_eth_src_mac;
            o_if0_ip_eth_type           [16*ft_resp_reg +: 16] = i_if0_ip_eth_type;
            o_if0_ip_version            [4*ft_resp_reg +: 4]   = i_if0_ip_version;
            o_if0_ip_ihl                [4*ft_resp_reg +: 4]   = i_if0_ip_ihl;
            o_if0_ip_dscp               [6*ft_resp_reg +: 6]   = i_if0_ip_dscp;
            o_if0_ip_ecn                [2*ft_resp_reg +: 2]   = i_if0_ip_ecn;
            o_if0_ip_length             [16*ft_resp_reg +: 16] = i_if0_ip_length;
            o_if0_ip_identification     [16*ft_resp_reg +: 16] = i_if0_ip_identification;
            o_if0_ip_flags              [3*ft_resp_reg +: 3]   = i_if0_ip_flags;
            o_if0_ip_fragment_offset    [13*ft_resp_reg +: 13] = i_if0_ip_fragment_offset;
            o_if0_ip_ttl                [8*ft_resp_reg +: 8]   = i_if0_ip_ttl;
            o_if0_ip_protocol           [8*ft_resp_reg +: 8]   = i_if0_ip_protocol;
            o_if0_ip_header_checksum    [16*ft_resp_reg +: 16] = i_if0_ip_header_checksum;
            o_if0_ip_source_ip          [32*ft_resp_reg +: 32] = i_if0_ip_source_ip;
            o_if0_ip_dest_ip            [32*ft_resp_reg +: 32] = i_if0_ip_dest_ip;

            o_if0_ip_payload_axis_tdata[8*ft_resp_reg +: 8] = i_if0_ip_payload_axis_tdata;
            o_if0_ip_payload_axis_tvalid[ft_resp_reg] = i_if0_ip_payload_axis_tvalid;
            i_if0_ip_payload_axis_tready = o_if0_ip_payload_axis_tready[ft_resp_reg];
            o_if0_ip_payload_axis_tlast[ft_resp_reg] = i_if0_ip_payload_axis_tlast;
            o_if0_ip_payload_axis_tuser[ft_resp_reg] = i_if0_ip_payload_axis_tuser;

            if (i_if0_ip_payload_axis_tlast == 1'b1) begin
                next_state = S_WAIT_FOR_PACKET;
            end
        end
    endcase
end
endmodule
