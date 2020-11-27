`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/20 15:00:10
// Design Name: 
// Module Name: SyncGeneration
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

module SyncGeneration(pclk, reset, hSync, vSync, dataValid, hDataCnt, vDataCnt);
  
   input        pclk;
   input        reset;
   output       hSync;
   output       vSync;
   output       dataValid;
   output [9:0] hDataCnt;
   output [9:0] vDataCnt ;
 

   parameter    H_SP_END = 96;
   parameter    H_BP_END = 144;
   parameter    H_FP_START = 785;
   parameter    H_TOTAL = 800;
   
   parameter    V_SP_END = 2;
   parameter    V_BP_END = 35;
   parameter    V_FP_START = 516;
   parameter    V_TOTAL = 525;

   reg [9:0]    x_cnt,y_cnt;
   wire         h_valid,v_valid;
     
   always @(posedge reset or posedge pclk) begin
      if (reset)
         x_cnt <= 10'd1;
      else begin
         if (x_cnt == H_TOTAL)
            x_cnt <= 10'd1;
         else
            x_cnt <= x_cnt + 1;
      end
   end
   
   always @(posedge pclk or posedge reset) begin
      if (reset)
         y_cnt <= 10'd1;
      else begin
         if (y_cnt == V_TOTAL & x_cnt == H_TOTAL)
            y_cnt <= 1;
         else if (x_cnt == H_TOTAL)
            y_cnt <= y_cnt + 1;
         else y_cnt<=y_cnt;
      end
   end
   
   assign hSync = ((x_cnt > H_SP_END)) ? 1'b1 : 1'b0;
   assign vSync = ((y_cnt > V_SP_END)) ? 1'b1 : 1'b0;
   
   // Check P7 for horizontal timing   
   assign h_valid = ((x_cnt > H_BP_END) & (x_cnt <= H_FP_START)) ? 1'b1 : 1'b0;
   // Check P9 for vertical timing
   assign v_valid = ((y_cnt > V_BP_END) & (y_cnt <= V_FP_START)) ? 1'b1 : 1'b0;
   
   assign dataValid = ((h_valid == 1'b1) & (v_valid == 1'b1)) ? 1'b1 :  1'b0;
   
   // hDataCnt from 1 if h_valid==1
   assign hDataCnt = ((h_valid == 1'b1)) ? x_cnt - H_BP_END : 10'b0;
   // vDataCnt from 1 if v_valid==1
   assign vDataCnt = ((v_valid == 1'b1)) ? y_cnt - V_BP_END : 10'b0; 
            
   
endmodule