
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpio.h"
#include <xdevcfg.h>
#include "xparameters.h"	/* SDK generated parameters */
#include "xsdps.h"		/* SD device driver */
#include "xil_printf.h"
#include "ff.h"
#include "xil_cache.h"
#include "xplatform_info.h"
#include "sd.h"
#include "pl.h"
#include "sleep.h"
#include "xgpio.h"
//#include "xtmrctr.h"

#define DDR_MEMORY_LOCATION 0x2000000
#define PL_BITSTREAM_A "Top.bin"
#define PL_BITSTREAM_B "output.bin"


/* Definitions for driver GPIO */
//#define XPAR_XGPIO_NUM_INSTANCES 1

/* Definitions for peripheral AXI_GPIO_0 */
#define XPAR_AXI_GPIO_0_BASEADDR 0x41200000
#define XPAR_AXI_GPIO_0_HIGHADDR 0x4120FFFF
#define XPAR_AXI_GPIO_0_DEVICE_ID 0

static XDcfg_Config *XDcfg_0;

XDcfg DcfgInstance;
XDcfg *DcfgInstPtr;
XGpio Gpio;
XGpio Num_frames;
XGpio Start_Addr;
XGpio OP_SEL;
XGpio Word_to_Write;
XGpio XYBEL;
XGpio INIT1;
XGpio INIT2;
XGpio rst;
XGpio Start;
XGpio bit_position;
XGpio_Config *GPIOConfigPtr;
//XTmrCtr TimerCounter;
//XTmrCtr *TmrCtrInstancePtr = &TimerCounter;

typedef enum {
	idle = 0, init, printMenu, getCommand, bufferBitFile, loadBitFile, exit, check_status
} te_state;

int programLoop();
int Drivers_Init()
{
	int Status;

	GPIOConfigPtr=XGpio_LookupConfig(XPAR_AXI_GPIO_0_DEVICE_ID);
	Status = XGpio_CfgInitialize(&Gpio, GPIOConfigPtr, GPIOConfigPtr -> BaseAddress);

	DcfgInstPtr=&DcfgInstance;
	XDcfg_0=XDcfg_LookupConfig(XPAR_XDCFG_0_DEVICE_ID);
	Status = XDcfg_CfgInitialize(DcfgInstPtr, XDcfg_0, XDcfg_0->BaseAddr);
	if (Status != XST_SUCCESS) {
	print("initialization failed");
	return XST_FAILURE;
	}
				/* DeSelect PCAP as the configuration device*/
	XDcfg_ClearControlRegister(DcfgInstPtr, XDCFG_CTRL_PCAP_PR_MASK);
    if (Status != XST_SUCCESS) {
	     return XST_FAILURE;
      }
	Status = XGpio_Initialize(&Start_Addr, XPAR_AXI_GPIO_0_DEVICE_ID);
	if (Status != XST_SUCCESS)  {
	return XST_FAILURE;
	}
	XGpio_SetDataDirection(&Start_Addr, 1, 0);
	print("\n\r Start_Addr GPIO Initilazed Successfully \n\r");

	Status = XGpio_Initialize(&INIT1, XPAR_AXI_GPIO_1_DEVICE_ID);
	if (Status != XST_SUCCESS)  {
	    return XST_FAILURE;
	}
	XGpio_SetDataDirection(&INIT1, 1, 0);
	print("\n\r Num_frames GPIO Initilazed Successfully \n\r");

	Status = XGpio_Initialize(&INIT2, XPAR_AXI_GPIO_2_DEVICE_ID);
	if (Status != XST_SUCCESS)  {
	    return XST_FAILURE;
	}
	XGpio_SetDataDirection(&INIT2, 1, 0);
	print("\n\r OP_SEL GPIO Initilazed Successfully \n\r");

	Status = XGpio_Initialize(&Num_frames, XPAR_AXI_GPIO_3_DEVICE_ID);
    if (Status != XST_SUCCESS)  {
		return XST_FAILURE;
	}
    XGpio_SetDataDirection(&Num_frames, 1, 0);
	print("\n\r XYBEL GPIO Initilazed Successfully \n\r");

	Status = XGpio_Initialize(&OP_SEL, XPAR_AXI_GPIO_4_DEVICE_ID);
    if (Status != XST_SUCCESS)  {
	    return XST_FAILURE;
	}
    XGpio_SetDataDirection(&OP_SEL, 1, 0);
	print("\n\r INIT1 GPIO Initilazed Successfully \n\r");
    Status = XGpio_Initialize(&XYBEL, XPAR_AXI_GPIO_5_DEVICE_ID);
    if (Status != XST_SUCCESS)  {
	    return XST_FAILURE;
	}
    XGpio_SetDataDirection(&XYBEL, 1, 0);
	print("\n\r INIT2 GPIO Initilazed Successfully \n\r");

	Status = XGpio_Initialize(&rst, XPAR_AXI_GPIO_6_DEVICE_ID);
	if (Status != XST_SUCCESS)  {
	    return XST_FAILURE;
	}
	XGpio_SetDataDirection(&rst, 1, 0);
    print("\n\r Reset GPIO Initilazed Successfully \n\r");

	Status = XGpio_Initialize(&Start, XPAR_AXI_GPIO_7_DEVICE_ID);
	if (Status != XST_SUCCESS)  {
	    return XST_FAILURE;
	}
	XGpio_SetDataDirection(&Start, 1, 0);
    print("\n\r Start GPIO Initilazed Successfully \n\r");

    Status = XGpio_Initialize(&bit_position, XPAR_AXI_GPIO_8_DEVICE_ID);
    if (Status != XST_SUCCESS)  {
    	    return XST_FAILURE;
    	}
    XGpio_SetDataDirection(&bit_position, 1, 0);
    print("\n\r Start GPIO Initilazed Successfully \n\r");

//    Status = XTmrCtr_Initialize(TmrCtrInstancePtr, XPAR_AXI_TIMER_0_DEVICE_ID);
 //   if (Status != XST_SUCCESS) {
 //   	return XST_FAILURE;
 //   }
 //   print("\n\r Timer GPIO Initialazed Successfully \n\r");


    return 0;

}

