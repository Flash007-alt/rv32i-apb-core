// ============================================================================
// MODULE: Instruction Decoder
// PURPOSE: Parses the 32-bit RISC-V instruction and generates all control 
//          signals for the datapath multiplexers, ALU, and memory.
// ============================================================================

// ----------------------------------------------------------------------------
// REFERENCE NOTES:
// 
// RV32I R-TYPE FORMAT
// [6:0] OPCODE | [11:7] RD | [14:12] FUNCT3 | [19:15] RS1 | [24:20] RS2 | [31:25] FUNCT7
//
// INSTRUCTION          FUNCT3          FUNCT7          ALU_SEL
// ADD                  000             0000000         0000
// SUB                  000             0100000         0001
// AND                  111             0000000         0010
// OR                   110             0000000         0011
// EXOR                 100             0000000         0100
//
// RV32I I-TYPE FORMAT
// [6:0] OPCODE | [11:7] RD | [14:12] FUNCT3 | [19:15] RS1 | [31:20] IMMEDIATE
// ----------------------------------------------------------------------------

module decoder(
  // --- INPUTS ---
  input      [31:0] instruction,
  
  // --- CONTROL SIGNAL OUTPUTS ---
  output reg [3:0]  alu_sel,    // alu_sel codes used in alu design code
  output reg        reg_write,  // controls whether register file writes result (1 = write ALU/Mem result to RD)
  output reg        branch,     // controls branch decision logic
  output reg        alu_src,    // alu_src=0 --> B = rs2 | alu_src=1 --> immediate
  output reg        mem_read,   // controls data memory read enable
  output reg        mem_write,  // controls data memory write enable
  output reg        mem_to_reg, // controls write-back multiplexer
  
  // --- ADDRESS OUTPUTS ---
  output     [4:0]  rs1_addr,
  output     [4:0]  rs2_addr,
  output     [4:0]  rd_addr
);
  
  // ==========================================================================
  // INSTRUCTION SPLITTING
  // Decoder must split the 32-bit instruction into its structural pieces
  // ==========================================================================
  wire [6:0] opcode;
  wire [2:0] funct3;
  wire [6:0] funct7;
  
  assign opcode   = instruction[6:0];
  assign rd_addr  = instruction[11:7];
  assign funct3   = instruction[14:12];
  assign rs1_addr = instruction[19:15];
  assign rs2_addr = instruction[24:20];
  assign funct7   = instruction[31:25];

  // ==========================================================================
  // CONTROL LOGIC GENERATION
  // ==========================================================================
  always @(*) begin
    
    // 1. DEFAULT INITIALIZATION (Prevents inferred latches)
    alu_sel    = 4'b0000;
    reg_write  = 1'b0;
    branch     = 1'b0;
    alu_src    = 1'b0;
    mem_read   = 1'b0;
    mem_write  = 1'b0;
    mem_to_reg = 1'b0;
      
    // 2. R-TYPE INSTRUCTIONS (opcode is always 0110011)
    if(opcode == 7'b0110011) begin 
      reg_write = 1'b1; // R-type instruction always should write back the result to register file
          
      if     (funct3 == 3'b000 && funct7 == 7'b0000000) alu_sel = 4'b0000; // ADD
      else if(funct3 == 3'b000 && funct7 == 7'b0100000) alu_sel = 4'b0001; // SUB
      else if(funct3 == 3'b111 && funct7 == 7'b0000000) alu_sel = 4'b0010; // AND
      else if(funct3 == 3'b110 && funct7 == 7'b0000000) alu_sel = 4'b0011; // OR
      else if(funct3 == 3'b100 && funct7 == 7'b0000000) alu_sel = 4'b0100; // XOR
    end
      
    // 3. B-TYPE INSTRUCTIONS (BEQ OPCODE)
    if(opcode == 7'b1100011) begin
      branch  = 1'b1;
      alu_sel = 4'b0001; // Use subtraction to compare equality
    end
      
    // 4. I-TYPE INSTRUCTIONS (ADDI LOGIC)
    if(opcode == 7'b0010011) begin
      reg_write = 1'b1;
      alu_sel   = 4'b0000; // ADD
      alu_src   = 1'b1;    // Route immediate into ALU
    end

    // 5. I-TYPE INSTRUCTIONS (LOAD WORD OPCODE)   
    if(opcode == 7'b0000011) begin
      reg_write  = 1'b1;
      mem_read   = 1'b1;
      mem_write  = 1'b0;
      alu_src    = 1'b1;   // Route immediate into ALU for address calculation
      mem_to_reg = 1'b1;   // Route memory data to Register File
    end
  
    // 6. S-TYPE INSTRUCTIONS (STORE WORD OPCODE)
    if(opcode == 7'b0100011) begin
      mem_read  = 1'b0;
      mem_write = 1'b1;
      alu_src   = 1'b1;    // Route immediate into ALU for address calculation
    end    
      
  end
  
endmodule
