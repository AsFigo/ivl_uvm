// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_macros.svh
// Author(s): Srinivasan Venkataramanan
//            Ajeetha Kumari Venkatesan
//
// Copyright (c) VerifWorks 2016-2020  All Rights Reserved.
// Contact us via: support@verifworks.com
// Copyright (c) 2026 AsFigo (https://www.asfigo.com)
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of
// the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied.  See
// the License for the specific language governing
// permissions and limitations under the License.
// ========== Copyright Header End ============================
////////////////////////////////////////////////////////////////////////
`ifndef IVL_UVM_MACROS
  `define IVL_UVM_MACROS

 `define g2u_display(MSG, VERBOSITY=UVM_MEDIUM) \
   begin \
     if (uvm_report_enabled(VERBOSITY,UVM_INFO,get_name())) begin \
       uvm_report_info (get_name(), MSG, VERBOSITY, `uvm_file, `uvm_line); \
       uvm_count_info(); \
     end \
   end

  `define g2u_rand(obj, CNST = {} ) \
    begin \
      int rval; \
      rval = obj.randomize() with CNST ; \
      if (!rval) \
        $error ("Randomization failed"); \
    end 
  
  
  `define g2u_printf(FORMAT_MSG,VERBOSITY=UVM_MEDIUM) \
     begin \
       if (uvm_report_enabled(VERBOSITY,UVM_INFO,get_name())) \
         uvm_report_info (get_name(), $sformatf FORMAT_MSG, VERBOSITY, `uvm_file, `uvm_line); \
     end
  
  
  `define GO2UVM_DISP_ARG(arg) `"arg`"
  
  `define IVL_UVM_VPA $value$plusargs
   
  `ifndef UVM_TESTNAME
    `define UVM_TESTNAME uvm_test
  `endif // UVM_TESTNAME
  

  `ifndef IVL_UVM_MBX_T
    `define IVL_UVM_MBX_T int
  `else
    typedef class `IVL_UVM_MBX_T;
  `endif // IVL_UVM_MBX_T

`endif //  IVL_UVM_MACROS

`include "uvm_macros.svh"

