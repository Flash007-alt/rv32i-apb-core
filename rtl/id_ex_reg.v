// ============================================================================
// MODULE: ID/EX Pipeline Register
// PURPOSE: Latches control signals, register data, and addresses from the 
//          Decode stage and passes them to the Execute stage.
// ============================================================================

module id_ex_reg(
  input clk,
  input reset,
  input flush,
  input enable,
  
  // --- CONTROL SIGNALS IN (From Decode) ---
  input      [3:0]  id_alu_sel,
  input             id_reg_write,
  input             id_branch,
  input             id_alu_src,
  input             id_mem_read,
  input             id_mem_write,
  input             id_mem_to_reg,
  
  // --- DATA IN (From Decode) ---
  input      [31:0] id_pc,
  input      [31:0] id_rs1_data,
  input      [31:0] id_rs2_data,
  input      [31:0] id_imm_out,
  
  // --- ADDRESSES IN (From Decode) ---
  input      [4:0]  id_rs1,
  input      [4:0]  id_rs2,
  input      [4:0]  id_rd,

  // --- CONTROL SIGNALS OUT (To Execute) ---
  output reg [3:0]  ex_alu_sel,
  output reg        ex_reg_write,
  output reg        ex_branch,
  output reg        ex_alu_src,
  output reg        ex_mem_read,
  output reg        ex_mem_write,
  output reg        ex_mem_to_reg,
  
  // --- DATA OUT (To Execute) ---
  output reg [31:0] ex_pc,
  output reg [31:0] ex_rs1_data,
  output reg [31:0] ex_rs2_data,
  output reg [31:0] ex_imm_out,
  
  // --- ADDRESSES OUT (To Execute/Forwarding) ---
  output reg [4:0]  ex_rs1,
  output reg [4:0]  ex_rs2,
  output reg [4:0]  ex_rd
);

  always @(posedge clk) begin
    if (reset || flush) begin
      ex_alu_sel    <= 4'b0000;
      ex_reg_write  <= 1'b0;
      ex_branch     <= 1'b0;
      ex_alu_src    <= 1'b0;
      ex_mem_read   <= 1'b0;
      ex_mem_write  <= 1'b0;
      ex_mem_to_reg <= 1'b0;
      
      ex_pc         <= 32'b0;
      ex_rs1_data   <= 32'b0;
      ex_rs2_data   <= 32'b0;
      ex_imm_out    <= 32'b0;
      
      ex_rs1        <= 5'b0;
      ex_rs2        <= 5'b0;
      ex_rd         <= 5'b0;
    end else if(enable) begin
      ex_alu_sel    <= id_alu_sel;
      ex_reg_write  <= id_reg_write;
      ex_branch     <= id_branch;
      ex_alu_src    <= id_alu_src;
      ex_mem_read   <= id_mem_read;
      ex_mem_write  <= id_mem_write;
      ex_mem_to_reg <= id_mem_to_reg;
      
      ex_pc         <= id_pc;
      ex_rs1_data   <= id_rs1_data;
      ex_rs2_data   <= id_rs2_data;
      ex_imm_out    <= id_imm_out;
      
      ex_rs1        <= id_rs1;
      ex_rs2        <= id_rs2;
      ex_rd         <= id_rd;
    end
  end

endmodule
