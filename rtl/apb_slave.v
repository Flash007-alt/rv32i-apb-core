// ============================================================================
// MODULE: APB Memory Slave (With Wait States)
// ============================================================================

module apb_slave_memory(
  input             clk,
  input             reset,
  input             psel,
  input             penable,
  input             pwrite,
  input      [31:0] paddr,
  input      [31:0] pwdata,
  output reg [31:0] prdata,
  output            pready
);

  reg [31:0] memory_array [0:255];
  reg delay_cycle;

  // Generate a 1-cycle wait state on every access
  always @(posedge clk) begin
    if (reset) begin
      delay_cycle <= 1'b0;
    end else if (psel && !penable) begin
      delay_cycle <= 1'b0; // Setup phase: enforce wait next cycle
    end else if (psel && penable) begin
      delay_cycle <= 1'b1; // Access phase: grant ready after 1 cycle
    end else begin
      delay_cycle <= 1'b0;
    end
  end

  // PREADY is only high on the second cycle of the ACCESS phase
  assign pready = (psel && penable) ? delay_cycle : 1'b0;

  always @(posedge clk) begin
    if (psel && penable && pready && pwrite) begin
      memory_array[paddr[9:2]] <= pwdata;
    end
    if (psel && !penable && !pwrite) begin
      prdata <= memory_array[paddr[9:2]];
    end
  end

endmodule
