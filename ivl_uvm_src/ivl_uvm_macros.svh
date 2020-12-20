// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_macros.svh
// Author(s): Srinivasan Venkataramanan 
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
`ifndef IVL_UVM_MACROS
  `define IVL_UVM_MACROS

  /*
`ifdef UVM_REPORT_DISABLE_FILE_LINE
  `define UVM_REPORT_DISABLE_FILE
  `define UVM_REPORT_DISABLE_LINE
`endif

`ifdef UVM_REPORT_DISABLE_FILE
  `define uvm_file ""
`else
  `define uvm_file `__FILE__
`endif

`ifdef UVM_REPORT_DISABLE_LINE
  `define uvm_line 0
`else
  `define uvm_line `__LINE__
`endif


 `define uvm_info(ID, MSG, VERBOSITY) \
   begin \
     string msg; \
     static string sev_s = "UVM_INFO"; \
     if (uvm_report_enabled(VERBOSITY,UVM_INFO,ID)) begin \
       $swrite(msg, "%s %s(%0d) @%0t [%s] %s ", sev_s, `uvm_file, `uvm_line, $realtime, ID, MSG); \
       uvm_count_info(); \
       $display(msg); \
     end \
   end

 `define uvm_warning(ID, MSG) \
   begin \
     string msg; \
     static string sev_s = "UVM_WARNING"; \
     $swrite(msg, "%s %s(%0d) @%0t [%s] %s ", sev_s, `uvm_file, `uvm_line, $realtime, ID, MSG); \
     uvm_count_warn(); \
     $display(msg); \
   end

 `define uvm_error(ID, MSG) \
   begin \
     string msg; \
     static string sev_s = "UVM_ERROR"; \
     $swrite(msg, "%s %s(%0d) @%0t [%s] %s ", sev_s, `uvm_file, `uvm_line, $realtime, ID, MSG); \
     uvm_count_err(); \
     $display(msg); \
   end

 `define uvm_fatal(ID, MSG) \
   begin \
     string msg; \
     static string sev_s = "UVM_FATAL"; \
     $swrite(msg, "%s %s(%0d) @%0t [%s] %s ", sev_s, `uvm_file, `uvm_line, $realtime, ID, MSG); \
     uvm_count_fatal(); \
     $display(msg); \
     report_summarize (); \
     $finish(1); \
   end

  */
 `define g2u_display(MSG, VERBOSITY=UVM_MEDIUM) \
   begin \
     string msg; \
     static string sev_s = "UVM_INFO"; \
     if (uvm_report_enabled(VERBOSITY,UVM_INFO,log_id)) begin \
       $swrite(msg, "%s %s(%0d) @%0t [%s] %s ", sev_s, `uvm_file, `uvm_line, $realtime, log_id, MSG); \
       uvm_count_info(); \
       $display(msg); \
     end \
   end



`endif //  IVL_UVM_MACROS

`include "uvm_macros.svh"

