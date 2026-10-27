// ============================================================================
// MODULE: Register File Testbench (regfile_tb)
// PURPOSE: Verifies the asynchronous read behavior, synchronous write behavior, 
//          and the hardwired x0 zero-protection rule of the Register File.
// ============================================================================

module regfile_tb;
  
  // --- TESTBENCH CONTROL SIGNALS ---
  reg         clk;
  reg         reset;
  reg         reg_write;
  reg  [4:0]  rs1;
  reg  [4:0]  rs2;
  reg  [4:0]  rd;
  reg  [31:0] write_data;
  
  // --- OBSERVATION WIRES ---
  wire [31:0] rs1_data;
  wire [31:0] rs2_data;
  wire [31:0] debug_x3;

  // ==========================================================================
  // DEVICE UNDER TEST (DUT) INSTANTIATION
  // ==========================================================================
  regfile dut (
    .clk(clk),
    .reset(reset),
    .reg_write(reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(write_data),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .debug_x3(debug_x3)
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
    $display("--- Starting Register File Verification ---");
    
    // Initialize signals
    reset      = 1'b1;
    reg_write  = 1'b0;
    rs1        = 5'd0;
    rs2        = 5'd0;
    rd         = 5'd0;
    write_data = 32'd0;
    #10;
    
    // Release reset
    reset = 1'b0;
    #5;

    // 1. TEST WRITING TO A GENERAL REGISTER (x5 = 42)
    @(posedge clk);
    reg_write  = 1'b1;
    rd         = 5'd5;
    write_data = 32'd42;
    @(posedge clk);
    
    // Disable write and read back from rs1
    reg_write = 1'b0;
    rs1       = 5'd5;
    #5;
    if (rs1_data == 32'd42) begin
      $display("Write/Read x5 test Pass");
    end else begin
      $display("Write/Read x5 test Fail: expected 42, got %0d", rs1_data);
    end

    // 2. TEST HARDWIRED x0 PROTECTION RULE (Attempt to write 99 to x0)
    @(posedge clk);
    reg_write  = 1'b1;
    rd         = 5'd0;        // Target x0
    write_data = 32'd99;
    @(posedge clk);
    
    // Disable write and read back x0
    reg_write = 1'b0;
    rs1       = 5'd0;
    #5;
    if (rs1_data == 32'd0) begin
      $display("x0 Hardwire Protection test Pass");
    end else begin
      $display("x0 Hardwire Protection test Fail: expected 0, got %0d", rs1_data);
    end

    $display("--- Register File Verification Complete ---");
    $finish;
  end

endmodule
