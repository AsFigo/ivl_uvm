// This is linear queue / FIFO
// The queue length 1

`timescale 1ns/1ns

// TB
module test;

  logic clk, reset, rd,rd_ack;
  reg [3:0]DATA;  
  

  // Instantiate OVL example - ovl_even_parity
  ovl_win_unchange #( .width(4)) u_ovl_win_unchange (
	                     .clock     (clk),
			     .reset     (reset), 
			     .enable    (1'b1),
			     .start_event(rd),
			     .test_expr (DATA),
			     .end_event(rd_ack)
      
                 );
    
  
  //enabling the wave dump
  initial begin 
      $dumpfile("dump.vcd");
      $dumpvars(0, test);

  end
    

initial begin
    reset = 0;   rd = 0; rd_ack = 0;
    wait_clks(5);
   
    reset = 1; 
    wait_clks(5); 
    
    $display("Start testing");

    DATA = 0; rd =0; rd_ack =0;
    wait_clks(5);


// B
  
    rd = 0; rd_ack =0;
    wait_clks(5);
	
    $display("1 B with  NOT change in data");

    DATA = 4'b1100; rd =1; rd_ack =0;
    wait_clks(5);
    $display("B");


    DATA = 4'b1100;
    wait_clks(5);

    rd_ack =1;
    wait_clks(5);

    $display("2 B with NOT Data changing ");

// C

    DATA = 0; rd =0; rd_ack =0;
    wait_clks(5);

    $display("1 C with NOT change in data");

    DATA = 4'b0011; rd =1; rd_ack =0;
    wait_clks(5);
    $display("C");


    DATA = 4'b0011; 
    wait_clks(5);

    rd_ack =1;
    wait_clks(5);

    $display("2 C with NOT data changing ");

  
    rd = 0; rd_ack =0;
    wait_clks(5);

   $finish;
    
end

   task wait_clks(input int num_clks = 1);
      repeat (num_clks) @(posedge clk);
   endtask : wait_clks

  ivl_uvm_ovl_clk_gen #(.FREQ_IN_MHZ(100)) u_clk_100 (clk);

endmodule
