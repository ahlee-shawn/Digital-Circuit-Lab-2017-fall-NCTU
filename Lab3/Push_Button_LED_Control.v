`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/29 19:27:01
// Design Name: 
// Module Name: Push_Button_LED_Control
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


module Push_Button_LED_Control(
    input  clk,            // System clock at 100 MHz
    input  reset_n,        // System reset signal, in negative logic
    input  [3:0] usr_btn,  // Four user pushbuttons
    output [3:0] usr_led   // Four yellow LEDs
    );
    
    reg button3=1'b0,button2=1'b0,button1=1'b0,button0=1'b0;
    reg [2:0]level=3'b011;
    reg level_3=1'b0;
    reg [1:0]level_4=2'b00;
    reg [4:0]level_1=5'b00000;//20=10100
    reg [3:0]counter=4'b0000;
    reg [3:0]led=4'b0000;
    reg [23:0]shift3=24'b000000000000000000000000;
    reg [23:0]shift2=24'b000000000000000000000000;
    reg [23:0]shift1=24'b000000000000000000000000;
    reg [23:0]shift0=24'b000000000000000000000000;
    
    always@(posedge clk)begin
       if(!reset_n)begin
            counter=4'b0000;
            shift1=24'b000000000000000000000000;
            shift0=24'b000000000000000000000000;
            button1=1'b0;
            button0=1'b0;
       end
       if(button1)begin
            if((counter!=4'b0111)&&(counter!=4'b1111))
            counter=counter+4'b0001;
            else if(counter==4'b1111)
            counter=4'b0000;
            button1=1'b0;
        end
        if(button0)begin
            if(counter!=4'b1000&&(counter!=4'b0000)&&counter!=4'b0001)
            counter=counter-4'b0001;
            else if(counter==4'b0000)
            counter=4'b1111;
            else if(counter==4'b0001)
            counter=4'b0000;
            button0=1'b0;
        end
        if(usr_btn[1])begin
            shift1= shift1+24'b000000000000000000000001;
            if(shift1[23:0]==24'b000000000000000000000000)
            button1 <= 1'b0 ;
            else if(shift1[23:0]==24'b111111111111111111111111)begin
            button1 <= 1'b1;
            shift1=~shift1;
            end else 
            button1 <=button1;
        end
        if(usr_btn[0])begin
            shift0 = shift0+24'b000000000000000000000001;
            if(shift0[23:0]==24'b000000000000000000000000)
            button0 <= 1'b0 ;
            else if(shift0[23:0]==24'b111111111111111111111111)begin
            button0 <= 1'b1;
            shift0=~shift0;
            end else 
            button0 <=button0;
        end
    end
    
    always@(posedge clk)begin
        if(!reset_n)begin
            led=4'b0000;
            level=3'b011;
            level_3=1'b0;
            level_4=2'b00;
            level_1=5'b00000;
            shift3=24'b000000000000000000000000;
            shift2=24'b000000000000000000000000;
            button3=1'b0;
            button2=1'b0;
        end
        if(button3)begin
            if(level<3'b101)begin
            level=level+3'b001;
            end
            button3 = 1'b0;
       end
       if(button2)begin
            if(level>3'b001)begin
            level=level-3'b001;
            end
            button2 = 1'b0;
       end
        if(usr_btn[3])begin
            shift3= shift3+24'b000000000000000000000001;
            if(shift3[23:0]==24'b000000000000000000000000)
            button3 <= 1'b0 ;
            else if(shift3[23:0]==24'b111111111111111111111111)begin
            button3 <= 1'b1;
            shift3=~shift3;
            end else 
            button3 <=button3;
        end
        if(usr_btn[2])begin
            shift2= shift2+24'b000000000000000000000001;
            if(shift2[23:0]==24'b000000000000000000000000)
            button2 <= 1'b0 ;
            else if(shift2[23:0]==24'b111111111111111111111111)begin
            button2 <= 1'b1;
            shift2=~shift2;
            end else 
            button2 <=button2;
        end
        if(level==3'b101)begin
            led <= counter;
        end
        if(level==3'b100)begin
            if(level_4[1:0]!=2'b11)begin
            led <= counter;
            level_4=level_4+2'b01;
            end
            else if(level_4[1:0]==2'b11)begin
            led <= 4'b0000;
            level_4=2'b00;
            end
        end
        if(level==3'b011)begin
            if(level_3==1'b1)begin
            led <= counter;
            level_3=1'b0;
            end
            else if(level_3==1'b0)begin
            led <= 4'b0000;
            level_3=level_3+1'b1;
            end
        end
        if(level==3'b010)begin
            if(level_4[1:0]!=2'b11)begin
            led <= 4'b0000;
            level_4=level_4+2'b01;
            end
            else if(level_4[1:0]==2'b11)begin            
            led <= counter;
            level_4=2'b00;
            end
        end
        if(level==3'b001)begin
            if(level_1[4:0]!=5'b10100)begin
            led <= 4'b0000;
            level_1=level_1+5'b00001;
            end
            else if(level_1[4:0]==5'b10100)begin
            led <= counter ;
            level_1=5'b00000;
            end
        end
    end
    
    assign usr_led=led;
    
endmodule



