// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_pkg.sv
// Author(s): Anirudh Pradyumnan (apseng03@gmail.com)
//            Srinivasan Venkataramanan 
//
// Copyright (c) VerifWorks 2016-2020  All Rights Reserved.
// Contact us via: support@verifworks.com
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 3 as published by the Free Software Foundation.
// 
// This program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// 
// ========== Copyright Header End ============================
////////////////////////////////////////////////////////////////////////

  function uvm_count_info();
    uvm_info_counter++;
  endfunction : uvm_count_info

  /*

  function void uvm_count_info();
    uvm_info_counter++;
  endfunction : uvm_count_info
  */

  function void uvm_count_warn();
    uvm_warn_counter++;
  endfunction : uvm_count_warn

  function void uvm_count_err();
    uvm_err_counter++;
  endfunction : uvm_count_err

  function void uvm_count_fatal();
    uvm_fatal_counter++;
  endfunction : uvm_count_fatal


  function void report_summarize ();
    int num_errs;

    $display("");
    $display("--- UVM Report Summary ---");
    $display("");
    $display("** Report counts by severity");
    $display ("UVM_INFO : %0d", uvm_info_counter);
    $display ("UVM_WARNING : %0d", uvm_warn_counter);
    $display ("UVM_ERROR : %0d", uvm_err_counter);
    $display ("UVM_FATAL : %0d", uvm_fatal_counter);

    num_errs = uvm_err_counter;

    if(num_errs > 0) begin : fail
      $display ( "%c[1;31m",27 ) ; // RED color
      $display ("Test FAILED with %0d error(s), look for UVM_ERROR in log file",
                 num_errs);
      $display ( "%c[0m",27 ) ;
    end : fail
    else begin : pass
      $display ( "%c[5;34m",27 ) ; // BLUE color
      $display ( "*** Congratulations! Test PASSED with NO UVM_ERRORs ***" ) ;
      $display ( "%c[0m",27 ) ;
    end : pass

  `uvm_info (log_id, 
    "Thanks for using IVL_UVM Package",
    UVM_NONE)

  endfunction : report_summarize

  function void uvm_report_info( string id,
                                  string message,
                                  int verbosity,
                                  string filename = "",
                                  int line = 0);
    // ivl_uvm_compose_message(UVM_INFO, "", id, message, filename, line); 

  endfunction : uvm_report_info



function string ivl_uvm_compose_message(
      uvm_severity severity,
      string id,
      string message,
      string filename,
      int    line
      );
endfunction : ivl_uvm_compose_message

function string ivl_uvm_compose_message1(
      uvm_severity severity,
      string id,
      string message,
      string filename,
      int    line
      );
    uvm_severity_type sv;
    string time_str;
    string line_str;
    string name;

    
    $swrite(time_str, "%0t", $realtime);
 
    case(1)
      (name == "" && filename == ""):
	       return {sv, " @ ", time_str, " [", id, "] ", message};
      (name != "" && filename == ""):
	       return {sv, " @ ", time_str, ": ", name, " [", id, "] ", message};
      (name == "" && filename != ""):
           begin
               $swrite(line_str, "%0d", line);
		 return {sv, " ",filename, "(", line_str, ")", " @ ", time_str, " [", id, "] ", message};
           end
      (name != "" && filename != ""):
           begin
               $swrite(line_str, "%0d", line);
	         return {sv, " ", filename, "(", line_str, ")", " @ ", time_str, ": ", name, " [", id, "] ", message};
           end
    endcase
  endfunction : ivl_uvm_compose_message1

