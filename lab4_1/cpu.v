// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify modules (except InstMemory, DataMemory, and RegisterFile)
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted, // Whehther to finish simulation
           output [31:0]print_reg[0:31]); // Whehther to finish simulation
  /***** Wire declarations *****/
  /***** Register declarations *****/
  // You need to modify the width of registers
  // In addition, 
  // 1. You might need other pipeline registers that are not described below
  // 2. You might not need registers described below
  /***** IF/ID pipeline registers *****/
  reg IF_ID_inst;           // will be used in ID stage
  /***** ID/EX pipeline registers *****/
  // From the control unit
  reg ID_EX_alu_op;         // will be used in EX stage
  reg ID_EX_alu_src;        // will be used in EX stage
  reg ID_EX_mem_write;      // will be used in MEM stage
  reg ID_EX_mem_read;       // will be used in MEM stage
  reg ID_EX_mem_to_reg;     // will be used in WB stage
  reg ID_EX_reg_write;      // will be used in WB stage
  // From others
  reg ID_EX_rs1_data;
  reg ID_EX_rs2_data;
  reg ID_EX_imm;
  reg ID_EX_ALU_ctrl_unit_input;
  reg ID_EX_rd;

  /***** EX/MEM pipeline registers *****/
  // From the control unit
  reg EX_MEM_mem_write;     // will be used in MEM stage
  reg EX_MEM_mem_read;      // will be used in MEM stage
  reg EX_MEM_is_branch;     // will be used in MEM stage
  reg EX_MEM_mem_to_reg;    // will be used in WB stage
  reg EX_MEM_reg_write;     // will be used in WB stage
  // From others
  reg EX_MEM_alu_out;
  reg EX_MEM_dmem_data;
  reg EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  // From others
  reg MEM_WB_mem_to_reg_src_1;
  reg MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd; // 만듦

  /***** forwordings *****/
  reg forward_a;
  reg forward_b;



  /***** wire *****/
  
  wire [4:0] WB_rd;
  wire [31:0] alu_in1;
  wire [31:0] alu_in2;
  wire [31:0] alu_result;
  wire alu_zero;
  wire [31:0] dmem_dout;
  wire [31:0] wb_out;
  
  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire write_enable;
  wire pc_to_reg;
  wire alu_op;
  wire is_ecall;
  wire ctrl_unit_input;
  wire is_halted;
  wire [31:0] ecall_data;

  assign if_id_rs1 = IF_ID_inst[19:15];
  assign register_rs2 = IF_ID_inst[24:20];
  assign rd = IF_ID_inst[11:7];
  assign ctrl_unit_input = {IF_ID_inst[30], IF_ID_inst[14:12], IF_ID_inst[6:0]};
  assign is_halted = is_ecall && ecall_data == 10;

  //if
  wire [31:0] next_pc;
  wire [31:0] current_pc;
  wire [31:0] instruction;

  //id
  wire [4:0] if_id_rs1;
  wire [4:0] register_rs1;
  wire [4:0] register_rs2;
  wire WB_rd;





  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );

  adder adder(
    .add_input1(current_pc),  // input
    .add_input2(4),  // input
    .add_output(next_pc) // output
  )
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(instruction)     // output
  );

  // Update IF/ID pipeline registers here
  always @(posedge clk) begin
    if (reset) begin //??
      IF_ID_inst <= 0;
    end
    else begin
        IF_ID_inst <= instruction;
    end
  end

  //-----------ID-------------
  //--------------------------
  // ecall mux
  mux is_ecall(
    .s(is_ecall),      // input
    .in1(17),    // input
    .in0(if_id_rs1),    // input
    .out(register_rs1)     // output
  );

  HazardDetectionUnit HazardDetectionUnit(
    .rs1(register_rs1),
    .rs2 (register_rs2),          // input
    .rd(WB_rd),
    .is_rs1_used(),
    .is_rs2_used(),
    .mem_read(),
    .is_ecall(is_ecall),
    .pc_write(),
    .IF_ID_write(),
    .is_hazard(is_hazard)
  )

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (register_rs1),          // input
    .rs2 (register_rs2),          // input
    .rd (WB_rd),           // input
    .rd_din (WB_rd_din),       // input
    .write_enable (MEM_WB_reg_write),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout),      // output
    .print_reg(print_reg)
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(IF_ID_inst),  // input
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),  // output
    .pc_to_reg(pc_to_reg),     // output
    .alu_op(alu_op),        // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IF_ID_inst),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // Update ID/EX pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      ID_EX_rs1_data <= 0;
      ID_EX_rs2_data <= 0;
      ID_EX_ALU_ctrl_unit_input <= 0;
      ID_EX_imm <= 0;
      ID_EX_rs1 <= 0;
      ID_EX_rs2 <= 0;
      ID_EX_rd <= 0;
      ID_EX_mem_read <= 0;
      ID_EX_mem_to_reg <= 0;
      ID_EX_mem_write <= 0;
      ID_EX_reg_write <= 0;
      ID_EX_alu_src <= 0;
      ID_EX_is_halted <= 0;
      ID_EX_alu_op <= 0;
    end
    else begin
      ID_EX_rs1_data <= rs1_dout;
      ID_EX_rs2_data <= rs2_dout;
      ID_EX_ALU_ctrl_unit_input <= ctrl_unit_input;
      ID_EX_imm <= imm_gen_out;
      ID_EX_rs1 <= register_rs1;
      ID_EX_rs2 <= register_rs2;
      ID_EX_rd <= rd;
      ID_EX_mem_read <= mem_read;
      ID_EX_mem_to_reg <= mem_to_reg;
      ID_EX_mem_write <= hazard_mem_write;
      ID_EX_reg_write <= hazard_reg_write;
      ID_EX_alu_src <= alu_src;
      ID_EX_is_halted <= is_halted;
      ID_EX_alu_op <= alu_op;
    end
  end

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(),  // input
    .alu_op()         // output
  );

  // 
  mux4 A_mux(
    .s(forward_a),
    .in0(MEM_alu_out),
    .in1(WB_rd_din),
    .in2(ID_EX_rs1_data),
    .in3(0),
    .out(alu_in1)
  );
  mux4 B_mux(
    .s(forward_b),
    .in0(MEM_alu_out),
    .in1(WB_rd_din),
    .in2(ID_EX_rs2_data),
    .in3(0),
    .out(alu_in2)
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(ID_EX_alu_op),      // input
    .alu_in_1(alu_in1),    // input  
    .alu_in_2(alu_in2),    // input
    .alu_result(alu_result),  // output
    .alu_zero(alu_zero)     // output
  );

  //---------- ALU MUX----------
  mux is_alusrc(
    .s(ID_EX_alu_src),      // input
    .in1(ID_EX_imm),    // input
    .in0(ID_EX_rs2_data),    // input
    .out(alu_in2)     // output
  );

  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      EX_MEM_mem_write <= 0;
      EX_MEM_mem_read <= 0;
      EX_MEM_mem_to_reg <= 0;
      EX_MEM_reg_write <= 0;  
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 0;
      EX_MEM_is_halted <= 0;
    end
    else begin

    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (EX_MEM_alu_out),       // input
    .din (EX_MEM_dmem_data),        // input
    .mem_read (EX_MEM_mem_read),   // input
    .mem_write (EX_MEM_mem_write),  // input
    .dout (dmem_dout)        // output
  );

  //---------- Mem Mux ----------
  mux is_alu(
    .s(MEM_WB_mem_to_reg),      // input
    .in1(MEM_WB_mem_to_reg_src_1),    // dmem input 
    .in0(MEM_WB_mem_to_reg_src_2),    // alu input
    .out(MEM_WB_rd)     // output
  );

  // ---------- Forwarding ----------
  data_forwarding d_forwarding(
    .ID_EX_rs1(ID_EX_rs1_data),
    .ID_EX_rs2(ID_EX_rs2_data),
    .EX_MEM_rd(EX_MEM_rd),
    .EX_MEM_reg_write(EX_MEM_reg_write),
    .MEM_WB_rd(MEM_WB_rd),
    .MEM_WB_reg_write(MEM_WB_reg_write),
    .forward_a(forward_a),
    .forward_b(forward_b)
  );

  ecall_forwarding e_forwarding(
    .ID_EX_rs1(ID_EX_rs1_data),
    .EX_MEM_rd(EX_MEM_rd),
    .EX_MEM_reg_write(EX_MEM_reg_write),
    .MEM_WB_rd(MEM_WB_rd),
    .MEM_WB_reg_write(MEM_WB_reg_write)
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
    end
    else begin
    end
  end



  
endmodule
