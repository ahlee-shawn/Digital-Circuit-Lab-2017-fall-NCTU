`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/09/18 01:00:36
// Design Name: 
// Module Name: SeqMultiplier_tb
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


module SeqMultiplier_tb;
    
    reg     clk;
    reg     enable;
    reg     [7:0]A;
    reg     [7:0]B;
    wire    [15:0]C;
    
    SeqMultiplier   S1(clk,enable,A,B,C);
    
    initial
        begin
        #0;A[7:0]=8'b11111010;B[7:0]=8'b00000100;enable=1'b0;
        #100;enable=1'b1;
        end
        
        always begin
        clk = 1'b1; #5; clk = 1'b0; #5;
        end
        
    initial #400 $finish;
    
endmodule