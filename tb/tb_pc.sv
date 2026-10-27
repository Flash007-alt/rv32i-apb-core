// ============================================================================
// MODULE: Program Counter Testbench (pc_tb)
// PURPOSE: Verifies the reset behavior and address updating sequence of the 
//          Program Counter module.
// ============================================================================

module pc_tb;
  
  // --- TESTBENCH CONTROL SIGNALS ---
  reg         clk;
  reg         reset;
  reg  [31:0] next_pc;
  
  // --- OBSERVATION WIRES ---
  wire [31:0] pc_out;
  
  // ==========================================================================
  // DEVICE UNDER TEST (DUT) INSTANTIATION
  // ==========================================================================
  pc dut (
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .pc_out(pc_out)
  );
  
  // ==========================================================================
  // CLOCK GENERATION (10ns period -> 100MHz clock)
  // ==========================================================================
  initial clk = 0;
  always #5 clk = ~clk;
  
  // ==========================================================================
  // TEST STIMULUS & VERIFICATION
  // ==========================================================================
  initial begin
    $display("--- Starting Program Counter Verification ---");
    
    // 1. RESET TEST
    // Even though next_pc is driven with a non-zero value, reset should dominate.
    reset   = 1'b1;
    next_pc = 32'd4;
    #10;
    if (pc_out == 32'd0) begin
      $display("Reset test Pass");
    end else begin
      $display("Reset test Fail: expected 0, got %0d", pc_out);
    end
    
    // 2. NORMAL UPDATE TEST SEQUENCE
    reset   = 1'b0;
    next_pc = 32'd16;
    #10;
    if (pc_out == 32'd16) begin
      $display("Address Update test Pass");
    end else begin
      $display("Address Update test Fail: expected 16, got %0d", pc_out);
    end
    
    $display("--- Program Counter Verification Complete ---");
    $finish;
  end
  
endmodule
