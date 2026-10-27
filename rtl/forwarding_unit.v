// ============================================================================
// MODULE: Data Forwarding Unit
// PURPOSE: Detects data hazards (Read-After-Write) and forwards ALU/Memory 
//          results directly to the Execute stage to prevent pipeline stalls.
// ============================================================================

module forwarding_unit(
  // --- INPUTS (Source registers from Execute stage) ---
  input  [4:0] id_ex_rs1,
  input  [4:0] id_ex_rs2,
  
  // --- INPUTS (Destination registers & write enables from later stages) ---
  input  [4:0] ex_mem_rd,
  input        ex_mem_reg_write,
  
  input  [4:0] mem_wb_rd,
  input        mem_wb_reg_write,
  
  // --- OUTPUTS (Forwarding Mux Selectors) ---
  // 00 = No forwarding (use ID/EX register output)
  // 10 = Forward from EX/MEM stage (ALU result)
  // 01 = Forward from MEM/WB stage (Memory/ALU result)
  output reg [1:0] forward_a,
  output reg [1:0] forward_b
);

  always @(*) begin
    // Initialize to default (no forwarding)
    forward_a = 2'b00;
    forward_b = 2'b00;
    
    // --------------------------------------------------------------------
    // FORWARD A LOGIC (For rs1)
    // --------------------------------------------------------------------
    // 1. EX Hazard (Highest Priority - closest instruction)
    if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs1)) begin
      forward_a = 2'b10;
    end 
    // 2. MEM Hazard (Only if no EX hazard exists)
    else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs1)) begin
      forward_a = 2'b01;
    end
    
    // --------------------------------------------------------------------
    // FORWARD B LOGIC (For rs2)
    // --------------------------------------------------------------------
    // 1. EX Hazard 
    if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && (ex_mem_rd == id_ex_rs2)) begin
      forward_b = 2'b10;
    end 
    // 2. MEM Hazard
    else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_ex_rs2)) begin
      forward_b = 2'b01;
    end
  end

endmodule
