// ============================================================================
// MODULE: Instruction Memory
// PURPOSE: Acts as the Read-Only Memory (ROM) that holds the compiled program.
// ============================================================================

module instruction_memory(
  // --- INPUTS ---
  input      [31:0] address,      // Address from the Program Counter (PC)
  
  // --- OUTPUTS ---
  output     [31:0] instruction   // The 32-bit instruction fetched from memory
);
  
  // --- MEMORY ARRAY ---
  // 256 locations and each holds 32 bits [1 instruction]. So 256 x 32 = 8192 bits
  reg [31:0] memory [0:255]; 
  
  // ==========================================================================
  // ADDRESS MAPPING LOGIC
  // Address is 32 bits which is 4 bytes, so PC address is multiples of 4.
  // i.e. PC address 0 ---> instruction 0
  //      PC address 4 ---> instruction 1
  //      PC address 8 ---> instruction 2
  //
  // So address/4 gives the instruction index.
  // Hence right shift the address by 2 which means address/4.
  // Removing the lower 2 bits mimics the 2 right shifts, and the lower 2 
  // bits carry no useful info since instructions are word-aligned.
  // ==========================================================================
  assign instruction = memory[address[31:2]];

  // ==========================================================================
  // MEMORY INITIALIZATION
  // ==========================================================================
  initial begin
    // Before we hardcoded the instructions, but now we place the hex machine 
    // instructions in program.mem and load them dynamically here.
    $readmemh(program.mem", memory); 
  end
  
endmodule
