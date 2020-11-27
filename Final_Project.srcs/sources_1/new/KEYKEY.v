`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/20 15:49:00
// Design Name: 
// Module Name: KEYKEY
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

module KEYKEY(clk,reset,ps2k_clk,ps2k_data,left,right,up,down,bomb);
input clk,reset,ps2k_clk,ps2k_data;
output reg left,right,up,down,bomb;
reg [7:0]data;
reg [7:0]temp;
reg[3:0]num;
reg state;
reg r0,r1,r2;
wire n_ps2k_clk;
reg key;
reg state_reg;
wire flag;


always@(posedge clk or posedge reset)begin
if(reset)begin
r0<=1'b0;r1<=1'b0;r2<=1'b0;end
else begin
r0<=ps2k_clk;r1<=r0;r2<=r1;end end
assign n_ps2k_clk=~r1&r2;
always@(posedge clk or posedge reset)begin
if(reset)begin
num<=4'd0;temp<=8'd0;end
else if(n_ps2k_clk)begin
case(num)
4'd0:num<=num+1'b1;
4'd1:begin num<=num+1'b1;temp[0]<=ps2k_data;end
4'd2:begin num<=num+1'b1;temp[1]<=ps2k_data;end
4'd3:begin num<=num+1'b1;temp[2]<=ps2k_data;end
4'd4:begin num<=num+1'b1;temp[3]<=ps2k_data;end
4'd5:begin num<=num+1'b1;temp[4]<=ps2k_data;end
4'd6:begin num<=num+1'b1;temp[5]<=ps2k_data;end
4'd7:begin num<=num+1'b1;temp[6]<=ps2k_data;end
4'd8:begin num<=num+1'b1;temp[7]<=ps2k_data;end
4'd9:num<=num+1'b1;
4'd10:num<=4'd0;
default:num<=4'd0; endcase end end
always@(posedge clk or posedge reset)begin
if(reset)begin
key<=1'b0;state<=1'b0;end
else if(num==4'd10)begin
if (temp==8'hf0)
key<=1'b1;
else begin
if(!key)begin
state<=1'b1;data<=temp;end
else begin
state<=1'b0;key<=1'b0;end end end end
always@(posedge clk)begin
state_reg<=state;end
assign flag=(state_reg)&(~state);
always@(posedge clk or posedge reset)begin
if(reset)begin
left<=0;right<=0;up<=0;down<=0;bomb<=0;end
else if(flag)begin
case(data)
8'h1C:begin left<=1;end//a
8'h23:begin right<=1;end//d
8'h1D:begin up<=1;end//w
8'h1B:begin down<=1;end//s
8'h3B:begin bomb<=1;end//j
default:begin left<=0;right<=0;up<=0;down<=0;bomb<=0;end
endcase end
else if(left) left<=0;
else if(right) right<=0;
else if(up) up<=0;
else if(down) down<=0;
else if(bomb) bomb<=0;
end
endmodule
