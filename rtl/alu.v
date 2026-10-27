// ============================================================================
// MODULE: Arithmetic Logic Unit (ALU)
// PURPOSE: Performs all core mathematical and logical operations for the CPU.
// ============================================================================

module alu(
  // --- INPUTS ---
  input      [31:0] a,        // Operand A (from Register File RS1)
  input      [31:0] b,        // Operand B (from Register File RS2 or Immediate)
  input      [3:0]  alu_sel,  // Control signal from Decoder to select operation
  
  // --- OUTPUTS ---
  output reg [31:0] result,   // The 32-bit computed answer
  output            zero      // Flag used by branch logic
);
  
  // --- ALU OPERATIONS LOGIC ---
  always @(*) begin
    case(alu_sel)
      4'b0000 : result = a + b; // ADD
      4'b0001 : result = a - b; // SUB
      4'b0010 : result = a & b; // AND
      4'b0011 : result = a | b; // OR
      4'b0100 : result = a ^ b; // XOR
      default : result = 32'b0; // Default case prevents inferred latches
    endcase
  end

  // --- ZERO FLAG GENERATION ---
  // Creates a 32-bit comparator hardware. If all bits are zero, then this flag 
  // becomes 1, else 0. This flag is put outside the always block because it 
  // depends on the result and is continuously driven.
  assign zero = (result == 32'b0); 
  
endmodule
