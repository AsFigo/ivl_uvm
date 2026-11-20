// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_status_container.sv
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
// Direct test of uvm_status_container (UVM 1.1d BCL class). Its associative
// array and queue-of-handles members are linked lists on Icarus. Prints PASS
// or FAIL per check and a final summary line.
module t_status_container;
  import ivl_uvm_pkg::*;

  class obj_t extends uvm_object;
    function new(string name = "");
      super.new(.name(name));
    endfunction : new
  endclass : obj_t

  int n_fail;
  int n_chk;

  function void chk_int(
    string what,
    int got,
    int exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("STATUS_CONTAINER",
                $sformatf("PASS  %-28s got=%0d", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("STATUS_CONTAINER",
                 $sformatf("FAIL  %-28s got=%0d expected=%0d", what, got, exp))
    end
  endfunction : chk_int

  function void chk_str(
    string what,
    string got,
    string exp
  );
    n_chk++;
    if (got == exp) begin
      `uvm_info("STATUS_CONTAINER",
                $sformatf("PASS  %-28s got='%s'", what, got),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("STATUS_CONTAINER",
                 $sformatf("FAIL  %-28s got='%s' expected='%s'", what, got, exp))
    end
  endfunction : chk_str

  uvm_status_container sc;
  uvm_status_container sc2;
  uvm_scope_stack s;
  ivl_uvm_linked_list #(uvm_object, bit) ck;
  ivl_uvm_linked_list #(uvm_object, bit) cs;
  ivl_uvm_linked_list #(string, bit) fa;
  ivl_uvm_ll_node #(uvm_object, bit) n;
  ivl_uvm_ll_node #(string, bit) fn;
  obj_t o1, o2, o3;

  initial begin
    sc  = new;
    sc2 = new;
    o1  = new(.name("o1"));
    o2  = new(.name("o2"));
    o3  = new(.name("o3"));

    // defaults and plain fields
    chk_int(
      .what("default clone"),
      .got(sc.clone),
      .exp(1)
    );
    chk_int(
      .what("default warning"),
      .got(sc.warning),
      .exp(0)
    );
    chk_int(
      .what("default status"),
      .got(sc.status),
      .exp(0)
    );
    chk_int(
      .what("default intv"),
      .got(sc.intv),
      .exp(0)
    );
    chk_str(
      .what("default stringv"),
      .got(sc.stringv),
      .exp("")
    );
    sc.intv = 5;
    sc.stringv = "abc";
    sc.element = 3;
    chk_int(
      .what("write/read intv"),
      .got(sc.intv),
      .exp(5)
    );
    chk_str(
      .what("write/read stringv"),
      .got(sc.stringv),
      .exp("abc")
    );
    chk_int(
      .what("instance 2 intv unchanged"),
      .got(sc2.intv),
      .exp(0)
    );

    // get_function_type
    chk_str(
      .what("function type copy"),
      .got(sc.get_function_type(.what(UVM_COPY))),
      .exp("copy")
    );
    chk_str(
      .what("function type compare"),
      .got(sc.get_function_type(.what(UVM_COMPARE))),
      .exp("compare")
    );
    chk_str(
      .what("function type print"),
      .got(sc.get_function_type(.what(UVM_PRINT))),
      .exp("print")
    );
    chk_str(
      .what("function type record"),
      .got(sc.get_function_type(.what(UVM_RECORD))),
      .exp("record")
    );
    chk_str(
      .what("function type pack"),
      .got(sc.get_function_type(.what(UVM_PACK))),
      .exp("pack")
    );
    chk_str(
      .what("function type unpack"),
      .got(sc.get_function_type(.what(UVM_UNPACK))),
      .exp("unpack")
    );
    chk_str(
      .what("function type unknown"),
      .got(sc.get_function_type(.what(12345))),
      .exp("unknown")
    );

    // scope stack member (handle copied to a local before use)
    chk_str(
      .what("empty scope"),
      .got(sc.get_full_scope_arg()),
      .exp("")
    );
    s = sc.scope;
    s.set(.s("top"));
    s.down(.s("env"));
    chk_str(
      .what("scope top.env"),
      .got(sc.get_full_scope_arg()),
      .exp("top.env")
    );
    s = sc2.scope;
    chk_str(
      .what("instance 2 scope empty"),
      .got(sc2.get_full_scope_arg()),
      .exp("")
    );

    // field_array (static)
    sc.do_field_check(
      .field("f1"),
      .obj(o1)
    );
    sc2.do_field_check(
      .field("f2"),
      .obj(o2)
    );
    fa = uvm_status_container::field_array;
    fn = fa.find_node(.key("f1"));
    chk_int(
      .what("field f1 recorded"),
      .got(fn != null),
      .exp(1)
    );
    fn = fa.find_node(.key("f2"));
    chk_int(
      .what("field f2 recorded (shared)"),
      .got(fn != null),
      .exp(1)
    );
    fn = fa.find_node(.key("f3"));
    chk_int(
      .what("field f3 missing"),
      .got(fn != null),
      .exp(0)
    );

    // cycle_check (handle-keyed set)
    ck = sc.cycle_check;
    ck.set(
      .key(o1),
      .val(1)
    );
    n = ck.find_node(.key(o1));
    chk_int(
      .what("cycle_check has o1"),
      .got(n != null),
      .exp(1)
    );
    n = ck.find_node(.key(o2));
    chk_int(
      .what("cycle_check no o2"),
      .got(n != null),
      .exp(0)
    );
    ck.clear();
    n = ck.find_node(.key(o1));
    chk_int(
      .what("cycle_check cleared"),
      .got(n != null),
      .exp(0)
    );

    // m_do_cycle_check: same scope right after itself is not a cycle, going
    // back to an earlier scope is
    chk_int(
      .what("cycle o1 first"),
      .got(sc.m_do_cycle_check(.scope(o1))),
      .exp(0)
    );
    chk_int(
      .what("cycle o1 again (same)"),
      .got(sc.m_do_cycle_check(.scope(o1))),
      .exp(0)
    );
    chk_int(
      .what("cycle o2 new"),
      .got(sc.m_do_cycle_check(.scope(o2))),
      .exp(0)
    );
    chk_int(
      .what("cycle o1 revisited"),
      .got(sc.m_do_cycle_check(.scope(o1))),
      .exp(1)
    );
    chk_int(
      .what("cycle o3 new"),
      .got(sc.m_do_cycle_check(.scope(o3))),
      .exp(0)
    );
    chk_int(
      .what("cycle o2 revisited"),
      .got(sc.m_do_cycle_check(.scope(o2))),
      .exp(1)
    );
    cs = sc.m_uvm_cycle_scopes;
    cs.clear();
    chk_int(
      .what("cycle o1 after reset"),
      .got(sc.m_do_cycle_check(.scope(o1))),
      .exp(0)
    );
    chk_int(
      .what("instance 2 cycle o1"),
      .got(sc2.m_do_cycle_check(.scope(o1))),
      .exp(0)
    );

    `uvm_info("STATUS_CONTAINER",
              $sformatf("STATUS_CONTAINER: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_status_container
