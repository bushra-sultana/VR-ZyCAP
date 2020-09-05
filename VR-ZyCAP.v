`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2020 09:55:56 PM
// Design Name: 
// Module Name: VR-ZyCAP
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


module VR_ZyCAP(input clk, input Rst, input Start, input I0, input I1, input I2, input I3, input I4, input I5,
    output O,
    output Q,
    output Q1,
   inout     DDR_addr,
   inout     DDR_ba,
   inout     DDR_cas_n,
   inout     DDR_ck_n,
   inout     DDR_ck_p,
   inout     DDR_cke,
   inout     DDR_cs_n,
   inout     DDR_dm,
   inout     DDR_dq,
   inout     DDR_dqs_n,
   inout     DDR_dqs_p,
   inout     DDR_odt,
   inout     DDR_ras_n,
   inout     DDR_reset_n,
   inout     DDR_we_n,
   inout     FIXED_IO_ddr_vrn,
   inout     FIXED_IO_ddr_vrp,
   inout     FIXED_IO_mio,
   inout     FIXED_IO_ps_clk,
   inout     FIXED_IO_ps_porb,
   inout     FIXED_IO_ps_srstb
//   inout [31:0] Initial_frame_address,
//   inout [63:0] LUT_INIT_value,
//   inout [31:0] Number_of_frames,
//   inout [31:0]Op_Sel,
//   inout [0:0]Rst,
//   inout [31:0]Slice_XYBEL,
//   inout [0:0]Start,
//   inout [11:0]bit_location
        
    
    );
    
     
      wire [31:0]Initial_frame_address;
      wire [63:0]LUT_INIT_value;
      wire [31:0]Number_of_frames;
      wire [31:0]Op_Sel;
    //  wire [0:0]Rst;
      wire [31:0]Slice_XYBEL;
     // wire [0:0]Start;
      wire [11:0]bit_location;
      
 design_1_wrapper design_1_i
        (.DDR_addr(DDR_addr),
         .DDR_ba(DDR_ba),
         .DDR_cas_n(DDR_cas_n),
         .DDR_ck_n(DDR_ck_n),
         .DDR_ck_p(DDR_ck_p),
         .DDR_cke(DDR_cke),
         .DDR_cs_n(DDR_cs_n),
         .DDR_dm(DDR_dm),
         .DDR_dq(DDR_dq),
         .DDR_dqs_n(DDR_dqs_n),
         .DDR_dqs_p(DDR_dqs_p),
         .DDR_odt(DDR_odt),
         .DDR_ras_n(DDR_ras_n),
         .DDR_reset_n(DDR_reset_n),
         .DDR_we_n(DDR_we_n),
         .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
         .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
         .FIXED_IO_mio(FIXED_IO_mio),
         .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
         .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
         .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
         .Initial_frame_address(Initial_frame_address),
         .LUT_INIT_value(LUT_INIT_value),
         .Number_of_frames(Number_of_frames),
         .Op_Sel(Op_Sel),
         .Rst(),
         .Slice_XYBEL(Slice_XYBEL),
         .Start(),
         .bit_location(bit_location));

wire CAP;
         
Main_FSM FSM(
            .Clk(clk),
            .Reset(Rst),
            .Start(Start),
            .Op_Sel(Op_Sel),
            .Num_frames(Number_of_frames),
            .Slice_XYBEL(Slice_XYBEL),
            .Initial_frameaddr(Initial_frame_address),
            .LUT_INIT(LUT_INIT_value),
            .bit_location(bit_location),
            .Clock_dis(CE_dis),
            .GSR_clkEN(GSR_done)
           // .CAP(CAP)
    );      
     
    assign Clk_CAP=CE_dis?1'd0:1'd1;    
    assign Clk_GSR=GSR_done?1'd1:1'd0;  
     
    BUFGCE BUFGCE_inst (
             .O(clk_out),   // 1-bit output: Clock output
             .CE(Clk_CAP | Clk_GSR),// | Clk_GSR), // 1-bit input: Clock enable input for I0
             .I(clk)    // 1-bit input: Primary clock
           );
            
//    CAPTUREE2 #(
//                 .ONESHOT("TRUE")  // Specifies the procedure for performing single readback per CAP trigger.
//              )
//              CAPTUREE2_inst (
//                 .CAP(CAP), // 1-bit input: Capture Input
//                 .CLK(clk)  // 1-bit input: Clock Input
//              );
            
    LUT6 #(
         .INIT(64'h8000000000000000)  // Specify LUT Contents
       ) LUT6_inst (
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
       ) FDRE_inst (
         .Q(Q),      // 1-bit Data output
         .C(clk),      // 1-bit Clock input
         .CE(1'd1),    // 1-bit Clock enable input
         .R(1'd0),      // 1-bit Synchronous reset input
         .D(O)       // 1-bit Data input
        );    
    
    DUT D2( 
              .I0(I0),
              .I1(I1), 
              .I2(I2), 
              .I3(I3),
              .I4(I4),
              .I5(I5),
              .clk_out(clk_out),
               .Q(Q1)
       );
                
endmodule
