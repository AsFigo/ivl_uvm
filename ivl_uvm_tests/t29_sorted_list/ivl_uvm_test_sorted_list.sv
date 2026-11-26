// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_sorted_list.sv
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
// Test of ivl_uvm_linked_list::set_sorted: keys are kept in ascending string
// order (the order the BCL gets from iterating an associative array indexed
// by string), set_sorted on an existing key replaces the value, and set
// (newest first) is unchanged. Prints PASS or FAIL per check and a final
// summary line.
module t_sorted_list;
  import ivl_uvm_pkg::*;

  int n_fail;
  int n_chk;

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("SORTED_LIST",
                $sformatf("PASS  %-22s got=%s", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("SORTED_LIST",
                 $sformatf("FAIL  %-22s got=%s expected=%s", what, got, exp))
    end
  endfunction : chk_str

  // Keys from the first node on, joined with commas.
  function string keys_of(ivl_uvm_linked_list #(string, int) l);
    ivl_uvm_ll_node #(string, int) n;
    string s;
    s = "";
    n = l.first_node();
    while (n != null) begin
      if (s != "") begin
        s = {s, ","};
      end
      s = {s, n.key};
      n = n.next;
    end
    return s;
  endfunction : keys_of

  function string val_of(
    ivl_uvm_linked_list #(string, int) l,
    string key
  );
    ivl_uvm_ll_node #(string, int) n;
    n = l.find_node(key);
    if (n == null) begin
      return "none";
    end
    return $sformatf("%0d", n.val);
  endfunction : val_of

  ivl_uvm_string_list #(int) l;
  ivl_uvm_linked_list #(string, int) u;

  initial begin
    l = new;
    chk_str(
      .what("empty"),
      .got(keys_of(.l(l))),
      .exp("")
    );

    l.set_sorted(.key("m"), .val(1));
    chk_str(
      .what("one key"),
      .got(keys_of(.l(l))),
      .exp("m")
    );
    l.set_sorted(.key("c"), .val(2));
    chk_str(
      .what("before head"),
      .got(keys_of(.l(l))),
      .exp("c,m")
    );
    l.set_sorted(.key("x"), .val(3));
    chk_str(
      .what("after tail"),
      .got(keys_of(.l(l))),
      .exp("c,m,x")
    );
    l.set_sorted(.key("q"), .val(4));
    chk_str(
      .what("in the middle"),
      .got(keys_of(.l(l))),
      .exp("c,m,q,x")
    );
    l.set_sorted(.key("a"), .val(5));
    chk_str(
      .what("new smallest"),
      .got(keys_of(.l(l))),
      .exp("a,c,m,q,x")
    );
    chk_str(
      .what("size"),
      .got($sformatf("%0d", l.size())),
      .exp("5")
    );

    l.set_sorted(.key("q"), .val(40));
    chk_str(
      .what("replace keeps order"),
      .got(keys_of(.l(l))),
      .exp("a,c,m,q,x")
    );
    chk_str(
      .what("replace size"),
      .got($sformatf("%0d", l.size())),
      .exp("5")
    );
    chk_str(
      .what("replaced value"),
      .got(val_of(.l(l), .key("q"))),
      .exp("40")
    );
    chk_str(
      .what("other value"),
      .got(val_of(.l(l), .key("m"))),
      .exp("1")
    );

    // Names as components get them: prefix and digits, upper before lower.
    l.set_sorted(.key("agent"), .val(6));
    l.set_sorted(.key("agent_b"), .val(7));
    l.set_sorted(.key("Z"), .val(8));
    chk_str(
      .what("longer names"),
      .got(keys_of(.l(l))),
      .exp("Z,a,agent,agent_b,c,m,q,x")
    );

    l.remove_key(.key("agent"));
    chk_str(
      .what("remove keeps order"),
      .got(keys_of(.l(l))),
      .exp("Z,a,agent_b,c,m,q,x")
    );

    u = new;
    u.set(.key("b"), .val(1));
    u.set(.key("a"), .val(2));
    chk_str(
      .what("set is newest first"),
      .got(keys_of(.l(u))),
      .exp("a,b")
    );
    u.set(.key("c"), .val(3));
    chk_str(
      .what("set newest first 2"),
      .got(keys_of(.l(u))),
      .exp("c,a,b")
    );

    `uvm_info("SORTED_LIST",
              $sformatf("SORTED_LIST: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_sorted_list
