//-----------------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2011 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//-----------------------------------------------------------------------------

//
// Modified from Accellera UVM 1.1d for Icarus Verilog (IVL_UVM).
// Copyright (c) 2026 AsFigo (https://www.asfigo.com)
// Authors: Srinivasan Venkataramanan, Ajeetha Kumari Venkatesan
// SPDX-License-Identifier: Apache-2.0

`ifdef IVL_UVM
// uvm_component: the BCL class, ported in steps. This first cut has the
// component hierarchy (parent, children, full name, depth) and the phase
// methods. Not ported yet: configuration, factory overrides, recording,
// domains, objections, hooks and the root component. Children are kept in an
// ivl_uvm_linked_list because Icarus has no associative array, so child
// iteration runs newest child first, not in name order as in the BCL. A
// component with no parent is a top-level component (the BCL attaches it to
// the root component).
virtual class uvm_component extends uvm_report_object;
  protected uvm_component m_parent;
  protected ivl_uvm_linked_list #(string, uvm_component) m_children;
  protected string m_name;

  extern function new(string name,
                      uvm_component parent);

  // Internal: overridden by `uvm_component_utils (stands in for the registry's create_component)
  extern virtual function uvm_component m_ivl_create_component(string name,
                                                               uvm_component parent);

  extern virtual function uvm_component get_parent();
  extern virtual function string get_full_name();
  extern virtual function void set_name(string name);
  extern function uvm_component get_child(string name);
  extern function int get_first_child(ref string name);
  extern function int get_next_child(ref string name);
  extern function int get_num_children();
  extern function int has_child(string name);
  extern function int unsigned get_depth();
  extern virtual function bit m_add_child(uvm_component child);
  extern function void m_set_full_name();

  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void end_of_elaboration_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
  extern virtual function void extract_phase(uvm_phase phase);
  extern virtual function void check_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual function void final_phase(uvm_phase phase);

  // Calls every phase once, in order, on this component only.
  extern virtual task ivl_uvm_run_all_phases();
endclass : uvm_component

function uvm_component::new(string name,
                            uvm_component parent);
  bit dup;
  super.new(name);

  if (name == "") begin
    name.itoa(m_inst_count);
    name = {"COMP_", name};
  end

  if (parent == this) begin
    `uvm_fatal("THISPARENT", "cannot set the parent of a component to itself")
  end

  m_children = new;

  // The BCL returns after the fatal; a constructor cannot use a bare return
  // here, so the rest is skipped with a flag.
  dup = 0;
  if (parent != null) begin
    if (parent.has_child(name) && this != parent.get_child(name)) begin
      `uvm_fatal("CLDEXT",
                 $sformatf("Cannot set '%s' as a child of '%s', %s",
                           name, parent.get_full_name(),
                           "which already has a child by that name."))
      dup = 1;
    end
  end

  if (!dup) begin
    m_parent = parent;

    set_name(name);

    if (m_parent != null) begin
      if (!m_parent.m_add_child(this)) begin
        m_parent = null;
      end
    end

    reseed();
  end
endfunction : new

function uvm_component uvm_component::get_parent();
  return m_parent;
endfunction : get_parent

function string uvm_component::get_full_name();
  if (m_name == "") begin
    return this.get_name();
  end
  return m_name;
endfunction : get_full_name

function void uvm_component::set_name(string name);
  if (m_name != "") begin
    `uvm_error("INVSTNM",
               $sformatf("It is illegal to change the name of a component. The component name will not be changed to \"%s\"", name))
    return;
  end
  super.set_name(name);
  m_set_full_name();
endfunction : set_name

function uvm_component uvm_component::get_child(string name);
  ivl_uvm_ll_node #(string, uvm_component) n;
  n = m_children.find_node(name);
  if (n != null) begin
    return n.val;
  end
  `uvm_warning("NOCHILD",
               {"Component with name '", name, "' is not a child of component '", this.get_full_name(), "'"})
  return null;
endfunction : get_child

function int uvm_component::get_first_child(ref string name);
  ivl_uvm_ll_node #(string, uvm_component) n;
  n = m_children.first_node();
  if (n == null) begin
    return 0;
  end
  name = n.key;
  return 1;
endfunction : get_first_child

function int uvm_component::get_next_child(ref string name);
  ivl_uvm_ll_node #(string, uvm_component) n;
  n = m_children.find_node(name);
  if (n == null) begin
    return 0;
  end
  n = n.next;
  if (n == null) begin
    return 0;
  end
  name = n.key;
  return 1;
endfunction : get_next_child

function int uvm_component::get_num_children();
  return m_children.size();
endfunction : get_num_children

function int uvm_component::has_child(string name);
  ivl_uvm_ll_node #(string, uvm_component) n;
  n = m_children.find_node(name);
  return (n != null);
endfunction : has_child

function int unsigned uvm_component::get_depth();
  int unsigned d;
  string nm;
  nm = m_name;
  if (nm == "") begin
    return 0;
  end
  d = 1;
  for (int i = 0; i < nm.len(); i++) begin
    if (nm.getc(i) == ".") begin
      d++;
    end
  end
  return d;
endfunction : get_depth

function bit uvm_component::m_add_child(uvm_component child);
  ivl_uvm_ll_node #(string, uvm_component) n;
  n = m_children.find_node(child.get_name());
  if (n != null) begin
    if (n.val != child) begin
      `uvm_warning("BDCLD",
                   $sformatf("A child with the name '%0s' (type=%0s) already exists.",
                             child.get_name(), n.val.get_type_name()))
      return 0;
    end
  end
  m_children.set(child.get_name(), child);
  return 1;
endfunction : m_add_child

function void uvm_component::m_set_full_name();
  ivl_uvm_ll_node #(string, uvm_component) n;
  uvm_component c;
  if (m_parent == null) begin
    m_name = this.get_name();
  end
  else begin
    m_name = {m_parent.get_full_name(), ".", this.get_name()};
  end
  if (m_children == null) begin
    return;
  end
  n = m_children.first_node();
  while (n != null) begin
    c = n.val;
    c.m_set_full_name();
    n = n.next;
  end
endfunction : m_set_full_name

function uvm_component uvm_component::m_ivl_create_component(string name,
                                                             uvm_component parent);
  return null;
endfunction : m_ivl_create_component

function void uvm_component::build_phase(uvm_phase phase);
  `g2u_display ("build_phase", UVM_HIGH)
endfunction : build_phase

function void uvm_component::connect_phase(uvm_phase phase);
  `g2u_display ("connect_phase", UVM_HIGH)
endfunction : connect_phase

function void uvm_component::end_of_elaboration_phase(uvm_phase phase);
  `g2u_display ("end_of_elaboration_phase", UVM_HIGH)
endfunction : end_of_elaboration_phase

function void uvm_component::start_of_simulation_phase(uvm_phase phase);
  `g2u_display ("start_of_simulation_phase", UVM_HIGH)
endfunction : start_of_simulation_phase

task uvm_component::run_phase(uvm_phase phase);
  `g2u_display ("run_phase", UVM_HIGH)
endtask : run_phase

function void uvm_component::extract_phase(uvm_phase phase);
endfunction : extract_phase

function void uvm_component::check_phase(uvm_phase phase);
endfunction : check_phase

function void uvm_component::report_phase(uvm_phase phase);
endfunction : report_phase

function void uvm_component::final_phase(uvm_phase phase);
endfunction : final_phase

task uvm_component::ivl_uvm_run_all_phases();
  uvm_phase u_ph_0;

  u_ph_0 = new();
  this.build_phase (u_ph_0);
  this.connect_phase (u_ph_0);
  this.end_of_elaboration_phase (u_ph_0);
  this.start_of_simulation_phase (u_ph_0);
  this.run_phase (u_ph_0);
  this.extract_phase (u_ph_0);
  this.check_phase (u_ph_0);
  this.report_phase (u_ph_0);
  this.final_phase (u_ph_0);
endtask : ivl_uvm_run_all_phases

`else
// BCL (UVM 1.1d) text of the members ported above, verbatim; the rest of the
// class is not ported yet.
//
//   /*protected*/ uvm_component m_parent;
//   protected     uvm_component m_children[string];
//   protected     uvm_component m_children_by_handle[uvm_component];
//   string m_name;
//
// function uvm_component::get_first_child(ref string name);
//   return m_children.first(name);
// endfunction
//
// function int uvm_component::get_next_child(ref string name);
//   return m_children.next(name);
// endfunction
//
// function int uvm_component::get_num_children();
//   return m_children.num();
// endfunction
//
// function int uvm_component::has_child(string name);
//   return m_children.exists(name);
// endfunction
//
// function uvm_component uvm_component::get_child(string name);
//   if (m_children.exists(name))
//     return m_children[name];
//   `uvm_warning("NOCHILD",{"Component with name '",name,
//        "' is not a child of component '",get_full_name(),"'"})
//   return null;
// endfunction
//
// function int unsigned uvm_component::get_depth();
//   if(m_name == "") return 0;
//   get_depth = 1;
//   foreach(m_name[i])
//     if(m_name[i] == ".") ++get_depth;
// endfunction
`endif // IVL_UVM
