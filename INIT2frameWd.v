`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/07/2020 09:43:56 PM
// Design Name: 
// Module Name: INIT2frameWd
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


module INIT2frameWd( 

input Clk,
input Start, 
input [63:0] INIT,
output [15:0] frame_word0,
output [15:0] frame_word1,
output [15:0] frame_word2,
output [15:0] frame_word3

    );
wire [63:0] icap_not_swapped; 
wire [63:0] icap_swapped;   
    
wire [15:0] frame1_s; 
wire [15:0] frame2_s; 
wire [15:0] frame3_s; 
wire [15:0] frame4_s; 



   
assign icap_not_swapped = INIT;    
assign icap_swapped =
			{icap_not_swapped[55],icap_not_swapped[5],icap_not_swapped[5],icap_not_swapped[52],icap_not_swapped[51],icap_not_swapped[50],icap_not_swapped[49],icap_not_swapped[48],
			icap_not_swapped[63],icap_not_swapped[62],icap_not_swapped[61],icap_not_swapped[60],icap_not_swapped[59],icap_not_swapped[58],icap_not_swapped[57],icap_not_swapped[56],
			icap_not_swapped[39],icap_not_swapped[38],icap_not_swapped[37],icap_not_swapped[36],icap_not_swapped[35],icap_not_swapped[34],icap_not_swapped[33],icap_not_swapped[32],
			icap_not_swapped[47],icap_not_swapped[46],icap_not_swapped[45],icap_not_swapped[44],icap_not_swapped[43],icap_not_swapped[42],icap_not_swapped[41],icap_not_swapped[40],
			icap_not_swapped[23],icap_not_swapped[22],icap_not_swapped[21],icap_not_swapped[20],icap_not_swapped[19],icap_not_swapped[18],icap_not_swapped[17],icap_not_swapped[16],
			icap_not_swapped[31],icap_not_swapped[30],icap_not_swapped[29],icap_not_swapped[28],icap_not_swapped[27],icap_not_swapped[26],icap_not_swapped[25],icap_not_swapped[24],
			icap_not_swapped[7],icap_not_swapped[6],icap_not_swapped[5],icap_not_swapped[4],icap_not_swapped[3],icap_not_swapped[2],icap_not_swapped[1],icap_not_swapped[0],
			icap_not_swapped[15],icap_not_swapped[14],icap_not_swapped[13],icap_not_swapped[12],icap_not_swapped[11],icap_not_swapped[10],icap_not_swapped[9],icap_not_swapped[8]}
			;
			
assign frame1_s = icap_swapped[63:48];
assign frame2_s = icap_swapped[47:32];
assign frame3_s = icap_swapped[31:16];
assign frame4_s = icap_swapped[15:0];
             
assign  frame_word0 = frame1_s;
assign  frame_word1 = frame2_s;
assign  frame_word2 = frame3_s;
assign  frame_word3 = frame4_s;

endmodule
