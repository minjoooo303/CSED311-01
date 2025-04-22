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

  wire is_ecall;

  // IF
  wire [31:0] current_pc;
  wire [31:0] next_pc;
  wire [31:0] instruction;
  wire pc_write;

  // ID
  wire [4:0] rs1_IF_ID;
  wire [4:0] register_rs1;
  wire [4:0] register_rs2;
  wire reg_write;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;

  assign register_rs1 = IF_ID_inst[19:15];
  assign register_rs2 = IF_ID_inst[24:20];

  wire is_hazard;
  wire is_rs1_used;
  wire is_rs2_used;
  wire write_IF_ID;

  wire [6:0] ctrl_inst; // Control Unit의 input, 즉 opcodes
  assign ctrl_inst = IF_ID_inst[6:0];

  wire mem_read_ID;
  wire mem_to_reg_ID;
  wire mem_write_ID;
  wire alu_src_ID;
  wire reg_write_ID;
  wire pc_to_reg_ID;
  wire [1:0] alu_op_ID;
  wire [10:0] ALUctrl_input_ID;
  wire [4:0] rd_ID;
  wire is_halted_ID;
  assign ALUctrl_input_ID = {IF_ID_inst[30], IF_ID_inst[14:12], IF_ID_inst[6:0]};
  assign rd_ID = IF_ID_inst[11:7];
  assign is_halted_ID = is_ecall && (ecall_data == 10);

  wire [31:0] inst_IF_ID; // Immediate Generator input
  assign inst_IF_ID = IF_ID_inst;
  wire [31:0] immgenout_ID; // Immediate Generator output

  wire forward_ecall;
  wire [31:0] ecall_data;

  // EX
  wire is_halted_EX;
  assign is_halted_EX = ID_EX_is_halted;

  wire [4:0] rs1_EX;
  wire [4:0] rs2_EX;
  wire [4:0] rd_EX;
  assign rs1_EX = ID_EX_rs1;
  assign rs2_EX = ID_EX_rs2; 
  assign rd_EX = ID_EX_rd;

  wire [31:0] rs1_dout_EX;
  wire [31:0] rs2_dout_EX;
  assign rs1_dout_EX = ID_EX_rs1_data;
  assign rs2_dout_EX = ID_EX_rs2_data;

  wire [10:0] ALUctrl_input_EX;
  wire [1:0] alu_op_EX;
  wire [3:0] ALUctrl_output; // ALU Control Unit output
  wire [31:0] immgenout_EX;
  assign ALUctrl_input_EX = ID_EX_ALU_ctrl_unit_input;
  assign alu_op_EX = ID_EX_alu_op;
  assign immgenout_EX = ID_EX_imm;

  wire [31:0] alu_out_EX;
  wire alu_zero;

  wire mem_read_EX; // Hazard Detection Unit input (ID/EX.MemRead)
  wire mem_to_reg_EX;
  wire mem_write_EX;
  wire reg_write_EX;
  assign mem_read_EX = ID_EX_mem_read;
  assign mem_to_reg_EX = ID_EX_mem_to_reg;
  assign mem_write_EX = ID_EX_mem_write;
  assign reg_write_EX = ID_EX_reg_write;

  wire forward_a;
  wire forward_b;
  wire [31:0] forwardA_mux_out;
  wire [31:0] forwardB_mux_out;
  wire alu_src;
  assign alu_src = ID_EX_alu_src;
  // wire [31:0] alu_in_1;
  wire [31:0] alu_in_2;

  // MEM
  wire is_halted_MEM;
  wire [4:0] rd_MEM;
  wire [31:0] alu_out_MEM;
  wire [31:0] dmem_data_MEM; // forwardB_mux_out

  wire mem_read_MEM;
  wire mem_write_MEM;
  wire [31:0] datamem_out;

  wire mem_to_reg_MEM;
  wire reg_write_MEM;

  assign is_halted_MEM = EX_MEM_is_halted;
  assign rd_MEM = EX_MEM_rd;
  assign alu_out_MEM = EX_MEM_alu_out;
  assign dmem_data_MEM = EX_MEM_dmem_data;
  assign mem_read_MEM = EX_MEM_mem_read;
  assign mem_write_MEM = EX_MEM_mem_write;
  assign mem_to_reg_MEM = EX_MEM_mem_to_reg;
  assign reg_write_MEM = EX_MEM_reg_write;


  // WB
  wire [4:0] rd_WB; // Write register
  wire [31:0] rd_din_WB; // Write data
  wire reg_write_WB;

  wire mem_to_reg_WB;
  wire [31:0] mem_to_reg_src_1_WB;
  wire [31:0] mem_to_reg_src_2_WB;

  assign rd_WB = MEM_WB_rd;
  assign reg_write_WB = MEM_WB_reg_write;
  assign mem_to_reg_WB = MEM_WB_mem_to_reg;
  assign mem_to_reg_src_1_WB = MEM_WB_mem_to_reg_src_1; // MemtoReg==0일 때 선택됨
  assign mem_to_reg_src_2_WB = MEM_WB_mem_to_reg_src_2; // MemtoReg==1일 때 선택됨

  // output of cpu
  assign is_halted = MEM_WB_is_halted;

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
  reg EX_MEM_is_halted;     // 추가
  // From others
  reg EX_MEM_alu_out;
  reg EX_MEM_dmem_data;
  reg EX_MEM_rd;

  /***** MEM/WB pipeline registers *****/
  // From the control unit
  reg MEM_WB_mem_to_reg;    // will be used in WB stage
  reg MEM_WB_reg_write;     // will be used in WB stage
  reg MEM_WB_is_halted;     // 추가
  // From others
  reg MEM_WB_mem_to_reg_src_1;
  reg MEM_WB_mem_to_reg_src_2;
  reg [4:0] MEM_WB_rd; // 추가



  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );

  adder pc_adder(
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
    if (reset) begin
      IF_ID_inst <= 0;
    end
    else begin
      IF_ID_inst <= instruction;
    end
  end

  //-----------ID-------------
  //--------------------------
  // ecall mux
  muxFiveBits is_ecall(
    .s(is_ecall),      // input
    .in0(rs1_IF_ID),    // input
    .in1(17),    // input
    .out(register_rs1)     // output
  );

  HazardDetectionUnit HazardDetectionUnit(
    .rs1(register_rs1),
    .rs2(register_rs2),          // input
    .rd(rd_EX),
    .is_rs1_used(is_rs1_used),
    .is_rs2_used(is_rs2_used),
    .mem_read(mem_read_EX),
    .is_ecall(is_ecall),
    .pc_write(pc_write),
    .IF_ID_write(write_IF_ID),
    .is_hazard(is_hazard)
  )

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(register_rs1),          // input
    .rs2(register_rs2),          // input
    .rd(rd_WB),           // input
    .rd_din(rd_din_WB),       // input
    .write_enable(reg_write),    // input
    .rs1_dout(rs1_dout),     // output
    .rs2_dout(rs2_dout),      // output
    .print_reg(print_reg)
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(ctrl_inst),  // input
    .is_hazard(is_hazard),     // 추가 input
    .mem_read(mem_read_ID),      // output
    .mem_to_reg(mem_to_reg_ID),    // output
    .mem_write(mem_write_ID),     // output
    .alu_src(alu_src_ID),       // output
    .write_enable(reg_write_ID),  // output
    .pc_to_reg(pc_to_reg_ID),     // output
    .alu_op(alu_op_ID),        // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );


  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(inst_IF_ID),  // input
    .imm_gen_out(immgenout_ID)    // output
  );


  ecall_forwarding ecall_forwarding(
    .ID_EX_rs1(17), 
    .EX_MEM_rd(rd_MEM),
    .EX_MEM_reg_write(reg_write_MEM),
    .MEM_WB_rd(rd_WB),
    .MEM_WB_reg_write(reg_write_WB),
    .forward_ecall(forward_ecall)
  );

  mux4 ecall_forward_mux(
    .s(forward_ecall),
    .in0(rs1_dout),
    .in1(alu_out_MEM),
    .in2(rd_din_WB),
    .in3(0),
    .out(ecall_data)
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
      ID_EX_ALU_ctrl_unit_input <= ALUctrl_input_ID;
      ID_EX_imm <= immgenout_ID;
      ID_EX_rs1 <= register_rs1;
      ID_EX_rs2 <= register_rs2;
      ID_EX_rd <= rd_ID;
      ID_EX_mem_read <= mem_read_ID;
      ID_EX_mem_to_reg <= mem_to_reg_ID;
      ID_EX_mem_write <= mem_write_ID;
      ID_EX_reg_write <= reg_write_ID;
      ID_EX_alu_src <= alu_src_ID;
      ID_EX_is_halted <= is_halted_ID;
      ID_EX_alu_op <= alu_op_ID;
    end
  end


  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(ALUctrl_input_EX),  // input
    .ALUOp(alu_op_EX)       // input
    .alu_op(ALUctrl_output)         // output
  );

  data_forwarding data_forward(
    .ID_EX_rs1(rs1_EX), 
    .ID_EX_rs2(rs2_EX),
    .EX_MEM_rd(rd_MEM),
    .EX_MEM_reg_write(reg_write_MEM),
    .MEM_WB_rd(rd_WB),
    .MEM_WB_reg_write(reg_write_WB),
    .forward_a(forward_a),       // output
    .forward_b(forward_b)        // output
  );

  mux4 forwardA_mux (
    .s(forward_a),
    .in0(rs1_dout_EX),
    .in1(alu_out_MEM),
    .in2(rd_din_WB),
    .in3(0)
    .out(forwardA_mux_out)
  );

  mux4 forwardB_mux (
    .s(forward_b),
    .in0(rs2_dout_EX),
    .in1(alu_out_MEM),
    .in2(rd_din_WB),
    .in3(0)
    .out(forwardB_mux_out)
  );

  mux alu_in_2_mux (
    .s(alu_src),
    .in0(forwardB_mux_out),
    .in1(immgenout_EX),
    .out(alu_in_2)
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_op),      // input
    .alu_in_1(forwardA_mux_out),    // input  
    .alu_in_2(alu_in_2),    // input
    .alu_result(alu_out_EX),  // output
    .alu_zero(alu_zero)     // output
  );


  // Update EX/MEM pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      EX_MEM_mem_write <= 0;     
      EX_MEM_mem_read <= 0;      
      //EX_MEM_is_branch <= 0;     
      EX_MEM_mem_to_reg <= 0;    
      EX_MEM_reg_write <= 0;
      EX_MEM_is_halted <= 0;     
      EX_MEM_alu_out <= 0;
      EX_MEM_dmem_data <= 0;
      EX_MEM_rd <= 0;
    end
    else begin
      EX_MEM_mem_write <= mem_write_EX;     
      EX_MEM_mem_read <= mem_read_EX;      
      //EX_MEM_is_branch <= 0;     
      EX_MEM_mem_to_reg <= mem_to_reg_EX;    
      EX_MEM_reg_write <= reg_write_EX;  
      EX_MEM_is_halted <= is_halted_EX;    
      EX_MEM_alu_out <= alu_out_EX;
      EX_MEM_dmem_data <= forwardB_mux_out; //
      EX_MEM_rd <= rd_EX;
    end
  end

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (alu_out_MEM),       // input
    .din (dmem_data_MEM),        // input
    .mem_read (mem_read_MEM),   // input
    .mem_write (mem_write_MEM),  // input
    .dout (datamem_out)        // output
  );

  // Update MEM/WB pipeline registers here
  always @(posedge clk) begin
    if (reset) begin
      MEM_WB_mem_to_reg <= 0;    
      MEM_WB_reg_write <= 0;     
      MEM_WB_is_halted <= 0;     
      MEM_WB_mem_to_reg_src_1 <= 0;
      MEM_WB_mem_to_reg_src_2 <= 0;
      MEM_WB_rd <= 0; 
    end
    else begin
      MEM_WB_mem_to_reg <= mem_to_reg_MEM;    
      MEM_WB_reg_write <= reg_write_MEM;     
      MEM_WB_is_halted <= is_halted_MEM;     
      MEM_WB_mem_to_reg_src_1 <= alu_out_MEM;
      MEM_WB_mem_to_reg_src_2 <= datamem_out;
      MEM_WB_rd <= rd_MEM; 
    end
  end

  mux memtoreg_mux (
    .s(mem_to_reg_WB),
    .in0(mem_to_reg_src_1_WB),
    .in1(mem_to_reg_src_2_WB),
    .out(rd_din_WB)
  );
  
endmodule
