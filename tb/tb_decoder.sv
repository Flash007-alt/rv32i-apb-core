// ============================================================================
// MODULE: Decoder Testbench (decoder_tb)
// PURPOSE: Verifies the control signal generation of the Instruction Decoder 
//          for various R-type instructions (ADD, SUB, AND, OR, XOR).
// ============================================================================

module decoder_tb;
  
  // --- TESTBENCH SIGNALS ---
  reg  [31:0] instruction;
  
  // Wires to observe outputs from the DUT
  wire [3:0]  alu_sel;
  wire        reg_write;
  
  // Expected values for self-checking
  reg  [3:0]  expected_alu_sel;
  reg         expected_reg_write;
  
  // ==========================================================================
  // DEVICE UNDER TEST (DUT) INSTANTIATION
  // ==========================================================================
  decoder dut(
    .instruction(instruction),
    .alu_sel(alu_sel),
    .reg_write(reg_write)
  );
  
  // ==========================================================================
  // TEST VECTOR GENERATION & SELF-CHECKING
  // ==========================================================================
  initial begin
    $display("--- Starting Decoder Verification ---");
    
    // 1. ADD INSTRUCTION
    expected_alu_sel   = 4'b0000;
    expected_reg_write = 1'b1;
    instruction        = 32'b00000000001000001000000110110011;
    #5;
    if (expected_alu_sel == alu_sel && expected_reg_write == reg_write) begin
      $display("ADD passed");
    end else begin
      $display("ADD failed: expected alu_sel=%b reg_write=%b, got alu_sel=%b reg_write=%b", 
                expected_alu_sel, expected_reg_write, alu_sel, reg_write);
    end

    // 2. SUB INSTRUCTION
    expected_alu_sel   = 4'b0001;
    expected_reg_write = 1'b1;
    instruction        = 32'b01000000001000001000000110110011;
    #5;
    if (expected_alu_sel == alu_sel && expected_reg_write == reg_write) begin
      $display("SUB passed");
    end else begin
      $display("SUB failed: expected alu_sel=%b reg_write=%b, got alu_sel=%b reg_write=%b", 
                expected_alu_sel, expected_reg_write, alu_sel, reg_write);
    end

    // 3. AND INSTRUCTION
    expected_alu_sel   = 4'b0010;
    expected_reg_write = 1'b1;
    instruction        = 32'b00000000001000001111000110110011;
    #5;
    if (expected_alu_sel == alu_sel && expected_reg_write == reg_write) begin
      $display("AND passed");
    end else begin
      $display("AND failed: expected alu_sel=%b reg_write=%b, got alu_sel=%b reg_write=%b", 
                expected_alu_sel, expected_reg_write, alu_sel, reg_write);
    end

    // 4. OR INSTRUCTION
    expected_alu_sel   = 4'b0011;
    expected_reg_write = 1'b1;
    instruction        = 32'b00000000001000001110000110110011;
    #5;
    if (expected_alu_sel == alu_sel && expected_reg_write == reg_write) begin
      $display("OR passed");
    end else begin
      $display("OR failed: expected alu_sel=%b reg_write=%b, got alu_sel=%b reg_write=%b", 
                expected_alu_sel, expected_reg_write, alu_sel, reg_write);
    end

    // 5. XOR INSTRUCTION
    expected_alu_sel   = 4'b0100;
    expected_reg_write = 1'b1;
    instruction        = 32'b00000000001000001100000110110011;
    #5;
    if (expected_alu_sel == alu_sel && expected_reg_write == reg_write) begin
      $display("XOR passed");
    end else begin
      $display("XOR failed: expected alu_sel=%b reg_write=%b, got alu_sel=%b reg_write=%b", 
                expected_alu_sel, expected_reg_write, alu_sel, reg_write);
    end

    $display("--- Decoder Verification Complete ---");
    $finish;
  end
  
endmodule
