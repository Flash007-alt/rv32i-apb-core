// ============================================================================
// MODULE: Hazard Detection Unit
// PURPOSE: Detects Load-Use hazards and stalls the pipeline by freezing the 
//          PC and IF/ID registers, and inserting a bubble into ID/EX.
// ============================================================================

module hazard_detection_unit(
  // --- INPUTS ---
  input        id_ex_mem_read,  // Is the instruction in Execute stage a Load?
  input  [4:0] id_ex_rd,        // Destination register of the Load instruction
  input  [4:0] if_id_rs1,       // Source register 1 of Decode instruction
  input  [4:0] if_id_rs2,       // Source register 2 of Decode instruction

  // --- OUTPUTS ---
  output reg   pc_write,        // 0 = Stall PC
  output reg   if_id_write,     // 0 = Stall IF/ID Register
  output reg   ctrl_mux_sel     // 0 = Insert Bubble (Zero out control signals)
);

  always @(*) begin
    // Default: Normal execution (No stall)
    pc_write     = 1'b1;
    if_id_write  = 1'b1;
    ctrl_mux_sel = 1'b1;

    // Load-Use Hazard Detection Condition
    if (id_ex_mem_read && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin
      // Hazard detected: Stall the pipeline
      pc_write     = 1'b0;
      if_id_write  = 1'b0;
      ctrl_mux_sel = 1'b0;
    end
  end

endmodule
