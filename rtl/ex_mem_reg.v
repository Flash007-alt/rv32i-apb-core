module ex_mem_reg(
  input clk,
  input reset,
  input enable,
  
  input             ex_reg_write,
  input             ex_mem_to_reg,
  input             ex_mem_read,
  input             ex_mem_write,
  input      [31:0] ex_alu_result,
  input      [31:0] ex_rs2_data,
  input      [4:0]  ex_rd,

  output reg        mem_reg_write,
  output reg        mem_mem_to_reg,
  output reg        mem_mem_read,
  output reg        mem_mem_write,
  output reg [31:0] mem_alu_result,
  output reg [31:0] mem_rs2_data,
  output reg [4:0]  mem_rd
);

  always @(posedge clk) begin
    if (reset) begin
      mem_reg_write  <= 1'b0;
      mem_mem_to_reg <= 1'b0;
      mem_mem_read   <= 1'b0;
      mem_mem_write  <= 1'b0;
      mem_alu_result <= 32'b0;
      mem_rs2_data   <= 32'b0;
      mem_rd         <= 5'b0;
    end else if (enable) begin
      mem_reg_write  <= ex_reg_write;
      mem_mem_to_reg <= ex_mem_to_reg;
      mem_mem_read   <= ex_mem_read;
      mem_mem_write  <= ex_mem_write;
      mem_alu_result <= ex_alu_result;
      mem_rs2_data   <= ex_rs2_data;
      mem_rd         <= ex_rd;
    end
  end
endmodule
