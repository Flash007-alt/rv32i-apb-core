`timescale 1ns/1ps

// ============================================================================
// COVERAGE CLASSES (FIXED)
// ============================================================================
class apb_coverage;
  logic PSEL, PENABLE, PWRITE, PREADY;
  logic [31:0] PADDR;

  // Removed @(posedge clk) - sampling is triggered manually
  covergroup apb_cg;
    option.per_instance = 1; 
    
    cp_pwrite: coverpoint PWRITE iff (PSEL && PENABLE) { bins read_op = {0}; bins write_op = {1}; }
    cp_pready: coverpoint PREADY iff (PSEL && PENABLE) { bins no_stall = {1}; bins wait_state = {0}; }
    cx_op_stall: cross cp_pwrite, cp_pready;
  endgroup

  function new(); apb_cg = new(); endfunction
  function void sample(logic sel, logic en, logic wr, logic rdy, logic [31:0] addr);
    this.PSEL = sel; this.PENABLE = en; this.PWRITE = wr; this.PREADY = rdy; this.PADDR = addr;
    apb_cg.sample(); // Manual trigger
  endfunction
endclass

class core_coverage;
  logic load_use_stall;
  logic [31:0] id_instruction;
  logic [1:0]  forward_a, forward_b;

  // Removed @(posedge clk) - sampling is triggered manually
  covergroup core_cg;
    option.per_instance = 1; 
    
    cp_opcode: coverpoint id_instruction[6:0] {
      bins r_type = {7'b0110011}; bins i_alu = {7'b0010011}; bins i_load = {7'b0000011}; 
      bins s_store = {7'b0100011}; bins b_type = {7'b1100011}; bins nop = {7'b0000000};
    }
    cp_fwd_a: coverpoint forward_a { bins no_fwd = {2'b00}; bins mem_fwd = {2'b01}; bins ex_fwd = {2'b10}; }
    cp_fwd_b: coverpoint forward_b { bins no_fwd = {2'b00}; bins mem_fwd = {2'b01}; bins ex_fwd = {2'b10}; }
    cp_stall: coverpoint load_use_stall { bins running = {0}; bins stalled = {1}; }
  endgroup

  function new(); core_cg = new(); endfunction
  function void sample(logic [31:0] inst, logic [1:0] fwd_a, logic [1:0] fwd_b, logic stall);
    this.id_instruction = inst; this.forward_a = fwd_a; this.forward_b = fwd_b; this.load_use_stall = stall;
    core_cg.sample(); // Manual trigger
  endfunction
endclass

// ============================================================================
// TOP LEVEL TESTBENCH
// ============================================================================
module tb_cpu_top;
  logic clk;
  logic reset;

  cpu_top uut (
    .clk(clk),
    .reset(reset)
  );

  always #5 clk = ~clk;

  apb_coverage  apb_cov;
  core_coverage core_cov;

  initial begin
    apb_cov  = new();
    core_cov = new();
    
    clk = 0;
    reset = 1;
    #20;
    reset = 0;

    #1000;
    
    $display("========================================");
    $display("Simulation Complete.");
    
    // CRITICAL FIX: Extract get_inst_coverage() instead of get_coverage()
    $display(">>> APB Protocol Coverage: %.2f%%", apb_cov.apb_cg.get_inst_coverage());
    $display(">>> RV32I Core Coverage:   %.2f%%", core_cov.core_cg.get_inst_coverage());
    $display("========================================");
    $finish;
  end

  // Coverage Sampling
  always @(posedge clk) begin
    if (!reset) begin
      apb_cov.sample(uut.apb_psel, uut.apb_penable, uut.apb_pwrite, uut.apb_pready, uut.apb_paddr);
      core_cov.sample(uut.id_instruction, uut.forward_a, uut.forward_b, ~uut.hazard_pc_write);
    end
  end

  // DEBUG MONITOR: Prove which program.mem file is loading
  always @(posedge clk) begin
    if (!reset && uut.pc_write) begin
      $display("Time=%0t | FETCH | PC: %0d | INST: %h", $time, uut.pc_current, uut.instruction);
    end
  end

  // APB Bus Monitor
  always @(posedge clk) begin
    if (uut.apb_psel && uut.apb_penable) begin
      if (uut.apb_pwrite)
        $display("Time=%0t | APB WRITE | ADDR: 0x%0h | DATA OUT: 0x%0h | PREADY: %b", $time, uut.apb_paddr, uut.apb_pwdata, uut.apb_pready);
      else
        $display("Time=%0t | APB READ  | ADDR: 0x%0h | DATA IN:  0x%0h | PREADY: %b", $time, uut.apb_paddr, uut.apb_prdata, uut.apb_pready);
    end
  end

endmodule
