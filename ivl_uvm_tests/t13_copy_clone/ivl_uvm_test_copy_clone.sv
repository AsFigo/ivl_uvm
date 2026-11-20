// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_copy_clone.sv
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
// Direct test of uvm_object::copy, do_copy, create and clone (UVM 1.1d BCL).
// The classes write create and do_copy by hand, so the test does not depend
// on the factory or field macros. Prints PASS or FAIL per check and a final
// summary line.
module t_copy_clone;
  import ivl_uvm_pkg::*;

  class item_t extends uvm_object;
    int v;
    string s;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "item_t";
    endfunction : get_type_name

    virtual function uvm_object create(
      string name = ""
    );
      item_t t;
      t = new(.name(name));
      return t;
    endfunction : create

    virtual function void do_copy(
      uvm_object rhs
    );
      item_t r;
      super.do_copy(.rhs(rhs));
      if (!$cast(r, rhs) || r == null) begin
        return;
      end
      v = r.v;
      s = r.s;
    endfunction : do_copy
  endclass : item_t

  class sub_t extends item_t;
    int w;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function string get_type_name();
      return "sub_t";
    endfunction : get_type_name

    virtual function uvm_object create(
      string name = ""
    );
      sub_t t;
      t = new(.name(name));
      return t;
    endfunction : create

    virtual function void do_copy(
      uvm_object rhs
    );
      sub_t r;
      super.do_copy(.rhs(rhs));
      if (!$cast(r, rhs) || r == null) begin
        return;
      end
      w = r.w;
    endfunction : do_copy
  endclass : sub_t

  // no create override: clone cannot build a new object
  class plain_t extends uvm_object;
    function new(string name = "");
      super.new(.name(name));
    endfunction : new
  endclass : plain_t

  // deep copy through copy(), so the copy map is used
  class node_t extends uvm_object;
    int v;
    node_t next;

    function new(string name = "");
      super.new(.name(name));
    endfunction : new

    virtual function uvm_object create(
      string name = ""
    );
      node_t t;
      t = new(.name(name));
      return t;
    endfunction : create

    virtual function void do_copy(
      uvm_object rhs
    );
      node_t r;
      super.do_copy(.rhs(rhs));
      if (!$cast(r, rhs) || r == null) begin
        return;
      end
      v = r.v;
      if (next != null && r.next != null) begin
        next.copy(.rhs(r.next));
      end
    endfunction : do_copy
  endclass : node_t

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("COPY_CLONE",
                $sformatf("PASS  %-34s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COPY_CLONE",
                 $sformatf("FAIL  %-34s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("COPY_CLONE",
                $sformatf("PASS  %-34s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("COPY_CLONE",
                 $sformatf("FAIL  %-34s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  item_t a, b, ci;
  sub_t sa, csub;
  plain_t pl;
  node_t s1, s2, d1, d2;
  uvm_object o;
  uvm_object c;

  initial begin
    a = new(.name("a"));
    b = new(.name("b"));
    sa = new(.name("sa"));
    pl = new(.name("pl"));
    s1 = new(.name("s1"));
    s2 = new(.name("s2"));
    d1 = new(.name("d1"));
    d2 = new(.name("d2"));

    // create
    c = a.create(.name("made"));
    chk_int(
      .what("create returns an object"),
      .got(c != null),
      .exp(1)
    );
    chk_str(
      .what("create sets the name"),
      .got(c.get_name()),
      .exp("made")
    );
    chk_str(
      .what("create returns the same type"),
      .got(c.get_type_name()),
      .exp("item_t")
    );

    // copy
    a.v = 42;
    a.s = "hi";
    b.copy(.rhs(a));
    chk_int(
      .what("copy int"),
      .got(b.v),
      .exp(42)
    );
    chk_str(
      .what("copy string"),
      .got(b.s),
      .exp("hi")
    );
    chk_str(
      .what("copy keeps the name"),
      .got(b.get_name()),
      .exp("b")
    );
    a.v = 7;
    chk_int(
      .what("copy is independent"),
      .got(b.v),
      .exp(42)
    );
    b.copy(.rhs(null));
    chk_int(
      .what("copy of null is ignored"),
      .got(b.v),
      .exp(42)
    );

    // clone
    a.v = 42;
    c = a.clone();
    chk_int(
      .what("clone returns an object"),
      .got(c != null),
      .exp(1)
    );
    chk_int(
      .what("clone is a new object"),
      .got(c != a),
      .exp(1)
    );
    chk_str(
      .what("clone has the name"),
      .got(c.get_name()),
      .exp("a")
    );
    chk_str(
      .what("clone has the type"),
      .got(c.get_type_name()),
      .exp("item_t")
    );
    chk_int(
      .what("clone casts to item_t"),
      .got($cast(ci, c)),
      .exp(1)
    );
    chk_int(
      .what("clone int"),
      .got(ci.v),
      .exp(42)
    );
    chk_str(
      .what("clone string"),
      .got(ci.s),
      .exp("hi")
    );
    ci.v = 1;
    chk_int(
      .what("clone is independent"),
      .got(a.v),
      .exp(42)
    );

    // clone of a derived class through a base handle
    sa.v = 5;
    sa.s = "sub";
    sa.w = 9;
    o = sa;
    c = o.clone();
    chk_int(
      .what("clone derived casts to sub_t"),
      .got($cast(csub, c)),
      .exp(1)
    );
    chk_str(
      .what("clone derived type"),
      .got(c.get_type_name()),
      .exp("sub_t")
    );
    chk_int(
      .what("clone derived base field"),
      .got(csub.v),
      .exp(5)
    );
    chk_int(
      .what("clone derived own field"),
      .got(csub.w),
      .exp(9)
    );

    // no create: clone returns null
    c = pl.clone();
    chk_int(
      .what("clone without create is null"),
      .got(c == null),
      .exp(1)
    );

    // deep copy of objects that point to each other
    s1.v = 1;
    s2.v = 2;
    s1.next = s2;
    s2.next = s1;
    d1.next = d2;
    d2.next = d1;
    d1.copy(.rhs(s1));
    chk_int(
      .what("cyclic copy first node"),
      .got(d1.v),
      .exp(1)
    );
    chk_int(
      .what("cyclic copy second node"),
      .got(d2.v),
      .exp(2)
    );
    s1.v = 5;
    d1.copy(.rhs(s1));
    chk_int(
      .what("copy again after the map is cleared"),
      .got(d1.v),
      .exp(5)
    );

    `uvm_info("COPY_CLONE",
              $sformatf("COPY_CLONE: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_copy_clone
