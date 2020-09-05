`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sir Syed Institute of Science and Technology
// Engineer: Bushra Sultana
// 
// Create Date: 08/17/2019 07:30:37 PM
// Design Name: VR-ZyCAP
// Module Name: write_frame
// Project Name: 
// Target Devices:   Zedboard
// Tool Versions:  2016.3
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module write_frame_fsm( 
input clk, input rst, input start, output reg write_done, 
input [31:0] Num_frames,
input [31:0] frame_address,
output  [31:0] I_W,
//output [31:0] data_output,
output  CSIB_W, RWB_W,
output reg [5:0] state_reg,
output reg [9:0] count,
input [31:0] Modified_Words,
output reg [9:0] read_addr
//input [31:0] input_frames,
//input start_frame

    );
 
wire [15:0] Num_frame_words;
wire [31:0] frame_words,Unswapped_data; 
reg [31:0] Swapped_data;    
assign Num_frame_words= (Num_frames+1) * 7'd101;
//assign Num_frame_words=decimaltohexa(Num_frame_words);
wire [15:0] num = 16'hA00;
assign frame_words= {16'hA000, Num_frame_words};
    
 reg [31:0] d_in; 
 wire [31:0] data_output;  
 //reg [5:0] state_reg;
 //reg [9:0] count=101;
 reg [9:0] count1=0;
 reg CE, write;
 
assign I_W = d_in;  
assign CSIB_W = CE;
assign RWB_W = write;   

assign Unswapped_data = frame_address;

integer i, j;

always@(posedge clk)
begin
if(rst)
Swapped_data<=0;
else if(Unswapped_data)
begin
 for(i=0; i<4; i=i+1)
 begin
       for(j=0; j<8; j=j+1)
     Swapped_data[(i*8) + (7-j)] <= Unswapped_data[(i*8)+j];
 end
end
end
 
 always@(posedge clk)
 begin
 if(rst)
 begin
 state_reg<=6'd0;
 d_in<=32'd0; 
 CE<=1;
 write<=1;
 write_done<=0;
 count<=0;
 read_addr<=9'd104;;
  end
 else if(start)
 case(state_reg)
 6'd0: begin 
       d_in<=32'h00000000;
       write<=1;
       CE<=1;
       state_reg<=6'd1;
       end
 6'd1: begin 
             d_in<=32'h00000000;
             write<=0;
             CE<=1;
             state_reg<=6'd2;
             end
 //
 5'd2: begin
       write<=0;
       CE<=0;
       d_in<=32'hFFFFFFFF;
  //     if(count==3)
       state_reg<=5'd3;
    //   else begin state_reg<=state_reg;
   //        count<=count+1; end
       end
 5'd3: begin
        d_in<=32'h000000DD;
        CE<=0;
        write<=0;
        state_reg<=5'd4;
        end
 5'd4: begin
        d_in<=32'h88440022;
        CE<=0;
        write<=0;
        state_reg<=5'd5;
       end 
 //dummy_word--
 5'd5:  begin
        d_in<=32'hFFFFFFFF;
        CE<=0;
        write<=0;
        state_reg<=5'd6;
        end   
//sync_word//
 5'd6:  begin
         d_in<=32'h5599AA66;
         CE<=0;
         write<=0;
         state_reg<=5'd8;
         end 
 //noop  
 5'd7:  begin
         d_in<=32'h04000000;
         CE<=0;
         write<=0;
         state_reg<=5'd8;
         end 
 5'd8:  begin
         d_in<=32'h04000000;
         CE<=0;
         write<=0;
         state_reg<=5'd9;
         end
//write_to_cmd
 5'd9:  begin
          d_in<=32'h0C000180;        //30008001
          CE<=0;
          write<=0;
          state_reg<=5'd10;
          end
 //RCRC
 5'd10:  begin
          d_in<=32'h000000E0;           //00000007
          CE<=0;
          write<=0;
          state_reg<=5'd11;
          end
 //NOOP
 //5'd9:  begin
 //         d_in<=32'h000000E0;
 //         CE<=0;
 //         write<=0;
 //         state_reg<=5'd10;
 //         end
//NOOP
 5'd11:  begin
           d_in<=32'h04000000;            //20000000
            CE<=0;
            write<=0;
            state_reg<=5'd12;
          end
 5'd12:  begin
             d_in<=32'h04000000;
             CE<=0;
             write<=0;
             state_reg<=5'd13;
          end
 //write_ID_reg
 5'd13: begin
              d_in<=32'h0C800180;           //30018001
              CE<=0;
              write<=0;
              state_reg<=5'd14;
        end
 //ID_CODE
 5'd14: begin 
              d_in<=32'hC44E0EC9;               //23727093
              CE<=0;
              write<=0;
              state_reg<=5'd16;
          end 
////5'd14: begin
//               d_in<=32'hC44E0EC9;
//               CE<=0;
//               write<=0;
//               state_reg<=5'd15;
//         end 
//NOOP
5'd15: begin
               d_in<=32'h04000000;
               CE<=0;
               write<=0;
               state_reg<=5'd16;
       end
//write_to_FAR_reg
5'd16: begin
               d_in<=32'h0C000480;             //30002001
               CE<=0;
               write<=0;
               state_reg<=5'd17;
              end
//Frame_Address_reg
5'd17: begin
               d_in<=Swapped_data;//Swapped_data;//frame_address;//32'h00428004;
               CE<=0;
               write<=0;
               state_reg<=5'd18;
               end
//NOOP
5'd18: begin
                d_in<=32'h04000000;
                CE<=0;
                write<=0;
                state_reg<=5'd19;
                end
 //write_to_CMD
5'd19:   begin
                d_in<=32'h0C000180;                //30008001
                CE<=0;
                write<=0;
                state_reg<=5'd20;
             end 
 //write_CFG
5'd20:   begin
                d_in<=32'h00000080;               //00000001
                CE<=0;
                write<=0;
                state_reg<=5'd21;
             end
//NOOP
5'd21:       begin
                d_in<=32'h04000000;            //20000000
                CE<=0;
                write<=0;
                state_reg<=5'd22;
               end 
 //write_to_FDRI
5'd22:       begin
                 d_in<=32'h0C000200; //32'h0C000280 //30004000
                   CE<=0;
                   write<=0;
                   state_reg<=5'd23;
               end
 //write_no_of_words
5'd23:       begin
                 d_in<=frame_words;//32'h0A000053;//32'h0A00809f;//frame_words;//32'h0A00809f;           //write 505 words  --500000CA
                  CE<=0;
                  write<=0;
                  state_reg<=5'd25;
                 // count<=101;
              end
//state_NOOP           
6'd24:        begin         
                    d_in<=32'h04000000; 
                    CE<=0;
                    write<=0;
                    state_reg<=6'd25;
               end 
 
//6'd24:                   begin
//                                                                  CE<=0;
//                                                                  write<=1;
//                                                                  state_reg<=6'd24;
//                                                    end              
//write_scrubbed_Words
5'd25:       begin
                  if(count==Num_frame_words-101)
                  state_reg<=5'd26;
                  else begin 
                  count<=count+1;
                  state_reg<=state_reg;
                  d_in<=Modified_Words; 
                  read_addr<=read_addr+1;
                  end
                  CE<=0;
                  write<=0;
                 // write_done<=1;
                  
             end
//write_pad_data      
5'd26:       begin
                  d_in<=32'h00000000;
                  if(count1==8'd101)
                  state_reg<=5'd29;
                  else 
                  begin
                  count1<=count1+1;
                  state_reg<=state_reg; end
                  CE<=0;
                  write<=0;
                 end  
                          
/////type1_write_1_word_to_CRC
//5'd27:       begin
//              d_in<=32'h0C000080;      //30008001
//              CE<=0;
//              write<=0;
//              state_reg<=5'd28;
//              end
//5'd28:       begin
//              d_in<=32'h00000050;      //0000000A
//              CE<=0;
//              write<=0;
//              state_reg<=5'd29;
//              end
              
5'd29:       begin
              d_in<=32'h0C000180;      //20000000
               CE<=0;
               write<=0;
               state_reg<=5'd30;
             end
             
 5'd30:       begin
             d_in<=32'h000000E0;      //3000C001
              CE<=0;
              write<=0;
              state_reg<=5'd31;
              end                     
              
//write_to_FAR_Register             
 5'd31:       begin
             d_in<=32'h04000000;         //00000100
             CE<=0;
             write<=0;
             state_reg<=6'd32;
                                       end
      //setup FAR
6'd32:       begin
             d_in<=32'h04000000;         //3000A001
             CE<=0;
             write<=0;
             state_reg<=6'd33;
               end
//type1_write_1_CMD
6'd33:       begin
             d_in<=32'h0C000480;         //00000000
             CE<=0;
             write<=0;
             state_reg<=6'd34;
              end
6'd34:       begin
             d_in<=32'h00600801;         //30008001
             CE<=0;
             write<=0;
             state_reg<=6'd35;
             end
                           
6'd35:       begin
             d_in<=32'h0C000180;     //00000005
             CE<=0;
             write<=0;
             state_reg<=6'd36;
             end
//type1_write_1_word_to_CMD                                               
6'd36:       begin
             d_in<=32'h000000E0;    //20000000
             CE<=0;
             write<=0;
            state_reg<=6'd37;
             end                                                                 
6'd37:       begin
            d_in<=32'h04000000;    //30002001
            CE<=0;
            write<=0;
            state_reg<=6'd38;
            end
      
 //write 1 word to FAR                                                                
6'd38:       begin
             d_in<=32'h04000000;    //30002001
             CE<=0;
             write<=0;
             state_reg<=6'd39;
             end
//////write 1 word to FAR                                                                
 
6'd39:       begin
            d_in<=32'h0C000180; //Swapped_data;//frame_address;//32'h00428084;    
             CE<=0;
             write<=0;
             state_reg<=6'd40;
             end
//dummy
6'd40:       begin
              d_in<=32'h000000B0;    //30008001
             CE<=0;
             write<=0;
             state_reg<=6'd41;
             end  
 //desynch
6'd41:       begin
             d_in<=32'hFFFFFFFF;    //0000000D
             CE<=0;
             write<=0;
             state_reg<=6'd42;
                                                                end
6'd42:       begin
                  d_in<=32'hFFFFFFFF;     //20000000
                 CE<=0;
                 write<=0;
                 state_reg<=6'd43;
                         end
//dummy
6'd43:       begin
                  d_in<=32'h04000000;          //30002001
                  CE<=0;
                  write<=0;
                  state_reg<=6'd43;
             end
// //NOOP
6'd44:       begin
                  d_in<=32'h04000000;
                   CE<=0;
                   write<=0;
                   state_reg<=6'd44;
                   write_done<=1;
                          end
6'd45:       begin
                   d_in<=32'hAAAAAAAA;
                    CE<=1;
                    write<=1;
                    state_reg<=6'd45;
                    write_done<=1;
             end

 endcase
    
 end 
 
      
ila_2 ila_write_frame(
                .clk(clk), // input wire clk
               .probe0(d_in), // input wire [31:0]  probe0  
               .probe1(read_addr), // input wire [31:0]  probe1 
               .probe2(state_reg), // input wire [63:0]  probe2 
               .probe3(write), // input wire [0]  probe3 
               .probe4(CE),
               .probe5(start),
               .probe6(rst),
               .probe7(count),
               .probe8(count1)
          //     .probe8(write_done),
          //     .probe9(NOOP3),
          //     .probe10(NOOP5),
          //     .probe11(NOOP6),
          //     .probe12(count1),
          //     .probe13(NOOP9)
                // input wire [0]  probe4
           ); 

                                   
endmodule