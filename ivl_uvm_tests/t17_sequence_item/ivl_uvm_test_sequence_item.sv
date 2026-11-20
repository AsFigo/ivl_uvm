// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_sequence_item.sv
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
// Direct test of uvm_sequence_item (UVM 1.1d BCL class): the sequence id,
// set_id_info, the depth (cached after the first get_depth), the full name and
// sequence path through a parent sequence and a sequencer, set_item_context,
// the root sequence, the set_sequencer hook, the sequence rows of print, and
// copy, clone and compare through the transaction base. Parent sequence and
// sequencer are the placeholder classes of the package. Prints PASS or FAIL
// per check and a final summary line. The test sets $timeformat so times
// print in ns.
module t_sequence_item;
  import ivl_uvm_pkg::*;

  class item_t extends uvm_sequence_item;
    int data;
    int n_pseq;

    `uvm_object_utils_begin(item_t)
      `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "item_t");
      super.new(name);
    endfunction : new

    virtual function void m_set_p_sequencer();
      n_pseq++;
    endfunction : m_set_p_sequencer
  endclass : item_t

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("SEQUENCE_ITEM",
                $sformatf("PASS  %-40s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("SEQUENCE_ITEM",
                 $sformatf("FAIL  %-40s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("SEQUENCE_ITEM",
                $sformatf("PASS  %-40s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("SEQUENCE_ITEM",
                 $sformatf("FAIL  %-40s got='%s' expected='%s'", what, got, exp))
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
      `uvm_info("SEQUENCE_ITEM",
                $sformatf("PASS  %-40s count=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("SEQUENCE_ITEM",
                 $sformatf("FAIL  %-40s count=%0d expected=%0d in:\n%s", what, got, exp, text))
    end
  endfunction : chk_count

  uvm_table_printer tp;
  uvm_printer_knobs kn;
  uvm_sequence_item plain;
  item_t it, other, noname, it2, it4, it5, it6, cp, cl;
  uvm_object co;
  uvm_sequence_base seq, gseq;
  uvm_sequencer_base sqr;
  string txt;

  initial begin
    $timeformat(-9, 0, " ns", 0);
    tp = new;
    kn = tp.knobs;
    kn.reference = 0;

    // defaults
    plain = new(.name("plain"));
    chk_str(
      .what("base type name"),
      .got(plain.get_type_name()),
      .exp("uvm_sequence_item")
    );
    it = new(.name("it"));
    chk_int(
      .what("default sequence id"),
      .got(it.get_sequence_id()),
      .exp(-1)
    );
    chk_int(
      .what("default use sequence info"),
      .got(it.get_use_sequence_info()),
      .exp(0)
    );
    chk_int(
      .what("default sequencer is null"),
      .got(it.get_sequencer() == null),
      .exp(1)
    );
    chk_int(
      .what("default parent sequence is null"),
      .got(it.get_parent_sequence() == null),
      .exp(1)
    );
    chk_int(
      .what("is_item"),
      .got(it.is_item()),
      .exp(1)
    );
    chk_int(
      .what("depth without a parent"),
      .got(it.get_depth()),
      .exp(1)
    );
    it.set_depth(.value(5));
    chk_int(
      .what("set_depth"),
      .got(it.get_depth()),
      .exp(5)
    );

    // sequence id and set_id_info
    it.set_sequence_id(.id(9));
    chk_int(
      .what("set_sequence_id"),
      .got(it.get_sequence_id()),
      .exp(9)
    );
    other = new(.name("other"));
    other.set_transaction_id(.id(7));
    other.set_sequence_id(.id(3));
    it.set_id_info(.item(other));
    chk_int(
      .what("set_id_info transaction id"),
      .got(it.get_transaction_id()),
      .exp(7)
    );
    chk_int(
      .what("set_id_info sequence id"),
      .got(it.get_sequence_id()),
      .exp(3)
    );

    // names of a free item
    chk_str(
      .what("full name of a free item"),
      .got(it.get_full_name()),
      .exp("it")
    );
    noname = new(.name(""));
    chk_str(
      .what("full name of an unnamed item"),
      .got(noname.get_full_name()),
      .exp("_item")
    );
    chk_str(
      .what("sequence path of a free item"),
      .got(it.get_sequence_path()),
      .exp("it")
    );
    chk_str(
      .what("root sequence name of a free item"),
      .got(it.get_root_sequence_name()),
      .exp("")
    );

    // parent chain: it2 -> seq -> gseq, the sequencer on gseq
    sqr = new(.name("sqr"), .parent(null));
    seq = new(.name("seq"));
    gseq = new(.name("gseq"));
    it2 = new(.name("it2"));
    it2.set_parent_sequence(.parent(seq));
    seq.set_parent_sequence(.parent(gseq));
    chk_int(
      .what("parent sequence set"),
      .got(it2.get_parent_sequence() == seq),
      .exp(1)
    );
    chk_str(
      .what("full name through two parents"),
      .got(it2.get_full_name()),
      .exp("gseq.seq.it2")
    );
    chk_str(
      .what("sequence path"),
      .got(it2.get_sequence_path()),
      .exp("gseq.seq.it2")
    );
    chk_str(
      .what("root sequence name"),
      .got(it2.get_root_sequence_name()),
      .exp("gseq")
    );
    chk_int(
      .what("root sequence handle"),
      .got(it2.get_root_sequence() == gseq),
      .exp(1)
    );
    chk_str(
      .what("root sequence name of the root"),
      .got(gseq.get_root_sequence_name()),
      .exp("")
    );
    chk_int(
      .what("depth through two parents"),
      .got(it2.get_depth()),
      .exp(3)
    );
    chk_int(
      .what("depth of the middle sequence"),
      .got(seq.get_depth()),
      .exp(2)
    );
    gseq.set_sequencer(.sequencer(sqr));
    chk_str(
      .what("full name with a sequencer"),
      .got(it2.get_full_name()),
      .exp("sqr.gseq.seq.it2")
    );

    // set_sequencer hook
    it.set_sequencer(.sequencer(sqr));
    chk_int(
      .what("set_sequencer calls the hook"),
      .got(it.n_pseq),
      .exp(1)
    );
    chk_int(
      .what("set_sequencer stores the sequencer"),
      .got(it.get_sequencer() == sqr),
      .exp(1)
    );
    chk_str(
      .what("full name from the sequencer"),
      .got(it.get_full_name()),
      .exp("sqr.it")
    );

    // set_item_context
    seq.set_sequencer(.sequencer(sqr));
    it4 = new(.name("it4"));
    it4.set_item_context(.parent_seq(seq));
    chk_int(
      .what("context use sequence info"),
      .got(it4.get_use_sequence_info()),
      .exp(1)
    );
    chk_int(
      .what("context parent"),
      .got(it4.get_parent_sequence() == seq),
      .exp(1)
    );
    chk_int(
      .what("context sequencer from the parent"),
      .got(it4.get_sequencer() == sqr),
      .exp(1)
    );
    chk_int(
      .what("context depth"),
      .got(it4.get_depth()),
      .exp(3)
    );
    chk_int(
      .what("context calls the hook"),
      .got(it4.n_pseq),
      .exp(1)
    );
    it5 = new(.name("it5"));
    it5.set_item_context(
      .parent_seq(null),
      .sequencer(sqr)
    );
    chk_int(
      .what("context with a sequencer only"),
      .got(it5.get_sequencer() == sqr),
      .exp(1)
    );
    chk_int(
      .what("context with no parent depth"),
      .got(it5.get_depth()),
      .exp(1)
    );

    // print: sequence rows only with the info switched on
    it6 = new(.name("it6"));
    it6.data = 5;
    txt = it6.sprint(.printer(tp));
    chk_count(
      .what("no depth row by default"),
      .text(txt),
      .sub("depth"),
      .exp(0)
    );
    chk_count(
      .what("no sequencer row by default"),
      .text(txt),
      .sub("sequencer"),
      .exp(0)
    );
    it6.print_sequence_info = 1;
    txt = it6.sprint(.printer(tp));
    chk_count(
      .what("depth row with print_sequence_info"),
      .text(txt),
      .sub("depth"),
      .exp(1)
    );
    it4.data = 11;
    txt = it4.sprint(.printer(tp));
    chk_count(
      .what("depth row after set_item_context"),
      .text(txt),
      .sub("depth"),
      .exp(1)
    );
    chk_count(
      .what("parent sequence name row"),
      .text(txt),
      .sub("parent sequence (name)"),
      .exp(1)
    );
    chk_count(
      .what("parent sequence full name row"),
      .text(txt),
      .sub("parent sequence (full name)"),
      .exp(1)
    );
    chk_count(
      .what("parent sequence full name value"),
      .text(txt),
      .sub("sqr.gseq.seq"),
      .exp(1)
    );
    chk_count(
      .what("sequencer row"),
      .text(txt),
      .sub("sequencer"),
      .exp(1)
    );
    chk_count(
      .what("data row"),
      .text(txt),
      .sub("data"),
      .exp(1)
    );

    // copy, clone and compare go through the transaction base only
    it4.set_sequence_id(.id(12));
    it4.accept_tr(.accept_time(7));
    cp = new(.name("cp"));
    cp.copy(.rhs(it4));
    chk_int(
      .what("copy data"),
      .got(cp.data),
      .exp(11)
    );
    chk_int(
      .what("copy accept time"),
      .got(cp.get_accept_time()),
      .exp(7)
    );
    chk_int(
      .what("copy leaves the sequence id"),
      .got(cp.get_sequence_id()),
      .exp(-1)
    );
    chk_int(
      .what("copy leaves the parent sequence"),
      .got(cp.get_parent_sequence() == null),
      .exp(1)
    );
    co = it4.clone();
    chk_int(
      .what("clone is an item_t"),
      .got($cast(cl, co)),
      .exp(1)
    );
    chk_int(
      .what("clone data"),
      .got(cl.data),
      .exp(11)
    );
    chk_int(
      .what("clone leaves the sequence id"),
      .got(cl.get_sequence_id()),
      .exp(-1)
    );
    chk_int(
      .what("compare equal"),
      .got(cp.compare(.rhs(it4))),
      .exp(1)
    );
    cp.data = 0;
    chk_int(
      .what("compare different"),
      .got(cp.compare(.rhs(it4))),
      .exp(0)
    );

    `uvm_info("SEQUENCE_ITEM",
              $sformatf("SEQUENCE_ITEM: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_sequence_item
