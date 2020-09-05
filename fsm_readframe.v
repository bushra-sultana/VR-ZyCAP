`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:      Sir Syed CASE institute of Science and Technology, Islamabad
// Engineer:     Bushra Sultana
// 
// Create Date:    20:47:13 04/02/2019 
// Design Name:    VR_ZyCAP
// Module Name:    fsm_readframe 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module fsm_readframe( //input SYSCLK_P, input SYSCLK_N,input rst,
    input clk,
    input rst,
    input Start,
    input [31:0] frame_Addr,
    input [31:0] Num_frame,
    output reg word_ready,
    output reg read_done,
    output CSIB_R,
    output RWB_R,
    output [31:0] I_R,
    output reg [9:0] write_addr,
 //   output reg  we,
    output Clk_de
   
    
//    input I0, //D, G, GE,CLR,
//    input I1,
//    input I2,
//    input I3,
//    input I4,
//    input I5,
//    output Q,O
//output [31:0] data_output
    );


reg RW_B, CSI_B;
reg [31:0] data_input;
reg [5:0] state_reg;
reg [9:0] count, count1;
reg NOOP, NOOP1,NOOP2, NOOP3, NOOP4, NOOP5, NOOP6, NOOP7,NOOP8 ; 
wire [31:0] data_output;
wire [15:0] Num_frame_words;
wire [31:0] frame_words, Unswapped_data;
reg [31:0] Swapped_data;
reg read_done, Clk_dis;
wire CAP;

//wire clk, clk_100;
assign CSIB_R = CSI_B;
assign RWB_R = RW_B;
assign I_R = data_input;

assign Num_frame_words= (Num_frame+1) * 7'd101;
//assign Num_frame_words=(Num_frame_words);
wire [15:0] num = 16'd4608;
assign frame_words= {16'h1200, Num_frame_words};

assign Clk_de = (Clk_dis)?1'd1:Clk_de;
assign CAP = (Clk_dis)?1'd1:CAP;
assign Unswapped_data=frame_Addr;
//reg RW_B, CSI_B;

parameter [5:0] state_rst=6'd0, state_Dummy_Word1=6'd1, state_Bus_Width_Sync=6'd2, state_Bus_Width_Detect=6'd3,
state_Dummy_Word2=6'd4, state_Sync_Word2=6'd5, state_Type1_NOOP_Word=6'd6, state_Type1_NOOP_Word0=6'd7, 
state_Type1_Write_1_Word_CMD=6'd9, state_SHUTDOWN_Command=6'd10, state_RCRC_Command=6'd11, state_RCFG_command=6'd12,
state_Type_1_Word_to_FAR=6'd13, state_Frame_address_register=6'd14, state_Type1_Read_0_Words_from_FDRO=6'd15, 
state_Type2_Read_2860321_Words_from_FDRO=6'd16, state_Packet_data_Read_FDRO_Word0=6'd17,state_Packet_data_Read_FDRO_Word1=6'd18,
state_Start_Command=6'd19, state_Desync_command=6'd20, state_rst1=6'd21,state_deassert_CE=6'd22,state_ICAP_disable=6'd23,state_Read=6'd24,
state_ICAP_enable=6'd25, state_ICAP_disable1=6'd26, state_Write=6'd27,state_enable1=6'd28;


//  clk_wiz_0 dcm
//   (
//    // Clock out ports
//    .clk_out1(clk_100),     // output clk_out1
//    // Status and control signals
//    .reset(rst), // input reset
//    .locked(locked),       // output locked
//   // Clock in ports
//    .clk_in1_p(SYSCLK_P),    // input clk_in1_p
//    .clk_in1_n(SYSCLK_N));     // OUT
//// INST_TAG_END ------ End INSTANTIATION Template ---------

//		// Make sure the clock is routed on a global net
//		BUFG BUFG_inst1 (
//		.O(clk),
//		.I(clk_100)
//		);	 
		     
CAPTUREE2 #(
      .ONESHOT("TRUE")  // Specifies the procedure for performing single readback per CAP trigger.
   )
   CAPTUREE2_inst (
      .CAP(CAP), // 1-bit input: Capture Input
      .CLK(clk)  // 1-bit input: Clock Input
   );

integer i, j;
reg [3:0] word0, word1, word2, word3, word4, word5, word6, word7;
always@(posedge clk)
begin
if(rst)
Swapped_data<=0;
else 

begin
 for(i=0; i<4; i=i+1)
 begin
       for(j=0; j<8; j=j+1)
       Swapped_data[i*8 + (7-j)] <= Unswapped_data[(i*8)+j];
 end
end
end


always@(posedge clk)
begin
if(rst)
state_reg<=state_rst;
else if(Start)
case(state_reg)
6'd0:  begin                             //state_rst
            RW_B<=1;
            CSI_B<=1;
            data_input<=32'h00000000;
            state_reg<=6'd1;
            count<=0;
            count1<=0;
            Clk_dis<=1'd1;
            read_done<=0;
            end
//state_rst1:  
6'd1:          begin
               RW_B<=0;
               CSI_B<=1;
               data_input<=32'h00000000;
               state_reg<=6'd2;
               end			
//state_Dummy_Word1: 
6'd2:           begin
                 RW_B<=0;
                 CSI_B<=0;
				 data_input<=32'hFFFFFFFF;
				 state_reg<=6'd3;
				 end
				 
//state_Bus_Width_Sync: begin
6'd3:            begin
                 RW_B<=0;
                 CSI_B<=0;
				 data_input<=32'h000000DD;
				 state_reg<=6'd4;
                 end
						
//state_Bus_Width_Detect: 
6'd4:           begin
                 RW_B<=0;
                 CSI_B<=0;
				 data_input<=32'h88440022;
				 state_reg<=6'd5;
                 end
								
//state_Dummy_Word2:  
6'd5:            begin
                 RW_B<=0;
                 CSI_B<=0;
				 data_input<=32'hFFFFFFFF;
				 state_reg<=6'd6;
				 end

//state_Sync_Word2:  
 6'd6:            begin
                  RW_B<=0;
                  CSI_B<=0;
				  data_input<=32'h5599AA66;
				  state_reg<=6'd8;
				   NOOP<=1;
				  end
						
////state_Type1_NOOP_Word:  
//6'd7:             begin
//                  RW_B<=0;
//                  CSI_B<=0;
//				  data_input<=32'h04000000;
//				  state_reg<=6'd9;
//				  NOOP<=1;
//				  end
				  
//state_Type1_NOOP_Word0: 
6'd8:             begin
                  RW_B<=0;
                  CSI_B<=0;
				  data_input<=32'h04000000;
				  if(NOOP2)
				   begin
         		  state_reg<=6'd9; end
				  else if(NOOP3)
				  state_reg<=6'd13;
				  else if(NOOP4)
				  begin if(count==2)
				       begin
				         state_reg<=6'd17; 
				         count<=0; 
				       end
				  else count<=count+1;
				  end
				  else if(NOOP5)
				  state_reg<=6'd9;
				  else if(NOOP6)
				  begin if(count==5)
				        begin
				         state_reg<=6'd24;
				         count<=0; end
				         else count<=count+1;
				  end
				  else 
				  state_reg<=6'd9;
				  end
                  						
//state_Type1_Write_1_Word_CMD: 
6'd9:             begin
                  RW_B<=0;
                  CSI_B<=0;
				  data_input<=32'h0C000180;
				  if(NOOP==1)
				  state_reg<=6'd11;
				  else if(NOOP2)
				  state_reg<=6'd12;
				  else if(NOOP5)
				  state_reg<=6'd24;
//				  else if(NOOP6)
//				  state_reg<=state_RCRC_Command;
//				  else if(NOOP7)
//				  state_reg<=state_Desync_command;
				//  else
				//  state_reg<=state_SHUTDOWN_Command;
				  end
                  
//state_SHUTDOWN_Command: 
//6'd10:            begin
//				  data_input<=32'h0000000B;
//				  state_reg<=6'd8;
//				  NOOP<=1;
//				  end
                  	
//state_RCRC_Command: 
6'd11:             begin
                   RW_B<=0;
                   CSI_B<=0;
				   data_input<=32'h000000E0;
				   state_reg<=6'd8;
				   NOOP<=0;
		//		   if(count<=20)
				   NOOP2<=1;
				   end
                  	
						
//state_RCFG_command: 
6'd12:             begin
                   RW_B<=0;
                   CSI_B<=0;
				   data_input<=32'h00000020;
				   state_reg<=6'd8;
				   NOOP2<=0;
				   NOOP3<=1;
				   end
	
        
//state_Type_1_Word_to_FAR: 
6'd13:             begin
                   RW_B<=0;
                   CSI_B<=0;
				   data_input<=32'h0C000480;
				   state_reg<=6'd14;
				   NOOP3<=0;
				   end
                  
 
////state_Frame_address_register: 
6'd14:            begin

				  data_input<=Swapped_data;//frame_Addr;   //32'h00428004;
				  state_reg<=6'd15;
				  end
				  
////state_Type1_Read_0_Words_from_FDRO: 
6'd15:            begin
				  data_input<=32'h14000600;
				  state_reg<=6'd16;
				  end
                 
////state_Type2_Read_2860321_Words_from_FDRO: 
6'd16:            begin
				  data_input<=frame_words;//32'h12000053;  //32'h12D4A584;//frame_words; //32'h12D4A584;
				  state_reg<=6'd8;
				  NOOP4<=1;
				  end
////state_ICAP_disable: 
6'd17:            begin 
                  CSI_B<=1;
                  RW_B<=0;
                  data_input<=32'h00000000;
                  NOOP4<=0;
                  state_reg<=6'd18;
                  end
////state_Select_Read_Mode: 
6'd18:            begin
                  CSI_B<=1;
                  RW_B<=1;
                  state_reg<=6'd19;
                  end
////state_ICAP_enable: 
6'd19:            begin
                  CSI_B<=0;
                  RW_B<=1;
                  state_reg<= 6'd20;
                  end  
////state_Packet_data_Read_FDRO_Word0: 
6'd20:            begin
//				  NOOP4<=0;
                  Clk_dis<=1'd1;
                  
				  data_input<=32'h00000000;
				  if(count1==Num_frame_words)
				  begin
				  state_reg<=6'd21;
				  word_ready =0; end
				  else
				  begin
				  count1<=count1+1;
				  word_ready<=1;
				  write_addr<=write_addr+1;
				 // we<=1;
                  state_reg<=state_reg;
				  end
				  end
////state_ICAP_disable1: 
6'd21:            begin
                   CSI_B<=1;
                   RW_B<=1;
                   state_reg<= 6'd22;
                  end
////state_Write: 
6'd22:            begin  
                   CSI_B<=1;
                   RW_B<=0;
                   state_reg<= 6'd23;
                 end
////state_enable1: 
6'd23:            begin 
                     CSI_B<=0;
                     RW_B<=0;
                     NOOP5=1;
                     state_reg<= 6'd8;
                  end
////state_Packet_data_Read_FDRO_Word1:  begin
              
////				  data_input<=32'h00000000;
////				  state_reg<=state_Type1_NOOP_Word0;
////				  NOOP5<=1;
////				  end
                
				  
////state_Start_Command: 	
////              begin
////				   CSI_B<=0;
////				  data_input<=32'h00000005;
////				  state_reg<=state_Type1_NOOP_Word0;
////				  NOOP5<=0;
////				  NOOP6<=1;
////				  end
               			  
////state_Desync_command: 
6'd24:            begin
				  data_input<=32'h000000B0;
				  state_reg<=6'd25;
				  NOOP5<=0;
				  NOOP6<=1;
				  end
				  
////state_deassert_CE: 
6'd25:            begin
                    data_input<=32'h04000000;//FFFFFFFF;
                    CSI_B<=0;
                    RW_B<=0;
                    read_done<=1;
                    NOOP6<=0;
                    state_reg<=6'd25;
                  end
                  
6'd26:            begin      
                  CSI_B<=1;
                  RW_B<=1; 
                  read_done<=1;
                  data_input<=32'hAAAAAAAA;
                  state_reg<=6'd26;
                  end
			  
endcase
end





ila_1 ila_read_frame(
	 .clk(clk), // input wire clk
    .probe0(data_input), // input wire [31:0]  probe0  
	.probe1(data_output), // input wire [31:0]  probe1 
	.probe2(state_reg), // input wire [63:0]  probe2 
	.probe3(RW_B), // input wire [0]  probe3 
	.probe4(CSI_B),
	.probe5(rst),
	.probe6(NOOP4),
	.probe7(count),
	.probe8(NOOP2),
	.probe9(NOOP3),
	.probe10(NOOP5),
	.probe11(NOOP6),
	.probe12(count1),
	.probe13(NOOP),
	.probe14(frame_words),
	.probe15(Unswapped_data),
	.probe16(Swapped_data),
	.probe17(Num_frame_words),
	.probe18(CAP),
	.probe19(done_FF)
	 // input wire [0]  probe4
);


//ila_0 ila (
//	.clk(clk), // input wire clk
//	.trig_out(),// output wire trig_out 
//	.trig_out_ack(1'd1),// input wire trig_out_ack 
//    .probe0(data_output[31:0]) // input wire [31:0] probe0
//);


endmodule
