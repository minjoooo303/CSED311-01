// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module cpu(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted,
           output [31:0]print_reg[0:31]
           ); // Whehther to finish simulation
  /***** Wire declarations *****/
  
  // PC
  wire [31:0] next_pc;
  wire [31:0] current_pc;
  wire CurrIsNextPC;

  // pc_mux
  wire iord;
  wire [31:0] aluout;
  wire [31:0] mem_addr;

  // mem_mux_reg
  wire mem_to_reg;
  wire [31:0] MDR_wire; // Memory Data Register
  wire [31:0] write_data_reg;

  // Register File
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [4:0] rd;
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout; 
  wire write_enable; //RegWrite
  
  // reg_mux_alu_a
  wire alusrca;
  wire [31:0] a;
  wire [31:0] mux_a_out;

  // reg_mux_alu_b
  wire alusrcb;
  wire [31:0] imm_gen_out;
  wire [31:0] b;
  wire [31:0] mux_b_out;

  // Memory
  wire [31:0] write_data; // input
  wire mem_read;
  wire mem_write;
  wire [31:0] mem_data; // output

  // Control Unit
  wire [6:0] op;
  wire pcwritenotcond;
  wire pcwrite;
  wire irwrite;
  wire pcsource;
  wire ALUOp;
  wire is_ecall;

  // ImmGen
  wire [31:0] ir; // input
  
  // ALU Control Unit
  wire [3:0] alu_crtl_input;
  wire [3:0] alu_op;
  wire [1:0] btype;

  // ALU
  wire [31:0] alu_result;
  wire alu_bcond;
  wire [31:0] ALUOut_wire;

  /***** Register declarations *****/
  reg [31:0] IR; // instruction register
  reg [31:0] MDR; // memory data register
  reg [31:0] A; // Read 1 data register
  reg [31:0] B; // Read 2 data register
  reg [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.
  
  assign rs1 = IR[19:15];
  assign rs2 = IR[24:20];
  assign rd = IR[11:7];
  assign a = A;
  assign b = B;
  assign op = IR[6:0];
  assign ir = IR;
  assign alu_crtl_input = {IR[30], IR[14:12], IR[6:0]};
  assign CurrIsNextPC = (pcwritenotcond && !alu_bcond) || pcwrite;
  assign MDR_wire = MDR;
  assign ALUOut_wire = ALUOut;


  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .CurrIsNextPC(CurrIsNextPC),
    .current_pc(current_pc)   // output
  );

  mux pc_mux(
    .s(iord),
    .in0(current_pc),
    .in1(aluout),
    .out(mem_addr)
  );

  mux mem_mux_reg(
    .s(mem_to_reg),
    .in0(aluout),
    .in1(MDR),
    .out(write_data_reg)
  );

  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(rs1),          // input
    .rs2(rs2),          // input
    .rd(rd),           // input
    .rd_din(write_data_reg),       // input
    .write_enable(write_enable),    // input
    .rs1_dout(rs1_dout),     // output
    .rs2_dout(rs2_dout),      // output
    .print_reg(print_reg)     // output (TO PRINT REGISTER VALUES IN TESTBENCH)
  );

  mux reg_mux_alu_a(
    .s(alusrca),
    .in0(current_pc),
    .in1(a),
    .out(mux_a_out)
  );

  mux4 reg_mux_alu_b(
    .s(alusrcb),
    .in0(current_pc),
    .in1(b),
    .in2(4),
    .in3(imm_gen_out),
    .out(mux_b_out)
  );

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),        // input
    .clk(clk),          // input
    .addr(mem_addr),         // input
    .din(write_data),          // input
    .mem_read(mem_read),     // input
    .mem_write(mem_write),    // input
    .dout(mem_data)          // output
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit(
    .reset(reset),
    .clk(clk),
    .part_of_inst(op),  // input
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .write_enable(write_enable),     // output
    .PCWriteNotCond(pcwritenotcond),
    .PCWrite(pcwrite),
    .IorD(iord),
    .IRWrite(irwrite),
    .PCsource(pcsource),
    .ALUOp(ALUOp),
    .ALUSrcA(alusrca),
    .ALUSrcB(alusrcb),
    .is_ecall(is_ecall)       // output (ecall inst)
  );


  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(ir),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .part_of_inst(alu_crtl_input),  // input
    .ALUOp(ALUOp),                  // input
    .alu_op(alu_op),         // output
    .btype(btype)           // output
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(alu_op),     // input
    .btype(btype),     // input
    .alu_in_1(mux_a_out),    // input  
    .alu_in_2(mux_b_out),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)     // output
  );

  mux alu_mux_pc(
    .s(pcsource),
    .in0(alu_result),
    .in1(ALUOut_wire),
    .out(next_pc)
  );

  initial begin
    IR = 0;
    MDR = 0;
    A = 0;
    B = 0;
    ALUOut = 0;
  end

  // is_halted 처리
  always @(*) begin
    if(is_ecall && reg_file.rf[17] == 10) begin is_halted = 1; end
    else begin is_halted = 0; end
  end

  // 클럭마다 register 값들 처리
  always @(posedge clk) begin
    if(reset) begin
      IR <= 0;
      MDR <= 0;
      A <= 0;
      B <= 0;
      ALUOut <= 0;
    end
    else begin
      if(irwrite) begin
        IR <= mem_data;
      end
      MDR <= mem_data;
      A <= rs1_dout;
      B <= rs2_dout;
      ALUOut <= alu_result;
    end
  end

endmodule