//int start_timer()
//{
//	XTmrCtr_SetOptions(TmrCtrInstancePtr, 0,	XTC_AUTO_RELOAD_OPTION);
//	XTmrCtr_SetResetValue(TmrCtrInstancePtr,0,0);
//	XTmrCtr_Reset(TmrCtrInstancePtr,0);
//	u32 Value1 = XTmrCtr_GetValue(TmrCtrInstancePtr, 0);
//	XTmrCtr_Start(TmrCtrInstancePtr, 0);
//	return Value1;
//}

//int stop_timer()
//{
//	XTmrCtr_Stop(TmrCtrInstancePtr,0);
//	u32 Value2 = XTmrCtr_GetValue(TmrCtrInstancePtr, 0);
//	return Value2;
//}

int Recnfg_Cntrl_rst()
{
	 XGpio_DiscreteWrite(&rst, 1, 1);
     XGpio_DiscreteWrite(&rst, 1, 0);
return 0;
	}

int Trigger()
{
	XGpio_DiscreteWrite(&rst, 1, 0);
	XGpio_DiscreteWrite(&rst, 1, 1);
	XGpio_DiscreteWrite(&rst, 1, 0);
    XGpio_DiscreteWrite(&Start, 1, 0);
	XGpio_DiscreteWrite(&Start, 1, 1);
	return 0;
	}

int read_frame()
{
	XGpio_DiscreteWrite(&OP_SEL, 1, 0x00000001);
	XGpio_DiscreteWrite(&Start_Addr, 1, 0x00420120);  //Slice X0Y0
	XGpio_DiscreteWrite(&Num_frames, 1, 0x00000001);

	return 0;
}

int Write_frame()
{
	XGpio_DiscreteWrite(&OP_SEL, 1, 0x00000002);
	XGpio_DiscreteWrite(&Start_Addr, 1, 0x00420120);  //Slice X0Y0
	XGpio_DiscreteWrite(&Num_frames, 1, 0x00000004);

	return 0;
}

int Read_Modify_Write_LUT()
{
	XGpio_DiscreteWrite(&OP_SEL, 1, 0x00000003);
	XGpio_DiscreteWrite(&XYBEL, 1, 0x00000001);    //SLICE X0Y0 Bel=1; //
	XGpio_DiscreteWrite(&INIT1, 1, 0xfffffffe);    //INIT={INIT2 INIT1}
	XGpio_DiscreteWrite(&INIT2, 1, 0xffffffff);

	return 0;
}

int Read_Modify_Write_FF()
{
	XGpio_DiscreteWrite(&OP_SEL, 1, 0x00000004);
	XGpio_DiscreteWrite(&Start_Addr, 1, 0x0042029f);   // frame_address
	XGpio_DiscreteWrite(&bit_position, 1, 0x00000B64); // bit_location in 101 frames

return 0;
	}

int Read_BRAM()
{
	XGpio_DiscreteWrite(&OP_SEL, 1, 0x00000000);
	XGpio_DiscreteWrite(&Start_Addr, 1, 0x000000cd);    //addr=205

	return 0;
	}

