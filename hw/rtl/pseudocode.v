/*
Writing some pseudocode for these modules in this file

arbiter.v
    One module per Tx interface
    Takes in (up to) two packets from the two other interfaces, outputs them one at a time

forwarder.v
    One module per Rx interface
    Receives an Rx packet, sends the dest IP to the routing table and gets back the routing table entry
    Based on routing table entry, block the packet, or try to forward it to the correct output interface

forwarding_table.v
    Combined module for all three interfaces
    Stores a routing table in a register bank
    Takes in up to 3 destination IP addresses, returns an entire table entry that matches that IP, if one is found
*/

module arbiter(
    input clk, reset,
    /* Input Interface 0 */
    input if0_valid,
    input if0_eth_header_in,
    input if0_ip_header_in,
    input if0_ip_payload_axis,

    /* Output Interface 0 */
    output o_if0_valid,
    output o_if0_eth_header_in,
    output o_if0_ip_header_in,
    output o_if0_ip_payload_axis,
);


endmodule

module forwarder(
    input clk, reset,
    /* Input Interface 0 */
    input i_if0_packet_valid,
    input i_if0_eth_header_in,
    input i_if0_ip_header_in,
    input i_if0_ip_payload_axis,
    
    /* Output Interface 0 */
    output o_if0_valid,
    output o_if0_eth_header_in,
    output o_if0_ip_header_in,
    output o_if0_ip_payload_axis,

    /* Output Interface 1 */
    output o_if1_valid,
    output o_if1_eth_header_in,
    output o_if1_ip_header_in,
    output o_if1_ip_payload_axis,
);


STATE WAIT_FOR_PACKET, SEND_TO_FORWARDING_TABLE, FORWARD_PACKET



endmodule
