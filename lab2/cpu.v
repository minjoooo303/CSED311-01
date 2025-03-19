// Submit this file with other files you created.
// Do not touch port declarations of the module 'cpu'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,                     // positive reset signal
           input clk,                       // clock signal
           output is_halted,                // Whehther to finish simulation
           output [31:0] print_reg [0:31]); // TO PRINT REGISTER VALUES IN TESTBENCH (YOU SHOULD NOT USE THIS)
  /***** Wire declarations *****/

  wire [31:0] instruction;
  wire [6:0] opcode;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;

  // PC
  wire [31:0] current_pc;
  wire [31:0] next_pc;
  wire [31:0] pc_plus_four;
  wire [31:0] pc_sum;
  wire pc_src1;
  wire [31:0] pc_mux_1_out;

  // Immediate Generator output
  wire [31:0] imm_gen_out;

  // Registers
  wire [31:0] write_data_reg;
  wire [31:0] rs1_dout; //Read data 1
  wire [31:0] rs2_dout; //Read data 2

  // ALU input
  wire [3:0] alu_op;
  wire [1:0] btype;
  wire [31:0] alu_in_2;

  // ALU output
  wire alu_bcond;
  wire [31:0] alu_result;

  // Control Unit output
  wire is_jal;
  wire is_jalr; // pc_src2
  wire branch;
  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire reg_write;
  wire pc_to_reg;
  wire is_ecall;

  // Data Memory output
  wire [31:0] datamem_read_data;

  // Data
  wire [31:0] data;

  assign opcode = instruction[6:0];
  assign rs1 = instruction[19:15];
  assign rs2 = instruction[24:20];
  assign rd = instruction[11:7];
  assign pc_src1 = (branch & alu_bcond) | is_jal;

  // ALU Control
  wire [10:0] alu_crtl_input;
  assign alu_crtl_input = {instruction[30], instruction[14:12], instruction[6:0]};

  /***** Register declarations *****/

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  pc pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );

  adder pc_4(
    .add_input1(current_pc),  //input
    .add_input2(4),  //input
    .add_output(pc_plus_four)   //output
  );


  adder pc_imm(
    .add_input1(current_pc),  //input
    .add_input2(imm_gen_out),  //input
    .add_output(pc_sum)   //output
  );

  mux pc_mux_1(
    .s(pc_src1),      // input
    .in1(pc_sum),    // input
    .in0(pc_plus_four),    // input
    .out(pc_mux_1_out)     // output
  );

  mux pc_mux_2(
    .s(is_jalr),      // input
    .in1(alu_result),    // input
    .in0(pc_mux_1_out),    // input
    .out(next_pc)     // output
  );
  
  // ---------- Instruction Memory ----------
  instruction_memory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(instruction)     // output
  );

  // ---------- Register File ----------
  register_file reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (rs1),          // input
    .rs2 (rs2),          // input
    .rd (rd),           // input
    .rd_din (write_data_reg),       // input
    .write_enable (reg_write), // input
    .is_ecall (is_ecall),
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout),     // output
    .print_reg (print_reg),  //DO NOT TOUCH THIS
    .ishalted(is_halted)
  );

  mux is_PCtoReg(
    .s(pc_to_reg),  // input
    .in1(pc_plus_four),         // input
    .in0(data),         // input
    .out(write_data_reg)          // output
  );

  mux is_ALUSrc(
    .s(alu_src),      // input
    .in1(imm_gen_out),    // input
    .in0(rs2_dout),    // input
    .out(alu_in_2)     // output
  ); 

  // ---------- Control Unit ----------
  control_unit ctrl_unit (
    .part_of_inst(instruction),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(reg_write),  // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  immediate_generator imm_gen(
    .part_of_inst(instruction),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  alu_control_unit alu_ctrl_unit (
    .part_of_inst(alu_crtl_input),  // input
    .alu_op(alu_op),         // output,
    .btype(btype)
  );

  // ---------- ALU ----------
  alu alu (
    .alu_op(alu_op),      // input
    .btype(btype),       // input (modified)
    .alu_in_1(rs1_dout),    // input  
    .alu_in_2(alu_in_2),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)    // output
  );

  // ---------- Data Memory ----------
  data_memory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (alu_result),       // input
    .din (rs2_dout),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (datamem_read_data)        // output
  );

  mux is_MemtoReg(
    .s(mem_to_reg),      // input
    .in1(datamem_read_data),    // input
    .in0(alu_result),    // input
    .out(data)     // output
  );
 

endmodule
