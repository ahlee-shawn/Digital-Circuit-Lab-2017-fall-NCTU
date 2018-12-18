`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/18 00:31:25
// Design Name: 
// Module Name: SeqMultiplier
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


module SeqMultiplier(
    input wire clk,
    input wire enable,
    input wire [7:0] A,
    input wire [7:0] B,
    output wire [15:0] C
    );
    
    reg [3:0]counter=4'b0000;
    reg [7:0]q=8'b00000000;
    reg [7:0]a=8'b00000000;
    reg c=1'b0;
    reg e=1'b1;
    reg f=1'b1;
    reg [15:0]Ans=16'b0000000000000000;
    
    always@(*)begin
    if(e&&f&&enable)begin
    q=A;
    e=!e;
    f=!f;
    end end
    
    always@(posedge clk)begin
    if(q[0]&&enable&&!e)
    {c,a}=a+B;
    if(enable&&!e)begin
    q={a[0],q[7:1]};
    a={c,a[7:1]};
    if(c&&enable&&!e)begin
    c=!c; end
    counter<=counter+4'b0001;
    end
    if((counter[3:0]==4'b0111)&&!e&&enable)begin
    Ans={a[7:0],q[7:0]};
    e=!e;
    end
    end
    
    assign  C=Ans;

endmodule
