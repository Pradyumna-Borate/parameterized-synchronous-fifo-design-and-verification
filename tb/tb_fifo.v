`timescale 1ns/1ps

module tb_fifo ();
	reg clk, reset;
	reg wr_en, rd_en;
	reg [7:0] wr_data;
	wire [7:0] rd_data;
	integer value_errors;
	integer value_checks;
	integer flag_errors;
	integer flag_checks;
	integer invalid_op_errors;
	integer invalid_op_checks;
	integer wrap_around_checks;
	integer wrap_around_errors;
	integer simultaneous_checks;
	integer simultaneous_errors;
	integer reset_checks;
	integer reset_errors;
	reg empty_before_reset;


	reg [3:0] prev_rd_ptr, curr_rd_ptr;
	reg [3:0] prev_wr_ptr, curr_wr_ptr;

	wire fifo_full, fifo_empty;

	synchronous_fifo DUT (.clk(clk), .reset(reset), .wr_en(wr_en), .rd_en(rd_en), .wr_data(wr_data), .rd_data(rd_data), .fifo_full(fifo_full), .fifo_empty(fifo_empty));
	
	initial begin
		forever begin
			#0.5; clk= ~clk;
		end
	end

	initial begin
		$monitor("wr_en= %b, rd_en= %b, rd_data= %d, wr_data= %d fifo_full=%b, fifo_empty= %b",wr_en, rd_en, rd_data, wr_data, fifo_full, fifo_empty);
		clk= 1'b0; reset= 1'b1; wr_en=1'b0; rd_en=1'b0; value_errors=0; value_checks= 0; flag_errors=0; flag_checks= 0; invalid_op_errors=0; invalid_op_checks= 0;
		wrap_around_checks= 0; wrap_around_errors=0; simultaneous_checks= 0; simultaneous_errors= 0; reset_checks= 0; reset_errors= 0;

		@(negedge clk); reset= 1'b0;
		@(posedge clk);
		#0.1; check_flags(fifo_empty, fifo_full, 1'b1, 1'b0); 
		if(fifo_empty) begin
			$display("PASS: reset works successfully\n");
			reset_checks= reset_checks + 1;
		end else begin
			$display("FAIL: reset doesn't work successfully\n");
			reset_checks= reset_checks + 1;
			reset_errors= reset_errors + 1;
		end
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd222;
		@(posedge clk);
		#0.1; check_flags(fifo_empty, fifo_full, 1'b0, 1'b0);
		
		
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd29;
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd153;
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd120;
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd34;
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd165;
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd143;
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd21;
		@(posedge clk);
		#0.1; check_flags(fifo_empty, fifo_full, 1'b0, 1'b1);
		if(DUT.wr_ptr !== 4'b1000) begin
			$display("FAIL: wr_ptr is not wrap around correctly \n");
			wrap_around_errors= wrap_around_errors+1;
			wrap_around_checks= wrap_around_checks+1;

		end
		else begin
			$display("PASS: wr_ptr is wrap around correctly \n");
			wrap_around_checks= wrap_around_checks+1;

		end 
		@(negedge clk); wr_en= 1'b1; wr_data= 8'd41;
		prev_wr_ptr= DUT.wr_ptr;
		@(posedge clk);
		#0.1;	
		curr_wr_ptr= DUT.wr_ptr;
		if(prev_wr_ptr !== curr_wr_ptr) begin
			$display("FAIL: FIFO wrote in a full condition\n");
			invalid_op_errors=invalid_op_errors+1;
			invalid_op_checks=invalid_op_checks+1;
		end
		else begin
			$display("PASS: FIFO rejected to write in a full condition");
			invalid_op_checks=invalid_op_checks+1;

		end

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		@(posedge clk);
		#0.1; check_data(rd_data, 8'd222);

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		@(posedge clk);
		#0.1; check_data(rd_data, 8'd29);

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		@(posedge clk);
		#0.1; check_data(rd_data, 8'd153);

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		@(posedge clk);
		#0.1; check_data(rd_data, 8'd120);

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		@(posedge clk);
		#0.1; check_data(rd_data, 8'd34);

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		@(posedge clk);
		#0.1; check_data(rd_data, 8'd165);

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		@(posedge clk);
		#0.1; check_data(rd_data, 8'd143);

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		
		@(posedge clk);
		#0.1; check_data(rd_data, 8'd21);
		if(DUT.rd_ptr !== 4'b1000) begin
			$display("FAIL: rd_ptr is not wrap around correctly \n");
			wrap_around_errors= wrap_around_errors+1;
			wrap_around_checks= wrap_around_checks+1;

		end
		else begin
			$display("PASS: rd_ptr is wrap around correctly \n");
			wrap_around_checks= wrap_around_checks+1;

		end 

		@(negedge clk); wr_en=1'b0; rd_en= 1'b1;
		prev_rd_ptr= DUT.rd_ptr;		
		@(posedge clk);
		#0.1; 
		curr_rd_ptr= DUT.rd_ptr;
		if(prev_rd_ptr !== curr_rd_ptr) begin
			$display("FAIL: FIFO read in an empty condition\n");
			invalid_op_errors=invalid_op_errors+1;
			invalid_op_checks=invalid_op_checks+1;
		end
		else begin
			$display("PASS: FIFO rejected to read in an empty condition");
			invalid_op_checks=invalid_op_checks+1;

		end
		
		@(negedge clk); wr_en= 1'b1; rd_en=1'b0; wr_data= 8'd100;
		@(negedge clk); wr_en= 1'b1; rd_en=1'b1; wr_data= 8'd101;
		prev_rd_ptr= DUT.rd_ptr;
		prev_wr_ptr= DUT.wr_ptr;
		@(posedge clk); #0.1;
		curr_rd_ptr= DUT.rd_ptr;
		curr_wr_ptr= DUT.wr_ptr;
		if((curr_rd_ptr === prev_rd_ptr + 4'd1) && (curr_wr_ptr === prev_wr_ptr + 4'd1)) begin
			$display("PASS: simultaneous operation pointers updated successfully");
			simultaneous_checks= simultaneous_checks + 1;
		end else begin
			$display("FAIL: simultaneous operation pointer updation failed");
			simultaneous_checks= simultaneous_checks + 1;
			simultaneous_errors= simultaneous_errors + 1;
		end


		if(rd_data === 8'd100) begin
			$display("PASS: data read successfully");
			simultaneous_checks= simultaneous_checks + 1;
		end else begin
			$display("FAIL: data read failed");
			simultaneous_checks= simultaneous_checks + 1;
			simultaneous_errors= simultaneous_errors + 1;
		end
		@(negedge clk);  rd_en=1'b1; wr_en=1'b0;
		
		@(posedge clk); #0.1;
		
		if(rd_data === 8'd101) begin
			$display("PASS: data written successfully");
			simultaneous_checks= simultaneous_checks + 1;
		end else begin
			$display("FAIL: data write failed");
			simultaneous_checks= simultaneous_checks + 1;
			simultaneous_errors= simultaneous_errors + 1;
		end
		
		@(negedge clk); wr_en= 1'b1; rd_en=1'b0; wr_data= 8'd102;
		@(negedge clk);  rd_en=1'b1; wr_en=1'b0;
		@(negedge clk); wr_en= 1'b1; rd_en=1'b0; wr_data= 8'd103;
		@(posedge clk); #0.1; empty_before_reset= fifo_empty;
		@(negedge clk); reset= 1'b1;
		@(posedge clk);
		#0.1; check_flags(fifo_empty, fifo_full, 1'b1, 1'b0);
		if((fifo_empty) && (~empty_before_reset)) begin
			$display("PASS: reset works successfully\n");
			reset_checks= reset_checks + 1;
		end else begin
			$display("FAIL: reset doesn't work successfully\n");
			reset_checks= reset_checks + 1;
			reset_errors= reset_errors + 1;
		end

		@(negedge clk); rd_en= 1'b0;
		@(posedge clk);
		#0.1; check_flags(fifo_empty, fifo_full, 1'b1, 1'b0);

		#10;

		$display("\n \nSUMMARY \n \n");

		$display("total value checks= %d \ntotal value errors= %d \n", value_checks, value_errors);
		if((value_errors == 0) && (value_checks > 0))
			$display("VALUE TEST PASSED SUCCESSFULLY !!\n");
		else
			$display("VALUE TEST FAILED \n");
		
		$display("total flag checks= %d \ntotal flag errors= %d \n", flag_checks, flag_errors);
		if((flag_errors == 0) && (flag_checks > 0))
			$display("FLAG TEST PASSED SUCCESSFULLY !!\n");
		else
			$display("FLAG TEST FAILED \n");

		$display("total invalid_op checks= %d \ntotal invalid_op errors= %d \n", invalid_op_checks, invalid_op_errors);
		if((invalid_op_errors == 0) && (invalid_op_checks > 0))
			$display("INVALID_OP TEST PASSED SUCCESSFULLY !!\n");
		else
			$display("INVALID_OP TEST FAILED \n");

		$display("total wrap_around checks= %d \ntotal wrap_around errors= %d \n", wrap_around_checks, wrap_around_errors);
		if((wrap_around_errors == 0) && (wrap_around_checks > 0))
			$display("WRAP_AROUND TEST PASSED SUCCESSFULLY !!\n");
		else
			$display("WRAP_AROUND TEST FAILED \n");
		
		$display("total simultaneous checks= %d \ntotal simultaneous errors= %d \n", simultaneous_checks, simultaneous_errors);
		if((simultaneous_errors == 0) && (simultaneous_checks > 0))
			$display("SIMULTANEOUS TEST PASSED SUCCESSFULLY !!\n");
		else
			$display("SIMULTANEOUS TEST FAILED \n");

		$display("total reset checks= %d \ntotal reset errors= %d \n", reset_checks, reset_errors);
		if((reset_errors == 0) && (reset_checks > 0))
			$display("RESET TEST PASSED SUCCESSFULLY !!\n");
		else
			$display("RESET TEST FAILED \n");

		
		$stop;

	end

	task check_data;
		
		input[7:0] rd_data;
		input[7:0] expected_data;
		begin
			if(rd_data !== expected_data) begin
				$display("FAIL: returned value= %d, expected value= %d \n", rd_data, expected_data);
				value_errors= value_errors + 1;
			end
			else begin
				$display("PASS: returned value= %d \n", rd_data);
			end
			value_checks= value_checks + 1;
		end
	endtask

	task check_flags;
		
		input empty, full;
		input expected_empty, expected_full;
		begin
			if( (empty !== expected_empty) || (full !== expected_full)) begin
				$display("FAIL: returned empty= %d, expected empty= %d FAIL: returned full= %d, expected full= %d\n", empty, expected_empty, full, expected_full );
				flag_errors= flag_errors + 1;
			end
			else begin
				$display("PASS: returned empty= %d  returned full= %d\n", empty, full);
			end
			flag_checks= flag_checks + 1;
		end
	endtask


endmodule