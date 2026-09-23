// DESCRIPTION: Verilator: Verilog Test module
//
// A parameterized class specialized on the same interface with two different
// modports must yield two distinct classes, and modport-qualified virtual
// interface values must be accepted as arguments of their methods.
//
// This file ONLY is placed under the Creative Commons Public Domain
// SPDX-FileCopyrightText: 2026 Persimmons Inc.
// SPDX-License-Identifier: CC0-1.0

package p;
  typedef struct packed {
    logic a;
    logic [7:0] b;
  } req_t;
endpackage

interface my_if (
    input logic clk
);
  p::req_t req_sig;
  p::req_t rsp_sig;
  modport drv_mp(input clk, rsp_sig, output req_sig);
  modport mon_mp(input clk, req_sig, rsp_sig);
endinterface

class db #(
    type T = int
);
  static T store[string];
  static function void set(string key, T value);
    store[key] = value;
  endfunction
  static function bit get(string key, inout T value);
    if (store.exists(key)) begin
      value = store[key];
      return 1;
    end
    return 0;
  endfunction
endclass

class env;
  virtual my_if.drv_mp drv_vif[4];
  virtual my_if.mon_mp mon_vif[4];
  virtual my_if.drv_mp one;
  function void run();
    for (int t = 0; t < 4; t++) begin
      void'(db#(virtual my_if.drv_mp)::get($sformatf("in%0d", t), drv_vif[t]));
      db#(virtual my_if.drv_mp)::set($sformatf("arr%0d", t), drv_vif[t]);
      void'(db#(virtual my_if.mon_mp)::get($sformatf("min%0d", t), mon_vif[t]));
      db#(virtual my_if.mon_mp)::set($sformatf("marr%0d", t), mon_vif[t]);
      begin
        virtual my_if.drv_mp s = drv_vif[t];
        db#(virtual my_if.drv_mp)::set($sformatf("scalar%0d", t), s);
      end
    end
    one = drv_vif[0];
    db#(virtual my_if.drv_mp)::set("member", one);
  endfunction
endclass

module t;
  logic clk = 0;
  my_if ifs[4] (clk);
  initial begin
    env e;
    e = new;
    db#(virtual my_if.drv_mp)::set("in0", ifs[0]);
    db#(virtual my_if.drv_mp)::set("in1", ifs[1]);
    db#(virtual my_if.mon_mp)::set("min0", ifs[0]);
    e.run();
    // Distinct specializations keep distinct storage
    if (db#(virtual my_if.drv_mp)::store.size() != 11) $stop;
    if (db#(virtual my_if.mon_mp)::store.size() != 5) $stop;
    if (e.drv_vif[0] == null || e.drv_vif[1] == null || e.mon_vif[0] == null) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
