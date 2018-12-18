`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/12/06 20:44:08
// Design Name: 
// Module Name: lab9
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: This is a sample circuit to show you how to initialize an SRAM
//              with a pre-defined data file. Hit BTN0/BTN1 let you browse
//              through the data.
// 
// Dependencies: LCD_module, debounce
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lab9(
  // General system I/O ports
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,

  // 1602 LCD Module Interface
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
);

localparam [3:0] S_MAIN_INIT = 0,  S_MAIN_WAIT = 1, S_MAIN_ADDR = 2,  S_MAIN_READ = 3,
				 S_MAIN_STORE = 4, S_MAIN_BUF1 = 5, S_MAIN_RESET = 6, S_MAIN_MULTI = 7,
                 S_MAIN_PLUS = 8,  S_MAIN_BUF2 = 9, S_MAIN_IF = 10,   S_MAIN_BUF3 = 11, 
				 S_MAIN_SHOW = 12;     

// declare system variables
wire              btn_level, btn_pressed;
reg               prev_btn_level;
reg  [3:0]        P, P_next;
reg  [11:0]       init_counter = 0;
reg  [11:0]       store_counter = 0;
reg  [11:0]       k_counter = 0;
reg  [11:0]       x_counter = 0;

reg  signed [7:0]F[0:1023];
reg  signed [7:0]G[0:63];

reg  [11:0]       addr = 0;
reg  signed [7:0] data;

reg  signed [23:0] max_sum = 0;
reg  [11:0] max_pos = 0;

reg  signed [23:0] sum;
reg  signed [23:0] tem;

reg  [7:0] out1, out2, out3, out4, out5, out6, out7, out8, out9;

reg  [127:0] row_A = "Press BTN0 to do";
reg  [127:0] row_B = "x-correlation...";

// declare SRAM control signals
wire [10:0] sram_addr;
wire [7:0]  data_in;
wire [7:0]  data_out;
wire        sram_we, sram_en;

assign usr_led = P;

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
  
debounce btn_db3(
  .clk(clk),
  .btn_input(usr_btn[0]),
  .btn_output(btn_level)
);

//
// Enable one cycle of btn_pressed per each button hit
//
always @(posedge clk) begin
	if (~reset_n) prev_btn_level <= 0;
	else prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level & ~prev_btn_level);

// ------------------------------------------------------------------------
// The following code describes an initialized SRAM memory block that
// stores an 1024+64 8-bit signed data samples.
sram ram0(.clk(clk), 
		  .we(sram_we), 
		  .en(sram_en),
          .addr(sram_addr), 
		  .data_i(data_in), 
		  .data_o(data_out));

assign sram_we = usr_btn[3]; // In this demo, we do not write the SRAM. However,
                             // if you set 'we' to 0, Vivado fails to synthesize
                             // ram0 as a BRAM -- this is a bug in Vivado.
//assign sram_we = 0;
assign sram_en = (P == S_MAIN_ADDR || P == S_MAIN_READ); // Enable the SRAM block.
assign sram_addr = addr[11:0];
assign data_in = 8'b0; // SRAM is read-only so we tie inputs to zeros.
// End of the SRAM memory block.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the main controller
always @(posedge clk) begin
	if (~reset_n) P <= S_MAIN_INIT; // read samples at 000 first
	else P <= P_next;
end

always @(*) begin // FSM next-state logic
  case (P)
	S_MAIN_INIT:
		if (init_counter == 1000) P_next = S_MAIN_WAIT;
		else P_next = S_MAIN_INIT;
	S_MAIN_WAIT:
		if (btn_pressed == 1) P_next = S_MAIN_ADDR;
		else P_next = S_MAIN_WAIT;
    S_MAIN_ADDR: // send an address to the SRAM 
		P_next = S_MAIN_READ;
    S_MAIN_READ: // fetch the sample from the SRAM
		P_next = S_MAIN_STORE;
    S_MAIN_STORE:
		P_next = S_MAIN_BUF1;
    S_MAIN_BUF1:
		if (store_counter == 1088) P_next = S_MAIN_RESET;
		else P_next = S_MAIN_ADDR;
	S_MAIN_RESET:
		P_next = S_MAIN_MULTI;
	S_MAIN_MULTI:
		P_next = S_MAIN_PLUS;
	S_MAIN_PLUS:
		P_next = S_MAIN_BUF2;
	S_MAIN_BUF2:
		if (k_counter == 64) P_next = S_MAIN_IF;
		else P_next = S_MAIN_MULTI;
	S_MAIN_IF:
		P_next = S_MAIN_BUF3;
	S_MAIN_BUF3:
		if (x_counter == 960) P_next = S_MAIN_SHOW;
		else P_next = S_MAIN_RESET;
  endcase
end

// FSM ouput logic: Fetch the data bus of sram[] for display
always @(posedge clk) begin
	if (~reset_n) data <= 8'b0;
	else if (sram_en && !sram_we) data <= data_out;
end
// End of the main controller
// ------------------------------------------------------------------------

always @(posedge clk) begin
	if (~reset_n) init_counter <= 0;
	else if(P == S_MAIN_INIT) init_counter <= init_counter + 1;
end

always @(posedge clk) begin
	if (~reset_n) store_counter <= 0;
	else if(P == S_MAIN_ADDR) store_counter <= store_counter + 1;
end

always @(posedge clk) begin
	if (P == S_MAIN_STORE) begin
		if(addr < 1024) F[addr] = data;
		else G[addr-1024] = data;
	end
end

always @(posedge clk) begin
	if (~reset_n) addr <= 12'h000;
	else if (P == S_MAIN_BUF1) addr <= (addr < 2048)? addr + 1 : addr;
end

always @(posedge clk) begin
	if (~reset_n) tem <= 0;
	else if (P == S_MAIN_MULTI) tem = F[k_counter + x_counter] * G[k_counter];
	else if (P == S_MAIN_RESET) tem <= 0;
end

always @(posedge clk) begin
	if (~reset_n) sum <= 0;
	else if (P == S_MAIN_PLUS) begin
		sum <= sum + tem;
		k_counter <= k_counter + 1;
		end
	else if (P == S_MAIN_RESET) begin 
		sum <= 0;
		k_counter <= 0;
		end
end

always @(posedge clk) begin
	if (~reset_n) begin
		max_sum = 0;
		max_pos = 0;
		end
	if (P == S_MAIN_IF) begin
		x_counter <= x_counter + 1;
		if (sum > max_sum) begin
            max_sum <= sum;
            max_pos <= x_counter;
			end
		end
end

always @(posedge clk) begin
	if (~reset_n) begin
		out1 <= 8'b0;
		out2 <= 8'b0;
		out3 <= 8'b0;
		out4 <= 8'b0;
		out5 <= 8'b0;
		out6 <= 8'b0;
		out7 <= 8'b0;
		out8 <= 8'b0;
		out9 <= 8'b0;
		end
	else if (P == S_MAIN_SHOW) begin
		out1 <= ((max_sum[23:20] > 9) ? "7" : "0") + max_sum[23:20];
		out2 <= ((max_sum[19:16] > 9) ? "7" : "0") + max_sum[19:16];
		out3 <= ((max_sum[15:12] > 9) ? "7" : "0") + max_sum[15:12];
		out4 <= ((max_sum[11:8 ] > 9) ? "7" : "0") + max_sum[11:8 ];
		out5 <= ((max_sum[7 :4 ] > 9) ? "7" : "0") + max_sum[7 :4 ];
		out6 <= ((max_sum[3 :0 ] > 9) ? "7" : "0") + max_sum[3 :0 ];
		out7 <= ((max_pos[11:8] > 9) ? "7" : "0") + max_pos[11:8];
		out8 <= ((max_pos[7 :4] > 9) ? "7" : "0") + max_pos[7 :4];
		out9 <= ((max_pos[3 :0] > 9) ? "7" : "0") + max_pos[3 :0];
		end
end

always @(posedge clk) begin
	if (~reset_n) begin
		row_A <= {"P", "r", "e", "s", "s", " ", "B", "T", "N", "0", " ", "t", "o", " ", "d", "o"};
		row_B <= {"x", "-", "c", "o", "r", "r", "e", "l", "a", "t", "i", "o", "n", ".", ".", "."};
		end
	if (P == S_MAIN_WAIT) begin
		row_A <= {"P", "r", "e", "s", "s", " ", "B", "T", "N", "0", " ", "t", "o", " ", "d", "o"};
		row_B <= {"x", "-", "c", "o", "r", "r", "e", "l", "a", "t", "i", "o", "n", ".", ".", "."};
		end
	if (P == S_MAIN_SHOW) begin
		row_A <= {"M", "a", "x", " ", "v", "a", "l", "u", "e", " ", out1, out2, out3, out4, out5, out6};
		row_B <= {"M", "a", "x", " ", "l", "o", "c", "a", "t", "i", "o", "n", " ", out7, out8, out9};
		end
end

endmodule