int programLoop() {
	te_state state = init;
	u32 Status;
	u32 size;
//	XGpio FF_Out;
//	XGpio Start;
//		int Q;
	const char *filename;
	char c = 0x00;

	while (1) {

		switch (state) {
		case init:
			xil_printf("*** Initializing the SD Card\r\n");
			// Initialize the SD Card and open the bit file
			Status = sdInit();

			if (Status != XST_SUCCESS) {
				xil_printf("Could not mount the SD Card\r\n");
				return XST_FAILURE;
			}

			state = printMenu;
			break;
		case idle:
			usleep(1000);
			state = getCommand;
			break;
		case printMenu:
			xil_printf("*** Command Menu\r\n");
			xil_printf("1: Load pattern A\r\n");
			xil_printf("2: Load pattern B\r\n");
			xil_printf("3: Print this menu\r\n");
			xil_printf("0: Exit\r\n");
			state = idle;
			break;
		case getCommand:
			xil_printf("*** Enter Command\r\n");
			// retrieve a character from the UART
			c = '2';//inbyte();
			if(c == '0') {
				state = exit;
				break;
			} else if( c == '1' ) {
				filename = PL_BITSTREAM_A;
				xil_printf("Loading Pattern A\r\n");
			} else if(c == '2') {
				filename = PL_BITSTREAM_B;
				xil_printf("Loading Pattern B\r\n");
			} else if(c == '3') {
				state = printMenu;
				break;
			}
			else {
				xil_printf("Unknown Command\r\n");
				state = idle;
				break;
			}
			state = bufferBitFile;
			break;
		case bufferBitFile:
			//xil_printf("*** Buffering the bitstream to DDR -- ");
			Status = sdOpenFile(filename);
			xil_printf("Open File on SD Card -- %s\r\n",Status == XST_SUCCESS ? "Success": "Failed");
			// Read the bit file into the DDR Memory
			size = GetFileSize();
			Status = sdLoadToMemory(0, DDR_MEMORY_LOCATION, size);
//			printmenu (DDR_MEMORY_LOCATION,size);
			xil_printf("File Size-- %dKB\r\n",size/1024);
			xil_printf("Loading file to DDR Memory -- %s\r\n",Status == XST_SUCCESS ? "Success": "Failed");
			state = loadBitFile;
			break;
		case loadBitFile:
			xil_printf("Loading the bitstream to the PL -- ");
			size = GetFileSize();
			xil_printf("\r\nFile Size-- %dKB\r\n",size/1024);
			u32 file_size_words = size/4;
			Status = plLoadBitstream(DDR_MEMORY_LOCATION, file_size_words);
			xil_printf("%s\r\n\r\n",Status == XST_SUCCESS ? "Success": "Failed");
			state = exit;
			break;
		case exit:
			xil_printf("*** Releasing the SD Card\r\n");
			sdRelease();
			xil_printf("*** Exiting\r\n");
			return XST_SUCCESS;
			break;
		default:
			return XST_FAILURE;
			break;
		}
	}

	return XST_FAILURE;

}

int main()
{
	int a, b,cc;
	int OptionNext = 1;
	int Exit = 0;
	int Status;
	OptionNext = '1';
	while(Exit != 1) {
			do {
				print("    1: Initialize All Drivers  \n\r");
				print("    2: Read_frame \n\r");
				print("    3: Write_frame \n\r");
				print("    4: Read_Modify_Write_LUT \n\r");
				print("    5: Read_Modify_Write_FF \n\r");
				print("    6: Read_BRAM  \n\r");
				print("> ");

				//inbyte();
				xil_printf("%c\n\r", OptionNext);
			} while (!isdigit(OptionNext));
		switch (OptionNext) {
					case '0':
							Exit = 1;
							break;
						case '1':
							xil_printf("Starting Driver's initilization\n\r");
							Drivers_Init();
							OptionNext='5';
							xil_printf("Driver Initilized!\n\r");
							break;
						case '2':     //Read_frame
							Recnfg_Cntrl_rst();
							read_frame();
                            Trigger();

							break;
						case '3':    //Write_frame
							Recnfg_Cntrl_rst();
							Write_frame();
                            Trigger();

							break;
						case '4': //Read_Modify_Write_LUT
							Recnfg_Cntrl_rst();
							Read_Modify_Write_LUT();
                            Trigger();

							break;
						case '5':   //Read_Modify_Write_FF

						    Status = programLoop();
							if (Status != XST_SUCCESS) {
							xil_printf("Error in execution of program! \r\n");
							return XST_FAILURE;
							}
							Recnfg_Cntrl_rst();
							Read_Modify_Write_FF();
						    Trigger();

							break;
						case '6':   //Read_BRAM
							Recnfg_Cntrl_rst();
							Read_BRAM();
						//	b=stop_timer();
							Trigger();
							break;
		}
	}

}