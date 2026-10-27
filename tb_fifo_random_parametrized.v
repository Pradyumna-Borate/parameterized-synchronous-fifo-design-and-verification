`timescale 1ns/1ps

module tb_fifo_random_parameterized #(parameter DATA_WIDTH= 8, DATA_DEPTH=8, POINTER_WIDTH= $clog2(DATA_DEPTH)) ();

	reg clk=1'b0, reset;
	reg wr_en, rd_en;
	reg [DATA_WIDTH-1:0] wr_data;
	wire [DATA_WIDTH-1:0] rd_data;
	wire fifo_full, fifo_empty;

	integer errors=0, checks=0, flag_checks=0, flag_errors= 0, data_checks= 0, data_errors= 0, invalid_op_checks= 0, invalid_op_errors= 0, sim_checks= 0, sim_errors= 0, reset_checks= 0, reset_errors= 0;
	reg checker_rd_en=1'b0, checker_wr_en= 1'b0, checker_fifo_full= 1'b0, checker_fifo_empty= 1'b1;

	reg [POINTER_WIDTH-1:0] model_rd_ptr= 0, model_wr_ptr= 0;
	reg [DATA_WIDTH-1:0] model_memory [0:DATA_DEPTH-1];
	reg [DATA_WIDTH-1:0] model_rd_data;
	reg model_fifo_full, model_fifo_empty;
	integer model_count= 0;
	reg model_write, model_read;

	integer r_wr_en, r_rd_en, r_wr_data;

	reg empty=0, full=0, write=0, read=0, simultaneous=0, wr_when_full=0, rd_when_empty=0, rd_ptr_wa=0, wr_ptr_wa=0, res_not_empty=0, idle=0; //coverage parameters
	integer n= 100; reg done=0; integer MAX_CYCLES= 10000;
	reg bad_read, bad_write;
	reg [DATA_WIDTH-1:0] prev_rd_data;

	synchronous_fifo #(.DATA_WIDTH(DATA_WIDTH), .DATA_DEPTH(DATA_DEPTH)) DUT(.clk(clk), .reset(reset), .wr_en(wr_en), .rd_en(rd_en), .wr_data(wr_data), .rd_data(rd_data), .fifo_full(fifo_full), .fifo_empty(fifo_empty));
	
	initial begin
		forever begin
			#0.5; clk= ~clk;
		end
	end

	always@(posedge clk) begin
		if(reset) begin
			model_rd_ptr <= 0;
			model_wr_ptr <= 0;
			model_count <= 0;

		end else begin
			if(model_write) begin
				model_memory[model_wr_ptr] <= wr_data;
				if(model_wr_ptr == DATA_DEPTH-1)
        				model_wr_ptr <= 0;
    				else
        				model_wr_ptr <= model_wr_ptr + 1'b1;
			end
			if(model_read) begin
				model_rd_data <= model_memory[model_rd_ptr];
				if(model_rd_ptr == DATA_DEPTH-1)
        				model_rd_ptr <= 0;
    				else
        				model_rd_ptr <= model_rd_ptr + 1'b1;
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
		end else if(model_count == DATA_DEPTH) begin
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
		clk= 1'b0; reset= 1'b0; wr_en=1'b0; rd_en=1'b0;	
		
		apply_reset();

		repeat(DATA_DEPTH) begin
    			stimulus(1'b1, 1'b0, $random);
		end

		stimulus(1'b1, 1'b0, $random);

		apply_reset();

		while(!done && n<=MAX_CYCLES) begin

			repeat(n) begin
				r_rd_en= $random & 1;
				r_wr_en= $random & 1;
				r_wr_data= $random;
	
				stimulus(r_wr_en, r_rd_en, r_wr_data);
			end

			apply_reset();

			repeat(DATA_DEPTH) begin
    				stimulus(1'b1, 1'b0, $random);
			end


			repeat(DATA_DEPTH)
    				stimulus(1'b0, 1'b1, 0);

		
			@(posedge clk); #0.1;
			@(negedge clk); rd_en= 1'b0; #10;

			if(empty & full & write & read & simultaneous & wr_when_full & rd_when_empty & rd_ptr_wa & wr_ptr_wa & res_not_empty & idle) begin
				coverage_report();
				error_report();
				done=1;
			end else begin
				n= n*10;
			end
			MAX_CYCLES= MAX_CYCLES + 1;
		
		end
		if(!done)
			$display("WARNING: All the functions were not covered in the randomised simulation");		
		$stop;
	end

	task apply_reset;
		begin
			@(negedge clk); 
			if(!model_fifo_empty) res_not_empty= 1'b1;
			reset= 1'b1;
			wr_en= 1'b0;
			rd_en= 1'b0;
			checker_rd_en = 1'b0; checker_wr_en= 1'b0;
			bad_read= 1'b0; bad_write= 1'b0;
			@(posedge clk); #0.1; check_flags(); check_reset();
			@(negedge clk); reset= 1'b0;

		end
	endtask

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
			if(checker_rd_en & checker_wr_en & ~checker_fifo_empty & ~checker_fifo_full)
				check_sim_op;
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
		input [DATA_WIDTH-1:0] d;
		begin
			@(negedge clk); 
			checker_rd_en= r; checker_wr_en= w;
			rd_en= r; wr_en= w; wr_data= d;
			checker_fifo_full= model_fifo_full; checker_fifo_empty= model_fifo_empty;

			if(wr_en & ~model_fifo_full) write= 1'b1;
			if(rd_en & ~model_fifo_empty) read= 1'b1;
			if(wr_en & rd_en) simultaneous= 1'b1;
			if(rd_en & model_fifo_empty) rd_when_empty= 1'b1;
			if(wr_en & model_fifo_full) wr_when_full= 1'b1;
			if(rd_en & ~model_fifo_empty && (model_rd_ptr == DATA_DEPTH-1)) rd_ptr_wa= 1'b1;			
			if(wr_en & ~model_fifo_full && (model_wr_ptr == DATA_DEPTH-1)) wr_ptr_wa= 1'b1;
			if(~rd_en & ~wr_en) idle= 1'b1;

			bad_read= checker_rd_en && checker_fifo_empty;
			bad_write= checker_wr_en && checker_fifo_full;
			prev_rd_data= rd_data;
			@(posedge clk);
			#0.1; checker_task();
			if(model_fifo_empty) empty= 1'b1;
			if(model_fifo_full) full= 1'b1;
		end
	endtask

	task coverage_report;
    		begin
        		$display("Coverage reoprt");
        		$display("Empty observed             : %b", empty);
        		$display("Full observed              : %b", full);
        		$display("Accepted write             : %b", write);
        		$display("Accepted read              : %b", read);
        		$display("Simultaneous read/write    : %b", simultaneous);
        		$display("Write attempted when full  : %b", wr_when_full);
       			$display("Read attempted when empty  : %b", rd_when_empty);
        		$display("Read pointer wraparound    : %b", rd_ptr_wa);
        		$display("Write pointer wraparound   : %b", wr_ptr_wa);
        		$display("Reset while nonempty       : %b", res_not_empty);
        		$display("Idle cycle                 : %b", idle);
       		end
	endtask

	task error_report;
    		begin
        		if(errors == 0)
				$display("TEST PASSED SUCCESSFULLY !!! \nno. of checks performed= %d \n", checks);
			else
				$display("TEST FAILED !!! \nno. of checks performed= %d, no. of errors= %d \n", checks, errors);
			$display("Flag test \nchecks= %d, errors= %d", flag_checks, flag_errors);
			$display("Data test \nchecks= %d, errors= %d", data_checks, data_errors);
			$display("Invalid op test \nchecks= %d, errors= %d", invalid_op_checks, invalid_op_errors);
			$display("Simultaneous op test \nchecks= %d, errors= %d", sim_checks, sim_errors);
			$display("Reset test \nchecks= %d, errors= %d", reset_checks, reset_errors);
       		end
	endtask

	
endmodule