// ============================================================================
// MODULE: CPU Top Level (cpu_top)
// PURPOSE: Connects all datapath components to form the Single-Cycle RV32I CPU.
// ============================================================================

module cpu_top(
  input  clk,
  input  reset,
  
  // --- TEMPORARY OUTPUTS (For Testbench Verification) ---
  output [31:0] pc_current,
  output [31:0] instruction,
  output [3:0]  alu_sel,
  output        reg_write
);
  
  // ==========================================================================
  // INTERNAL WIRES (Grouped by Datapath Stage)
  // ==========================================================================

  // --- 1. INSTRUCTION FETCH WIRES ---
  wire [31:0] pc_next;
  wire [31:0] next_pc_in;
  
  // --- 2. DECODE & CONTROL WIRES ---
  wire        alu_src;
  wire        branch;
  wire        mem_read;
  wire        mem_write;
  wire        mem_to_reg;
  wire [31:0] imm_out;
  wire [31:0] id_pc;
  wire [31:0] id_instruction;  

  // --- 3. REGISTER FILE WIRES ---
  wire [31:0] rs1_data;
  wire [31:0] rs2_data;
  wire [31:0] write_data;
  
  // --- 4. EXECUTE (ALU) WIRES ---
  wire [31:0] alu_b_in;
  wire [31:0] alu_result;
  wire        zero;
  wire [31:0] branch_target;
  wire        pc_src;
  
  wire [3:0] ex_alu_sel;
  wire ex_reg_write;
  wire ex_branch;
  wire ex_alu_src;
  wire ex_mem_read;
  wire ex_mem_write;
  wire ex_mem_to_reg;
  wire [31:0] ex_pc;
  wire [31:0] ex_rs1_data;
  wire [31:0] ex_rs2_data;
  wire [31:0] ex_imm_out;
  wire [4:0] ex_rs1;
  wire [4:0] ex_rs2;
  wire [4:0] ex_rd;
  
  // --- 5. MEMORY WIRES ---
  wire        mem_reg_write;
  wire        mem_mem_to_reg;
  wire        mem_mem_read;
  wire        mem_mem_write;
  
  wire [31:0] mem_alu_result;
  wire [31:0] mem_rs2_data;
  wire [4:0]  mem_rd;

  // --- 6. WRITE-BACK WIRES ---
  wire        wb_reg_write;
  wire        wb_mem_to_reg;
  wire [31:0] wb_alu_result;
  wire [31:0] wb_read_data;
  wire [4:0]  wb_rd;

  // --- FORWARDING WIRES ---
  wire [1:0]  forward_a;
  wire [1:0]  forward_b;
  wire [31:0] alu_a_in;
  wire [31:0] alu_b_fwd;


  // --- HAZARD & STALL WIRES ---
  wire hazard_pc_write;
  wire hazard_if_id_write;
  wire hazard_ctrl_mux_sel;
  wire pc_write;
  wire if_id_write;
  wire ctrl_mux_sel;

  // --- DECODER MULTIPLEXED WIRES (For Bubbles) ---
  wire [3:0] id_alu_sel;
  wire       id_reg_write;
  wire       id_branch;
  wire       id_alu_src;
  wire       id_mem_read;
  wire       id_mem_write;
  wire       id_mem_to_reg;

  // --- APB BUS WIRES ---
  wire        apb_transfer_req;
  wire        apb_pready;
  wire        apb_psel;
  wire        apb_penable;
  wire        apb_pwrite;
  wire [31:0] apb_paddr;
  wire [31:0] apb_pwdata;
  wire [31:0] apb_prdata;
  wire        apb_stall;


  // ==========================================================================
  // HARDWARE MULTIPLEXERS & COMBINATIONAL LOGIC
  // ==========================================================================

  // APB Stall Logic Integration
  assign pc_write     = hazard_pc_write & (~apb_stall);
  assign if_id_write  = hazard_if_id_write & (~apb_stall);
  assign ctrl_mux_sel = hazard_ctrl_mux_sel & (~apb_stall);

  // APB Bus Driver Assignments
  assign apb_paddr  = mem_alu_result;
  assign apb_pwdata = mem_rs2_data;
  assign apb_pwrite = mem_mem_write;

  // Branch Target Adder
  assign branch_target = ex_pc + ex_imm_out; 
  
  // Branch Decision AND Gate
  assign pc_src = ex_branch & zero;
  
  // PC Next Multiplexer
  assign next_pc_in = pc_src ? branch_target : pc_next;
  
  // Forward A Multiplexer
  assign alu_a_in = (forward_a == 2'b10) ? mem_alu_result :
                    (forward_a == 2'b01) ? write_data :
                    ex_rs1_data;

  // Forward B Multiplexer
  assign alu_b_fwd = (forward_b == 2'b10) ? mem_alu_result :
                     (forward_b == 2'b01) ? write_data :
                     ex_rs2_data;

  // ALU Source Multiplexer
  assign alu_b_in = (ex_alu_src == 1'b1) ? ex_imm_out : alu_b_fwd;

  // Register Write-Back Multiplexer
  assign write_data = wb_mem_to_reg ? wb_read_data : wb_alu_result;

  // Control Signal Bubble Mux
  assign id_alu_sel    = ctrl_mux_sel ? alu_sel    : 4'b0000;
  assign id_reg_write  = ctrl_mux_sel ? reg_write  : 1'b0;
  assign id_branch     = ctrl_mux_sel ? branch     : 1'b0;
  assign id_alu_src    = ctrl_mux_sel ? alu_src    : 1'b0;
  assign id_mem_read   = ctrl_mux_sel ? mem_read   : 1'b0;
  assign id_mem_write  = ctrl_mux_sel ? mem_write  : 1'b0;
  assign id_mem_to_reg = ctrl_mux_sel ? mem_to_reg : 1'b0;


  // ==========================================================================
  // SUB-MODULE INSTANTIATIONS
  // ==========================================================================

  pc pc_inst(
    .clk(clk), 
    .reset(reset),
    .pc_write(pc_write),
    .next_pc(next_pc_in),
    .pc_out(pc_current)
  );
  
  pc_adder pc_adder_inst(
    .pc_current(pc_current),
    .pc_next(pc_next)
  );
  
  instruction_memory instruction_memory_inst(
    .address(pc_current),
    .instruction(instruction)
  );

  if_id_reg if_id_reg_inst(
     .clk(clk),
     .reset(reset),
     .flush(pc_src),
     .enable(if_id_write),
     .if_pc(pc_current),
     .if_instruction(instruction),
     .id_pc(id_pc),
     .id_instruction(id_instruction)
  );

  decoder decoder_inst(
    .instruction(id_instruction),
    .alu_sel(alu_sel),
    .reg_write(reg_write),
    .alu_src(alu_src),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .mem_to_reg(mem_to_reg),
    .branch(branch)
  );

  regfile regfile_inst(
    .clk(clk),
    .reset(reset),
    .rs1(id_instruction[19:15]),
    .rs2(id_instruction[24:20]),
    .rd(wb_rd),
    .write_data(write_data),
    .reg_write(wb_reg_write),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
  );
  
  imm_gen imm_gen_inst(
    .instruction(id_instruction),
    .immediate(imm_out)
  );

  id_ex_reg id_ex_reg_inst(
    .clk(clk),
    .reset(reset),
    .flush(pc_src),
    .enable(~apb_stall),
    .id_alu_sel(id_alu_sel),
    .id_reg_write(id_reg_write),
    .id_branch(id_branch),
    .id_alu_src(id_alu_src),
    .id_mem_read(id_mem_read),
    .id_mem_write(id_mem_write),
    .id_mem_to_reg(id_mem_to_reg),
    .id_pc(id_pc),
    .id_rs1_data(rs1_data),
    .id_rs2_data(rs2_data),
    .id_imm_out(imm_out),
    .id_rs1(id_instruction[19:15]),
    .id_rs2(id_instruction[24:20]),
    .id_rd(id_instruction[11:7]),

    .ex_alu_sel(ex_alu_sel),
    .ex_reg_write(ex_reg_write),
    .ex_branch(ex_branch),
    .ex_alu_src(ex_alu_src),
    .ex_mem_read(ex_mem_read),
    .ex_mem_write(ex_mem_write),
    .ex_mem_to_reg(ex_mem_to_reg),
    .ex_pc(ex_pc),
    .ex_rs1_data(ex_rs1_data),
    .ex_rs2_data(ex_rs2_data),
    .ex_imm_out(ex_imm_out),
    .ex_rs1(ex_rs1),
    .ex_rs2(ex_rs2),
    .ex_rd(ex_rd)
  );

  alu alu_inst(
    .a(alu_a_in),
    .b(alu_b_in),
    .alu_sel(ex_alu_sel),
    .result(alu_result),
    .zero(zero)
  );

  ex_mem_reg ex_mem_reg_inst(
    .clk(clk),
    .reset(reset),
    .enable(~apb_stall),

    .ex_reg_write(ex_reg_write),
    .ex_mem_to_reg(ex_mem_to_reg),
    .ex_mem_read(ex_mem_read),
    .ex_mem_write(ex_mem_write),
    
    .ex_alu_result(alu_result),
    .ex_rs2_data(alu_b_fwd),
    .ex_rd(ex_rd),

    .mem_reg_write(mem_reg_write),
    .mem_mem_to_reg(mem_mem_to_reg),
    .mem_mem_read(mem_mem_read),
    .mem_mem_write(mem_mem_write),
    
    .mem_alu_result(mem_alu_result),
    .mem_rs2_data(mem_rs2_data),
    .mem_rd(mem_rd)
  );

  mem_wb_reg mem_wb_reg_inst(
    .clk(clk),
    .reset(reset),
    .enable(~apb_stall),

    .mem_reg_write(mem_reg_write),
    .mem_mem_to_reg(mem_mem_to_reg),
    .mem_alu_result(mem_alu_result),
    .mem_read_data(apb_prdata), // <--- CONNECTED TO APB SLAVE
    .mem_rd(mem_rd),

    .wb_reg_write(wb_reg_write),
    .wb_mem_to_reg(wb_mem_to_reg),
    .wb_alu_result(wb_alu_result),
    .wb_read_data(wb_read_data),
    .wb_rd(wb_rd)
  );

  forwarding_unit fwd_unit_inst(
    .id_ex_rs1(ex_rs1),
    .id_ex_rs2(ex_rs2),
    .ex_mem_rd(mem_rd),
    .ex_mem_reg_write(mem_reg_write),
    .mem_wb_rd(wb_rd),
    .mem_wb_reg_write(wb_reg_write),
    .forward_a(forward_a),
    .forward_b(forward_b)
  );

  hazard_detection_unit hazard_unit_inst(
    .id_ex_mem_read(ex_mem_read),
    .id_ex_rd(ex_rd),
    .if_id_rs1(id_instruction[19:15]),
    .if_id_rs2(id_instruction[24:20]),
    .pc_write(hazard_pc_write),
    .if_id_write(hazard_if_id_write),
    .ctrl_mux_sel(hazard_ctrl_mux_sel)
  );

  // ==========================================
  // APB MASTER INSTANTIATION (MEM STAGE)
  // ==========================================
  apb_master apb_master_inst (
    .clk(clk),
    .reset(reset),
    .transfer_req(mem_mem_write | mem_mem_read),
    .pready(apb_pready),
    .psel(apb_psel),
    .penable(apb_penable),
    .stall(apb_stall)
  );

  // ==========================================
  // APB SLAVE MEMORY INSTANTIATION (MEM STAGE)
  // ==========================================
  apb_slave_memory apb_slave_mem_inst (
    .clk(clk),
    .reset(reset),
    .psel(apb_psel),
    .penable(apb_penable),
    .pwrite(apb_pwrite),   // Updated
    .paddr(apb_paddr),     // Updated
    .pwdata(apb_pwdata),   // Updated
    .prdata(apb_prdata),
    .pready(apb_pready)
  );

endmodule
