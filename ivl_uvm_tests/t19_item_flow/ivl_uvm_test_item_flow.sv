// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_item_flow.sv
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
// Direct test of a user transaction through the item flow: one item class on
// uvm_sequence_item with the field macros (int, bit vector, enum, string,
// real) and no hand-written create, copy or compare. The item is made with
// type_id::create, filled by hand (no randomize), printed, copied, cloned,
// compared, packed and unpacked, and passed through a small producer /
// consumer pair. A plain module test, not a uvm_test with phases. Prints PASS
// or FAIL per check and a final summary line.
module t_item_flow;
  import ivl_uvm_pkg::*;

  typedef enum {READ, WRITE} kind_e;

  class bus_item extends uvm_sequence_item;
    bit [15:0] addr;
    int data;
    kind_e kind;
    string tag;
    real scale;

    `uvm_object_utils_begin(bus_item)
      `uvm_field_int(addr, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON | UVM_DEC)
      `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
      `uvm_field_string(tag, UVM_ALL_ON)
      `uvm_field_real(scale, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "bus_item");
      super.new(name);
    endfunction : new
  endclass : bus_item

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("ITEM_FLOW",
                $sformatf("PASS  %-40s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("ITEM_FLOW",
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
      `uvm_info("ITEM_FLOW",
                $sformatf("PASS  %-40s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("ITEM_FLOW",
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
      `uvm_info("ITEM_FLOW",
                $sformatf("PASS  %-40s count=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("ITEM_FLOW",
                 $sformatf("FAIL  %-40s count=%0d expected=%0d in:\n%s", what, got, exp, text))
    end
  endfunction : chk_count

  // producer: builds the item number i with type_id::create (no randomize)
  function bus_item make_item(
    int i
  );
    bus_item t;
    t = bus_item::type_id::create(.name($sformatf("tr%0d", i)));
    t.addr = 16'h1000 + i;
    t.data = 100 * i;
    if (i % 2) begin
      t.kind = WRITE;
    end
    else begin
      t.kind = READ;
    end
    t.tag = $sformatf("beat%0d", i);
    t.scale = 0.5 * i;
    return t;
  endfunction : make_item

  // consumer: takes a copy of the item, as a driver or monitor does
  function bus_item receive(
    bus_item t
  );
    bus_item r;
    r = bus_item::type_id::create(.name("rx"));
    r.copy(.rhs(t));
    return r;
  endfunction : receive

  uvm_table_printer tp;
  uvm_printer_knobs kn;
  uvm_packer pk;
  uvm_packer pku;
  bus_item t0, t1, t2, rx, cp, un, cl;
  uvm_object o;
  bit bits[];
  int nbits;
  string txt;
  int i;

  initial begin
    $timeformat(-9, 0, " ns", 0);
    tp = new;
    kn = tp.knobs;
    kn.reference = 0;
    pk = new;
    pku = new;
    pk.use_metadata = 1;
    pku.use_metadata = 1;

    // create and fill
    t1 = make_item(.i(1));
    chk_str(
      .what("created name"),
      .got(t1.get_name()),
      .exp("tr1")
    );
    chk_str(
      .what("created type name"),
      .got(t1.get_type_name()),
      .exp("bus_item")
    );
    chk_int(
      .what("an item has the sequence defaults"),
      .got(t1.get_sequence_id()),
      .exp(-1)
    );
    chk_int(
      .what("field addr"),
      .got(t1.addr),
      .exp(16'h1001)
    );
    chk_str(
      .what("field tag"),
      .got(t1.tag),
      .exp("beat1")
    );

    // print
    txt = t1.sprint(.printer(tp));
    chk_count(
      .what("name of the item in the table"),
      .text(txt),
      .sub("tr1"),
      .exp(1)
    );
    chk_count(
      .what("row addr"),
      .text(txt),
      .sub("addr"),
      .exp(1)
    );
    chk_count(
      .what("addr in hex"),
      .text(txt),
      .sub("'h1001"),
      .exp(1)
    );
    chk_count(
      .what("row data"),
      .text(txt),
      .sub("data"),
      .exp(1)
    );
    chk_count(
      .what("row kind with its enum type"),
      .text(txt),
      .sub("kind   kind_e"),
      .exp(1)
    );
    chk_count(
      .what("enum value printed by name"),
      .text(txt),
      .sub("WRITE"),
      .exp(1)
    );
    chk_count(
      .what("row tag"),
      .text(txt),
      .sub("beat1"),
      .exp(1)
    );
    chk_count(
      .what("row scale"),
      .text(txt),
      .sub("scale"),
      .exp(1)
    );
    t1.print(.printer(tp));

    // producer and consumer
    t2 = make_item(.i(2));
    rx = receive(.t(t2));
    chk_str(
      .what("received copy keeps its own name"),
      .got(rx.get_name()),
      .exp("rx")
    );
    chk_int(
      .what("received addr"),
      .got(rx.addr),
      .exp(16'h1002)
    );
    chk_int(
      .what("received data"),
      .got(rx.data),
      .exp(200)
    );
    chk_int(
      .what("received kind"),
      .got(rx.kind == READ),
      .exp(1)
    );
    chk_str(
      .what("received tag"),
      .got(rx.tag),
      .exp("beat2")
    );
    chk_int(
      .what("received item equals the sent one"),
      .got(t2.compare(.rhs(rx))),
      .exp(1)
    );

    // compare finds each kind of difference
    rx.data = 201;
    chk_int(
      .what("compare differs in an int"),
      .got(t2.compare(.rhs(rx))),
      .exp(0)
    );
    rx.data = 200;
    rx.kind = WRITE;
    chk_int(
      .what("compare differs in an enum"),
      .got(t2.compare(.rhs(rx))),
      .exp(0)
    );
    rx.kind = READ;
    rx.tag = "beat9";
    chk_int(
      .what("compare differs in a string"),
      .got(t2.compare(.rhs(rx))),
      .exp(0)
    );
    rx.tag = "beat2";
    rx.scale = 7.5;
    chk_int(
      .what("compare differs in a real"),
      .got(t2.compare(.rhs(rx))),
      .exp(0)
    );
    rx.scale = 1.0;
    chk_int(
      .what("equal again after restoring"),
      .got(t2.compare(.rhs(rx))),
      .exp(1)
    );

    // clone
    o = t1.clone();
    chk_int(
      .what("clone is a bus_item"),
      .got($cast(cl, o)),
      .exp(1)
    );
    chk_str(
      .what("clone keeps the name"),
      .got(cl.get_name()),
      .exp("tr1")
    );
    chk_int(
      .what("clone is a new object"),
      .got(cl != t1),
      .exp(1)
    );
    chk_int(
      .what("clone equals the original"),
      .got(t1.compare(.rhs(cl))),
      .exp(1)
    );
    cl.data = 5;
    chk_int(
      .what("clone is independent"),
      .got(t1.data),
      .exp(100)
    );

    // pack and unpack: addr 16 + data 32 + kind 32 + tag "beat1" and its
    // null byte 48 + scale 64
    nbits = t1.pack(bits, pk);
    chk_int(
      .what("pack size in bits"),
      .got(nbits),
      .exp(192)
    );
    un = bus_item::type_id::create(.name("un"));
    void'(un.unpack(bits, pku));
    chk_int(
      .what("unpack addr"),
      .got(un.addr),
      .exp(16'h1001)
    );
    chk_int(
      .what("unpack data"),
      .got(un.data),
      .exp(100)
    );
    chk_int(
      .what("unpack kind"),
      .got(un.kind == WRITE),
      .exp(1)
    );
    chk_str(
      .what("unpack tag"),
      .got(un.tag),
      .exp("beat1")
    );
    chk_int(
      .what("unpack scale"),
      .got(un.scale == 0.5),
      .exp(1)
    );
    chk_int(
      .what("unpacked item equals the original"),
      .got(t1.compare(.rhs(un))),
      .exp(1)
    );

    // the default packer, as a bench calls pack with no packer
    nbits = t1.pack(bits);
    chk_int(
      .what("pack with the default packer"),
      .got(nbits > 0),
      .exp(1)
    );

    // a few items in a row
    for (i = 0; i < 3; i++) begin
      t0 = make_item(.i(i));
      rx = receive(.t(t0));
      chk_int(
        .what($sformatf("item %0d goes through intact", i)),
        .got(t0.compare(.rhs(rx))),
        .exp(1)
      );
    end

    `uvm_info("ITEM_FLOW",
              $sformatf("ITEM_FLOW: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_item_flow
