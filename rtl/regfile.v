// ============================================================================
// MODULE: Register File
// PURPOSE: 32x32-bit memory array for the CPU's general-purpose registers.
//          Features dual asynchronous read ports and a single synchronous write port.
// ============================================================================

module regfile(
  // --- INPUTS ---
  input             clk,
  input             reset,
  input             reg_write,  // Write enable control signal
  
  // 2^5 = 32, so 5 bits are needed to address 32 registers
  input      [4:0]  rs1,        // Source register 1 address
  input      [4:0]  rs2,        // Source register 2 address
  input      [4:0]  rd,         // Destination register address to write
  input      [31:0] write_data, // Data to be written to the destination register
  
  // --- OUTPUTS ---
  output     [31:0] rs1_data,   // Data read from source register 1
  output     [31:0] rs2_data,   // Data read from source register 2
  
  output     [31:0] debug_x3    // For debugging only
);
  
  // --- REGISTER ARRAY ---
  reg [31:0] registers [0:31]; 

  // ==========================================================================
  // INITIALIZATION
  // Initialize all 32 registers to 0 so the CPU starts in a known state 
  // (prevents 'x' state propagation). This also satisfies the RISC-V 
  // requirement that x0 boots up as 0.
  // ==========================================================================
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1) begin
      registers[i] = 32'b0;
    end
  end

  // ==========================================================================
  // ASYNCHRONOUS READ LOGIC
  // Register data is continuously available combinationally based on the 
  // requested address.
  // ==========================================================================
// Internal Bypassing: If reading and writing the same register on the same cycle, 
  // forward the incoming write_data directly to the output.
  assign rs1_data = (reg_write && (rd == rs1) && (rs1 != 5'b0)) ? write_data : registers[rs1];
  assign rs2_data = (reg_write && (rd == rs2) && (rs2 != 5'b0)) ? write_data : registers[rs2];
  
  // Debugging only
  assign debug_x3 = registers[3];
  
  // ==========================================================================
  // SYNCHRONOUS WRITE LOGIC
  // Write operations only happen on the clock edge when enabled.
  // ==========================================================================
  always @(posedge clk) begin
    // RISC-V rule: The x0 register address should only allow reading. 
    // No writing is supported (x0 is hardwired to 0).
    if (reg_write && rd != 5'd0) begin
      registers[rd] <= write_data; 
    end
  end
  
endmodule