module regfile (
  input clk,
  input we,
  input [2:0] waddr,
  input [7:0] wdata,
  input [2:0] raddr1,
  input [2:0] raddr2,
  output [7:0] rdata1,
  output [7:0] rdata2
);

  // Internal memory
  reg [7:0] registers [0:7];

  // Synchronous write port
  always @(posedge clk) begin
    if (we)
      registers[waddr] <= wdata;
  end

  // Asynchronous read ports
  assign rdata1 = registers[raddr1];
  assign rdata2 = registers[raddr2];
  
endmodule