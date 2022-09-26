// This is linear queue / FIFO
// The queue length 1
//  CASES A ,C ,and  D should expect as fail

`timescale 1ns/1ns

// TB
module test;

  logic clk, reset, rd,rd_ack,DATA;  
  
  //enabling the wave dump
  initial begin 
      $dumpfile("dump.vcd");
      $dumpvars(0, test);

  end

  // Instantiate OVL example - ovl_even_parity
  ovl_win_change u_ovl_win_change (
	                     .clock     (clk),
			     .reset     (reset), 
			     .enable    (1'b1),
			     .start_event(rd),
			     .test_expr (DATA),
			     .end_event(rd_ack)
      
                 );
    
  
    

initial begin
    reset = 0;   rd = 0; rd_ack = 0;
    wait_clks(5);
   
    reset =1;
    wait_clks(5);
   
     
    
    $display("Start testing");

    $display("1 A with no change in data");

    DATA = 0; rd =1; rd_ack =0;
    wait_clks(1);
    $display("A");


    DATA = 0; rd_ack =1;
    wait_clks(1);
    $display("2 A with no change in data");


    $display("1 B with change in data");
    DATA = 1; rd =1;rd_ack =0;
    wait_clks(1);
    $display("B");

    DATA = 0; rd_ack =1;
    wait_clks(1);
    $display("2 B with change in data");

    $display("1 C with no change in data");
    DATA = 1; rd =1;rd_ack =0;
    wait_clks(1);
    $display("C");

    DATA = 1; rd_ack =1;
    wait_clks(1);
    $display("2 C with no change in data");


    $display("1 D with no change in data");
    DATA = 1; rd =1;rd_ack =0;
    wait_clks(1);
    $display("D");

    DATA = 1; rd_ack =1;
    wait_clks(1);
    $display("2 D with no change in data");



   $finish;
    
end

   task wait_clks(input int num_clks = 1);
      repeat (num_clks) @(posedge clk);
   endtask : wait_clks

  ivl_uvm_ovl_clk_gen #(.FREQ_IN_MHZ(100)) u_clk_100 (clk);

endmodule
