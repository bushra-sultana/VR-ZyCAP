`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 10:07:29 AM
// Design Name: 
// Module Name: bit_flip
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bit_flip( input clk, input start, input rst, input [11:0] bit_location, input [12:0] write_addr, input [31:0] data_output,
 output reg done, output [31:0] modify_word1, output [12:0] addr2mod);

wire [7:0] word_position;
wire [7:0] bitposition;
reg [31:0] modify_word;
wire [31:0] modify_word1;
wire [31:0] word;
wire [12:0] addr2mod;

assign word_position=(((bit_location/32)-1)>0)?((bit_location/32)-1):0;
assign bitposition=(((bit_location%32)-1)>0)?((bit_location%32)-1):bit_location;
assign word = (32'h00000001 << bitposition);
assign modify_word1= modify_word ^ word ;
assign addr2mod= word_position+105;

//assign done = modify_word?1'd1:1'd0;

always@(posedge clk)
begin
if (rst)
begin
  modify_word<=0;
  done <= 0; end
else if(write_addr==word_position+105)
begin
  modify_word<=data_output;
  done<=1; end
else modify_word<=modify_word;
end

ila_4 ILA (
	.clk(clk), // input wire clk
	.probe0(word_position), // input wire [7:0]  probe0  
	.probe1(bitposition), // input wire [7:0]  probe1 
	.probe2(word), // input wire [31:0]  probe2 
	.probe3(modify_word1), // input wire [31:0]  probe3 
	.probe4(modify_word), // input wire [31:0]  probe4 
	.probe5(addr2mod) // input wire [12:0]  probe5 

);


endmodule
