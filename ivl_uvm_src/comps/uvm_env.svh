//
//------------------------------------------------------------------------------
//   Copyright 2007-2011 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc.
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
//------------------------------------------------------------------------------

//
// Modified from Accellera UVM 1.1d for Icarus Verilog (IVL_UVM).
// Copyright (c) 2026 AsFigo (https://www.asfigo.com)
// Authors: Srinivasan Venkataramanan, Ajeetha Kumari Venkatesan
// SPDX-License-Identifier: Apache-2.0

`ifdef IVL_UVM
`ifndef IVL_UVM_ENV_SVH
`define IVL_UVM_ENV_SVH

// The base class for hierarchical containers of other components that
// together comprise a complete environment.
virtual class uvm_env extends uvm_component;
  // Creates the env with the given name below parent.
  extern function new (string name = "env",
                       uvm_component parent = null);

  const static string type_name = "uvm_env";

  // Returns the type name of this class.
  extern virtual function string get_type_name ();
endclass : uvm_env

function uvm_env::new (string name = "env",
                       uvm_component parent = null);
  super.new (name, parent);
endfunction : new

function string uvm_env::get_type_name ();
  return type_name;
endfunction : get_type_name

`endif // IVL_UVM_ENV_SVH

`else

//------------------------------------------------------------------------------
//
// CLASS: uvm_env
//
// The base class for hierarchical containers of other components that
// together comprise a complete environment. The environment may
// initially consist of the entire testbench. Later, it can be reused as
// a sub-environment in even larger system-level environments.
//------------------------------------------------------------------------------

virtual class uvm_env extends uvm_component;

  // Function: new
  //
  // Creates and initializes an instance of this class using the normal
  // constructor arguments for <uvm_component>: ~name~ is the name of the
  // instance, and ~parent~ is the handle to the hierarchical parent, if any.

  function new (string name="env", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  const static string type_name = "uvm_env";

  virtual function string get_type_name ();
    return type_name;
  endfunction

endclass

`endif // IVL_UVM
