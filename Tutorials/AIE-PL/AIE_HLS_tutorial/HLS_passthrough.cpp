// ==============================================================
// File generated by Vitis Model Composer(TM)
// Version: 2023.2
//  
// (c) Copyright 2017 - 2022 Xilinx, Inc. All rights reserved.
// (c) Copyright 2022 - 2023 Advanced Micro Devices, Inc. All rights reserved.
//  
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//  
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//  
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//  
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// ==============================================================
#include "HLS_passthrough.h"
#include <StreamAdapters.h>

/**
 * @brief HLS
 * @param arg0 direction=input protocol=Default length=8
 * @param arg1 direction=output protocol=Default length=8
 */
void
HLS_passthrough(hls::stream< int >& arg0, hls::stream< int >& arg1)
{
    #pragma HLS INTERFACE axis port=arg0
    #pragma HLS INTERFACE axis port=arg1
    #pragma HLS INTERFACE ap_ctrl_none port=return
    #pragma HLS dataflow
    int stream_adapter[32];
    #pragma HLS stream variable=stream_adapter depth=3
    xmc::StreamAdapter1d<32>::readStream(arg0, stream_adapter);
    xmc::StreamAdapter1d<32>::writeStream(arg1, stream_adapter);
}


