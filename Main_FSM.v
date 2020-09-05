`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Sir Syed CASE institute of Science and Technology, Islamabad
// Engineer: Bushra Sultana
// 
// Create Date: 06/21/2019 07:40:37 PM
// Design Name: VR_ZyCAP
// Module Name: Main_FSM
// Project Name: 
// Target Devices: Zedboard
// Tool Versions: 2016.3
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//module Main_FSM(
module Main_FSM(
input Clk,
input Reset,
input Start,
input [31:0] Op_Sel,
input [31:0] Num_frames,
input [31:0] Slice_XYBEL,
input [31:0] Initial_frameaddr,
input [63:0] LUT_INIT,
input [11:0] bit_location,
output Clock_dis,
//input addr2_Mod,
output GSR_clkEN
//output CAP
 );
 
wire word_ready, Sys_Start; 
wire read_done;
wire CSIB_R, CSIB_W;
wire RWB_R, RWB_W;
wire [31:0] I_R, I_W;
wire [31:0] OUT_ICAP;

reg  [2:0] Op_Sel_line;
 
wire [8:0] write_addr, read_addr; 
reg [31:0] Data_store, Words_to_Write, Num_frames_RD, frameaddr_RD, Num_frames_Wr, frameaddr_Wr;
wire [31:0] BRAM_input;
wire [31:0] BRAM_data;
reg we, Start_BF, Op_done, Start_Trans;
reg [9:0] Mem_addr_Wr;
reg Start_RD, Start_Wr;
wire [31:0] flipped_bit_Word;
wire Wr_en;
wire [31:0] frame_word0;
wire [31:0] frame_word1;
wire [31:0] frame_word2;
wire [31:0] frame_word3;


assign Wr_en=we;
assign GSR_clkEN=write_done;
assign BRAM_input = Data_store;

debounce D1(
    .clk(Clk)  ,  //--input clock
    .button(Start),  //--input signal to be debounced
    .result(Sys_Start)
     ); //--debounced signal


fsm_readframe FSM_RD( //input SYSCLK_P, input SYSCLK_N,input rst,
     .clk(Clk),
     .rst(Reset),
     .Start(Start_RD),
     .frame_Addr(frameaddr_RD),
     .Num_frame(Num_frames_RD),
     .word_ready(word_ready),
     .read_done(read_done),
     .CSIB_R(CSIB_R),
     .RWB_R(RWB_R),
     .I_R(I_R),
     .write_addr(write_addr),
     //.we(we),
     .Clk_de(Clock_dis)
    // .CAP(CAP)
 );
 
write_frame_fsm FSM_WR(
             .start(Start_Wr),
             .clk(Clk),
             .rst(Reset),
             .Num_frames(Num_frames_Wr),
             .frame_address(frameaddr_Wr),
             .I_W(I_W),
             .CSIB_W(CSIB_W),
             .RWB_W(RWB_W),                //    .read_done(1'd1),//read_done),
             .write_done(write_done),
             .state_reg(state_reg_write),
             .count(count_write),
             .Modified_Words(Words_to_Write),
             .read_addr(read_addr)//done)
              ); 
 wire msb_lsb;
 wire [31:0] Frameaddr_LUT;
LUT2frameAddr SLICE2FAR( 
              .Clk(Clk),
              .Reset(Reset),
              .Start(Start_Trans),
              .XYBel(Slice_XYBEL),
              .Frame_address(Frameaddr_LUT),
              .word_offset(word_offset),
              .msb_lsb(msb_lsb),
              .done_FAR(done_FAR)
              
                  );

INIT2frameWd INT2FRM( 
             .Clk(Clk),
             .Start(Start_Trans), 
             .INIT(LUT_INIT),
             .frame_word0(wordframes0),
             .frame_word1(wordframes1),
             .frame_word2(wordframes2),
             .frame_word3(wordframes3)

    );
wire [12:0] Addr2Mod;

bit_flip BF( .clk(Clk), 
             .start(Start_BF), 
             .rst(Reset), 
             .bit_location(bit_location), 
             .write_addr(Mem_addr_Wr), 
             .data_output(OUT_ICAP),
             .done(done_FF), 
             .modify_word1(flipped_bit_Word), 
             .addr2mod(Addr2Mod));


blk_mem_gen_0 BRAM (
         .clka(Clk),    // input wire clka
         .wea(Wr_en),      // input wire [0 : 0] wea
         .addra(Mem_addr_Wr),  // input wire [8 : 0] addra
         .dina(BRAM_input),    // input wire [31 : 0] dina
         .clkb(Clk),    // input wire clkb
         .addrb(Mem_address_R),  // input wire [8 : 0] addrb
         .doutb(BRAM_data)  // output wire [31 : 0] doutb
          ); 

 
ICAPE2 #  ( .DEVICE_ID(0'h23727093),  // Specifies the pre-programmed Device ID value to be used for simulation // purposes.
             .ICAP_WIDTH("X32"),               // Specifies the input and output data width. 
             .SIM_CFG_FILE_NAME("E:\my_projects\project_AND_OR\my.bit")        // Specifies the Raw Bitstream (RBT) file to be parsed by the simulation // model. 
  ) 
  
  ICAPE2_inst ( .O(OUT_ICAP),              // 32-bit output: Configuration data output bus 
               .CLK(Clk),                        // 1-bit input: Clock Input 
               .CSIB(CE),                      // 1-bit input: Active-Low ICAP Enable 
               .I(I),                            // 32-bit input: Configuration data input bus 
               .RDWRB(RW)                    // 1-bit input: Read/Write Select input
  ); 

//STARTUPE2 #(
//        .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
//        .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency(ns) for simulation.
//     )
//     STARTUPE2_inst (
//        .CFGCLK(CFGCLK),       // 1-bit output: Configuration main clock output
//        .CFGMCLK(CFGMCLK),     // 1-bit output: Configuration internal oscillator clock output
//        .EOS(EOS),             // 1-bit output: Active high output signal indicating the End Of Startup.
//        .PREQ(PREQ),           // 1-bit output: PROGRAM request to fabric output
//        .CLK(CLK),             // 1-bit input: User start-up clock input
//        .GSR(write_done),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
//        .GTS(GTS),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
//        .KEYCLEARB(KEYCLEARB), // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
//        .PACK(PACK),           // 1-bit input: PROGRAM acknowledge input
//        .USRCCLKO(USRCCLKO),   // 1-bit input: User CCLK input
//        .USRCCLKTS(USRCCLKTS), // 1-bit input: User CCLK 3-state enable input
//        .USRDONEO(USRDONEO),   // 1-bit input: User DONE pin output control
//        .USRDONETS(USRDONETS)  // 1-bit input: User DONE 3-state enable output
//     );

reg CE, RW;
reg [31:0] I;
reg [8:0] Mem_address_W;
reg [8:0] Mem_address_R;

assign frame_word0=(Mem_addr_Wr==9'd105)?OUT_ICAP:frame_word0;   
assign frame_word1=(Mem_addr_Wr==9'd206)?OUT_ICAP:frame_word1;
assign frame_word2=(Mem_addr_Wr==9'd307)?OUT_ICAP:frame_word2;
assign frame_word3=(Mem_addr_Wr==9'd408)?OUT_ICAP:frame_word3;

//reg [31:0] Newwords0;
//reg [31:0] Newwords1;
//reg [31:0] Newwords2;
//reg [31:0] Newwords3;

wire [31:0] Newwords0;
wire [31:0] Newwords1;
wire [31:0] Newwords2;
wire [31:0] Newwords3;
wire [15:0] wordframes0;
wire [15:0] wordframes1;
wire [15:0] wordframes2;
wire [15:0] wordframes3;

//always@(posedge Clk)
//begin
//if(msb_lsb==1'd1)
//begin//-- LUT B or D , modify MSB
assign Newwords0 = msb_lsb?({(wordframes0), frame_word0[15:0]}):({frame_word0[31:16],(wordframes0)});
assign Newwords1 = msb_lsb?({(wordframes1),frame_word1[15:0]}):({frame_word1[31:16], (wordframes1)});
assign Newwords2 = msb_lsb?({(wordframes2), frame_word2[15:0]}):({frame_word2[31:16],(wordframes2)});
assign Newwords3 = msb_lsb?({(wordframes3), frame_word3[15:0]}):({frame_word3[31:16],(wordframes3)});//--Goldwords(0)(15 downto 0);--keep LSB unchanged
//Newwords1 <= wordframes1 & frame_word1;//--Goldwords(1)(15 downto 0);--keep LSB unchanged
//Newwords2 <= wordframes2 & frame_word2;//--Goldwords(2)(15 downto 0);--keep LSB unchanged
//Newwords3 <= wordframes3 & frame_word3; end//--Goldwords(3)(15 downto 0);--keep LSB unchanged
//else
//begin	//--LUT A or C, modify LSB
//Newwords0 <= frame_word0 & wordframes0; //-- keep MSB unchanged ;Goldwords(0)(31 downto 16)
//Newwords1 <= frame_word1 & wordframes1; //-- keep MSB unchanged ;Goldwords(1)(31 downto 16)
//Newwords2 <= frame_word2 & wordframes2; //-- keep MSB unchanged ;Goldwords(2)(31 downto 16)
//Newwords3 <= frame_word3 & wordframes3; end

//end

//assign CE = Op_Sel_line?CSIB_R:CSIB_W;
//assign RW = Op_Sel_line?RWB_R:RWB_W;
//assign I = Op_Sel_line?I_R:I_W;
//assign we = Op_Sel_line?word_ready:we;
//assign Mem_address_W = Op_Sel_line?write_addr;
//assign Data_store = Op_Sel_line?OUT_ICAP;
//assign Data_store = Op_Sel_line?OUT_ICAP;

//always@(posedge Clk)
//if(Reset)
//begin
//       CE<=0;
//       RW<=0;
//       I<=0; 
//       we<=0;
//       Mem_address_W<=0;
//       Mem_address_R<=0;
//       Data_store <= 0;
//       Words_to_Write <=0;
//end
//else
//case(Op_Sel_line)

//3'd1: begin 
//       CE <= CSIB_R;
//       RW <= RWB_R;
//       I <=  I_R;
//       we <= word_ready;   
//       Mem_address_W<=write_addr;
//       Data_store <= OUT_ICAP;
//      end
      
//3'd2: begin
//       CE <= CSIB_W;
//       RW <= RWB_W;
//       I <=  I_W; 
//       Words_to_Write <= BRAM_data; 
//       Mem_address_R<=read_addr;
//      end

//endcase

reg [4:0] Next_state; 
reg [3:0] cnt_words2;

parameter [4:0] state_rst=5'd0, state_Read=5'd1, state_Write=5'd2, state_Modify_LUT=5'd3, state_Modify_FF=5'd4, state_Read_BRAM=5'd5,
state_done=5'd6, state_Read_LUT=5'd7, state_Modify_frame=5'd8, state_Read_FF=5'd9, state_write1=5'd10;

wire done_FAR, done_FF;
always@(posedge Clk)
begin
if(Reset)
   Next_state <= state_rst;
else if(Sys_Start)
case(Next_state)
state_rst :  if(Op_Sel==32'd1)
             Next_state <= state_Read;
             else if(Op_Sel==32'd2)
             Next_state <= state_Write;
             else if(Op_Sel==32'd3)
             Next_state<= state_Modify_LUT;
             else if(Op_Sel==32'd4)
             Next_state<= state_Modify_FF;
             else if (Op_Sel==32'd5)
             Next_state<= state_Read_BRAM;
state_Read:  if(read_done==0)
             Next_state<=state_Read;
             else Next_state <= state_done;
state_Write: if(write_done==0)
                 Next_state<=state_Write;
             else Next_state <= state_done;
state_Modify_LUT:  if(done_FAR)
                   Next_state <= state_Read_LUT;
                   else Next_state<=state_Modify_LUT;
state_Read_LUT:    if(read_done)
                   Next_state<=state_Modify_frame;
                   else 
                   Next_state<=state_Read_LUT;
state_Modify_frame: 
                   if(done_FF)
                   Next_state<= state_write1;
                   else if(cnt_words2 == 0)
                   Next_state<= state_Modify_frame;
                   else if(cnt_words2 == 1)
                   Next_state<= state_Modify_frame;
                   else if(cnt_words2 == 2)
                   Next_state<= state_Modify_frame;
                   else if(cnt_words2 == 3)
                   Next_state<= state_Modify_frame;
                   else if(cnt_words2 == 4)
                   Next_state<= state_write1;
                   
state_write1:      if(write_done==1)
                    Next_state <= state_done; 
                    
state_Modify_FF:   Next_state<=state_Read_FF;
state_Read_FF:     if(read_done)
                   Next_state<=state_Modify_frame;
                   else 
                   Next_state<=state_Read_FF;
endcase   
end

always@(posedge Clk)
begin 
if(Reset)
   begin
       Start_RD<=0;
       Start_Wr<=0;
       Op_Sel_line<=0;
   end
else
case (Next_state)
state_Read: begin//Initialize all signals
               CE <= CSIB_R;
               RW <= RWB_R;
               I <=  I_R;
               we <= word_ready;   
               Mem_addr_Wr<=write_addr;
               Data_store <= OUT_ICAP;
               Start_RD <=1;
            //   Op_Sel_line <= 3'd1;
               Num_frames_RD <= Num_frames;
               frameaddr_RD <= Initial_frameaddr;
               //Mem_addr_Wr<=9'd0;
               if(read_done==1)
               Start_RD <=0;
             end
state_Write: begin
               CE <= CSIB_W;
               RW <= RWB_W;
               I <=  I_W; 
               Words_to_Write <= BRAM_data; 
               Mem_address_R<=read_addr;
               Start_Wr <=1;
          //     Op_Sel_line <= 3'd2;
               Num_frames_Wr <= Num_frames;
               frameaddr_Wr <= Initial_frameaddr;
               if(write_done==1)
               Start_Wr <= 0; 
             end

state_Modify_LUT:  begin
                Start_Trans <=1;
                if(done_FAR)
                begin
                Num_frames_RD <= 32'd4;
                Num_frames_Wr <= 32'd4;
                frameaddr_RD <= Frameaddr_LUT;
                frameaddr_Wr <= Frameaddr_LUT;
                
                end
                   end
state_Read_LUT: begin 
               CE <= CSIB_R;
               RW <= RWB_R;
               I <=  I_R;
               we <= word_ready;   
               Mem_addr_Wr<=write_addr;
               Data_store <= OUT_ICAP;
               Start_RD <=1;
                //Op_Sel_line <= 3'd1;
                if(read_done)
                Start_RD<=0;
                else Start_RD<=1;
                cnt_words2 = 0;
                 
             end

state_Modify_frame: begin
                 if(done_FF)
                 begin
                 we <=1'd1;
                 Mem_addr_Wr <= Addr2Mod;
                 Data_store <= flipped_bit_Word; end
                 Op_Sel_line <= 3'd0;
                 if(cnt_words2 == 0)
                 begin  //  --Modify four words with Newwords content
                  we <=1'd1;
                  Mem_addr_Wr <= 9'd101 + 5;//--unsigned(word_offset_s);  --address of the word to change
                  Data_store <=Newwords1;//--x"00000000";--x"0000ffff";--(cnt_words2);--x"00000001";--Newwords(1);     --2nd word
                  cnt_words2 <= cnt_words2+1; end
                  
                 else if(cnt_words2 ==1) 
                 begin
                  we <=1'd1;
                  Mem_addr_Wr <=  Mem_addr_Wr  + 101;//--unsigned(word_offset_s);  --address of the word to change
                  Data_store <=Newwords0;//--x"00000080";--x"0000ffff";--x"00000080";--(cnt_words2);--Newwords(0);     --ist word
                  cnt_words2 <= cnt_words2+1; end
                                                   
                 else if(cnt_words2 ==2) 
                 begin
                  we <=1'd1;
                  cnt_words2 <= cnt_words2+1;
                  Mem_addr_Wr <=  Mem_addr_Wr  + 101;// --go to the next frame
                  Data_store <=Newwords3; end//--x"00000000"; --x"0000feff";--Newwords(3);--(cnt_words2);--Newwords(3);        --4th word
                 
                 else if(cnt_words2 == 3) 
                 begin
                 we <=1'd1;
                 cnt_words2 <= cnt_words2+1;
                 Mem_addr_Wr <=  Mem_addr_Wr  + 101;// --go to the next frame     
                 Data_store <= Newwords2; end//--x"00000000";--x"0000ffff";--Newwords(2);--(cnt_words2);--Newwords(2);     --3rd word
                 end
                 
                // framesonbram_s <='1';    
state_write1:   begin 
              if(write_done==1)
                    Start_Wr <= 1'd0; 
                  else 
                    Start_Wr <= 1'd1;
                CE <= CSIB_W;
                RW <= RWB_W;
                I <=  I_W; 
                Words_to_Write <= BRAM_data; 
                Mem_address_R<=read_addr;
           //    Start_Wr <=1;
                 Mem_addr_Wr <=1'd0;
                 we<=0;
                // Op_Sel_line <= 3'd2;  
                  end                                                

state_Modify_FF:  begin
                  Num_frames_RD <= 32'd1;
                  Num_frames_Wr <= 32'd1;
                  frameaddr_RD <= Initial_frameaddr; //32'h0042011f;
                  frameaddr_Wr <= Initial_frameaddr;//32'h0042011f;
                  end                                              
                   
state_Read_FF:   begin
                  CE <= CSIB_R;
                  RW <= RWB_R;
                   I <=  I_R;
                  we <= word_ready;   
                  Mem_addr_Wr<=write_addr;
                  Data_store <= OUT_ICAP;
                  Start_RD <=1;
                  Start_BF<=1;
                  Op_Sel_line <= 3'd1;
                 if(read_done)
                  Start_RD<=0;
                 else Start_RD<=1;
                 end
                
state_done:     Op_done<=1;
                


endcase
end
 
ila_0 ila_BRAM
(
            .clk(Clk),
            .probe0(OP_Sel),  //[2:0] 
            .probe1(BRAM_input), //[31:0]
            .probe2(RW),    
            .probe3(Start_RD), 
            .probe4(ReadWordICAP), //[31:0], 
            .probe5(Mem_addr_Wr), //[9:0]
            .probe6(BRAM_data), //[31:0]
            .probe7(I), 
            .probe8(Mem_addr_R),
            .probe9(word_ready_s),
            .probe10(CE),
            .probe11(Start_Trans),
            .probe12(BRAM_input),
            .probe13(clk_100),
            .probe14(CSIB_W),
            .probe15(Sys_Start),
            .probe16(Mem_address_R),
            .probe17(Words_to_Write),
            .probe18(Addr2Mod),//addr2_Mod),   //[12:0]
            .probe19(Data_store),//Mod_frame),
            .probe20(frame_word0),
            .probe21(frame_word1),
            .probe22(frame_word2),
            .probe23(frame_word3),
            .probe24(wordframes3),//addra_s),
            .probe25(wordframes0),
            .probe26(wordframes1),
            .probe27(wordframes2),
            .probe28(cnt_words2),//icap_not_swapped),
            .probe29(done_FAR),//icap_swapped),
            .probe30(Initial_frameaddr),
            .probe31(Num_frames),
            .probe32(frameaddr_RD),//Frameaddr_LUT),
            .probe33(word_ready),//OP_SEL_s),
            .probe34(Start_Wr),
            .probe35(write_done),
            .probe36(Start_BF),
            .probe37(Next_state),  //[5:]
            .probe38(OUT_ICAP),
            .probe39(read_done),
            .probe40(Wr_en),
            .probe41(flipped_bit_Word), //[31:0]
            .probe42(Op_Sel)
            
        );		 
  
endmodule
