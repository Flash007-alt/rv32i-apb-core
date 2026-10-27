module mem_wb_reg(
  input clk,
  input reset,
  input enable,
  
  input             mem_reg_write,
  input             mem_mem_to_reg,
  input      [31:0] mem_alu_result,
  input      [31:0] mem_read_data,
  input      [4:0]  mem_rd,

  output reg        wb_reg_write,
  output reg        wb_mem_to_reg,
  output reg [31:0] wb_alu_result,
  output reg [31:0] wb_read_data,
  output reg [4:0]  wb_rd
);

  always @(posedge clk) begin
    if (reset) begin
      wb_reg_write  <= 1'b0;
      wb_mem_to_reg <= 1'b0;
      wb_alu_result <= 32'b0;
      wb_read_data  <= 32'b0;
      wb_rd         <= 5'b0;
    end else if (enable) begin
      wb_reg_write  <= mem_reg_write;
      wb_mem_to_reg <= mem_mem_to_reg;
      wb_alu_result <= mem_alu_result;
      wb_read_data  <= mem_read_data;
      wb_rd         <= mem_rd;
    end
  end
endmodule
