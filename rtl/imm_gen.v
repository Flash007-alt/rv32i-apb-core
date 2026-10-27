// ============================================================================
// MODULE: Immediate Generator (imm_gen)
// PURPOSE: Extracts and sign-extends immediate values from the 32-bit 
//          instruction based on the opcode format (I, S, and B types).
// ============================================================================

module imm_gen(
  // --- INPUTS ---
  input      [31:0] instruction,  // 32-bit instruction from memory
  
  // --- OUTPUTS ---
  output reg [31:0] immediate     // 32-bit sign-extended immediate value
);

  // Extract opcode to determine instruction type
  wire [6:0] opcode = instruction[6:0];

  // ==========================================================================
  // SIGN EXTENSION & EXTRACTION LOGIC
  // Note: RISC-V cleverly always places the sign bit at instruction[31]. 
  // We use Verilog replication {N{instruction[31]}} to copy the sign bit 
  // N times to pad the upper bits of the 32-bit wire.
  // ==========================================================================
  always @(*) begin
    
    // Default case to prevent inferred latches
    immediate = 32'b0; 
    
    case(opcode)
      
      // --- I-TYPE (ADDI, LW) ---
      // Format: [31:20] -> bits [11:0] of immediate
      7'b0010011, 
      7'b0000011: immediate = { {20{instruction[31]}}, instruction[31:20] };
      
      // --- S-TYPE (Store Word) ---
      // Format: [31:25] and [11:7] combine to form bits [11:0]
      7'b0100011: immediate = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
      
      // --- B-TYPE (Branch) ---
      // Format: [31], [7], [30:25], [11:8] with an implied 0 at the LSB (bit 0)
      7'b1100011: immediate = { {19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0 };
      
      default:    immediate = 32'b0;
      
    endcase
  end

endmodule
