module alu8 (
  input [7:0] a,
  input [7:0] b,
  input [2:0] alu_op,
  output reg [7:0] result,
  output z_flag,
  output reg c_flag
);
  
  localparam OP_ADD = 3'b000, OP_SUB = 3'b001, OP_AND = 3'b010, OP_OR = 3'b011, OP_XOR = 3'b100, OP_SHL = 3'b101, OP_SHR = 3'b110, OP_MOV = 3'b111;  
  
  // ALU operation
  always @(*) begin
    case(alu_op)
      OP_ADD: result = a + b;
      OP_SUB: result = a - b;
      OP_AND: result = a & b;
      OP_OR: result = a | b;
      OP_XOR: result = a ^ b;
      OP_SHL: result = a << 1;
      OP_SHR: result = a >> 1;
      OP_MOV: result = b;
    endcase
  end
  
  // Zero flag
  assign z_flag = (result == 8'h00);
  
  // Carry flag
  always @(*) begin
    c_flag = 1'b0;
    case (alu_op)
      OP_ADD: begin
        if ({1'b0, a} + {1'b0, b} > 8'hFF)
          c_flag = 1'b1;
        else
          c_flag = 1'b0;
      end
      OP_SUB: begin
        if (a < b)
          c_flag = 1'b1;
        else
          c_flag = 1'b0;
      end
      OP_SHL: begin
        c_flag = a[7];
      end
      OP_SHR: begin
        c_flag = a[0];
      end
      default: c_flag = 1'b0;
    endcase
  end
  
endmodule