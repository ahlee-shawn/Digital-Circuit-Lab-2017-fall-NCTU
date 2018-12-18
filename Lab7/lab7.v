`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/05/08 15:29:41
// Design Name: 
// Module Name: lab6
// Project Name: 
// Target Devices: 
// Tool Versions:
// Description: The sample top module of lab 6: sd card reader. The behavior of
//              this module is as follows
//              1. When the SD card is initialized, display a message on the LCD.
//                 If the initialization fails, an error message will be shown.
//              2. The user can then press usr_btn[2] to trigger the sd card
//                 controller to read the super block of the sd card (located at
//                 block # 8192) into the SRAM memory.
//              3. During SD card reading time, the four LED lights will be turned on.
//                 They will be turned off when the reading is done.
//              4. The LCD will then displayer the sector just been read, and the
//                 first byte of the sector.
//              5. Everytime you press usr_btn[2], the next byte will be displayed.
// 
// Dependencies: clk_divider, LCD_module, debounce, sd_card
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab7(
  // General system I/O ports
  input  clk,
  input  reset_n,
  input  [3:0] usr_btn,
  output [3:0] usr_led,

  // SD card specific I/O ports
  output spi_ss,
  output spi_sck,
  output spi_mosi,
  input  spi_miso,
  
  // 1602 LCD Module Interface
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D,
  
  //UART
  input  uart_rx,
  output uart_tx
);

reg  [127:0] row_A = "SD card cannot  ";
reg  [127:0] row_B = "be initialized! ";

localparam [3:0] S_MAIN_INIT = 0, S_MAIN_IDLE = 1,
                 S_MAIN_WAIT = 2, S_MAIN_READ = 3,
                 S_MAIN_FIND = 4, S_MAIN_DONE = 5, S_MAIN_GET = 6,
                 S_MAIN_STORE = 7, S_MAIN_CALCULATE = 8, S_MAIN_FINISH = 9,
                 S_UART_INIT = 10, S_UART_PRINT = 11, S_UART_DONE = 12;
localparam [1:0] S_UART_IDLE = 0, S_UART_WAIT = 1,
                 S_UART_SEND = 2, S_UART_INCR = 3;

reg  [7:0]out1,out2,out3,out4,out5,out6,out7,out8,out9,out10,out11,out12,out13,out14,out15,out16,out17,out18,out19,out20,out21,out22,out23,out24,out25,out26,out27,out28,out29,out30,out31,out32;
				 
// Declare system variables
reg  find_start = 0;
reg  calculate = 0;
reg  change_finish = 0;
reg  [2:0]count_head;
wire btn_level, btn_pressed;
wire print_enable, print_done;
reg  prev_btn_level;
reg  [8:0] send_counter;
reg  [3:0] P, P_next;
reg  [1:0] Q, Q_next;
reg  [9:0] sd_counter;
reg  [7:0] data_byte;
reg  [31:0] blk_addr;

reg  [0:1]row;
reg  [0:1]col;
reg  key = 0;
reg  value = 0;
reg  first = 0;
reg  [0:16*8-1]A_mat;
reg  [0:16*8-1]B_mat;
reg  [0:16*20-1]Ans_mat;
reg  [0:31]col_ans = {8'd0, 8'd20, 8'd40, 8'd60};
reg  check = 0;
reg  [15:0] counter;
reg  [0:7]data[0:144];
reg  [0:7]ans[0:79];
reg  [0:6]count;
reg  [7:0]get_input;

// Declare SD card interface signals
wire clk_sel;
wire clk_500k;
reg  rd_req;
reg  [31:0] rd_addr;
wire init_finished;
wire [7:0] sd_dout;
wire sd_valid;

// Declare the control/data signals of an SRAM memory block
wire [7:0] data_in;
wire [7:0] data_out;
wire [8:0] sram_addr;
wire sram_we, sram_en;

// declare UART signals
wire transmit;
wire received;
wire [7:0] rx_byte;
reg  [7:0] rx_temp;
wire [7:0] tx_byte;
wire is_receiving;
wire is_transmitting;
wire recv_error;
wire [7:0]in_buf_char;
wire [7:0]in_buf_char_2;
assign in_buf_char = data_out;
assign in_buf_char_2 = data_out;
assign clk_sel = (init_finished) ? clk : clk_500k; // clock for the SD controller
assign tx_byte = data[send_counter] ;
assign transmit = Q_next == S_UART_WAIT;
assign usr_led = P;

clk_divider#(200) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(clk_500k)
);

debounce btn_db0(
  .clk(clk),
  .btn_input(usr_btn[1]),
  .btn_output(btn_level)
);

sd_card sd_card0(
  .cs(spi_ss),
  .sclk(spi_sck),
  .mosi(spi_mosi),
  .miso(spi_miso),

  .clk(clk_sel),
  .rst(~reset_n),
  .rd_req(rd_req),
  .block_addr(rd_addr),
  .init_finished(init_finished),
  .dout(sd_dout),
  .sd_valid(sd_valid)
);

sram ram0(
  .clk(clk),
  .we(sram_we),
  .en(sram_en),
  .addr(sram_addr),
  .data_i(data_in),
  .data_o(data_out)
);

uart uart0(
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

//
// Enable one cycle of btn_pressed per each button hit
//
always @(posedge clk) begin
  if (~reset_n)
    prev_btn_level <= 0;
  else
    prev_btn_level <= btn_level;
end

assign btn_pressed = (btn_level == 1 && prev_btn_level == 0)? 1 : 0;

// ------------------------------------------------------------------------
// The following code sets the control signals of an SRAM memory block
// that is connected to the data output port of the SD controller.
// Once the read request is made to the SD controller, 512 bytes of data
// will be sequentially read into the SRAM memory block, one byte per
// clock cycle (as long as the sd_valid signal is high).
assign sram_we = sd_valid;          // Write data into SRAM when sd_valid is high.
assign sram_en = 1;                 // Always enable the SRAM block.
assign data_in = sd_dout;           // Input data always comes from the SD controller.
assign sram_addr = sd_counter[8:0]; // Set the driver of the SRAM address signal.
assign print_enable = (P == S_UART_PRINT);
assign print_done = (tx_byte == 8'h00);
// End of the SRAM memory block
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// FSM of the SD card reader that reads the super block (512 bytes)
always @(posedge clk) begin
  if (~reset_n) P <= S_MAIN_INIT;
  else P <= P_next;
end

always @(*) begin // FSM next-state logic
  case (P)
    S_MAIN_INIT: // wait for SD card initialization
      if (init_finished == 1) P_next = S_MAIN_IDLE;
      else P_next = S_MAIN_INIT;
    S_MAIN_IDLE: // wait for button click
      if (btn_pressed == 1) P_next = S_MAIN_WAIT;
      else P_next = S_MAIN_IDLE;
    S_MAIN_WAIT: // issue a rd_req to the SD controller until it's ready
      P_next = S_MAIN_READ;
    S_MAIN_READ: // wait for the input data to enter the SRAM buffer
      if (sd_counter == 512) P_next = S_MAIN_FIND;
      else P_next = S_MAIN_READ;
    S_MAIN_FIND:
      if (find_start == 1) P_next = S_MAIN_GET;
      else if (sd_counter == 512) P_next = S_MAIN_DONE;
      else P_next = S_MAIN_FIND;
    S_MAIN_DONE: // read byte 0 of the superblock from sram[]
      P_next = S_MAIN_WAIT;
	S_MAIN_GET:
	  P_next = S_MAIN_STORE;
	S_MAIN_STORE:
	  if (change_finish == 1) P_next = S_MAIN_CALCULATE;
	  else P_next = S_MAIN_GET;
    S_MAIN_CALCULATE:
      if (calculate == 1) P_next = S_MAIN_FINISH;
      else P_next = S_MAIN_CALCULATE;
    S_MAIN_FINISH:
      P_next = S_UART_INIT;
    S_UART_INIT:
      if (sd_counter == 1000) P_next = S_UART_PRINT;
      else P_next = S_UART_INIT;
    S_UART_PRINT:
      if (print_done == 1) P_next = S_UART_DONE;
      else P_next = S_UART_PRINT;
    S_UART_DONE:
      P_next = S_UART_DONE;
    default:
      P_next = S_MAIN_IDLE;
  endcase
end

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
      if (tx_byte == 8'h00) Q_next = S_UART_IDLE; // string transmission ends
      else Q_next = S_UART_WAIT;
  endcase
end

// FSM output logic: controls the 'rd_req' and 'rd_addr' signals.
always @(*) begin
  rd_req = (P == S_MAIN_WAIT);
  rd_addr = blk_addr;
end

always @(posedge clk) begin
  if (~reset_n) blk_addr <= 32'h2000;
  else if (P == S_MAIN_DONE && P_next == S_MAIN_WAIT) blk_addr <= blk_addr + 1;
  else blk_addr <= blk_addr; // In lab 6, change this line to scan all blocks
end

// FSM output logic: controls the 'sd_counter' signal.
// SD card read address incrementer
always @(posedge clk) begin
  if (~reset_n || (P == S_MAIN_READ && P_next == S_MAIN_FIND) || (P == S_MAIN_DONE && P_next == S_MAIN_WAIT) || (P == S_MAIN_FINISH && P_next == S_UART_INIT)) sd_counter <= 0;
  else if ((P == S_MAIN_READ && sd_valid) || P == S_MAIN_FIND || P == S_UART_INIT || P == S_MAIN_GET) sd_counter <= sd_counter + 1;
  else sd_counter <= sd_counter;
end

always @(posedge clk) begin
  if (~reset_n) begin
    count_head <= 3'b000;
	find_start <= 0;
	end
  if (P == S_MAIN_FIND) begin
	if (data_out == "M") count_head <= 3'b001;
	else if (data_out == "A" && count_head == 3'b001) count_head <= 3'b010;
    else if (data_out != "A" && count_head == 3'b001) count_head <= 3'b000;
	else if (data_out == "T" && count_head == 3'b010) count_head <= 3'b011;
    else if (data_out != "T" && count_head == 3'b010) count_head <= 3'b000;
	else if (data_out == "X" && count_head == 3'b011) count_head <= 3'b100;
    else if (data_out != "X" && count_head == 3'b011) count_head <= 3'b000;
	else if (data_out == "_" && count_head == 3'b100) count_head <= 3'b101; 
    else if (data_out != "_" && count_head == 3'b100) count_head <= 3'b000;
	else if (data_out == "T" && count_head == 3'b101) count_head <= 3'b110;
    else if (data_out != "T" && count_head == 3'b101) count_head <= 3'b000;
	else if (data_out == "A" && count_head == 3'b110) count_head <= 3'b111;
    else if (data_out != "A" && count_head == 3'b110) count_head <= 3'b000;
	else if (data_out == "G" && count_head == 3'b111) begin
	count_head <= 3'b000;
	find_start <= 1;
	end
    else if (data_out != "G" && count_head == 3'b111) count_head <= 3'b000;
	else count_head <= 3'b000;
  end
end

always @(posedge clk) begin
  if (~reset_n) begin
	get_input <= 8'b0;
	end
  if (P == S_MAIN_GET) begin
    get_input = in_buf_char;
	end
end

always @(posedge clk) begin
  if (~reset_n) begin 
    A_mat <= {16{8'h0}};
	B_mat <= {16{8'h0}};
	row <= 0;
	col <= 0;
	key <= 0;
	value <= 0;
	first <= 0;
	count <= 0;
	end
  if (P == S_MAIN_INIT) begin 
    A_mat <= {16{8'h0}};
	B_mat <= {16{8'h0}};
	row <= 0;
	col <= 0;
	key <= 0;
	value <= 0;
	first <= 0;
	count <= 0;
	end
  if (P == S_MAIN_STORE) begin
    if (count == 65) change_finish <= 1;
    else if (in_buf_char == 8'h0A || in_buf_char == 8'h0D) count <= count ;
	else if (count <= 31) begin A_mat[(count*4)+:4] <= in_buf_char <= "9" ? in_buf_char- "0" : in_buf_char - "A" + 10; count <= count + 1; end
	else if (count > 31 && count <=64) begin B_mat[((count-32)*4)+:4] <= in_buf_char <= "9" ? in_buf_char- "0" : in_buf_char - "A" + 10; count <= count + 1; end
	end
end

always @(posedge clk) begin
  if (~reset_n) begin 
    Ans_mat <= {16{20'h0}};
    counter <= 0;
    end
  if (P == S_MAIN_CALCULATE)
    counter <= counter + 8;
  if (P == S_MAIN_CALCULATE && counter <= 24) begin
    Ans_mat[(col_ans[counter+:8]+  0)+:20] <= B_mat[ 0+:8] * A_mat[(counter +  0)+:8] + B_mat[ 8+:8] * A_mat[(counter + 32)+:8] + B_mat[16+:8] * A_mat[(counter + 64)+:8] + B_mat[24+:8] * A_mat[(counter + 96)+:8];
    Ans_mat[(col_ans[counter+:8]+ 80)+:20] <= B_mat[32+:8] * A_mat[(counter +  0)+:8] + B_mat[40+:8] * A_mat[(counter + 32)+:8] + B_mat[48+:8] * A_mat[(counter + 64)+:8] + B_mat[56+:8] * A_mat[(counter + 96)+:8];
    Ans_mat[(col_ans[counter+:8]+160)+:20] <= B_mat[64+:8] * A_mat[(counter +  0)+:8] + B_mat[72+:8] * A_mat[(counter + 32)+:8] + B_mat[80+:8] * A_mat[(counter + 64)+:8] + B_mat[88+:8] * A_mat[(counter + 96)+:8];
	Ans_mat[(col_ans[counter+:8]+240)+:20] <= B_mat[96+:8] * A_mat[(counter +  0)+:8] + B_mat[104+:8] * A_mat[(counter + 32)+:8] + B_mat[112+:8] * A_mat[(counter + 64)+:8] + B_mat[120+:8] * A_mat[(counter + 96)+:8];
    end
  if (counter >= 40) calculate <= 1;
end

always@(posedge clk)begin
	ans[0  ] <= (Ans_mat[0  :3  ] < 10) ? Ans_mat[0  :3  ]+48 :  Ans_mat[0  :3  ]+55;
	ans[1  ] <= (Ans_mat[4  :7  ] < 10) ? Ans_mat[4  :7  ]+48 :  Ans_mat[4  :7  ]+55;
	ans[2  ] <= (Ans_mat[8  :11 ] < 10) ? Ans_mat[8  :11 ]+48 :  Ans_mat[8  :11 ]+55;
	ans[3  ] <= (Ans_mat[12 :15 ] < 10) ? Ans_mat[12 :15 ]+48 :  Ans_mat[12 :15 ]+55;
	ans[4  ] <= (Ans_mat[16 :19 ] < 10) ? Ans_mat[16 :19 ]+48 :  Ans_mat[16 :19 ]+55;
	ans[5  ] <= (Ans_mat[20 :23 ] < 10) ? Ans_mat[20 :23 ]+48 :  Ans_mat[20 :23 ]+55;
	ans[6  ] <= (Ans_mat[24 :27 ] < 10) ? Ans_mat[24 :27 ]+48 :  Ans_mat[24 :27 ]+55;
	ans[7  ] <= (Ans_mat[28 :31 ] < 10) ? Ans_mat[28 :31 ]+48 :  Ans_mat[28 :31 ]+55;
	ans[8  ] <= (Ans_mat[32 :35 ] < 10) ? Ans_mat[32 :35 ]+48 :  Ans_mat[32 :35 ]+55;
	ans[9  ] <= (Ans_mat[36 :39 ] < 10) ? Ans_mat[36 :39 ]+48 :  Ans_mat[36 :39 ]+55;
	ans[10 ] <= (Ans_mat[40 :43 ] < 10) ? Ans_mat[40 :43 ]+48 :  Ans_mat[40 :43 ]+55;
	ans[11 ] <= (Ans_mat[44 :47 ] < 10) ? Ans_mat[44 :47 ]+48 :  Ans_mat[44 :47 ]+55;
	ans[12 ] <= (Ans_mat[48 :51 ] < 10) ? Ans_mat[48 :51 ]+48 :  Ans_mat[48 :51 ]+55;
	ans[13 ] <= (Ans_mat[52 :55 ] < 10) ? Ans_mat[52 :55 ]+48 :  Ans_mat[52 :55 ]+55;
	ans[14 ] <= (Ans_mat[56 :59 ] < 10) ? Ans_mat[56 :59 ]+48 :  Ans_mat[56 :59 ]+55;
	ans[15 ] <= (Ans_mat[60 :63 ] < 10) ? Ans_mat[60 :63 ]+48 :  Ans_mat[60 :63 ]+55;
	ans[16 ] <= (Ans_mat[64 :67 ] < 10) ? Ans_mat[64 :67 ]+48 :  Ans_mat[64 :67 ]+55;
	ans[17 ] <= (Ans_mat[68 :71 ] < 10) ? Ans_mat[68 :71 ]+48 :  Ans_mat[68 :71 ]+55;
	ans[18 ] <= (Ans_mat[72 :75 ] < 10) ? Ans_mat[72 :75 ]+48 :  Ans_mat[72 :75 ]+55;
	ans[19 ] <= (Ans_mat[76 :79 ] < 10) ? Ans_mat[76 :79 ]+48 :  Ans_mat[76 :79 ]+55;
	ans[20 ] <= (Ans_mat[80 :83 ] < 10) ? Ans_mat[80 :83 ]+48 :  Ans_mat[80 :83 ]+55;
	ans[21 ] <= (Ans_mat[84 :87 ] < 10) ? Ans_mat[84 :87 ]+48 :  Ans_mat[84 :87 ]+55;
	ans[22 ] <= (Ans_mat[88 :91 ] < 10) ? Ans_mat[88 :91 ]+48 :  Ans_mat[88 :91 ]+55;
	ans[23 ] <= (Ans_mat[92 :95 ] < 10) ? Ans_mat[92 :95 ]+48 :  Ans_mat[92 :95 ]+55;
	ans[24 ] <= (Ans_mat[96 :99 ] < 10) ? Ans_mat[96 :99 ]+48 :  Ans_mat[96 :99 ]+55;
	ans[25 ] <= (Ans_mat[100:103] < 10) ? Ans_mat[100:103]+48 :  Ans_mat[100:103]+55;
	ans[26 ] <= (Ans_mat[104:107] < 10) ? Ans_mat[104:107]+48 :  Ans_mat[104:107]+55;
	ans[27 ] <= (Ans_mat[108:111] < 10) ? Ans_mat[108:111]+48 :  Ans_mat[108:111]+55;
	ans[28 ] <= (Ans_mat[112:115] < 10) ? Ans_mat[112:115]+48 :  Ans_mat[112:115]+55;
	ans[29 ] <= (Ans_mat[116:119] < 10) ? Ans_mat[116:119]+48 :  Ans_mat[116:119]+55;
	ans[30 ] <= (Ans_mat[120:123] < 10) ? Ans_mat[120:123]+48 :  Ans_mat[120:123]+55;
	ans[31 ] <= (Ans_mat[124:127] < 10) ? Ans_mat[124:127]+48 :  Ans_mat[124:127]+55;
	ans[32 ] <= (Ans_mat[128:131] < 10) ? Ans_mat[128:131]+48 :  Ans_mat[128:131]+55;
	ans[33 ] <= (Ans_mat[132:135] < 10) ? Ans_mat[132:135]+48 :  Ans_mat[132:135]+55;
	ans[34 ] <= (Ans_mat[136:139] < 10) ? Ans_mat[136:139]+48 :  Ans_mat[136:139]+55;
	ans[35 ] <= (Ans_mat[140:143] < 10) ? Ans_mat[140:143]+48 :  Ans_mat[140:143]+55;
	ans[36 ] <= (Ans_mat[144:147] < 10) ? Ans_mat[144:147]+48 :  Ans_mat[144:147]+55;
	ans[37 ] <= (Ans_mat[148:151] < 10) ? Ans_mat[148:151]+48 :  Ans_mat[148:151]+55;
	ans[38 ] <= (Ans_mat[152:155] < 10) ? Ans_mat[152:155]+48 :  Ans_mat[152:155]+55;
	ans[39 ] <= (Ans_mat[156:159] < 10) ? Ans_mat[156:159]+48 :  Ans_mat[156:159]+55;
	ans[40 ] <= (Ans_mat[160:163] < 10) ? Ans_mat[160:163]+48 :  Ans_mat[160:163]+55;
	ans[41 ] <= (Ans_mat[164:167] < 10) ? Ans_mat[164:167]+48 :  Ans_mat[164:167]+55;
	ans[42 ] <= (Ans_mat[168:171] < 10) ? Ans_mat[168:171]+48 :  Ans_mat[168:171]+55;
	ans[43 ] <= (Ans_mat[172:175] < 10) ? Ans_mat[172:175]+48 :  Ans_mat[172:175]+55;
	ans[44 ] <= (Ans_mat[176:179] < 10) ? Ans_mat[176:179]+48 :  Ans_mat[176:179]+55;
	ans[45 ] <= (Ans_mat[180:183] < 10) ? Ans_mat[180:183]+48 :  Ans_mat[180:183]+55;
	ans[46 ] <= (Ans_mat[184:187] < 10) ? Ans_mat[184:187]+48 :  Ans_mat[184:187]+55;
	ans[47 ] <= (Ans_mat[188:191] < 10) ? Ans_mat[188:191]+48 :  Ans_mat[188:191]+55;
	ans[48 ] <= (Ans_mat[192:195] < 10) ? Ans_mat[192:195]+48 :  Ans_mat[192:195]+55;
	ans[49 ] <= (Ans_mat[196:199] < 10) ? Ans_mat[196:199]+48 :  Ans_mat[196:199]+55;
	ans[50 ] <= (Ans_mat[200:203] < 10) ? Ans_mat[200:203]+48 :  Ans_mat[200:203]+55;
	ans[51 ] <= (Ans_mat[204:207] < 10) ? Ans_mat[204:207]+48 :  Ans_mat[204:207]+55;
	ans[52 ] <= (Ans_mat[208:211] < 10) ? Ans_mat[208:211]+48 :  Ans_mat[208:211]+55;
	ans[53 ] <= (Ans_mat[212:215] < 10) ? Ans_mat[212:215]+48 :  Ans_mat[212:215]+55;
	ans[54 ] <= (Ans_mat[216:219] < 10) ? Ans_mat[216:219]+48 :  Ans_mat[216:219]+55;
	ans[55 ] <= (Ans_mat[220:223] < 10) ? Ans_mat[220:223]+48 :  Ans_mat[220:223]+55;
	ans[56 ] <= (Ans_mat[224:227] < 10) ? Ans_mat[224:227]+48 :  Ans_mat[224:227]+55;
	ans[57 ] <= (Ans_mat[228:231] < 10) ? Ans_mat[228:231]+48 :  Ans_mat[228:231]+55;
	ans[58 ] <= (Ans_mat[232:235] < 10) ? Ans_mat[232:235]+48 :  Ans_mat[232:235]+55;
	ans[59 ] <= (Ans_mat[236:239] < 10) ? Ans_mat[236:239]+48 :  Ans_mat[236:239]+55;
	ans[60 ] <= (Ans_mat[240:243] < 10) ? Ans_mat[240:243]+48 :  Ans_mat[240:243]+55;          
	ans[61 ] <= (Ans_mat[244:247] < 10) ? Ans_mat[244:247]+48 :  Ans_mat[244:247]+55;                        
	ans[62 ] <= (Ans_mat[248:251] < 10) ? Ans_mat[248:251]+48 :  Ans_mat[248:251]+55;                        
	ans[63 ] <= (Ans_mat[252:255] < 10) ? Ans_mat[252:255]+48 :  Ans_mat[252:255]+55;                        
	ans[64 ] <= (Ans_mat[256:259] < 10) ? Ans_mat[256:259]+48 :  Ans_mat[256:259]+55;                        
	ans[65 ] <= (Ans_mat[260:263] < 10) ? Ans_mat[260:263]+48 :  Ans_mat[260:263]+55;                        
	ans[66 ] <= (Ans_mat[264:267] < 10) ? Ans_mat[264:267]+48 :  Ans_mat[264:267]+55;                        
	ans[67 ] <= (Ans_mat[268:271] < 10) ? Ans_mat[268:271]+48 :  Ans_mat[268:271]+55;                        
	ans[68 ] <= (Ans_mat[272:275] < 10) ? Ans_mat[272:275]+48 :  Ans_mat[272:275]+55;                        
	ans[69 ] <= (Ans_mat[276:279] < 10) ? Ans_mat[276:279]+48 :  Ans_mat[276:279]+55;                        
	ans[70 ] <= (Ans_mat[280:283] < 10) ? Ans_mat[280:283]+48 :  Ans_mat[280:283]+55;                        
	ans[71 ] <= (Ans_mat[284:287] < 10) ? Ans_mat[284:287]+48 :  Ans_mat[284:287]+55;                        
	ans[72 ] <= (Ans_mat[288:291] < 10) ? Ans_mat[288:291]+48 :  Ans_mat[288:291]+55;                        
	ans[73 ] <= (Ans_mat[292:295] < 10) ? Ans_mat[292:295]+48 :  Ans_mat[292:295]+55;                        
	ans[74 ] <= (Ans_mat[296:299] < 10) ? Ans_mat[296:299]+48 :  Ans_mat[296:299]+55;                        
	ans[75 ] <= (Ans_mat[300:303] < 10) ? Ans_mat[300:303]+48 :  Ans_mat[300:303]+55;          
	ans[76 ] <= (Ans_mat[304:307] < 10) ? Ans_mat[304:307]+48 :  Ans_mat[304:307]+55;          
	ans[77 ] <= (Ans_mat[308:311] < 10) ? Ans_mat[308:311]+48 :  Ans_mat[308:311]+55;          
	ans[78 ] <= (Ans_mat[312:315] < 10) ? Ans_mat[312:315]+48 :  Ans_mat[312:315]+55;          
	ans[79 ] <= (Ans_mat[316:319] < 10) ? Ans_mat[316:319]+48 :  Ans_mat[316:319]+55;                                                                                               
end                                                                                                
                                                                                                   
always @(posedge clk)begin                                                                         
	{data[ 0], data[ 1], data[ 2], data[ 3], data[ 4], data[ 5], data[ 6], data[ 7],               
	 data[ 8], data[ 9], data[10], data[11], data[12], data[13], data[14], data[15] }              
	  <= { "The result is:", 8'h0D, 8'h0A};                                                        
		  
	{data[16], data[17], data[18], data[19], data[20], data[21], data[22], data[23],
	 data[24], data[25], data[26], data[27], data[28], data[29], data[30], data[31],
	 data[32], data[33], data[34], data[35], data[36], data[37], data[38], data[39],
     data[40], data[41], data[42], data[43], data[44], data[45], data[46], data[47] }
	  <= {"[ ", ans[0], ans[1], ans[2], ans[3], ans[4], ", ", ans[20], ans[21], ans[22], ans[23], ans[24], ", ", ans[40], ans[41], ans[42], ans[43], ans[44], ", ", ans[60], ans[61], ans[62], ans[63], ans[64], " ]", 8'h0D, 8'h0A};
	
	{data[48], data[49], data[50], data[51], data[52], data[53], data[54], data[55],
	 data[56], data[57], data[58], data[59], data[60], data[61], data[62], data[63],
     data[64], data[65], data[66], data[67], data[68], data[69], data[70], data[71],
	 data[72], data[73], data[74], data[75], data[76], data[77], data[78], data[79]}
	  <= {"[ ", ans[5], ans[6], ans[7], ans[8], ans[9], ", ", ans[25], ans[26], ans[27], ans[28], ans[29], ", ", ans[45], ans[46], ans[47], ans[48], ans[49], ", ", ans[65], ans[66], ans[67], ans[68], ans[69], " ]", 8'h0D, 8'h0A};
	  
	{data[80 ], data[81 ], data[82 ], data[83 ], data[84 ], data[85 ], data[86 ], data[87 ],
     data[88 ], data[89 ], data[90 ], data[91 ], data[92 ], data[93 ], data[94 ], data[95 ],
	 data[96 ], data[97 ], data[98 ], data[99 ], data[100], data[101], data[102], data[103],
	 data[104], data[105], data[106], data[107], data[108], data[109], data[110], data[111]	}
	  <= {"[ ", ans[10], ans[11], ans[12], ans[13], ans[14], ", ", ans[30], ans[31], ans[32], ans[33], ans[34], ", ", ans[50], ans[51], ans[52], ans[53], ans[54], ", ", ans[70], ans[71], ans[72], ans[73], ans[74], " ]", 8'h0D, 8'h0A};
	
	{data[112], data[113], data[114], data[115], data[116], data[117], data[118], data[119],
     data[120], data[121], data[122], data[123], data[124], data[125], data[126], data[127],
     data[128], data[129], data[130], data[131], data[132], data[133], data[134], data[135],
     data[136], data[137], data[138], data[139], data[140], data[141], data[142], data[143], data[144]	}
	  <= {"[ ", ans[15], ans[16], ans[17], ans[18], ans[19], ", ", ans[35], ans[36], ans[37], ans[38], ans[39], ", ", ans[55], ans[56], ans[57], ans[58], ans[59], ", ", ans[75], ans[76], ans[77], ans[78], ans[79], " ]", 8'h0D, 8'h0A, 8'h00};
end

always @(posedge clk) begin
    if(~reset_n || P_next == S_UART_INIT) send_counter <= 0;
    else send_counter <= send_counter + (Q_next == S_UART_INCR);
end

always @(posedge clk) begin
  out1   <= (B_mat[0  :3  ] < 10) ? B_mat[0  :3  ]+48 :  B_mat[0  :3  ]+55;
  out2   <= (B_mat[4  :7  ] < 10) ? B_mat[4  :7  ]+48 :  B_mat[4  :7  ]+55;
  out3   <= (B_mat[8  :11 ] < 10) ? B_mat[8  :11 ]+48 :  B_mat[8  :11 ]+55;
  out4   <= (B_mat[12 :15 ] < 10) ? B_mat[12 :15 ]+48 :  B_mat[12 :15 ]+55;
  out5   <= (B_mat[16 :19 ] < 10) ? B_mat[16 :19 ]+48 :  B_mat[16 :19 ]+55;
  out6   <= (B_mat[20 :23 ] < 10) ? B_mat[20 :23 ]+48 :  B_mat[20 :23 ]+55;
  out7   <= (B_mat[24 :27 ] < 10) ? B_mat[24 :27 ]+48 :  B_mat[24 :27 ]+55;
  out8   <= (B_mat[28 :31 ] < 10) ? B_mat[28 :31 ]+48 :  B_mat[28 :31 ]+55;
  out9   <= (B_mat[32 :35 ] < 10) ? B_mat[32 :35 ]+48 :  B_mat[32 :35 ]+55;
  out10  <= (B_mat[36 :39 ] < 10) ? B_mat[36 :39 ]+48 :  B_mat[36 :39 ]+55;
  out11  <= (B_mat[40 :43 ] < 10) ? B_mat[40 :43 ]+48 :  B_mat[40 :43 ]+55;
  out12  <= (B_mat[44 :47 ] < 10) ? B_mat[44 :47 ]+48 :  B_mat[44 :47 ]+55;
  out13  <= (B_mat[48 :51 ] < 10) ? B_mat[48 :51 ]+48 :  B_mat[48 :51 ]+55;
  out14  <= (B_mat[52 :55 ] < 10) ? B_mat[52 :55 ]+48 :  B_mat[52 :55 ]+55;
  out15  <= (B_mat[56 :59 ] < 10) ? B_mat[56 :59 ]+48 :  B_mat[56 :59 ]+55;
  out16  <= (B_mat[60 :63 ] < 10) ? B_mat[60 :63 ]+48 :  B_mat[60 :63 ]+55;
  out17  <= (B_mat[64 :67 ] < 10) ? B_mat[64 :67 ]+48 :  B_mat[64 :67 ]+55;
  out18  <= (B_mat[68 :71 ] < 10) ? B_mat[68 :71 ]+48 :  B_mat[68 :71 ]+55;
  out19  <= (B_mat[72 :75 ] < 10) ? B_mat[72 :75 ]+48 :  B_mat[72 :75 ]+55;
  out20  <= (B_mat[76 :79 ] < 10) ? B_mat[76 :79 ]+48 :  B_mat[76 :79 ]+55;
  out21  <= (B_mat[80 :83 ] < 10) ? B_mat[80 :83 ]+48 :  B_mat[80 :83 ]+55;
  out22  <= (B_mat[84 :87 ] < 10) ? B_mat[84 :87 ]+48 :  B_mat[84 :87 ]+55;
  out23  <= (B_mat[88 :91 ] < 10) ? B_mat[88 :91 ]+48 :  B_mat[88 :91 ]+55;
  out24  <= (B_mat[92 :95 ] < 10) ? B_mat[92 :95 ]+48 :  B_mat[92 :95 ]+55;
  out25  <= (B_mat[96 :99 ] < 10) ? B_mat[96 :99 ]+48 :  B_mat[96 :99 ]+55;
  out26  <= (B_mat[100:103] < 10) ? B_mat[100:103]+48 :  B_mat[100:103]+55;
  out27  <= (B_mat[104:107] < 10) ? B_mat[104:107]+48 :  B_mat[104:107]+55;
  out28  <= (B_mat[108:111] < 10) ? B_mat[108:111]+48 :  B_mat[108:111]+55;
  out29  <= (B_mat[112:115] < 10) ? B_mat[112:115]+48 :  B_mat[112:115]+55;
  out30  <= (B_mat[116:119] < 10) ? B_mat[116:119]+48 :  B_mat[116:119]+55;
  out31  <= (B_mat[120:123] < 10) ? B_mat[120:123]+48 :  B_mat[120:123]+55;
  out32  <= (B_mat[124:127] < 10) ? B_mat[124:127]+48 :  B_mat[124:127]+55;
  if (~reset_n) begin
    row_A = "SD card cannot  ";
    row_B = "be initialized! ";
  end
  else if (P == S_MAIN_IDLE) begin
    row_A <= "Hit BTN1 to read";
    row_B <= "the SD card ... ";
  end
  else begin
    row_A <= {out1,out2,out3,out4,out5,out6,out7,out8,out9,out10,out11,out12,out13,out14,out15,out16};
    row_B <= {out17,out18,out19,out20,out21,out22,out23,out24,out25,out26,out27,out28,out29,out30,out31,out32};
  end
end

endmodule