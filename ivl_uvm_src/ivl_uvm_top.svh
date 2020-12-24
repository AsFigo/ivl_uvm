module ivl_uvm_top;
  import test_pkg::*;

  `UVM_TESTNAME uvm_test_top;

  initial begin : m_top
    $display ( "Using UVM_TESTNAME: %s",
      `GO2UVM_DISP_ARG (`UVM_TESTNAME) );
    uvm_test_top = new();

  end : m_top
endmodule : ivl_uvm_top

