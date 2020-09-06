/******************************************************************************
*
* Copyright (C) 2012 - 2017 Xilinx, Inc.  All rights reserved.
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal 
* in the Software without restriction, including without limitation the rights 
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell  
* copies of the Software, and to permit persons to whom the Software is 
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in 
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications: 
* (a) running on a Xilinx device, or 
* (b) that interact with a Xilinx device through a bus or interconnect.  
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF 
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in 
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/
/*****************************************************************************/
/**
*
* @file sd.c
*
* Contains code for the SD card FLASH functionality.
*
* <pre>
* MODIFICATION HISTORY:
*
* Ver	Who	Date		Changes
* ----- ---- -------- -------------------------------------------------------
* 1.00a sc	01/26/16 Initial release - based on V12.00a of sd.c from FSBL
*
* </pre>
*
* @note
*
******************************************************************************/

/***************************** Include Files *********************************/
#include "xparameters.h"
#include "xil_printf.h"

#if defined(XPAR_PS7_SD_0_S_AXI_BASEADDR) || defined(XPAR_XSDPS_0_BASEADDR)

#include "xstatus.h"
#include "ff.h"
#include "sd.h"

/************************** Constant Definitions *****************************/

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/
/******************************************************************************/
/**
*
* This function copies a string to another, the source string must be null-
* terminated.
*
* @param 	Dest is starting address for the destination string
* @param 	Src is starting address for the source string
*
* @return	Starting address for the destination string
*
****************************************************************************/
char *strcpy_rom(char *Dest, const char *Src)
{
	unsigned i;
	for (i=0; Src[i] != '\0'; ++i)
		Dest[i] = Src[i];
	Dest[i] = '\0';
	return Dest;
}

/************************** Function Prototypes ******************************/

/************************** Variable Definitions *****************************/

static FIL fil;		/* File object */
static FATFS fatfs;
static char buffer[32];
static char *bit_file = buffer;

/******************************************************************************/
/******************************************************************************/
/**
*
* This function initializes the controller for the SD FLASH interface.
*
* @param	filename of the file that is to be used
*
* @return
*		- XST_SUCCESS if the controller initializes correctly
*		- XST_FAILURE if the controller fails to initializes correctly
*
* @note		None.
*
****************************************************************************/
u32 sdInit()
{

	FRESULT rc;
	TCHAR *path = "0:/"; /* Logical drive number is 0 */

	/* Register volume work area, initialize device */
	rc = f_mount(&fatfs, path, 0);

	if (rc != FR_OK) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;

}

/******************************************************************************/
/**
*
* This function provides the SD FLASH interface to Memory transfer
*
* @param	none
*
* @return
*		- u32 size of file in bytes
*
* @note		None.
*
****************************************************************************/
u32 GetFileSize() {

	return fil.fsize;

}

/******************************************************************************/
/**
*
* This function provides the SD FLASH interface to Memory transfer
*
* @param	SourceAddress is address in FLASH data space
* @param	DestinationAddress is address in DDR data space
* @param	LengthBytes is the number of bytes to move
*
* @return
*		- XST_SUCCESS if the read/write completes correctly
*		- XST_FAILURE if the read/write fails to completes correctly
*
* @note		None.
*
****************************************************************************/
u32 sdLoadToMemory( u32 SourceAddress, u32 DestinationAddress, u32 LengthBytes)
{

	FRESULT rc;	 /* Result code */
	UINT br;

	rc = f_lseek(&fil, SourceAddress);
	if (rc) {
		xil_printf("SD: Unable to seek to %lx\r\n", SourceAddress);
		return XST_FAILURE;
	}

	rc = f_read(&fil, (void*)DestinationAddress, LengthBytes, &br);

	if (rc) {
		xil_printf("*** ERROR: f_read returned %d\r\n", rc);
	}

	return XST_SUCCESS;

} /* End of SDAccess */

/******************************************************************************/
/**
*
* This function opens the file object
*
* @param	filename is a filename of the file to open on the SD Card
* 
* @return	None.
*   	- XST_SUCCESS if the file opens correctly
*		- XST_FAILURE if the file cannot be opened
*
* @note		None.
*
****************************************************************************/
u32 sdOpenFile(const char *filename) {
	FRESULT rc;	 /* Result code */
	strcpy_rom(buffer, filename);
	bit_file = (char *)buffer;

	rc = f_open(&fil, bit_file, FA_READ);
	if (rc) {
		xil_printf("SD: Unable to open file %s: %d\r\n", bit_file, rc);
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

/******************************************************************************/
/**
*
* This function closes the file object
*
* @param	None
*
* @return	None.
*
* @note		None.
*
****************************************************************************/
void sdRelease(void) {

	f_close(&fil);
	return;


}
#endif


