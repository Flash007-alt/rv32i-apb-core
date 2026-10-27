// ============================================================================
// MODULE: Program Counter (PC)
// PURPOSE: A 32-bit register that holds the memory address of the current 
//          instruction. Supports clock gating (stalling) via pc_write.
// ============================================================================

module pc(
  // --- INPUTS ---
  input             clk,       // System clock
  input             reset,     // Active-high synchronous reset
  input             pc_write,  // Stall control: 1 = update PC, 0 = freeze PC
  input      [31:0] next_pc,   // The next address to load
  
  // --- OUTPUTS ---
  output reg [31:0] pc_out     // The current instruction address
);
  
  // --- SEQUENTIAL LOGIC ---
  always @(posedge clk) begin
    if (reset) begin
      // Initialize to 0 so CPU starts execution at a known address.
      pc_out <= 32'b0;
    end else if (pc_write) begin
      // Advance to the next instruction address only if not stalled
      pc_out <= next_pc;
    end
    // If pc_write is 0, the PC retains its current value (stalls)
  end
  
endmodule
