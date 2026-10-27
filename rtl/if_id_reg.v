// ============================================================================
// MODULE: IF/ID Pipeline Register
// PURPOSE: Latches the Program Counter and Instruction from the Fetch stage 
//          and passes them to the Decode stage on the next clock edge.
// ============================================================================

module if_id_reg(
  input             clk,
  input             reset,
  input             flush,
  input             enable,          // For clock gating / pipeline stalls

  // --- INPUTS (From Fetch Stage) ---
  input      [31:0] if_pc,
  input      [31:0] if_instruction,
  
  // --- OUTPUTS (To Decode Stage) ---
  output reg [31:0] id_pc,
  output reg [31:0] id_instruction
);

  always @(posedge clk) begin
    if (reset || flush) begin
      id_pc          <= 32'b0;
      id_instruction <= 32'b0; // NOP instruction essentially
    end 
    else if (enable) begin
      id_pc          <= if_pc;
      id_instruction <= if_instruction;
    end
    // If enable is 0, the register holds its current value (stalls)
  end

endmodule
