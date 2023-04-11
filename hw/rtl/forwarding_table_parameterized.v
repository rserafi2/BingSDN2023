// forwarding_table.v
// parameterizable number of input interfaces
// each input interfaces contains header fields from different packets

// FOR EACH INPUT HEADER {
//     check the forwarding table for a match
//     if no match is found, then query the controller 
// 
// } 

// issue: we are going to have an arbitrary number of inputs to this module (i.e. the number of interfaces)
// this means that there will be an arbitrary number of 

module forwarding_table #(
    parameter NUM_INTERFACES = 3,
    parameter NUM_ENTRIES = 64,
    parameter ENTRY_WIDTH_PARAM = 168
) (
    input wire clk, rst,
    
    // from forwarder.v modules
    input wire [NUM_INTERFACES-1:0] i_ft_hdr_valid, 
    input wire [(48*NUM_INTERFACES)-1:0] i_ft_dest_mac,
    input wire [(48*NUM_INTERFACES)-1:0] i_ft_src_mac,
    input wire [(32*NUM_INTERFACES)-1:0] i_ft_dest_ip,
    input wire [(32*NUM_INTERFACES)-1:0] i_ft_src_ip,

    // to forwarder.v modules
    output wire  [NUM_INTERFACES-1:0]                          o_ft_resp_valid, // set high when the dest MAC and IP outputs are valid
    output wire  [(NUM_INTERFACES*$clog2(NUM_INTERFACES))-1:0] o_ft_resp, // selects an output
    output wire  [NUM_INTERFACES-1:0]                          o_ft_drop_packet,

    // table read interface
    input wire  [$clog2(NUM_ENTRIES)-1:0] rd_index,
    input wire                            rd_valid,
    output wire [ENTRY_WIDTH_PARAM-1:0]   rd_data,

    // table write interface
    input wire                         wr_valid,
    input wire [ENTRY_WIDTH_PARAM-1:0] wr_data,

    // table miss interface
    output wire miss_valid,
    output wire 

);

/* Unfinished eginnings of a parameterized version of this module. WIP. */
/*
// Need a specification for which fields are which bits in each entry
localparam ENTRY_WIDTH = 48 + 48 + 32 + 32 + 8; // dest_mac (6B) src_mac (6B), dest_ip (4B), src_ip (4B), unused (4b), portnum ()
reg [NUM_ENTRIES-1:0] forwarding_table [ENTRY_WIDTH-1:0];

wire [NUM_INTERFACES-1:0] found_match;
integer i;
integer j;
// content addressable memory. search the routing table
always @ (posedge clk) begin
    found_match = 'b0;
    for (i = 0; i < NUM_INTERFACES; i++) begin
        for (j = 0; j < NUM_ENTRIES; j++) begin
            if ( (i_ft_hdr_valid[i] == 1'b1) && (i_ft_dest_mac[(48*(i+1)-1):(48*(i+1)-48)] == forwarding_table[j][ENTRY_WIDTH-1:ENTRY_WIDTH-48])) begin
                found_match[i] <= 1'b1;
                o_ft_resp[(i+1)*$clog2(NUM_INTERFACES)-1:(i+1)*$clog2(NUM_INTERFACES) - $clog2(NUM_INTERFACES)];
            end
        end
    end
end
*/



endmodule