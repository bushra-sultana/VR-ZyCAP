# VR-ZyCAP
A Zynq based reconfiguration controller, allows run time reconfiguration of LUT &amp; FF.

VR-ZyCAP is capable of performing 5 operations. Read frame, Write frame, DPR_LUT, DPR_FF, Read Memory.
Each function is performed based on Op_Sel value; 
For Read frame = Op_Sel -> 1, Write frame = Op_Sel->2, DPR_LUT = Op_Sel->3, DPR_FF = Op_Sel->4, Read Memory = Op_Sel->5
-	Read frame operation requires two input parameter;  Initial frame address, Number of frames to read (Maximum we can read 4 frames constrained by memory space)
-	Write frame Operation also require two input parameter; Initial frame address, Number of frames to write (BRAM data will be written to configuration memory)
-	DPR_LUT requires two input parameter; XYBEL,  Initialization Value (INIT)
-	DPR_FF also requires two input parameter; Initial frame address, bit_location
-	Read Memory function require memory address to read data from memory.

The above parameters are passed through inbyte() function in RMW.c file in Xilinx SDK. 
When we’ll run code, first it will ask to provide next option to perform different operations.
Option 1: Initialize all driver
Option 2: Read frame
Option 3: Write frame
Option 4: Read_Modify_Write_LUT
Option 5: Read_Modify_Write_FF
Option 6: Read_Memory
First, Option 1 is selected to initialize drivers. Then any other option can be selected to perform different operation. 
-	When Read frame function is selected; it will ask to input Op_Sel, Initial frame address and Num of frames
-	When Write frame function is selected; it will ask to provide Op_Sel, Initial frame address and Num of frames
-	When DPR_LUT function is selected; it will ask to provide Op_Sel, XYBEL and Initialization Value.
-	When DPR_FF function is selected; it will ask to provide Op_Sel, XYBEL and Initialization Value.
-	When Read Memory function is selected; it will ask to provide Op_Sel,and Mem_addr.

The ICAP output can be seen on Integrated Logic Analyzer (ILA) in Vivado IDE, BRAM_ILA shows ICAP input and output data. 

	In Read frame function, frames are read on OUT_ICAP signal. 
	In Write frame function, written frames can be seen on I signal.
	In DPR-LUT function, Read frame and Write frames can be seen on above signals in logic analyzer. Also for SliceX0Y0 where LUT is placed within the Verilog code. The change in logic (from AND to OR) can be seen on Zedborad using Dip Switches and LEDs.   
	In DPR-FF function, first we will done RAR configuration by loading partial bitstream. The partial bitstream for DUT (output.bin) should be stored in binary format in SD Card. In program loop function within RMW.c file, partial bitstream is read from SD CARD and load to DRAM, from where it is sent to configuration memory using PCAP. So DPR-FF function will first load partial bitstream to configuration memory, which will off the done led (blue) on Zedborad. Then input parameter to Read_Modify_Write function is passed through SDK terminal. And Modified bit can be seen on BRAM_ILA on OUT_ICAP, I signal. Also done led will be high after completion of operation.
	In Read BRAM function, Memory address is passed and output can be seen on BRAM data signal. 
	There are other signals for debugging like; BRAM_input, Mem_addr_R, Mem_addr_Wr, CSIB, RWB etc.
