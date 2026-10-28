`timescale 1ns/1ps

module tb_fifo_scoreboard();
	reg clk=1'b0, reset;
	reg wr_en, rd_en;
	reg [7:0] wr_data;
	wire [7:0] rd_data;
	wire fifo_full, fifo_empty;

	integer errors=0, checks=0, flag_checks=0, flag_errors= 0, data_checks= 0, data_errors= 0, invalid_op_checks= 0, invalid_op_errors= 0, sim_checks= 0, sim_errors= 0, reset_checks= 0, reset_errors= 0;
	reg checker_rd_en=1'b0, checker_wr_en= 1'b0, checker_fifo_full= 1'b0, checker_fifo_empty= 1'b1;

	reg [2:0] model_rd_ptr= 3'd0, model_wr_ptr= 3'd0;
	reg [7:0] model_memory [0:7];
	reg [7:0] model_rd_data;
	reg model_fifo_full, model_fifo_empty;
	integer model_count= 0;
	reg model_write, model_read;

	reg bad_read, bad_write;
	reg [7:0] prev_rd_data;

	synchronous_fifo DUT(.clk(clk), .reset(reset), .wr_en(wr_en), .rd_en(rd_en), .wr_data(wr_data), .rd_data(rd_data), .fifo_full(fifo_full), .fifo_empty(fifo_empty));
	
	initial begin
		forever begin
			#0.5; clk= ~clk;
		end
	end

	always@(posedge clk) begin
		if(reset) begin
			model_rd_ptr <= 3'd0;
			model_wr_ptr <= 3'd0;
			model_count <= 0;

		end else begin
			if(model_write) begin
				model_memory[model_wr_ptr] <= wr_data;
				model_wr_ptr<= model_wr_ptr + 3'd1;
			end
			if(model_read) begin
				model_rd_data <= model_memory[model_rd_ptr];
				model_rd_ptr<= model_rd_ptr + 3'd1;
			end

			if (model_write & ~model_read)
    				model_count <= model_count + 1;
			else if (~model_write & model_read)
    				model_count <= model_count - 1;

		end
	end

	always@(*) begin
		if(model_count == 0) begin
			model_fifo_full= 1'b0;
			model_fifo_empty= 1'b1;
		end else if(model_count == 8) begin
			model_fifo_full= 1'b1;
			model_fifo_empty= 1'b0;
		end else begin
			model_fifo_full= 1'b0;
			model_fifo_empty= 1'b0;
		end

		model_write= wr_en & ~model_fifo_full;
		model_read= rd_en & ~model_fifo_empty;
	end

	initial begin
		$monitor("wr_en= %b, rd_en= %b, rd_data= %d, wr_data= %d fifo_full=%b, fifo_empty= %b",wr_en, rd_en, rd_data, wr_data, fifo_full, fifo_empty);
		clk= 1'b0; reset= 1'b1; wr_en=1'b0; rd_en=1'b0;

		@(negedge clk); reset= 1'b0;
		checker_rd_en = rd_en; checker_wr_en= wr_en;
		@(posedge clk); #0.1; checker_task();
		
		stimulus(1, 0, 8'd222);
		stimulus(1, 0, 8'd152);
		stimulus(1, 0, 8'd25);
		
		@(negedge clk); reset= 1'b1;
		checker_rd_en = rd_en; checker_wr_en= wr_en;
		@(posedge clk); #0.1; checker_task(); reset= 1'b0;	

		stimulus(1, 0, 8'd212);
		stimulus(1, 0, 8'd43);
		stimulus(1, 0, 8'd95);
		stimulus(1, 0, 8'd2);
		stimulus(1, 0, 8'd234);
		stimulus(1, 0, 8'd242);
		stimulus(1, 0, 8'd197);
		stimulus(1, 0, 8'd86);
		stimulus(1, 0, 8'd61);

		stimulus(1, 1, 8'd44);
		stimulus(0, 1, 8'd222);
		stimulus(0, 1, 8'd152);
		stimulus(0, 1, 8'd25);
		stimulus(0, 1, 8'd2);
		stimulus(0, 1, 8'd234);
		stimulus(0, 1, 8'd242);
		stimulus(0, 1, 8'd197);
		stimulus(0, 1, 8'd86);
		stimulus(0, 1, 8'd55);
		
		@(posedge clk); #0.1;
		@(negedge clk); rd_en= 1'b0; #10;
		
		if(errors == 0)
			$display("TEST PASSED SUCCESSFULLY !!! \nno. of checks performed= %d \n", checks);
		else
			$display("TEST FAILED !!! \nno. of checks performed= %d, no. of errors= %d \n", checks, errors);
		$display("Flag test \nchecks= %d, errors= %d \n", flag_checks, flag_errors);
		$display("Data test \nchecks= %d, errors= %d \n", data_checks, data_errors);
		$display("invalid op test \nchecks= %d, errors= %d \n", invalid_op_checks, invalid_op_errors);
		$display("simultaneous op test \nchecks= %d, errors= %d \n", sim_checks, sim_errors);
		$display("reset test \nchecks= %d, errors= %d \n", reset_checks, reset_errors);
		$stop;
	end

	task check_flags;
		begin
			if((fifo_full !== model_fifo_full) || (fifo_empty !== model_fifo_empty)) begin
				flag_errors= flag_errors+1;
				errors= errors+1;
				$display("FAIL: Flag test failed \n");
			end
			else
				$display("PASS: Flag test passed successfully \n");
			flag_checks= flag_checks+1;
			checks= checks + 1;
		end
	endtask

	task check_data;
		begin
			if(rd_data !== model_rd_data) begin
				data_errors= data_errors + 1;
				errors= errors+1;
				$display("FAIL: Data test failed \n");
			end
			else
				$display("PASS: Data test passed successfully \n");
			data_checks= data_checks+1;
			checks= checks + 1;
		end
	endtask

	task check_reset;
		begin
			checks= checks + 1;
			reset_checks= reset_checks + 1;
			if(~fifo_empty) begin
				errors= errors + 1;
				reset_errors= reset_errors + 1;
				$display("FAIL: FIFO failed to correctly reset to its original state \n");
			end
			else
				$display("PASS: FIFO was correctly reset to its original state \n");

		end
	endtask

	task checker_task;
		begin
			check_flags();
			check_invalid_op();
			if(checker_rd_en & ~checker_fifo_empty)
				check_data();
			if(checker_rd_en & checker_wr_en)
				check_sim_op;
			if(reset)
				check_reset;
		end
	endtask
	
	task check_invalid_op;
		begin
			if(bad_read || bad_write) begin
				invalid_op_checks= invalid_op_checks + 1;
				checks= checks + 1;
				if((fifo_full!== model_fifo_full) || (fifo_empty !== model_fifo_empty) || (bad_read & (rd_data !== prev_rd_data))) begin
					invalid_op_errors= invalid_op_errors + 1;
					errors= errors + 1;
					$display("FAIL: FIFO performed an invalid operation \n");
				end
				else
					$display("PASS: FIFO successfully ignored an invalid operation\n");
			end
		end
	endtask

	task check_sim_op;
		begin
			sim_checks= sim_checks +1;
			checks= checks + 1;
			if((fifo_full !== model_fifo_full) || (fifo_empty !== model_fifo_empty) || (model_rd_data !== rd_data)) begin
				errors= errors + 1;
				sim_errors= sim_errors + 1;
				$display("FAIL: FIFO failed for a simultaneous operation \n");
			end
			else
				$display("PASS: FIFO successfully performed a simultaneous operation \n");
		end

	endtask
	
	task stimulus;
		input w, r;
		input [7:0] d;
		begin
			@(negedge clk); 
			checker_rd_en= r; checker_wr_en= w;
			rd_en= r; wr_en= w; wr_data= d;
			checker_fifo_full= model_fifo_full; checker_fifo_empty= model_fifo_empty;
			bad_read= checker_rd_en && checker_fifo_empty;
			bad_write= checker_wr_en && checker_fifo_full;
			prev_rd_data= rd_data;
			@(posedge clk);
			#0.1; checker_task();
		end
	endtask
	
endmodule