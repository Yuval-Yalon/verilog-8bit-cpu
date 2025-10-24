module testbench;
  reg clk;
  reg rst_n;
  reg start_cmd;
  reg [2:0] op_in;
  reg [2:0] rd_in;
  reg [2:0] rs1_in;
  reg [2:0] rs2_in;
  
  wire cmd_done;
  wire z_flag_out;
  wire c_flag_out;
  
  // OPCODEs for readability
  localparam OP_ADD = 3'b000, OP_SUB = 3'b001, OP_AND = 3'b010,
             OP_OR  = 3'b011, OP_XOR = 3'b100, OP_SHL = 3'b101,
             OP_SHR = 3'b110, OP_MOV = 3'b111;

  // Instantiate the DUT
  top u_dut (
    .clk(clk),
    .rst_n(rst_n),
    .start_cmd(start_cmd),
    .op_in(op_in),
    .rd_in(rd_in),
    .rs1_in(rs1_in),
    .rs2_in(rs2_in),
    .cmd_done(cmd_done),
    .z_flag_out(z_flag_out),
    .c_flag_out(c_flag_out)
  );

  // Clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period clock
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);

    // Testing reset
    rst_n = 1'b0;
    start_cmd = 1'b0;
    op_in  = 3'b0;
    rd_in  = 3'b0;
    rs1_in = 3'b0;
    rs2_in = 3'b0;
    #20;
    rst_n = 1'b1;
    @(posedge clk);
    
    // Initial values
    u_dut.u_regfile.registers[1] = 8'h10; // R1 = 16
    u_dut.u_regfile.registers[2] = 8'h0A; // R2 = 10
    u_dut.u_regfile.registers[3] = 8'hFF; // R3 = 255
    @(posedge clk);

    // ADD (R4 = R1 + R2) -> 16 + 10 = 26 (0x1A)
    $display("Test: ADD R4, R1, R2");
    op_in  = OP_ADD;
    rd_in  = 4;
    rs1_in = 1;
    rs2_in = 2;
    start_cmd = 1'b1;
    @(posedge clk);
    start_cmd = 1'b0;
    wait (cmd_done == 1'b1);
    @(posedge clk);
    @(posedge clk);
    
    // Check result
    if (u_dut.u_regfile.registers[4] == 8'h1A)
      $display("PASS: R4 is 0x1A");
    else
      $error("FAIL: ADD test failed! R4 is %h", u_dut.u_regfile.registers[4]);

    // SUB (R5 = R4 - R2) -> 26 - 10 = 16 (0x10)
    $display("Test: SUB R5, R4, R2");
    op_in  = OP_SUB;
    rd_in  = 5;
    rs1_in = 4;
    rs2_in = 2;
    start_cmd = 1'b1;
    @(posedge clk);
    start_cmd = 1'b0;
    wait (cmd_done == 1'b1);
    @(posedge clk);
    @(posedge clk);
    
    if (u_dut.u_regfile.registers[5] == 8'h10)
      $display("PASS: R5 is 0x10");
    else
      $error("FAIL: SUB test failed! R5 is %h", u_dut.u_regfile.registers[5]);

    // Z_FLAG (R6 = R5 - R1) -> 16 - 16 = 0
    $display("Test: Z-Flag (SUB R6, R5, R1)");
    op_in  = OP_SUB;
    rd_in  = 6;
    rs1_in = 5;
    rs2_in = 1;
    start_cmd = 1'b1;
    @(posedge clk);
    start_cmd = 1'b0;
    wait (cmd_done == 1'b1);
    @(posedge clk);
    @(posedge clk);
    
    if (u_dut.u_regfile.registers[6] == 8'h00)
      $display("PASS: Z-Flag is High");
    else
      $error("FAIL: Z-Flag test failed! R6 is %h", u_dut.u_regfile.registers[6]);

    // C_FLAG (R7 = R3 + R2) -> 255 + 10 = 265 (C=1, Res=9)
    $display("Test: C-Flag (ADD R7, R3, R2)");
    op_in  = OP_ADD;
    rd_in  = 7;
    rs1_in = 3;
    rs2_in = 2;
    start_cmd = 1'b1;
    @(posedge clk);
    start_cmd = 1'b0;
    wait (cmd_done == 1'b1);
    @(posedge clk);
    @(posedge clk);
    
    if (u_dut.u_regfile.registers[7] == 8'h09)
      $display("PASS: C-Flag is High");
    else
      $error("FAIL: C-Flag test failed! R7 is %h", u_dut.u_regfile.registers[7]);

    // AND (R0 = R1 & R2) -> 16 & 10 = 0 (0x10 & 0x0A = 0x00)
    $display("Test: AND R0, R1, R2");
    op_in  = OP_AND;
    rd_in  = 0;
    rs1_in = 1;
    rs2_in = 2;
    start_cmd = 1'b1;
    @(posedge clk);
    start_cmd = 1'b0;
    wait (cmd_done == 1'b1);
    @(posedge clk);
    @(posedge clk);
    
    if (u_dut.u_regfile.registers[0] == 8'h00)
      $display("PASS: AND test passed!");
    else
      $error("FAIL: AND test failed! R0 is %h", u_dut.u_regfile.registers[0]);

    // OR (R0 = R1 | R2) -> 16 | 10 = 26 (0x10 | 0x0A = 0x1A)
    $display("Test: OR R0, R1, R2");
    op_in  = OP_OR;
    rd_in  = 0;
    rs1_in = 1;
    rs2_in = 2;
    start_cmd = 1'b1;
    @(posedge clk);
    start_cmd = 1'b0;
    wait (cmd_done == 1'b1);
    @(posedge clk);
    @(posedge clk);
    
    if (u_dut.u_regfile.registers[0] == 8'h1A)
      $display("PASS: OR test passed!");
    else
      $error("FAIL: OR test failed! R0 is %h", u_dut.u_regfile.registers[0]);

    // MOV (R0 = R2) -> R0 = 10 (0x0A)
    $display("Test: MOV R0, R2");
    op_in  = OP_MOV;
    rd_in  = 0;
    rs1_in = 1; // Unused by MOV
    rs2_in = 2;
    start_cmd = 1'b1;
    @(posedge clk);
    start_cmd = 1'b0;
    wait (cmd_done == 1'b1);
    @(posedge clk);
    @(posedge clk);
    
    if (u_dut.u_regfile.registers[0] == 8'h0A)
      $display("PASS: MOV test passed!");
    else
      $error("FAIL: MOV test failed! R0 is %h", u_dut.u_regfile.registers[0]);
    
    $display("All tests completed.");
    $finish;
  end

endmodule
