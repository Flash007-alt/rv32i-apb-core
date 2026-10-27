// ============================================================================
// MODULE: PC Adder
// PURPOSE: Dedicated combinational adder that calculates the default next 
//          sequential instruction address (PC + 4 bytes).
// ============================================================================

module pc_adder(
  // --- INPUTS ---
  input  [31:0] pc_current, // The current instruction address
  
  // --- OUTPUTS ---
  output [31:0] pc_next     // The default next address (PC + 4)
);
  
  // --- COMBINATIONAL LOGIC ---
  // RISC-V instructions are 32 bits (4 bytes) wide, so we advance by 4
  assign pc_next = pc_current + 32'd4;
  
endmodule
