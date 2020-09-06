/******************************************************************************
 *
 * Copyright (C) 2010 - 2017 Xilinx, Inc.  All rights reserved.
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
 * @file  xdcfg_polled_example.c
 *
 * This file contains a polled mode design example for the Device Configuration
 * Interface. This example downloads a given bitstream to the FPGA fabric.
 *
 * @note		None.
 *
 * MODIFICATION HISTORY:
 *
 *<pre>
 * Ver   Who  Date     Changes
 * ----- ---- -------- ---------------------------------------------
 * 1.00  sc   23/01/17 First release, based on v3.1 of xdevcfg_polled_example.c
 *
 *</pre>
 ******************************************************************************/

#include "xparameters.h"
#include "xdevcfg.h"
#include "xil_printf.h"
#include "sleep.h"

/************************** Constant Definitions *****************************/
/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are only defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define DCFG_DEVICE_ID		XPAR_XDCFG_0_DEVICE_ID

/*
 * SLCR registers
 */
#define SLCR_LOCK	0xF8000004 /**< SLCR Write Protection Lock */
#define SLCR_UNLOCK	0xF8000008 /**< SLCR Write Protection Unlock */
#define SLCR_LVL_SHFTR_EN 0xF8000900 /**< SLCR Level Shifters Enable */
#define SLCR_PCAP_CLK_CTRL XPAR_PS7_SLCR_0_S_AXI_BASEADDR + 0x168 /**< SLCR
					* PCAP clock control register address
					*/
#define SLCR_PCAP_CLK_CTRL_EN_MASK 0x1
#define SLCR_LOCK_VAL	0x767B
#define SLCR_UNLOCK_VAL	0xDF0D

#define PS_LVL_SHFTR_EN			(XPS_SYS_CTRL_BASEADDR + 0x900)

/*Miscellaneous Control Register mask*/
#define XDCFG_MCTRL_PCAP_PCFG_POR_B_MASK    0x00000100
#define COUNTS_PER_MILLI_SECOND (COUNTS_PER_SECOND/1000)

#define LVL_PS_PL 0x0000000A

/*
 * Silicon Version
 */
#define SILICON_VERSION_1 0
#define SILICON_VERSION_2 1
#define SILICON_VERSION_3 2
#define SILICON_VERSION_3_1 3

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

u32 plFabricInit(XDcfg *DcfgInstPtr);

/************************** Variable Definitions *****************************/

static XDcfg DcfgInstance; /* Device Configuration Interface Instance */
#define DCFG_DEVICE_ID		XPAR_XDCFG_0_DEVICE_ID

/*****************************************************************************/
/**
 *
 * Main function to call the polled mode example.
 *
 * @param	None.
 *
 * @return
 *		- XST_SUCCESS if successful
 *		- XST_FAILURE if unsuccessful
 *
 * @note		None.
 *
 ******************************************************************************/

