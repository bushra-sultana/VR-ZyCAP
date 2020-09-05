`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/28/2020 07:39:22 PM
// Design Name: 
// Module Name: DUT
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


module DUT( input I0, input I1, input I2, input I3, input I4, input I5, input clk_out, output Q

    );
    
    wire O;
    
 LUT6 #(
                           .INIT(64'h8000000000000000)  // Specify LUT Contents
                ) LUT6_inst1 (
                                           .O(O),   // LUT general output
                                           .I0(I0), // LUT input
                                           .I1(I1), // LUT input
                                           .I2(I2), // LUT input
                                           .I3(I3), // LUT input
                                           .I4(I4), // LUT input
                                           .I5(I5)  // LUT input
                                  );
   
   FDRE #(
               .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
              ) FDRE_inst1 (
                           .Q(Q),      // 1-bit Data output
                           .C(clk_out),      // 1-bit Clock input
                           .CE(1'd1),    // 1-bit Clock enable input
                           .R(1'd0),      // 1-bit Synchronous reset input
                           .D(O)       // 1-bit Data input
                 );
endmodule
