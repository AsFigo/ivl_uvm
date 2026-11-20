// ========== Copyright Header Begin ==========================
//
// Project: IVL_UVM
// File: ivl_uvm_test_scope_stack.sv
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
// Direct test of uvm_scope_stack (UVM 1.1d class with a string queue member).
// Checks get/depth after each operation; prints PASS or FAIL per check and a
// final summary line.
module t_scope_stack;
  import ivl_uvm_pkg::*;

  int n_fail;
  int n_chk;

  function void chk(
    string what,
    string got,
    string exp,
    int got_d,
    int exp_d
  );
    n_chk++;
    if (got == exp && got_d == exp_d) begin
      `uvm_info("SCOPE_STACK",
                $sformatf("PASS  %-22s get='%s' depth=%0d", what, got, got_d),
                UVM_NONE)
    end
    else begin
      n_fail++;
      `uvm_error("SCOPE_STACK",
                 $sformatf("FAIL  %-22s get='%s' depth=%0d  expected get='%s' depth=%0d",
                           what, got, got_d, exp, exp_d))
    end
  endfunction : chk

  uvm_scope_stack s;
  uvm_scope_stack s2;

  initial begin
    s  = new;
    s2 = new;

    chk(
      .what("empty"),
      .got(s.get()),
      .exp(""),
      .got_d(s.depth()),
      .exp_d(0)
    );

    s.up_element();
    chk(
      .what("up_element on empty"),
      .got(s.get()),
      .exp(""),
      .got_d(s.depth()),
      .exp_d(0)
    );
    s.up();
    chk(
      .what("up on empty"),
      .got(s.get()),
      .exp(""),
      .got_d(s.depth()),
      .exp_d(0)
    );

    s.set(.s("top"));
    chk(
      .what("set"),
      .got(s.get()),
      .exp("top"),
      .got_d(s.depth()),
      .exp_d(1)
    );

    s.down(.s("env"));
    chk(
      .what("down"),
      .got(s.get()),
      .exp("top.env"),
      .got_d(s.depth()),
      .exp_d(2)
    );

    s.down_element(.element(3));
    chk(
      .what("down_element"),
      .got(s.get()),
      .exp("top.env[3]"),
      .got_d(s.depth()),
      .exp_d(3)
    );

    s.set_arg(.arg("f"));
    chk(
      .what("set_arg"),
      .got(s.get()),
      .exp("top.env[3].f"),
      .got_d(s.depth()),
      .exp_d(3)
    );
    s.unset_arg(.arg("f"));
    chk(
      .what("unset_arg"),
      .got(s.get()),
      .exp("top.env[3]"),
      .got_d(s.depth()),
      .exp_d(3)
    );

    s.set_arg_element(
      .arg("a"),
      .ele(2)
    );
    chk(
      .what("set_arg_element"),
      .got(s.get()),
      .exp("top.env[3].a[2]"),
      .got_d(s.depth()),
      .exp_d(3)
    );
    s.unset_arg(.arg("a[2]"));
    chk(
      .what("unset_arg element"),
      .got(s.get()),
      .exp("top.env[3]"),
      .got_d(s.depth()),
      .exp_d(3)
    );

    s.up_element();
    chk(
      .what("up_element drops [n]"),
      .got(s.get()),
      .exp("top.env"),
      .got_d(s.depth()),
      .exp_d(2)
    );

    s.down(.s("agt"));
    s.up_element();
    chk(
      .what("up_element keeps name"),
      .got(s.get()),
      .exp("top.env.agt"),
      .got_d(s.depth()),
      .exp_d(3)
    );

    s.up();
    chk(
      .what("up"),
      .got(s.get()),
      .exp("top.env"),
      .got_d(s.depth()),
      .exp_d(2)
    );

    s.down(.s("(x)"));
    chk(
      .what("down paren"),
      .got(s.get()),
      .exp("top.env(x)"),
      .got_d(s.depth()),
      .exp_d(3)
    );
    s.up();
    chk(
      .what("up skips (x)"),
      .got(s.get()),
      .exp("top"),
      .got_d(s.depth()),
      .exp_d(1)
    );

    s.up();
    chk(
      .what("up to empty"),
      .got(s.get()),
      .exp(""),
      .got_d(s.depth()),
      .exp_d(0)
    );

    s.set(.s("x"));
    s.down(.s("y"));
    s.set(.s("z"));
    chk(
      .what("set replaces stack"),
      .got(s.get()),
      .exp("z"),
      .got_d(s.depth()),
      .exp_d(1)
    );

    s.set(.s("r"));
    s.down(.s("a"));
    s.down(.s("b"));
    s.down(.s("c"));
    s.down(.s("d"));
    chk(
      .what("deep stack"),
      .got(s.get()),
      .exp("r.a.b.c.d"),
      .got_d(s.depth()),
      .exp_d(5)
    );

    s2.set(.s("other"));
    chk(
      .what("instance 2"),
      .got(s2.get()),
      .exp("other"),
      .got_d(s2.depth()),
      .exp_d(1)
    );
    chk(
      .what("instance 1 unchanged"),
      .got(s.get()),
      .exp("r.a.b.c.d"),
      .got_d(s.depth()),
      .exp_d(5)
    );

    `uvm_info("SCOPE_STACK",
              $sformatf("SCOPE_STACK: %s (%0d checks, %0d failed)",
                        (n_fail == 0) ? "PASS" : "FAIL", n_chk, n_fail),
              UVM_NONE)
  end
endmodule : t_scope_stack
