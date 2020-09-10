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


This Controller is described in a research paper mentioned below, that is under review in IEEE Transaction in computer Aided design (TCAD).

Research paper Title:  "VR-ZyCAP: A Versatile Resource-level ICAPController for ZynQ SoC"

Authors: Bushra Sultana, Anees Ullah, Arslan Malik, Ali Zahir, Pedro Reviriego, Fahad bin Muslim
