module top (
  input clk,
  input rst_n,
  input start_cmd,
  input [2:0] op_in,
  input [2:0] rd_in,
  input [2:0] rs1_in,
  input [2:0] rs2_in,
  output reg cmd_done,
  output z_flag_out,
  output c_flag_out
);
  
  // FSM States
  reg [1:0] state, next_state;
  localparam IDLE = 2'b00, EXECUTE = 2'b01, WRITEBACK = 2'b10;
  
  // Internal instruction registers
  reg [2:0] op_reg;
  reg [2:0] rd_reg;
  reg [2:0] rs1_reg;
  reg [2:0] rs2_reg;
  
  // FSM control signals
  reg rf_we;
  reg [2:0] rf_raddr1;
  reg [2:0] rf_raddr2;
  reg [2:0] rf_waddr;
  reg [2:0] alu_op_control;
  
  // Datapath wires
  wire [7:0] rf_rdata1;
  wire [7:0] rf_rdata2;
  wire [7:0] alu_result;
  wire alu_z_flag;
  wire alu_c_flag;
  
  // Instantiate the ALU
  alu8 u_alu(
    .a(rf_rdata1),
    .b(rf_rdata2),
    .alu_op(alu_op_control),
    .result(alu_result),
    .z_flag(alu_z_flag),
    .c_flag(alu_c_flag)
  );
  
  // Instantiate the Registerfile
  regfile u_regfile(
    .clk(clk),
    .we(rf_we),
    .waddr(rf_waddr),
    .wdata(alu_result),
    .raddr1(rf_raddr1),
    .raddr2(rf_raddr2),
    .rdata1(rf_rdata1),
    .rdata2(rf_rdata2)
  );
  
  // FSM: Synchronous block
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= IDLE;
      op_reg <= 3'b000;
      rd_reg <= 3'b000;
      rs1_reg <= 3'b000;
      rs2_reg <= 3'b000;
    end
    else begin
      state <= next_state;
      if (state == IDLE && start_cmd == 1) begin
        op_reg <= op_in;
        rd_reg <= rd_in;
        rs1_reg <= rs1_in;
        rs2_reg <= rs2_in;
      end
    end      
  end
  
  // FSM: Combinational block
  always @(*) begin
    next_state = state;
    cmd_done = 1'b0;
    rf_we = 1'b0;
    rf_raddr1 = rs1_reg;
    rf_raddr2 = rs2_reg;
    rf_waddr = rd_reg;
    alu_op_control = op_reg;
    case (state)
      IDLE: begin
        if (start_cmd)
          next_state = EXECUTE;
      end
      EXECUTE: next_state = WRITEBACK;
      WRITEBACK: begin
        rf_we = 1'b1;
        cmd_done = 1'b1;
        next_state = IDLE;
      end
    endcase
  end
  
  assign z_flag_out = alu_z_flag;
  assign c_flag_out = alu_c_flag;
  
endmodule