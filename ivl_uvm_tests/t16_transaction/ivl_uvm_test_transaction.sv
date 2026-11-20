// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_transaction.sv
// Author(s): Srinivasan Venkataramanan
//            Ajeetha Kumari Venkatesan
//
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
// Direct test of uvm_transaction (UVM 1.1d BCL class): defaults, the id and
// initiator accessors, the accept / begin / end time stamps and their hooks,
// copy, clone and the print rows. Recording and the begin / end events are not
// ported, so is_active stays 0. Prints PASS or FAIL per check and a final
// summary line. The time rows print in ns because the test sets $timeformat;
// without it %t prints in the simulation precision.
module t_transaction;
  import ivl_uvm_pkg::*;

  class comp_t extends uvm_component;
    function new(string name,
                 uvm_component parent);
      super.new(name, parent);
    endfunction : new

    virtual function string get_type_name();
      return "comp_t";
    endfunction : get_type_name
  endclass : comp_t

  class txn_t extends uvm_transaction;
    int data;
    int n_accept;
    int n_begin;
    int n_end;

    `uvm_object_utils_begin(txn_t)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "txn_t",
                 uvm_component initiator = null);
      super.new(name, initiator);
    endfunction : new

    virtual function void do_accept_tr();
      n_accept++;
    endfunction : do_accept_tr

    virtual function void do_begin_tr();
      n_begin++;
    endfunction : do_begin_tr

    virtual function void do_end_tr();
      n_end++;
    endfunction : do_end_tr
  endclass : txn_t

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("TRANSACTION",
                $sformatf("PASS  %-36s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("TRANSACTION",
                 $sformatf("FAIL  %-36s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  function void chk_time(
    string what,
    time got,
    time exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("TRANSACTION",
                $sformatf("PASS  %-36s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("TRANSACTION",
                 $sformatf("FAIL  %-36s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_time

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("TRANSACTION",
                $sformatf("PASS  %-36s matches", what),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("TRANSACTION",
                 $sformatf("FAIL  %-36s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  // number of times sub occurs in text
  function int count_of(
    string text,
    string sub
  );
    int n;
    int i;
    n = 0;
    for (i = 0; i + sub.len() <= text.len(); i++) begin
      if (text.substr(i, i + sub.len() - 1) == sub) begin
        n++;
      end
    end
    return n;
  endfunction : count_of

  function void chk_count(
    string what,
    string text,
    string sub,
    int exp
  );
    int got;
    got = count_of(
      .text(text),
      .sub(sub)
    );
    n_chk++;
    if (got == exp) begin
      `uvm_info("TRANSACTION",
                $sformatf("PASS  %-36s count=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("TRANSACTION",
                 $sformatf("FAIL  %-36s count=%0d expected=%0d in:\n%s", what, got, exp, text))
    end
  endfunction : chk_count

  uvm_table_printer tp;
  uvm_printer_knobs kn;
  comp_t c1;
  uvm_component got_c;
  txn_t t1, t2, t3, t4, cl;
  uvm_object o;
  integer h;
  string txt;
  time all_ones;

  initial begin
    $timeformat(-9, 0, " ns", 0);
    tp = new;
    kn = tp.knobs;
    kn.reference = 0;
    all_ones = 64'hFFFFFFFFFFFFFFFF;
    c1 = new(
      .name("c1"),
      .parent(null)
    );

    // defaults
    t1 = new(.name("t1"));
    chk_int(
      .what("default transaction id"),
      .got(t1.get_transaction_id()),
      .exp(-1)
    );
    chk_int(
      .what("default initiator is null"),
      .got(t1.get_initiator() == null),
      .exp(1)
    );
    chk_time(
      .what("default accept time"),
      .got(t1.get_accept_time()),
      .exp(all_ones)
    );
    chk_time(
      .what("default begin time"),
      .got(t1.get_begin_time()),
      .exp(all_ones)
    );
    chk_time(
      .what("default end time"),
      .got(t1.get_end_time()),
      .exp(all_ones)
    );
    chk_int(
      .what("not active"),
      .got(t1.is_active()),
      .exp(0)
    );
    chk_str(
      .what("name"),
      .got(t1.get_name()),
      .exp("t1")
    );

    // the print before any time stamp
    txt = t1.sprint(.printer(tp));
    chk_count(
      .what("no time rows before a stamp"),
      .text(txt),
      .sub("_time"),
      .exp(0)
    );
    chk_count(
      .what("no initiator row without initiator"),
      .text(txt),
      .sub("initiator"),
      .exp(0)
    );

    // id and initiator
    t1.set_transaction_id(.id(5));
    chk_int(
      .what("set transaction id"),
      .got(t1.get_transaction_id()),
      .exp(5)
    );
    t1.set_initiator(.initiator(c1));
    got_c = t1.get_initiator();
    chk_int(
      .what("set initiator"),
      .got(got_c == c1),
      .exp(1)
    );
    t2 = new(
      .name("t2"),
      .initiator(c1)
    );
    got_c = t2.get_initiator();
    chk_int(
      .what("initiator from the constructor"),
      .got(got_c == c1),
      .exp(1)
    );

    // accept_tr
    t1.accept_tr(.accept_time(7));
    chk_time(
      .what("accept_tr with a time"),
      .got(t1.get_accept_time()),
      .exp(7)
    );
    chk_int(
      .what("do_accept_tr called"),
      .got(t1.n_accept),
      .exp(1)
    );
    #10;
    t1.accept_tr();
    chk_time(
      .what("accept_tr now"),
      .got(t1.get_accept_time()),
      .exp(10)
    );
    chk_int(
      .what("do_accept_tr called again"),
      .got(t1.n_accept),
      .exp(2)
    );

    // begin_tr
    h = t1.begin_tr(.begin_time(20));
    chk_time(
      .what("begin_tr with a time"),
      .got(t1.get_begin_time()),
      .exp(20)
    );
    chk_int(
      .what("begin_tr handle is 0"),
      .got(h),
      .exp(0)
    );
    chk_int(
      .what("do_begin_tr called"),
      .got(t1.n_begin),
      .exp(1)
    );
    #15;
    h = t1.begin_tr();
    chk_time(
      .what("begin_tr now"),
      .got(t1.get_begin_time()),
      .exp(25)
    );
    h = t1.begin_child_tr(
      .begin_time(30),
      .parent_handle(0)
    );
    chk_time(
      .what("begin_child_tr with a time"),
      .got(t1.get_begin_time()),
      .exp(30)
    );
    chk_int(
      .what("do_begin_tr called for each"),
      .got(t1.n_begin),
      .exp(3)
    );

    // end_tr
    t1.end_tr(.end_time(40));
    chk_time(
      .what("end_tr with a time"),
      .got(t1.get_end_time()),
      .exp(40)
    );
    chk_int(
      .what("do_end_tr called"),
      .got(t1.n_end),
      .exp(1)
    );
    #5;
    t1.end_tr();
    chk_time(
      .what("end_tr now"),
      .got(t1.get_end_time()),
      .exp(30)
    );
    chk_int(
      .what("still not active"),
      .got(t1.is_active()),
      .exp(0)
    );

    // the print with all stamps and the initiator
    t1.data = 9;
    txt = t1.sprint(.printer(tp));
    chk_count(
      .what("accept_time row"),
      .text(txt),
      .sub("accept_time"),
      .exp(1)
    );
    chk_count(
      .what("begin_time row"),
      .text(txt),
      .sub("begin_time"),
      .exp(1)
    );
    chk_count(
      .what("end_time row"),
      .text(txt),
      .sub("end_time"),
      .exp(1)
    );
    chk_count(
      .what("accept time printed in ns"),
      .text(txt),
      .sub("10 ns"),
      .exp(1)
    );
    chk_count(
      .what("begin and end time printed in ns"),
      .text(txt),
      .sub("30 ns"),
      .exp(2)
    );
    chk_count(
      .what("initiator row"),
      .text(txt),
      .sub("initiator"),
      .exp(1)
    );
    chk_count(
      .what("initiator type"),
      .text(txt),
      .sub("comp_t"),
      .exp(1)
    );
    chk_count(
      .what("field macro row"),
      .text(txt),
      .sub("data"),
      .exp(1)
    );
    t1.print(.printer(tp));

    // copy: the times and the initiator, not the id
    t3 = new(.name("t3"));
    t3.copy(.rhs(t1));
    chk_time(
      .what("copy accept time"),
      .got(t3.get_accept_time()),
      .exp(t1.get_accept_time())
    );
    chk_time(
      .what("copy begin time"),
      .got(t3.get_begin_time()),
      .exp(t1.get_begin_time())
    );
    chk_time(
      .what("copy end time"),
      .got(t3.get_end_time()),
      .exp(t1.get_end_time())
    );
    got_c = t3.get_initiator();
    chk_int(
      .what("copy initiator"),
      .got(got_c == c1),
      .exp(1)
    );
    chk_int(
      .what("copy field macro"),
      .got(t3.data),
      .exp(9)
    );
    chk_int(
      .what("copy does not copy the id"),
      .got(t3.get_transaction_id()),
      .exp(-1)
    );

    // clone
    o = t1.clone();
    chk_int(
      .what("clone casts to txn_t"),
      .got($cast(cl, o)),
      .exp(1)
    );
    chk_time(
      .what("clone begin time"),
      .got(cl.get_begin_time()),
      .exp(30)
    );
    chk_int(
      .what("clone field macro"),
      .got(cl.data),
      .exp(9)
    );

    // compare uses the field macros only
    t4 = new(.name("t4"));
    t4.data = 9;
    chk_int(
      .what("compare equal"),
      .got(t4.compare(.rhs(t1))),
      .exp(1)
    );

    `uvm_info("TRANSACTION",
              $sformatf("TRANSACTION: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_transaction
