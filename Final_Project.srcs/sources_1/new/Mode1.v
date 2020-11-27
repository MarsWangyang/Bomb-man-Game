`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/06/14 14:38:05
// Design Name: 
// Module Name: Mode1
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

module Mode1(clk, rst, hsync, vsync, vga_r, vga_g, vga_b,lightctrl,LED,SEVEN,SEVEN_ENL,SEVEN_ENR,B);

input           clk;
input           rst;
input  [6:0]    lightctrl;
input           B;//B是炸彈信號
   
output          hsync,vsync;
output [3:0]    vga_r, vga_g, vga_b;
output [15:0]   LED;
output [1:7]    SEVEN;
output          SEVEN_ENL,SEVEN_ENR;

reg             SEVEN_ENL,SEVEN_ENR;
reg  [1:7]      SEVEN;
reg  [15:0]     LED;
wire            DEup,DEdown,DEleft,DEright;//這些才是我用來判斷是否改變CS的訊號   
wire            pclk;
wire            valid;
wire [9:0]      h_cnt,v_cnt;
reg  [11:0]     vga_data;
wire [11:0]     rom_dout_B,rom_dout_SB;
reg  [11:0]     rom_addr_B,rom_addr_SB;  //2^12=4096
wire            logo_area,Bomb_area,B1_area,B2_area;
reg  [9:0]      logo_x,Bomb_x,B1_x=10'd166,B2_x=10'd326;
reg  [9:0]      logo_y,Bomb_y,B1_y=10'd323,B2_y=10'd243;
reg  [1:0]      CS,NS; 
reg             LED_EN,SEVEN_EN,chest_detect;
reg  [26:0]     LEDclkCounter;
wire            LEDclk;
reg             LEDCount;
reg  [16:0]     SEVENclkCounter;
wire            SEVENclk;
reg  [20:0]     DECounter;
wire            DEclk;
reg             Exist_B1,Exist_B2,Exist_SB,Exist_Bomb;
reg             Bang;
reg  [25:0]     Cnt_Bomb;
   
parameter [9:0] logo_length=10'd60;
parameter [9:0] logo_height=10'd56; //60*56=3360<2^12=4096   

parameter [3:0] ONEONE=4'd0,ONETWO=4'd1,ONETHREE=4'd2,ONEFOUR=4'd3,
               TWOONE=4'd4,TWOTWO=4'd5,TWOTHREE=4'd6,TWOFOUR=4'd7,
               THREEONE=4'd8,THREETWO=4'd9,THREETHREE=4'd10,THREEFOUR=4'd11,
               FOURONE=4'd12,FOURTWO=4'd13,FOURTHREE=4'd14,FOURFOUR=4'd15;
                

wire clk_1,clk_2,clk_7,clk_3,clk_4,clk_5,clk_6;

   
dcm_25M u0(// Clock in ports
          .clk_in1(clk),        // input clk_in1
          // Clock out ports
          .clk_out1(clk_1),     // output clk_out1
          .clk_out2(clk_2),
          .clk_out3(clk_3),
          .clk_out4(clk_4),
          .clk_out5(clk_5),
          .clk_out6(clk_6),
          .clk_out7(clk_7), 
          // Status and control signals
          .reset(rst)    );
             	
reg ctrlclk;
always@(*)
begin
    case(lightctrl) 
    7'b1000000: ctrlclk = clk_1;
    7'b0100000: ctrlclk = clk_2;   
    7'b0010000: ctrlclk = clk_3;
    7'b0001000: ctrlclk = clk_4;
    7'b0000100: ctrlclk = clk_5;
    7'b0000010: ctrlclk = clk_6;
    7'b0000001: ctrlclk = clk_7;
    default:    ctrlclk = clk_6;
    endcase
end
		
SpongeBob u1 (
             .clka(ctrlclk),    // input wire clka
             .addra(rom_addr_SB),  // input wire [13 : 0] addra
             .douta(rom_dout_SB)  // output wire [11 : 0] douta
            );
            
Bomb u2 (
        .clka(ctrlclk),
        .addra(rom_addr_B),          
        .douta(rom_dout_B)
        );
        
SyncGeneration u3 (
		.pclk(ctrlclk)   , 
		.reset(rst)      , 
		.hSync(hsync)    , 
		.vSync(vsync)    , 
		.dataValid(valid), 
		.hDataCnt(h_cnt) , 
		.vDataCnt(v_cnt));
		
   
KEYKEY u4(.left(DEleft),.right(DEright),.up(DEup),.down(DEdown),.bomb(B));  		
		
	           		           		  
always@ (posedge clk or posedge rst)
begin
    if(rst)    
        CS<=ONEFOUR;
    else
        CS<=NS;
end

always@ (*)//CS和NS的判斷區;LED_EN, logo_x,logo_y,SEVEN_EN也在這裡
begin
    case(CS)  
      
     //ONE 
    ONEFOUR:begin
        
        logo_x=10'd173;
        logo_y=10'd92;
        SEVEN_EN=1'b0;
        
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上撞牆
            NS=CS;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=ONETHREE;
           
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左撞牆
            NS=CS;
           
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=TWOFOUR;
           
        end
        else
            NS=CS;      
    end
    
    ONETHREE:begin
    
        logo_x=10'd173;
        logo_y=10'd172;
        SEVEN_EN=1'b0;
         
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=ONEFOUR;
            
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=ONETWO;
            
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左撞牆
            NS=CS;
          
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=TWOTHREE;
               
        end
        else
            NS=CS;
    
    end 
       
    ONETWO:begin
    
        logo_x=10'd173;
        logo_y=10'd252;
        SEVEN_EN=1'b0;
        
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=ONETHREE;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下      會有BLOCK
            if(Exist_B2==1)        //BLOCK是否存在
            begin    
                NS=CS;
            end            
            else
                NS=ONEONE;
          
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左撞牆
            NS=CS;
           
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=TWOTWO;
               
        end
        else
            NS=CS;
    
    end
    
    ONEONE:begin
    
        logo_x=10'd173;
        logo_y=10'd332;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=ONETWO;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下撞牆
            NS=CS;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左撞牆
            NS=CS;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=TWOONE;
           
        end
        else
            NS=CS;
    end
    
    //TWO
    TWOFOUR:begin
    
        logo_x=10'd253;
        logo_y=10'd92;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上撞牆
            NS=CS;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=TWOTHREE;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=ONEFOUR;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=THREEFOUR;
           
        end
        else
            NS=CS;
    end
    
    TWOTHREE:begin
    
        logo_x=10'd253;
        logo_y=10'd172;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=TWOFOUR;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=TWOTWO;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=ONETHREE;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=THREETHREE;
           
        end
        else
            NS=CS;
    end
    
    TWOTWO:begin
    
        logo_x=10'd253;
        logo_y=10'd252;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=TWOTHREE;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=TWOONE;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=ONETWO;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=THREETWO;
           
        end
        else
            NS=CS;
    end
    
    TWOONE:begin
    
        logo_x=10'd253;
        logo_y=10'd332;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=TWOTWO;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下撞牆
            NS=CS;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左      會有BLOCK
            if(Exist_B2==1)        //BLOCK是否存在
            begin    
                NS=CS;
            end            
            else
                NS=ONEONE;
            
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=THREEONE;
           
        end
        else
            NS=CS;
    end
    
    //THREE
    THREEFOUR:begin
    
        logo_x=10'd333;
        logo_y=10'd92;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上撞牆
            NS=CS;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=THREETHREE;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=TWOFOUR;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=FOURFOUR;
           
        end
        else
            NS=CS;
    end
    
    THREETHREE:begin
    
        logo_x=10'd333;
        logo_y=10'd172;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=THREEFOUR;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=THREETWO;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=TWOTHREE;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=FOURTHREE;
           
        end
        else
            NS=CS;
    end
    
    THREETWO:begin
    
        logo_x=10'd333;
        logo_y=10'd252;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=THREETHREE;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=THREEONE;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左      
            NS=TWOTWO;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右          會有BLOCK
            if(Exist_B1==1)        //BLOCK是否存在
            begin    
                NS=CS;
            end            
            else
                NS=FOURTWO;
           
        end
        else
            NS=CS;
    end
    
    THREEONE:begin
    
        logo_x=10'd333;
        logo_y=10'd332;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=THREETWO;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下撞牆
            NS=CS;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=TWOONE;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右
            NS=FOURONE;
           
        end
        else
            NS=CS;
    end
    
    //FOUR
    FOURFOUR:begin
    
        logo_x=10'd413;
        logo_y=10'd92;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上撞牆
            NS=CS;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=FOURTHREE;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=THREEFOUR;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右撞牆
            NS=CS;
           
        end
        else
            NS=CS;
    end
    
    FOURTHREE:begin
    
        logo_x=10'd413;
        logo_y=10'd172;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=FOURFOUR;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下      會有BLOCK
            if(Exist_B1==1)        //BLOCK是否存在
            begin    
                NS=CS;
            end            
            else
                NS=FOURTWO;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=THREETHREE;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右撞牆
            NS=CS;
           
        end
        else
            NS=CS;
    end
    
    
    FOURTWO:begin
    
        logo_x=10'd413;
        logo_y=10'd252;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上
            NS=FOURTWO;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下
            NS=FOURONE;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=THREETWO;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右撞牆
            NS=CS;
           
        end
        else
            NS=CS;
    end
    
    FOURONE:begin

        logo_x=10'd413;
        logo_y=10'd332;
        SEVEN_EN=1'b1;
    
        if      (DEup==1 && DEdown==0 && DEleft==0 && DEright==0)begin//往上      會有BLOCK
            if(Exist_B1==1)        //BLOCK是否存在
            begin    
                NS=CS;
            end            
            else
                NS=CS;
           
        end
        else if (DEup==0 && DEdown==1 && DEleft==0 && DEright==0)begin//往下撞牆
            NS=CS;
        
        end
        else if (DEup==0 && DEdown==0 && DEleft==1 && DEright==0)begin//往左
            NS=THREEONE;
         
        end
        else if (DEup==0 && DEdown==0 && DEleft==0 && DEright==1)begin//往右撞牆
            NS=CS;
           
        end
        else
            NS=CS;
    end
    
  
    default:NS=ONEFOUR;
    endcase
end
 
assign logo_area = ((v_cnt >= logo_y) & (v_cnt <= logo_y + logo_height - 1) & 
                    (h_cnt >= logo_x) & (h_cnt <= logo_x + logo_length - 1)) ? 1'b1 : 1'b0;
                    
assign Bomb_area = ((v_cnt >= Bomb_y) & (v_cnt <= Bomb_y + logo_height - 1) & 
                    (h_cnt >= Bomb_x) & (h_cnt <= Bomb_x + logo_length - 1)) ? 1'b1 : 1'b0;      
                    
assign B1_area = ((v_cnt >= B1_y) & (v_cnt <= B1_y + 10'd75 - 1) & 
                    (h_cnt >= B1_x) & (h_cnt <= B1_x + 10'd75 - 1)) ? 1'b1 : 1'b0;      
                    
assign B2_area = ((v_cnt >= B2_y) & (v_cnt <= B2_y + 10'd75 - 1) & 
                    (h_cnt >= B2_x) & (h_cnt <= B2_x + 10'd75 - 1)) ? 1'b1 : 1'b0;                                  
                   
//always@(posedge clk) begin
//    if(B)begin
        
    
    
                                         
                    
always@(*) begin//按下爆炸後，馬上把人物的地址給炸彈，並讓炸彈一直保有該地址
    if(B)  
        {Bomb_x,Bomb_y}={logo_x,logo_y};
    else
        {Bomb_x,Bomb_y}={Bomb_x,Bomb_y};        
end
            
always@(*)begin //讓底下display知道何時有炸彈的always
    if(B)  Exist_Bomb=1;//按下J後，此Enable跳到1,並且不會下來，直到爆炸完
    else if (Bang)   Exist_Bomb=0; //爆炸瞬間，炸彈要消失
    else    Exist_Bomb=Exist_Bomb; //沒事，讓Exist不要亂跳                   
end
                            
always @(posedge ctrlclk or posedge rst)
begin: logo_display
    if (rst == 1'b1) begin
        rom_addr_SB<=12'd0;
        vga_data <= 12'd0;      
    end
    else 
    begin
        if (valid == 1'b1) begin
            if(Bomb_area==1'b1)begin //在炸彈所在，輸出炸彈的圖片
                if(Exist_Bomb)begin
                    rom_addr_B <= rom_addr_B + 12'd1;
                    vga_data <= rom_dout_B;    
                end
                else begin//沒有炸彈，看是要輸出人，還是要輸出格子
                    if({Bomb_x,Bomb_y}=={logo_x,logo_y})begin
                        if(Exist_SB)begin //人活著且位置跟炸彈一樣，但炸彈沒了
                            rom_addr_SB <= rom_addr_SB + 12'd1;
                            vga_data <= rom_dout_SB;//輸出人
                        end
                        else //人死了，炸彈也沒了，輸出白色格子
                            vga_data <= 12'hfff;
                    end 
                end
            end       
          
            else if (logo_area == 1'b1) begin //在主角所在，輸出主角的圖片
                if(Exist_SB)begin
                    rom_addr_SB <= rom_addr_SB + 12'd1;
                    vga_data <= rom_dout_SB;
                end
                else//主角死了 
                    vga_data <= 12'hfff;//輸出白色格子 
            end
            
            else if (B1_area==1'b1)begin
                if(Exist_B1)begin
                    vga_data <= 12'hf00;//輸出紅色格子
                end
                else// 格子1沒了
                    vga_data <= 12'hfff;//輸出白色格子
            end
            
            else if (B2_area==1'b1)begin
                if(Exist_B2)begin
                    vga_data <= 12'hf00;//輸出紅色格子
                end
                else// 格子2沒了
                    vga_data <= 12'hfff;//輸出白色格子
            end     
                
            else begin//  在非logo area時: {從這裡開始要寫幾個東西: 1.格子外的地圖  2.格子內是白色的 3.用else讓黑色框線出來
                rom_addr_SB <= rom_addr_SB;//這一句一定要寫，因為logo_area與非logo_area是交錯出現的(輪流輸出的)，所以必須保留logo現在輸出到哪個地址了!!!
                
                if(  //其他白色格子的條件
                  ((  ((h_cnt>=166)&&(h_cnt<=240))||((h_cnt>=246)&&(h_cnt<=320))||((h_cnt>=326)&&(h_cnt<=400))||((h_cnt>=406)&&(h_cnt<=480))  )&&
                   (  ((v_cnt>= 83)&&(v_cnt<=157))||((v_cnt>=163)&&(v_cnt<=237))  )) 
                  ||
                  ((  ((h_cnt>=166)&&(h_cnt<=240))||((h_cnt>=246)&&(h_cnt<=320))||((h_cnt>=326)&&(h_cnt<=400))  )&&
                   (  ((v_cnt>= 243)&&(v_cnt<=317))  )) 
                  ||
                  ((  ((h_cnt>=246)&&(h_cnt<=320))||((h_cnt>=326)&&(h_cnt<=400))||((h_cnt>=406)&&(h_cnt<=480))  )&&
                   (  ((v_cnt>= 323)&&(v_cnt<=397))  ))  
                  )
                begin
                    vga_data <= 12'hfff;//這裡是畫出白色格子 
                end
//                //這裡放一個else if，放白色格子的條件，裡面再放一個case決定每個case中白色格子與終點圖的畫法; 
//                //case中(非TWOTWO時)放if@終點區域則畫出終點的圖形，else 塗白色
                
//                else if( //白色格子及紅色終點圖的條件(包括主角那格)
//                       ((  ((h_cnt>=166)&&(h_cnt<=235))||((h_cnt>=246)&&(h_cnt<=315))  )&&(  ((v_cnt>=246)&&(v_cnt<=315))  ))
//                       ||
//                       ((  ((h_cnt>=246)&&(h_cnt<=315))||((h_cnt>=326)&&(h_cnt<=395))  )&&(  ((v_cnt>=166)&&(v_cnt<=235))  ))
//                       )
//                begin
//                    if( 
//                      ( ((h_cnt>=331)&&(h_cnt<=375))&&(((v_cnt>172)&&(v_cnt<=176))||((v_cnt>=212)&&(v_cnt<=216))) )
//                      ||
//                      ( ((v_cnt>=172)&&(v_cnt<=216))&&(((h_cnt>331)&&(h_cnt<=335))||((h_cnt>=371)&&(h_cnt<=375))) ) 
//                      )//終點圖之區域偵測
//                    begin
//                         vga_data=16'hf00;
//                    end
//                    else begin
//                         vga_data=16'hfff;
//                    end     
                         

//                end   
                else begin   
                    vga_data <= 12'h000;//其他畫上黑色，格子與背景都出來了
                end
            end
         end
         else begin
             vga_data <= 12'h000;//不在顯示器的display area內，這個決定了螢幕的背光
             
             if (v_cnt == 0)//輸出完一趟後 rom addr要歸零
                rom_addr_SB <= 12'b0;
             else
               rom_addr_SB<=rom_addr_SB;
         end
    end
end
   
assign {vga_r,vga_g,vga_b} = vga_data;

always@  (posedge clk) //除頻區
begin
    if(rst) LEDclkCounter<=27'd0;
    else LEDclkCounter<=LEDclkCounter+1'b1;
    
    if(rst) SEVENclkCounter<=17'd0;
    else SEVENclkCounter<=SEVENclkCounter+1'b1;
end        

assign LEDclk=LEDclkCounter[26];//做LED用的CLK
assign SEVENclk=SEVENclkCounter[16];


always@ (posedge rst or posedge LEDclk)
begin
    if(rst)begin
        LEDCount<=1'b0;
    end
    else begin
        if(LED_EN==1)
            LEDCount<=LEDCount+1'b1;
        else
            LEDCount<=1'b0;  
    end  
    
    case(LEDCount)
    1'b0:LED=16'b0000000000000000;
    1'b1:LED=16'b0000000010101010;
    default:LED=16'b0000000000000000;
    endcase
    
end    
    

always@ (posedge clk)// 分配七段的enable
begin
    case(SEVENclk)
    1'b0:begin SEVEN_ENL=1;SEVEN_ENR=0;end
    1'b1:begin SEVEN_ENL=0;SEVEN_ENR=1;end
    endcase
end

always@(SEVENclk or SEVEN_ENL or SEVEN_ENR or SEVEN_EN) //讓七段顯示數字
begin
    if(SEVEN_ENL==1&&SEVEN_ENR==0)
        if(SEVEN_EN==1)
            SEVEN=7'b0110000;
        else
            SEVEN=7'b1111110;//如果不在終點，左就會顯示0
    else if(SEVEN_ENL==0&&SEVEN_ENR==1)
        if(SEVEN_EN==1)
            SEVEN=7'b1111110;
        else
            SEVEN=7'b1111110;//如果不在終點，右就會顯示0
    else
        SEVEN=7'b1111110; 
end     
        

endmodule   