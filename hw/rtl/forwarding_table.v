// forwarding_table.v
// parameterizable number of input interfaces
// each input interfaces contains header fields from different packets

module forwarding_table #(
    parameter NUM_INTERFACES = 3,
    parameter NUM_ENTRIES = 32,
    parameter ENTRY_WIDTH = 168
) (
    input wire clk, rst,
    
    // from forwarder.v modules
    input wire [NUM_INTERFACES-1:0] i_ft_hdr_valid, 
    input wire [(48*NUM_INTERFACES)-1:0] i_ft_dest_mac,
    input wire [(48*NUM_INTERFACES)-1:0] i_ft_src_mac,
    input wire [(32*NUM_INTERFACES)-1:0] i_ft_dest_ip,
    input wire [(32*NUM_INTERFACES)-1:0] i_ft_src_ip,

    // to forwarder.v modules
    output reg  [NUM_INTERFACES-1:0]                          o_ft_resp_valid, // set high when the dest MAC and IP outputs are valid
    output reg  [(NUM_INTERFACES*$clog2(NUM_INTERFACES))-1:0] o_ft_resp, // selects an output
    output reg  [NUM_INTERFACES-1:0]                          o_ft_drop_packet,

    // table read interface
    input wire                            rd_valid,
    input wire [$clog2(NUM_ENTRIES)-1:0]  rd_index,
    output reg [ENTRY_WIDTH-1:0]          rd_data,

    // table write interface
    input wire                         wr_valid,
    input wire [$clog2(NUM_ENTRIES)-1:0] wr_index,
    input wire [ENTRY_WIDTH-1:0]       wr_data,
    
    // table miss interface
    output wire miss_valid
);

reg [47:0] PC_MAC = 48'hb025aa2dd37e;
reg [47:0] RPI0_MAC = 48'he45f01f03497;
reg [47:0] RPI1_MAC = 48'he45f01cc693a;

reg [31:0] PC_IP = 32'hc0a801c8;
reg [31:0] RPI0_IP = 32'hc0a801d2;
reg [31:0] RPI1_IP = 32'hc0a801dc;

// Note: this annoying syntax for a "part-select"
// "[i*48 +: 48]" means "[(i+1)*48-1:i*48])"

reg [167:0] forwarding_table [NUM_ENTRIES-1:0]; // indexable by forwarding_table[entry_idx]

integer i;
initial begin
    for (i = 0; i < 32; i = i + 1 ) begin
        forwarding_table[i] = 'b0;
    end

    // Initialize entries
    // PC mac address   = B0:25:AA:2D:D3:7E = 48'hb025aa2dd37e
    // PC IP address    = 192.168.1.200 = 32'hc0a801c8

    // rpi0 mac address = e4:5f:01:f0:34:97 = 48'he45f01f03497
    // rpi0 IP address    = 192.168.1.210 = 32'hc0a801d2

    // rpi1 mac address = e4:5f:01:cc:69:3a = 48'he45f01cc693a
    // rpi0 IP address    = 192.168.1.220 = 32'hc0a801dc

    // pc to rpi0
    forwarding_table[0] = {RPI0_MAC, PC_MAC,   RPI0_IP, PC_IP, 4'b0, 2'b01, 1'b0, 1'b1};

    // pc to rpi1
    forwarding_table[1] = {RPI1_MAC, PC_MAC,   RPI1_IP, PC_IP, 4'b0, 2'b10, 1'b0, 1'b1};

    // rpi0 to PC
    forwarding_table[2] = {PC_MAC,   RPI0_MAC, PC_IP,   RPI0_IP, 4'b0, 2'b00, 1'b0, 1'b1};

    // rpi0 to rpi1
    forwarding_table[3] = {RPI1_MAC, RPI0_MAC, RPI1_IP, RPI0_IP, 4'b0, 2'b10, 1'b0, 1'b1};
    
    // rpi1 to pc   
    forwarding_table[4] = {PC_MAC,   RPI1_MAC, PC_IP,   RPI1_IP, 4'b0, 2'b00, 1'b0, 1'b1};

    // rpi1 to rpi0
    forwarding_table[5] = {RPI0_MAC, RPI1_MAC, RPI0_IP, RPI1_IP, 4'b0, 2'b01, 1'b0, 1'b1};

    //forwarding_table[0] = {48'hb025aa2dd37e, 48'he45f01f03497, 32'hc0a801c8, 32'hc0a801c8, 4'b0, 2'b00, 1'b0, 1'b1}; // PC dest
    //forwarding_table[1] = {48'he45f01f03497, 48'h0, 32'h0, 32'h0, 4'b0, 2'b01, 1'b0, 1'b1}; // RPI0 dest
    //forwarding_table[2] = {48'he45f01cc693a, 48'h0, 32'h0, 32'h0, 4'b0, 2'b10, 1'b0, 1'b1}; // RPI1 dest
    
end

// Forwarding Table Search Logic
// *************************************
// NOT IMPLEMENTED FOR THE FRIDAY DEMO.
// ONE OPTION IS JUST TO SEARCH THE TABLE EVERY TIME UNTIL A MATCH IS FOUND, AND SEND TO THE SPI_CONTROLLER MODULE WHEN WE DON"T FIND A MATCH
// THE SPI_CONTROLLER WOULD JUST HANDLE WRITING TO THE TABLE WHEN NO MATCH IS FOUND
// *************************************

// Store one bit per input interface.
// If this bit is zero, then we search the table for the dest mac address if the input header is valid for the corresponding interface
// If no match is found, then we set this bit to 1.
// If this bit is 1, then we enter the header information into a queue to send to the spi_controller
// We then just leave this bit as 1, and don't search the table for that header's MAC address until it's 0 again.
// When we get a response from the spi_controller, we rewrite the table entry and send the response back to forwarder.v
reg [NUM_INTERFACES-1:0] no_match = 'b0;

integer j;
always @(posedge clk) begin
    o_ft_resp = 'b0;
    o_ft_resp_valid = 'b0;
    o_ft_drop_packet = 'b0;
    for (i = 0; i < 3; i = i + 1 ) begin
        for (j = 0; j < NUM_ENTRIES; j = j + 1 ) begin
            if ( (i_ft_hdr_valid[i] == 1'b1) 
                  && (i_ft_dest_mac[i*48 +: 48] == forwarding_table[j][167:168-48])
                  && (i_ft_src_mac[i*48 +: 48] == forwarding_table[j][168-48-1:168-48-48])
                  && (forwarding_table[j][0])) begin
                //no_match[i] = 1'b1;
                o_ft_resp_valid[i] = 'b1;
                o_ft_resp[i*2 +: 2] = forwarding_table[j][3:2];
                o_ft_drop_packet[i] = forwarding_table[j][1];
            end
        end
    end

    for (i = 0; i < NUM_INTERFACES; i = i + 1) begin
        // IF THERE IS NO MATCH, this code handles it
        if ((i_ft_hdr_valid[i] == 1'b1) && (o_ft_resp_valid[i] == 1'b0)) begin // if a valid bit is low, there was no match found
            o_ft_drop_packet[i] = 1'b1;
            o_ft_resp_valid[i] = 1'b1;
        end
    end
end

// Forwarding Table Read logic (asynchronous)
always @(*) begin
    if (rd_valid) begin
        rd_data <= forwarding_table[rd_index];
    end else begin
        rd_data <= 'b0;
    end
end

// Forwarding Table Write logic (synchronous)
always @(posedge clk) begin
    if (wr_valid) begin
        forwarding_table[wr_index] <= wr_data;
    end
end

endmodule