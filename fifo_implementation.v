module synchronous_fifo
#(parameter DATA_DEPTH= 8, DATA_WIDTH= 8)
(
	input clk, reset, 
	input wr_en, rd_en,
	input [DATA_WIDTH-1:0] wr_data,
	output reg [DATA_WIDTH-1:0] rd_data,
	output reg fifo_full, fifo_empty
);
	parameter POINTER_WIDTH= $clog2(DATA_DEPTH);

	reg [POINTER_WIDTH:0] rd_ptr= 0, wr_ptr=0;
	reg [DATA_WIDTH-1:0] memory [0:DATA_DEPTH-1];
	
	always@(posedge clk) begin

		if(reset) begin
			wr_ptr<= 0;
			rd_ptr<= 0;
		end

		else begin
	
			if(wr_en & ~fifo_full) begin
				memory[wr_ptr[POINTER_WIDTH-1:0]]<= wr_data;
 				wr_ptr <= wr_ptr + 1'b1;				
			end
			
			if(rd_en & ~fifo_empty) begin
				rd_data <= memory[rd_ptr[POINTER_WIDTH-1:0]];
        			rd_ptr <= rd_ptr + 1'b1;				
			end

		end	
		
	end
	
	always@(*) begin
		if((rd_ptr[POINTER_WIDTH-1:0] == wr_ptr[POINTER_WIDTH-1:0]) && (rd_ptr[POINTER_WIDTH] ^ wr_ptr[POINTER_WIDTH]))
			fifo_full= 1'b1;
		else
			fifo_full= 1'b0;

		if(rd_ptr == wr_ptr)
			fifo_empty= 1'b1;
		else
			fifo_empty= 1'b0;			
		
	end

endmodule
	