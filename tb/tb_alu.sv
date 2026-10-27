// ============================================================================
// MODULE: ALU Testbench (tb_alu)
// PURPOSE: Verifies all arithmetic and logical operations of the ALU by 
//          comparing the computed result against an expected value.
// ============================================================================

module alu_tb;
  
  // --- TESTBENCH SIGNALS ---
  // Registers for driving inputs to the Device Under Test (DUT)
  reg  [31:0] a;
  reg  [31:0] b;
  reg  [3:0]  alu_sel;
  
  // Wires for observing outputs from the DUT
  wire [31:0] result;
  wire        zero;
  
  // Register for holding the expected answer for self-checking
  reg  [31:0] expected;

  // ==========================================================================
  // DEVICE UNDER TEST (DUT) INSTANTIATION
  // ==========================================================================
  alu dut(
    .a(a),
    .b(b),
    .alu_sel(alu_sel),
    .result(result),
    .zero(zero)
  );
  
  // ==========================================================================
  // TEST VECTOR GENERATION & SELF-CHECKING LOGIC
  // ==========================================================================
  initial begin
    $display("--- Starting ALU Verification ---");
    
    // 1. ADD OPERATION
    a = 10; b = 10; alu_sel = 4'b0000; expected = 20;
    #10;
    if(result != expected) $display("ADD failed: expected %0d, got %0d", expected, result);
    else                   $display("ADD passed");
    
    // 2. SUBTRACT OPERATION
    a = 15; b = 5; alu_sel = 4'b0001; expected = 10;
    #10;
    if(result != expected) $display("SUBTRACT failed: expected %0d, got %0d", expected, result);
    else                   $display("SUBTRACT passed");
    
    // 3. AND OPERATION
    a = 12; b = 10; alu_sel = 4'b0010; expected = 8;
    #10;
    if(result != expected) $display("AND failed: expected %0d, got %0d", expected, result);
    else                   $display("AND passed");
    
    // 4. OR OPERATION
    a = 12; b = 10; alu_sel = 4'b0011; expected = 14;
    #10;
    if(result != expected) $display("OR failed: expected %0d, got %0d", expected, result);
    else                   $display("OR passed");
    
    // 5. EXOR OPERATION
    a = 12; b = 10; alu_sel = 4'b0100; expected = 6;
    #10;
    if(result != expected) $display("EXOR failed: expected %0d, got %0d", expected, result);
    else                   $display("EXOR passed");
    
    // 6. CHECKING DEFAULT CASE
    a = 5; b = 5; alu_sel = 4'b1111; expected = 0;
    #10;
    if(result != expected) $display("DEFAULT failed: expected %0d, got %0d", expected, result);
    else                   $display("DEFAULT passed");
    
    $display("--- ALU Verification Complete ---");
    $finish;
  end
  
endmodule
