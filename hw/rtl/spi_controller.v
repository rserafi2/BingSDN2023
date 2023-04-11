module spi_controller #(
    parameter NUM_ENTRIES = 32 //TODO: check for power of 2
) (
    input wire clk, rst,
    //SPI Rx
    input  wire        	spi_byte_rx_valid,
    input  wire [7:0]  	spi_byte_rx,
	//SPI Tx
    output wire [7:0]  	spi_byte_tx,
	//Forwarding Table Read
    output wire [$clog2(NUM_ENTRIES)-1:0]	entry_rd_index,
    output wire 	   	entry_rd_valid,
    input  wire [167:0]	entry_rd_data,
	//Forwarding Table Write
	output wire [$clog2(NUM_ENTRIES)-1:0]	entry_wr_index,
    output wire [1:0]  	entry_wr_valid,
    output wire [167:0] entry_wr_data
);

reg [$clog2(NUM_ENTRIES)-1:0] rd_index;
reg [$clog2(NUM_ENTRIES)-1:0] wr_index;
reg en_update_rd_index;
reg en_update_wr_index;
reg rd_valid;
reg wr_valid;
integer	byte_cnt;
reg inc_byte_cnt;
reg rst_byte_cnt;
reg [167:0]	temp_table_entry = 0;
reg en_update_temp_table_entry;
reg [1:0]	fpga_opcode;
reg [1:0]   controller_opcode;
reg [7:0]   tx = 0;

assign spi_byte_tx = tx;
assign entry_rd_index = rd_index;
assign entry_wr_index = wr_index;
assign entry_rd_valid = rd_valid;
assign entry_wr_valid = wr_valid;
assign entry_wr_data = temp_table_entry;

always@(posedge clk) begin
    if (en_update_rd_index) begin
        rd_index = spi_byte_rx;
    end
    if (en_update_wr_index) begin
        wr_index = spi_byte_rx;
    end
end

always@(posedge clk) begin
    if (rst_byte_cnt) begin
        byte_cnt <= 0;
    end else if (inc_byte_cnt) begin
        byte_cnt <= byte_cnt + 1;
    end
end

always@(posedge clk) begin
    if (en_update_temp_table_entry) begin
        temp_table_entry[8*byte_cnt+:8] = spi_byte_rx;
    end
end

// FSM states
localparam S_WAIT_FOR_PACKET = 4'b0000;
localparam S_WAIT_INDEX = 4'b0001;
localparam S_WAIT_READ = 4'b0011;
localparam S_TABLE_READ = 4'b0100;
localparam S_WAIT_WRITE = 4'b0101;
localparam S_TABLE_WRITE = 4'b0110;

reg [3:0] state, next_state;
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
	
	rd_valid = 0;
	wr_valid = 0;
    inc_byte_cnt = 'b0;
    rst_byte_cnt = 'b0;
	en_update_temp_table_entry = 'b0;

    en_update_rd_index = 'b0;
    en_update_wr_index = 'b0;

    case (state)
        S_WAIT_FOR_PACKET: begin
            tx = fpga_opcode; //TODO: fix how these are set
            if(spi_byte_rx_valid == 1'b1) begin
                controller_opcode = spi_byte_rx[1:0];
                //tx = controller_opcode;
                if((controller_opcode == 2'b10)||(controller_opcode == 2'b01)) begin
                    next_state = S_WAIT_INDEX;
                end
            end
        end
        S_WAIT_INDEX: begin
            tx = controller_opcode;
            if(spi_byte_rx_valid == 1'b1) begin
                rst_byte_cnt = 'b1;
                if(controller_opcode == 2'b01) begin 
                    en_update_rd_index <= 'b1;
                    next_state = S_WAIT_READ;
                end else if(controller_opcode == 2'b10) begin
                    en_update_wr_index = 'b1;
                    next_state = S_WAIT_WRITE;
                end else begin
                    next_state = S_WAIT_FOR_PACKET;//TODO: make error state
                end
            end
        end
        S_WAIT_READ: begin
            rd_valid = 1;
            tx = entry_rd_data[8*byte_cnt+:8];
            //tx = byte_cnt;
            if(spi_byte_rx_valid == 1'b1) begin
                next_state = S_TABLE_READ;
            end
        end
        S_TABLE_READ: begin
            rd_valid = 1;
            inc_byte_cnt = 'b1;
            if(byte_cnt > 20) begin
                rd_valid = 0;
                rst_byte_cnt = 'b1;
                next_state = S_WAIT_FOR_PACKET;
            end else begin
                next_state = S_WAIT_READ;
            end
        end
        S_WAIT_WRITE: begin
            tx = 'h55;
            if(spi_byte_rx_valid == 1'b1) begin
                en_update_temp_table_entry <= 'b1;
                next_state = S_TABLE_WRITE;
            end
        end
		S_TABLE_WRITE: begin
            // temp_table_entry
            inc_byte_cnt = 'b1;
            if(byte_cnt > 20) begin
                wr_valid = 1;
                rst_byte_cnt = 'b1;
                next_state = S_WAIT_FOR_PACKET;
            end else begin
                next_state = S_WAIT_WRITE;
            end
        end
    endcase
end

endmodule