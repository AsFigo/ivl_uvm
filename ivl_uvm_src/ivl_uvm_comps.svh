// ========== Copyright Header Begin ==========================
// 
// Project: IVL_UVM
// File: ivl_uvm_comps.svh
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


class uvm_report_object extends uvm_object;
  function new (string name = "uvm_report_object");
    super.new (name);
  endfunction : new 

endclass : uvm_report_object 

class uvm_phase extends uvm_object;
  function new (string name = "uvm_phase");
    super.new (name);
  endfunction : new 

  // BCL signatures. Objections are accepted and ignored for now: the run
  // phase ends when the component's run_phase returns.
  extern virtual function void raise_objection(uvm_object obj,
                                               string description = "",
                                               int count = 1);
  extern virtual function void drop_objection(uvm_object obj,
                                              string description = "",
                                              int count = 1);
endclass : uvm_phase 

function void uvm_phase::raise_objection(uvm_object obj,
                                         string description = "",
                                         int count = 1);
endfunction : raise_objection

function void uvm_phase::drop_objection(uvm_object obj,
                                        string description = "",
                                        int count = 1);
endfunction : drop_objection

`include "base/uvm_component.svh"

// Placeholders for the handle types of uvm_sequence_item. They carry no
// sequence or sequencer behaviour yet; the sequence item only needs their
// names, depth and sequencer.
class uvm_sequence_base extends uvm_sequence_item;
  function new (string name = "uvm_sequence");
    super.new (name);
  endfunction : new
endclass : uvm_sequence_base

class uvm_sequencer_base extends uvm_component;
  function new (string name,
                uvm_component parent);
    super.new (name, parent);
  endfunction : new
endclass : uvm_sequencer_base

virtual class uvm_test extends uvm_component;
  function new (string name = "uvm_test", uvm_component parent = null);
    super.new (name, parent);
    `g2u_display ("%m");
  endfunction : new 
endclass : uvm_test 



