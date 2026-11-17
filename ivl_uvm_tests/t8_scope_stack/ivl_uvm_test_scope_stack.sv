// Direct test of uvm_scope_stack (UVM 1.1d class with a string queue member).
// Checks get/depth after each operation; prints PASS or FAIL per check and a
// final summary line.
module t_scope_stack;
  import ivl_uvm_pkg::*;

  int n_fail;
  int n_chk;

  function void chk(string what, string got, string exp, int got_d, int exp_d);
    n_chk++;
    if (got == exp && got_d == exp_d) begin
      $display("PASS  %-22s get='%s' depth=%0d", what, got, got_d);
    end
    else begin
      n_fail++;
      $display("FAIL  %-22s get='%s' depth=%0d  expected get='%s' depth=%0d",
               what, got, got_d, exp, exp_d);
    end
  endfunction : chk

  uvm_scope_stack s;
  uvm_scope_stack s2;

  initial begin
    s  = new;
    s2 = new;

    chk("empty", s.get(), "", s.depth(), 0);

    s.up_element();
    chk("up_element on empty", s.get(), "", s.depth(), 0);
    s.up();
    chk("up on empty", s.get(), "", s.depth(), 0);

    s.set("top");
    chk("set", s.get(), "top", s.depth(), 1);

    s.down("env");
    chk("down", s.get(), "top.env", s.depth(), 2);

    s.down_element(3);
    chk("down_element", s.get(), "top.env[3]", s.depth(), 3);

    s.set_arg("f");
    chk("set_arg", s.get(), "top.env[3].f", s.depth(), 3);
    s.unset_arg("f");
    chk("unset_arg", s.get(), "top.env[3]", s.depth(), 3);

    s.set_arg_element("a", 2);
    chk("set_arg_element", s.get(), "top.env[3].a[2]", s.depth(), 3);
    s.unset_arg("a[2]");
    chk("unset_arg element", s.get(), "top.env[3]", s.depth(), 3);

    s.up_element();
    chk("up_element drops [n]", s.get(), "top.env", s.depth(), 2);

    s.down("agt");
    s.up_element();
    chk("up_element keeps name", s.get(), "top.env.agt", s.depth(), 3);

    s.up();
    chk("up", s.get(), "top.env", s.depth(), 2);

    s.down("(x)");
    chk("down paren", s.get(), "top.env(x)", s.depth(), 3);
    s.up();
    chk("up skips (x)", s.get(), "top", s.depth(), 1);

    s.up();
    chk("up to empty", s.get(), "", s.depth(), 0);

    s.set("x");
    s.down("y");
    s.set("z");
    chk("set replaces stack", s.get(), "z", s.depth(), 1);

    s.set("r");
    s.down("a");
    s.down("b");
    s.down("c");
    s.down("d");
    chk("deep stack", s.get(), "r.a.b.c.d", s.depth(), 5);

    s2.set("other");
    chk("instance 2", s2.get(), "other", s2.depth(), 1);
    chk("instance 1 unchanged", s.get(), "r.a.b.c.d", s.depth(), 5);

    $display("SCOPE_STACK: %0d checks, %0d failed -> %s", n_chk, n_fail,
             (n_fail == 0) ? "PASS" : "FAIL");
  end
endmodule : t_scope_stack
