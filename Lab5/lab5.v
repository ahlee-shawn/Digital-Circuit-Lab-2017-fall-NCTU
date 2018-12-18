`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 13:42:07
// Design Name: 
// Module Name: lab5
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


module lab5(
    input clk,
    input reset_n,
    input [3:0] usr_btn,
    output [3:0] usr_led,
    output LCD_RS,
    output LCD_RW,
    output LCD_E,
    output [3:0] LCD_D
    );
    
localparam [1:0] S_MAIN_INIT = 0, S_MAIN_PRIMES = 1,
                 S_MAIN_PRINT_FORWARD = 2, S_MAIN_PRINT_REVERSE = 3;
    
reg [127:0]  row_A = "Prime #01 is 002"; 
reg [127:0]  row_B = "Prime #02 is 003";
reg [0:2047]primes = {2048{1'b1}};
reg [11:0]   counter1 = 2, counter2 = 2, counter3 = 2;
reg [1:0]    P = 0,P_next;
reg [23:0]   init_counter;
reg [31:0]   print_counter;
reg [9:0]    number1=10'b0, number2=10'b0;
reg [7:0]print_num1[1:0];
reg [7:0]print_num2[1:0];
reg [9:0]    prime_number1 = 10'b0, prime_number2 = 10'b0;
reg [7:0]print_prime_number1[2:0];
reg [7:0]print_prime_number2[2:0];
reg  calculation_finish = 0;
reg  make_table = 0;
wire prime_done,table_done;
wire btn_level, btn_pressed;
reg prev_btn_level;
reg [9:0]prime_in_array[0:172];
reg [9:0]index = 1, index1 = 1;
reg [3:0]debug;

LCD_module lcd0(
  .clk(clk),
  .reset(~reset_n),
  .row_A(row_A),
  .row_B(row_B),
  .LCD_E(LCD_E),
  .LCD_RS(LCD_RS),
  .LCD_RW(LCD_RW),
  .LCD_D(LCD_D)
);

debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[3]),
  .btn_output(btn_level)
);

always@(posedge clk)begin
    if(~reset_n) begin
        P <= S_MAIN_INIT;
    end
    else begin
    P <= P_next;
    prev_btn_level <= btn_level;
    end
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0);
assign usr_led = P;
assign prime_done = calculation_finish;
//assign table_done = make_table;
    
always@(*)begin
    case (P)
        S_MAIN_INIT:
            if(init_counter < 1000) P_next = S_MAIN_INIT;
            else P_next = S_MAIN_PRIMES;
        S_MAIN_PRIMES:
            if(~prime_done) P_next = S_MAIN_PRIMES;
            else P_next = S_MAIN_PRINT_FORWARD;
        S_MAIN_PRINT_FORWARD:
            if(btn_pressed == 0) P_next = S_MAIN_PRINT_FORWARD;
            else P_next = S_MAIN_PRINT_REVERSE;
        S_MAIN_PRINT_REVERSE:
            if(btn_pressed == 0) P_next = S_MAIN_PRINT_REVERSE;
            else P_next = S_MAIN_PRINT_FORWARD;
    endcase
end

always@(posedge clk)begin
    if(P == S_MAIN_INIT) begin
        init_counter <= init_counter + 1;
        counter1 = 2;
        counter2 = 2;
        counter3 = 2;
        index = 1;
        index1 = 1; 
        calculation_finish = 0;
        primes = {2048{1'b1}};
        end
    else init_counter <= 0;
    if(P == S_MAIN_PRIMES)begin
        if(counter1 < 1023)begin
            if(primes[counter1])begin
                if(counter2 < 1023)begin
                    counter2 = counter2 + counter1;
                    primes[counter2] = 0;
                end
            end
            if(counter2 >= 1023 || primes[counter1] == 0)begin
                counter1 = counter1 + 1;
                counter2 = counter1;
                end
        end
        if(counter1 == 1023)begin
            if(primes[counter3])begin
                prime_in_array[index] = counter3;
                index = index + 1;
                calculation_finish = 0;
                end
            counter3 = counter3 + 1;
            if(counter3 == 1023) calculation_finish = 1;
        end
    end
    if(print_counter == 7000000 && P == S_MAIN_PRINT_FORWARD)begin
        index1 = index1 + 1;
        if(index1 > 172)index1 = 1; 
    end
    if(print_counter == 7000000 && P == S_MAIN_PRINT_REVERSE)begin
        index1 = index1 - 1;
        if(index1 < 1)index1 = 172;
    end
    if(P == S_MAIN_PRINT_FORWARD || P == S_MAIN_PRINT_REVERSE)begin
        if(print_counter <= 70000000) print_counter = print_counter + 1;
        else print_counter = 0;
    end
    number1 = index1;
    number2 = index1 + 1;
    prime_number1 = prime_in_array[index1];
    prime_number2 = prime_in_array[index1 + 1];
end

always@(posedge clk)begin
    if(P == S_MAIN_PRINT_FORWARD || P == S_MAIN_PRINT_REVERSE)begin
        { row_A[127:120], row_A[119:112], row_A[111:104], row_A[103:96] , row_A[95:88] , row_A[87:80], row_A[79:72]}
          <= {"Prime #"};
        if(print_num1[1] >= 10){ row_A[71:64]} <= {print_num1[1] + 55};
            else { row_A[71:64]} <= {print_num1[1] + 48};
        if(print_num1[0] >= 10){ row_A[63:56]} <= {print_num1[0] + 55};
            else { row_A[63:56]} <= {print_num1[0] + 48};
        { row_A[55:48], row_A[47:40], row_A[39:32] , row_A[31:24]} <= {" is "};
        if(print_prime_number1[2] >= 10){ row_A[23:16]} <= {print_prime_number1[2] + 55};
            else { row_A[23:16]} <= {print_prime_number1[2] + 48};
        if(print_prime_number1[1] >= 10){ row_A[15:8]} <= {print_prime_number1[1] + 55};
            else { row_A[15:8]} <= {print_prime_number1[1] + 48};
        if(print_prime_number1[0] >= 10){ row_A[7:0]} <= {print_prime_number1[0] + 55};
            else { row_A[7:0]} <= {print_prime_number1[0] + 48};
            
        { row_B[127:120], row_B[119:112], row_B[111:104], row_B[103:96] , row_B[95:88] , row_B[87:80], row_B[79:72]}
                      <= {"Prime #"};
        if(print_num2[1] >= 10){ row_B[71:64]} <= {print_num2[1] + 55};
            else { row_B[71:64]} <= {print_num2[1] + 48};
        if(print_num2[0] >= 10){ row_B[63:56]} <= {print_num2[0] + 55};
            else { row_B[63:56]} <= {print_num2[0] + 48};
        { row_B[55:48], row_B[47:40], row_B[39:32] , row_B[31:24]} <= {" is "};
        if(print_prime_number2[2] >= 10){ row_B[23:16]} <= {print_prime_number2[2] + 55};
            else { row_B[23:16]} <= {print_prime_number2[2] + 48};
        if(print_prime_number2[1] >= 10){ row_B[15:8]} <= {print_prime_number2[1] + 55};
            else { row_B[15:8]} <= {print_prime_number2[1] + 48};
        if(print_prime_number2[0] >= 10){ row_B[7:0]} <= {print_prime_number2[0] + 55};
            else { row_B[7:0]} <= {print_prime_number2[0] + 48};
    end
end

always@(posedge clk)begin
    if(P == S_MAIN_PRINT_FORWARD || P == S_MAIN_PRINT_REVERSE) begin
        print_num1[0] <= number1 - number1 / 16 * 16;
        print_num1[1] <= number1 / 16 - number1 / 256 * 16;
        print_prime_number1[0] <= prime_number1 - prime_number1 / 16 * 16;
        print_prime_number1[1] <= prime_number1 / 16 - prime_number1 / 256 * 16;
        print_prime_number1[2] <= prime_number1 / 256 - prime_number1 / 4096 * 16;
        
        print_num2[0] <= number2 - number2 / 16 * 16;
        print_num2[1] <= number2 / 16 - number2 / 256 * 16;
        print_prime_number2[0] <= prime_number2 - prime_number2 / 16 * 16;
        print_prime_number2[1] <= prime_number2 / 16 - prime_number2 / 256 * 16;
        print_prime_number2[2] <= prime_number2 / 256 - prime_number2 / 4096 * 16;
        end
end
    
endmodule