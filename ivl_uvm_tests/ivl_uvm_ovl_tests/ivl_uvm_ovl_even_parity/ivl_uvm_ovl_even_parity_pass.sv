// This is linear queue / FIFO
// The queue length 1

`timescale 1ns/1ns

// TB
module test;

  logic clk, reset, wn, rn;
  reg DATAIN;  
  
  //enabling the wave dump
  initial begin 
      $dumpfile("dump.vcd");
      $dumpvars(0, test);

  end

  // Instantiate OVL example - ovl_even_parity
  ovl_even_parity u_ovl_even_parity (
	                     .clock     (clk),
			     .reset     (reset), 
			     .enable    (1'b1),
			     .test_expr (DATAIN)
      
                 );
    
  
    

initial begin
    reset = 0;   wn = 0; rn = 0;
    wait_clks(5);


    
    $display("Start testing");

    DATAIN = 0;
    wait_clks(1);
    $display("done parity injecting 1");

    DATAIN = 0;
    wait_clks(1);
    $display("done parity injecting 2");
    
    DATAIN = 0;
    wait_clks(1);
    $display("done parity injecting 3");



   $finish;
    
end

   task wait_clks(input int num_clks = 1);
      repeat (num_clks) @(posedge clk);
   endtask : wait_clks

  ivl_uvm_ovl_clk_gen #(.FREQ_IN_MHZ(100)) u_clk_100 (clk);

endmodule
