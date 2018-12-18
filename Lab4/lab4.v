`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of CS, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/04/27 15:06:57
// Design Name: UART I/O example for Arty
// Module Name: lab4
// Project Name: 
// Target Devices: Xilinx FPGA @ 100MHz
// Tool Versions: 
// Description: 
// 
// The parameters for the UART controller are 9600 baudrate, 8-N-1-N
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab4(
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,
  input  uart_rx,
  output uart_tx
);

localparam [2:0] S_MAIN_INIT = 0, S_MAIN_PROMPT = 1,
                 S_MAIN_WAIT_KEY = 2, S_SECOND_PROMPT = 3,
                 S_SECOND_WAIT_KEY =4, S_GCD_START = 5,
                 S_GCD_TRAN = 6, S_GCD_PRINT = 7;
localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1,
                 S_UART_SEND = 2, S_UART_INCR = 3;

// declare system variables
wire print_enable, print_done;
reg [7:0] send_counter;
reg [4:0] P, P_next;
reg [4:0] Q, Q_next;
reg [23:0] init_counter;
reg [15:0] N1 = 16'b0;
reg [15:0] N2 = 16'b0;

// declare UART signals
wire transmit;
wire received;
wire [7:0] rx_byte;
reg  [7:0] rx_temp;
wire [7:0] tx_byte;
wire enter_pressed;
wire keyboard_input;
wire is_receiving;
wire is_transmitting;
wire recv_error;
wire GCD_FINISH;
wire GCD_DONE;
reg  calculation_finish;
reg  [7:0]ans[3:0];

/* The UART device takes a 100MHz clock to handle I/O at 9600 baudrate */
uart uart(
  .clk(clk),
  .rst(~reset_n),
  .rx(uart_rx),
  .tx(uart_tx),
  .transmit(transmit),
  .tx_byte(tx_byte),
  .received(received),
  .rx_byte(rx_byte),
  .is_receiving(is_receiving),
  .is_transmitting(is_transmitting),
  .recv_error(recv_error)
);

// Initializes some strings.
// System Verilog has an easier way to initialize an array,
// but we are using Verilog 2005 :(
//
localparam MEM_SIZE = 100;
localparam MAIN_PROMPT_STR = 0;
localparam SECOND_PROMPT_STR = 34;
localparam GCD_PROMPT_STR = 69;
reg [7:0] data[0:MEM_SIZE-1];

always @(posedge clk)begin
    if(~reset_n)begin
          { data[ 0], data[ 1], data[ 2], data[ 3], data[ 4], data[ 5], data[ 6], data[ 7],
          data[ 8], data[ 9], data[10], data[11], data[12], data[13], data[14], data[15],
          data[16], data[17], data[18], data[19], data[20], data[21], data[22], data[23],
          data[24], data[25], data[26], data[27], data[28], data[29], data[30], data[31],
          data[32], data[33] }
        <= { 8'h0D, 8'h0A, "Enter the first decimal number:", 8'h00 };
        end
    else begin
        { data[34], data[35], data[36], data[37], data[38], data[39], data[40], data[41],
        data[42], data[43], data[44], data[45], data[46], data[47], data[48], data[49],
        data[50], data[51], data[52], data[53], data[54], data[55], data[56], data[57],
        data[58], data[59], data[60], data[61], data[62], data[63], data[64], data[65],
        data[66], data[67], data[68] }
      <= { 8'h0D, 8'h0A,  "Enter the second decimal number:",  8'h00 };
    //MAIN_NUMBER_FINISH  
      { data[69], data[70], data[71], data[72], data[73], data[74], data[75], data[76],
        data[77], data[78], data[79], data[80], data[81], data[82], data[83], data[84]  } 
      <= { 8'h0D, 8'h0A,  "The GCD is: 0X" };
      if(ans[3] >= 10){ data[85]} <= {ans[3] + 55};
        else { data[85]} <= {ans[3] + 48};
      if(ans[2] >= 10){ data[86]} <= {ans[2] + 55};
        else { data[86]} <= {ans[2] + 48};
      if(ans[1] >= 10){ data[87]} <= {ans[1] + 55};
        else { data[87]} <= {ans[1] + 48};
      if(ans[0] >= 10){ data[88]} <= {ans[0] + 55};
        else { data[88]} <= {ans[0] + 48};
        end
end

// Combinational I/O logics
assign usr_led = N1[3:0];
assign enter_pressed = (rx_temp == 8'h0D);
assign keyboard_input = ((rx_temp == 8'h30) || (rx_temp == 8'h31) || (rx_temp == 8'h32) || (rx_temp == 8'h33) || (rx_temp == 8'h34) || (rx_temp == 8'h35) || (rx_temp == 8'h36) || (rx_temp == 8'h37) || (rx_temp == 8'h38) || (rx_temp == 8'h39));
assign tx_byte = (keyboard_input) ? rx_temp : data[send_counter] ;

// FSM output logics: print string control signals.
assign print_enable = (P == S_MAIN_PROMPT) || (P == S_SECOND_PROMPT ) || (P == S_GCD_PRINT ) ;
assign print_done = (Q==S_UART_INCR) ? (tx_byte == 8'h0) : ~print_enable ;
// FSM output logics
assign transmit = (Q_next == S_UART_WAIT || keyboard_input);
//
assign GCD_FINISH = calculation_finish ;
assign GCD_DONE = (P == S_GCD_TRAN);
// ------------------------------------------------------------------------
// Main FSM that reads the UART input and triggers
// the output of the string "Hello, World!".
always @(posedge clk) begin
  if (~reset_n) begin
  P <= S_MAIN_INIT;
  end 
  else P <= P_next;
end

always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT: // Delay 10 us.
	   if (init_counter < 1000) P_next = S_MAIN_INIT;
	   else  P_next = S_MAIN_PROMPT;
    S_MAIN_PROMPT: // Print the first prompt message.
      if (print_done) P_next = S_MAIN_WAIT_KEY;
      else P_next = S_MAIN_PROMPT;
    S_MAIN_WAIT_KEY: // wait for <Enter> key.
      if (enter_pressed) P_next = S_SECOND_PROMPT;
      else P_next = S_MAIN_WAIT_KEY;
    S_SECOND_PROMPT: // Print the prompt message.
      if (print_done) P_next = S_SECOND_WAIT_KEY;
      else P_next = S_SECOND_PROMPT;
    S_SECOND_WAIT_KEY:
      if (enter_pressed) P_next = S_GCD_START;
      else P_next = S_SECOND_WAIT_KEY;
    S_GCD_START: // Print the hello message.
      if (GCD_FINISH) P_next = S_GCD_TRAN;
      else P_next = S_GCD_START;
    S_GCD_TRAN:
      if (GCD_DONE) P_next = S_GCD_PRINT;
      else P_next = S_GCD_TRAN;
    S_GCD_PRINT:
      if (print_done) P_next = S_MAIN_INIT;
      else P_next = S_GCD_PRINT;
  endcase
end

// Initialization counter.
always @(posedge clk) begin
  if (P == S_MAIN_INIT) init_counter <= init_counter + 1;
  else init_counter <= 0;
end
// End of the FSM of the print string controller
// ------------------------------------------------------------------------

//GCD
always@(posedge clk)begin
    if(~reset_n) begin
        N1 <= 0;
        N2 <= 0;
        end
    else begin
        if (P == S_MAIN_INIT) begin
            N1 <= 0;
            N2 <= 0;
            end
        else if (P == S_MAIN_WAIT_KEY && keyboard_input) begin
            N1 <= N1*10+(rx_temp-48);
            end
        else if (P == S_SECOND_WAIT_KEY && keyboard_input) begin
            N2 <= N2*10+(rx_temp-48);
            end
        else if (P == S_GCD_START) begin
                if (N2 > N1) begin
                    N1 <= N2;
                    N2 <= N1;
                    end
                else if(N2 != 0) begin
                    N1 <= N1-N2;
                    end
                else calculation_finish <= 1;
                end
        else calculation_finish <= 0;
    end
end

always@(posedge clk)begin
    if(P == S_GCD_TRAN) begin
        ans[0] <= N1 - N1 / 16 * 16;
        ans[1] <= N1 / 16 - N1 / 256 * 16;
        ans[2] <= N1 / 256 - N1 / 4096 * 16;
        ans[3] <= N1 / 4096 - N1 /65536 * 16;
        end
end

// ------------------------------------------------------------------------
// FSM of the controller to send a string to the UART.
always @(posedge clk) begin
  if (~reset_n) Q <= S_UART_IDLE;
  else Q <= Q_next;
end

always @(*) begin // FSM next-state logic
  case (Q)
    S_UART_IDLE: // wait for the print_string flag
      if (print_enable) Q_next = S_UART_WAIT;
      else Q_next = S_UART_IDLE;
    S_UART_WAIT: // wait for the transmission of current data byte begins
      if (is_transmitting == 1) Q_next = S_UART_SEND;
      else Q_next = S_UART_WAIT;
    S_UART_SEND: // wait for the transmission of current data byte finishes
      if (is_transmitting == 0) Q_next = S_UART_INCR; // transmit next character
      else Q_next = S_UART_SEND;
    S_UART_INCR:
      if (tx_byte == 8'h0) Q_next = S_UART_IDLE; // string transmission ends
      else Q_next = S_UART_WAIT;
  endcase
end



// UART send_counter control circuit
always @(posedge clk) begin
    if(P_next == S_MAIN_INIT) send_counter <= MAIN_PROMPT_STR;
    else if(P_next == S_MAIN_WAIT_KEY) send_counter <= SECOND_PROMPT_STR;
    else if(P_next == S_SECOND_WAIT_KEY) send_counter <= GCD_PROMPT_STR;
    else send_counter <= send_counter + (Q_next == S_UART_INCR);
end
// End of the FSM of the print string controller
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// The following logic stores the UART input in a temporary buffer.
// The input character will stay in the buffer for one clock cycle.
always @(posedge clk) begin
  rx_temp <= (received)? rx_byte : 8'h0;
end
// ------------------------------------------------------------------------

endmodule







