`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/07/2020 09:30:54 PM
// Design Name: 
// Module Name: LUT2frameAddr
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


module LUT2frameAddr( 
    input Clk,
    input Start,
    input Reset,
    input [31:0] XYBel,
    output [31:0] Frame_address,
    output reg [7:0] word_offset,
    output msb_lsb,
    output reg done_FAR

    );
    
parameter Max_Y = 150, Y_Half = 50, Max_X = 114, Coloumn_HT = 50, Col_Half = 25, Max_HCLK = 1;//(0.1);

parameter  state_rst = 4'd0, state_TOP_HCLK = 4'd1, state_Major_Col = 4'd2, state_Minor = 4'd3, state_Wordoffset = 4'd4, state_done = 4'd5;

wire [2:0] Block_Type;
reg Top;
reg [4:0] HCLK;
reg [9:0] Major;
reg [6:0] Minor;
wire [15:0] X, Y;
wire [1:0] Bel;

reg [3:0] Next_state;

assign X = XYBel[31:17];
assign Y = XYBel[16 : 2];
assign Bel = XYBel[1:0];
assign msb_lsb = Bel[0];
assign Block_Type=0;


assign Frame_address= {6'd0 , Block_Type , Top , HCLK , Major , Minor};
always@(posedge Clk)
begin
if(Reset)
Next_state<=state_rst;
else if(Start)

case(Next_state)

state_rst:   Next_state<= state_TOP_HCLK;
state_TOP_HCLK: Next_state <= state_Major_Col;
state_Major_Col: Next_state <= state_Minor;
state_Minor:  Next_state <= state_Wordoffset;
state_Wordoffset:  Next_state <= state_done;

endcase
end


reg [7:0] A;
reg [2:0] Hrow_cnt;
integer i,j;

reg [7:0] Y_offset;

always@(posedge Clk)
begin
case(Next_state)
state_rst:  begin A<=0;
                 Hrow_cnt<=0;
                 HCLK <=0;
                 Major <= 0;
                 Minor<=0;
                 end //signals Zero
state_TOP_HCLK:  if(Y>Y_Half)
                  begin
                    Top <=0;
                     A= Y-Y_Half;
                     for(i=0; i<Max_HCLK; i=i+1)
                     begin
                        if(A>=Coloumn_HT) 
                          begin
                           A=A-Coloumn_HT;
                          Hrow_cnt<=Hrow_cnt+1; 
                           end
                      Y_offset<=A;
                      HCLK<=Hrow_cnt;
                      end
                  end
               
                else 
                      begin Top <=1;
                            HCLK <= 5'd1;
                            Y_offset<=0; 
                      end
state_Major_Col:  
                  if (X >=0 & X < 8)
						Major <= (X[9:0] >> 1) + 2;             //-- X srl 1 = X/2
					else if (X>=8 & X<28)
						Major<= (X[9 : 0] >> 1) + 3;
					else if (X>=28 & X<32)
						Major<= (X[9 : 0] >> 1) + 4;
					else if (X>=32 & X<48)
						Major<= (X[9 : 0] >> 1) + 5;
					else if (X>=48 & X<72)
						Major<= (X[9 : 0] >> 1) + 6;
					else if (X>=72 & X<92)
						Major<= (X[9 : 0] >> 1) + 7;
					else if (X>=92 & X<100)
						Major<= (X[9: 0]>> 1) + 8;
					else if (X>=100 & X<108)
						Major<= (X[9 : 0] >> 1) + 9;
					
           //       if (X >=0 && X <= 113)
           //         Major <= (X[9:0] >> 1)+2;            // -- X srl 1 = X/2
                                   
state_Minor:      if (X[0] == 0)  // --even (0,2,4...)
                  Minor <= 8'd32; //"0100000";  //--32
                  else //--odd (1,3,5...)
                  Minor <= 8'd26; //"0011010";  //-- 26                                            
state_Wordoffset: if(Bel < 2)
                  begin	//--LUTA or LUTB (0,1)
                  if(Y_offset < Col_Half)// --Odd words from 1 to 25
                   word_offset <= (Y_offset >> 1)+1; //--Odd words 1,3,5.....49
                else   // --Even words from  to 50
                   word_offset <= (Y_offset >> 1)+2; //--Even words 52,24,....100
                 end   
                else if(Bel>1) 
                begin     //--LUTC or LUTD (2,3)
                  if(Y_offset < Col_Half)//then --Odd words from 26 to 50
                   word_offset <= (Y_offset >> 1) + 2; //--  //Even words 2,4,6.....50
                  else    //--Even words from 22 to 41
                   word_offset <= (Y_offset >> 1)+ 3;   //Odd words 51,25....101
                   end //-- 
state_done:         done_FAR<=1;
endcase
end

ila_3 your_instance_name (
	.clk(Clk), // input wire clk


	.probe0(A), // input wire [7:0]  probe0  
	.probe1(Hrow_cnt), // input wire [2:0]  probe1 
	.probe2(Y_offset), // input wire [7:0]  probe2 
	.probe3(Top), // input wire [0:0]  probe3 
	.probe4(HCLK), // input wire [4:0]  probe4 
	.probe5(Major), // input wire [9:0]  probe5 
	.probe6(Minor), // input wire [7:0]  probe6 
	.probe7(word_offset), // input wire [7:0]  probe7 
	.probe8(done_FAR), // input wire [0:0]  probe8 
	.probe9(Frame_address) // input wire [31:0]  probe9
);
endmodule