u32 plLoadBitstream(u32 source_location, u32 source_size_words) {
	int Status;
	u32 IntrStsReg = 0;
	u32 StatusReg;
	u32 PartialCfg = 0;
	XDcfg *DcfgInstPtr = &DcfgInstance;

	XDcfg_Config *ConfigPtr;

	/*
	 * Initialize the Device Configuration Interface driver.
	 */
	ConfigPtr = XDcfg_LookupConfig(DCFG_DEVICE_ID);

	/*
	 * This is where the virtual address would be used, this example
	 * uses physical address.
	 */
	Status = XDcfg_CfgInitialize(DcfgInstPtr, ConfigPtr, ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	//Reset the fabric
//	plFabricInit(DcfgInstPtr);
//
	XDcfg_SetLockRegister(DcfgInstPtr, XDCFG_UNLOCK_DATA);
	// Enable and select PCAP interface for partial reconfiguration
	XDcfg_EnablePCAP(DcfgInstPtr);
	//Setting control register for PCAP mode
	XDcfg_SetControlRegister(DcfgInstPtr, XDCFG_CTRL_PCAP_MODE_MASK);

	Status = XDcfg_SelfTest(DcfgInstPtr);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	/*
	 * Check first time configuration or partial reconfiguration
	 */
	IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
	if (IntrStsReg & XDCFG_IXR_DMA_DONE_MASK) {
		PartialCfg = 1;
	}

	/*
	 * Enable the pcap clock.
	 */
	StatusReg = Xil_In32(SLCR_PCAP_CLK_CTRL);
	if (!(StatusReg & SLCR_PCAP_CLK_CTRL_EN_MASK)) {
		Xil_Out32(SLCR_UNLOCK, SLCR_UNLOCK_VAL);
		Xil_Out32(SLCR_PCAP_CLK_CTRL, (StatusReg | SLCR_PCAP_CLK_CTRL_EN_MASK));
		Xil_Out32(SLCR_UNLOCK, SLCR_LOCK_VAL);
	}

	/*
	 * Disable the level-shifters from PS to PL.
	 */
	if (!PartialCfg) {
		Xil_Out32(SLCR_UNLOCK, SLCR_UNLOCK_VAL);
		Xil_Out32(SLCR_LVL_SHFTR_EN, 0xA);
		Xil_Out32(SLCR_LOCK, SLCR_LOCK_VAL);
	}

	/*
	 * Select PCAP interface for partial reconfiguration
	 */
	if (PartialCfg) {
		XDcfg_EnablePCAP(DcfgInstPtr);
		XDcfg_SetControlRegister(DcfgInstPtr, XDCFG_CTRL_PCAP_PR_MASK);
	}

	/*
	 * Clear the interrupt status bits
	 */
	XDcfg_IntrClear(DcfgInstPtr, 0xFFFFFFFF/*(XDCFG_IXR_PCFG_DONE_MASK |	 XDCFG_IXR_D_P_DONE_MASK |	 XDCFG_IXR_DMA_DONE_MASK)*/);

	/* Check if DMA command queue is full */
	StatusReg = XDcfg_ReadReg(DcfgInstPtr->Config.BaseAddr,
			XDCFG_STATUS_OFFSET);
	if ((StatusReg & XDCFG_STATUS_DMA_CMD_Q_F_MASK) ==
	XDCFG_STATUS_DMA_CMD_Q_F_MASK) {
		return XST_FAILURE;
	}

	/*
	 * Download bitstream in non secure mode
	 */
	XDcfg_Transfer(DcfgInstPtr, (u8 *) source_location, source_size_words,
			(u8 *) XDCFG_DMA_INVALID_ADDRESS, 0, XDCFG_NON_SECURE_PCAP_WRITE);

	/* Poll IXR_DMA_DONE */
	IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
	while ((IntrStsReg & XDCFG_IXR_DMA_DONE_MASK) !=
	XDCFG_IXR_DMA_DONE_MASK) {
		IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
	}

	if (PartialCfg) {
		/* Poll IXR_D_P_DONE */
		while ((IntrStsReg & XDCFG_IXR_D_P_DONE_MASK) !=
		XDCFG_IXR_D_P_DONE_MASK) {
			IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
		}
	} else {
		/* Poll IXR_PCFG_DONE */
		while ((IntrStsReg & XDCFG_IXR_PCFG_DONE_MASK) !=
		XDCFG_IXR_PCFG_DONE_MASK) {
			IntrStsReg = XDcfg_IntrGetStatus(DcfgInstPtr);
		}
		/*
		 * Enable the level-shifters from PS to PL.
		 */
		Xil_Out32(SLCR_UNLOCK, SLCR_UNLOCK_VAL);
		Xil_Out32(SLCR_LVL_SHFTR_EN, 0xF);
		Xil_Out32(SLCR_LOCK, SLCR_LOCK_VAL);
	}
	XDcfg_ClearControlRegister(DcfgInstPtr, XDCFG_CTRL_PCAP_PR_MASK);
return XST_SUCCESS;

}

int GetSiliconVersion(XDcfg *DcfgInstPtr) {
	/*
	 * Get the silicon version
	 */
	int silicon_version = 0;
	silicon_version = XDcfg_GetPsVersion(DcfgInstPtr);

	return silicon_version;
}

/******************************************************************************/
/**
 *
 * This function programs the Fabric for use.
 *
 * @param	None
 *
 * @return
 *		- XST_SUCCESS if the Fabric  initialization is successful
 *		- XST_FAILURE if the Fabric  initialization fails
 * @note		None
 *
 ****************************************************************************/
#include "xtime_l.h"

u32 plFabricInit(XDcfg *DcfgInstPtr) {
	u32 PcapReg;
	u32 PcapCtrlRegVal;
	u32 MctrlReg;
	u32 PcfgInit;
	u32 TimerExpired = 0;
	XTime tCur = 0;
	XTime tEnd = 0;

	/*
	 * Set Level Shifters DT618760 - PS to PL enabling
	 */
	Xil_Out32(PS_LVL_SHFTR_EN, LVL_PS_PL);

	/*
	 * Get DEVCFG controller settings
	 */
	PcapReg = XDcfg_ReadReg(DcfgInstPtr->Config.BaseAddr, XDCFG_CTRL_OFFSET);

	/*
	 * Check the PL power status
	 */
	if (GetSiliconVersion(DcfgInstPtr) >= SILICON_VERSION_3) {
		MctrlReg = XDcfg_GetMiscControlRegister(DcfgInstPtr);

		if ((MctrlReg & XDCFG_MCTRL_PCAP_PCFG_POR_B_MASK) !=
		XDCFG_MCTRL_PCAP_PCFG_POR_B_MASK) {
			xil_printf("Fabric not powered up\r\n");
			return XST_FAILURE;
		}
	}

	/*
	 * Setting PCFG_PROG_B signal to high
	 */
	XDcfg_WriteReg(DcfgInstPtr->Config.BaseAddr, XDCFG_CTRL_OFFSET,
			(PcapReg | XDCFG_CTRL_PCFG_PROG_B_MASK));

	/*
	 * Check for AES source key
	 */
	PcapCtrlRegVal = XDcfg_GetControlRegister(DcfgInstPtr);
	if (PcapCtrlRegVal & XDCFG_CTRL_PCFG_AES_FUSE_MASK) {
		/*
		 * 5msec delay
		 */
		usleep(5000);
	}

	/*
	 * Setting PCFG_PROG_B signal to low
	 */
	XDcfg_WriteReg(DcfgInstPtr->Config.BaseAddr, XDCFG_CTRL_OFFSET,
			(PcapReg & ~XDCFG_CTRL_PCFG_PROG_B_MASK));

	/*
	 * Check for AES source key
	 */
	if (PcapCtrlRegVal & XDCFG_CTRL_PCFG_AES_FUSE_MASK) {
		/*
		 * 5msec delay
		 */
		usleep(5000);
	}

	/*
	 * Polling the PCAP_INIT status for Reset or timeout
	 */

	XTime_GetTime(&tCur);
	do {
		PcfgInit = (XDcfg_GetStatusRegister(DcfgInstPtr) &
		XDCFG_STATUS_PCFG_INIT_MASK);
		if (PcfgInit == 0) {
			break;
		}
		XTime_GetTime(&tEnd);
		if ((u64) ((u64) tCur + (COUNTS_PER_MILLI_SECOND * 30)) > (u64) tEnd) {
			TimerExpired = 1;
		}

	} while (!TimerExpired);

	if (TimerExpired == 1) {
		TimerExpired = 0;
		/*
		 * Came here due to expiration and PCAP_INIT is set.
		 * Retry PCFG_PROG_B High -> Low again
		 */

		/*
		 * Setting PCFG_PROG_B signal to high
		 */
		XDcfg_WriteReg(DcfgInstPtr->Config.BaseAddr, XDCFG_CTRL_OFFSET,
				(PcapReg | XDCFG_CTRL_PCFG_PROG_B_MASK));

		/*
		 * Check for AES source key
		 */
		PcapCtrlRegVal = XDcfg_GetControlRegister(DcfgInstPtr);
		if (PcapCtrlRegVal & XDCFG_CTRL_PCFG_AES_FUSE_MASK) {
			/*
			 * 5msec delay
			 */
			usleep(5000);
		}

		/*
		 * Setting PCFG_PROG_B signal to low
		 */
		XDcfg_WriteReg(DcfgInstPtr->Config.BaseAddr, XDCFG_CTRL_OFFSET,
				(PcapReg & ~XDCFG_CTRL_PCFG_PROG_B_MASK));

		/*
		 * Check for AES source key
		 */
		if (PcapCtrlRegVal & XDCFG_CTRL_PCFG_AES_FUSE_MASK) {
			/*
			 * 5msec delay
			 */
			usleep(5000);
		}
		/*
		 * Polling the PCAP_INIT status for Reset or timeout (second iteration)
		 */

		XTime_GetTime(&tCur);
		do {
			PcfgInit = (XDcfg_GetStatusRegister(DcfgInstPtr) &
			XDCFG_STATUS_PCFG_INIT_MASK);
			if (PcfgInit == 0) {
				break;
			}
			XTime_GetTime(&tEnd);
			if ((u64) ((u64) tCur + (COUNTS_PER_MILLI_SECOND * 30))
					> (u64) tEnd) {
				TimerExpired = 1;
			}

		} while (!TimerExpired);

		if (TimerExpired == 1) {
			/*
			 * Came here due to PCAP_INIT is not getting reset
			 * for PCFG_PROG_B signal High -> Low
			 */
			xil_printf("Fabric Init failed\r\n");
			return XST_FAILURE;
		}
	}

	/*
	 * Setting PCFG_PROG_B signal to high
	 */
	XDcfg_WriteReg(DcfgInstPtr->Config.BaseAddr, XDCFG_CTRL_OFFSET,
			(PcapReg | XDCFG_CTRL_PCFG_PROG_B_MASK));

	/*
	 * Polling the PCAP_INIT status for Set
	 */
	while (!(XDcfg_GetStatusRegister(DcfgInstPtr) &
	XDCFG_STATUS_PCFG_INIT_MASK))
		;

	return XST_SUCCESS;
}

