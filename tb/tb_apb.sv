
// ============================================================================
// MODULE: CPU Verification Testbench
// PURPOSE: Simulates the RV32I core and monitors APB bus transactions.
// ============================================================================
`timescale 1ns/1ps

module tb_cpu_top;
  reg clk;
  reg reset;

  // Instantiate the Top-Level CPU
  cpu_top uut (
    .clk(clk),
    .reset(reset)
  );

  // Clock Generation (10ns period -> 100 MHz)
  always #5 clk = ~clk;

  // Test Sequence
  initial begin
    // Initialize & System Reset
    clk = 0;
    reset = 1;
    #20;
    
    // Release reset and start execution
    reset = 0;

    // Run simulation for enough cycles to hit the memory instructions
    #400;
    
    $display("Simulation Complete.");
    $finish;
  end

  // APB Bus Monitor
  always @(posedge clk) begin
    if (uut.apb_psel && uut.apb_penable) begin
      $display("Time=%0t | APB ACCESS -> Addr: %h | Write: %b | Data: %h", 
               $time, uut.apb_paddr, uut.apb_pwrite, 
               uut.apb_pwrite ? uut.apb_pwdata : uut.apb_prdata);
    end
  end

endmodule