`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/04 14:03:05
// Design Name: 
// Module Name: lab8
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


module lab8(
  input clk,
  input reset_n,
  input [3:0] usr_btn,
  output [3:0] usr_led,
  output LCD_RS,
  output LCD_RW,
  output LCD_E,
  output [3:0] LCD_D
    );

reg[0:127] passwd_hash= 128'he9982ec5ca981bd365603623cf4b2277;
wire btn_level, btn_pressed;
reg prev_btn_level;
reg [127:0] row_A = "Press BTN3 To   ";
reg [127:0] row_B = "Crack The Passwd";
    
localparam [3:0] S_MAIN_INIT = 0,     S_MAIN_WAIT = 1,     S_MAIN_IDLE = 2,     S_MAIN_RESET = 3,
				 S_MAIN_MEMSET = 4,   S_MAIN_MEMCPY = 5,   S_MAIN_BREAK = 6,    S_MAIN_IF_ELSE = 7,
				 S_MAIN_ASSIGN1 = 8,  S_MAIN_ROTATE = 9,   S_MAIN_ASSIGN2 = 10, S_MAIN_ADD_CHUNK = 11,
				 S_MAIN_STORE = 12,   S_MAIN_COMPARE = 13, S_MAIN_BUF = 14,     S_MAIN_SHOW = 15;


reg [31:0]  h0;
reg [31:0]  h1;
reg [31:0]  h2;
reg [31:0]  h3;
reg [31:0]  a;
reg [31:0]  b;
reg [31:0]  c;
reg [31:0]  d;
reg [31:0]  f;
reg [31:0]  g;
reg [31:0]  temp;
reg [31:0]  x;
reg [31:0]  y;
reg [31:0]  z;

reg done = 0;
reg start = 0;

reg flag = 0;

reg [31:0]r[0:63];	
reg [31:0]k[0:63];
reg [7:0]msg[0:119];
reg [7:0]index[0:7];
reg [31:0]w[0:15];
reg [7:0]hash[0:15];
reg [7:0]timer[0:6];

//FSM controll			 
reg [3:0]    P = 0,P_next;
reg [23:0]   init_counter = 0;
reg [31:0]   time_counter = 0;
reg [31:0]   i = 32'd0;
reg finish = 0;

assign usr_led = flag;
	
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

initial begin
    { timer[0], timer[1], timer[2], timer[3], timer[4], timer[5], timer[6]} <= { 8'h30, 8'h30, 8'h30, 8'h30, 8'h30, 8'h30, 8'h30};
	{ r[0 ], r[1 ], r[2 ], r[3 ], r[4 ], r[5 ], r[6 ], r[7 ], r[8 ], r[9 ], r[10], r[11], r[12], r[13], r[14], r[15],
      r[16], r[17], r[18], r[19], r[20], r[21], r[22], r[23], r[24], r[25], r[26], r[27], r[28], r[29], r[30], r[31],
      r[32], r[33], r[34], r[35], r[36], r[37], r[38], r[39], r[40], r[41], r[42], r[43], r[44], r[45], r[46], r[47],
      r[48], r[49], r[50], r[51], r[52], r[53], r[54], r[55], r[56], r[57], r[58], r[59], r[60], r[61], r[62], r[63]} <=
    { 32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22, 32'd7, 32'd12, 32'd17, 32'd22,
      32'd5, 32'd9 , 32'd14, 32'd20, 32'd5, 32'd9 , 32'd14, 32'd20, 32'd5, 32'd9 , 32'd14, 32'd20, 32'd5,  32'd9, 32'd14, 32'd20,
      32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23, 32'd4, 32'd11, 32'd16, 32'd23,
      32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21, 32'd6, 32'd10, 32'd15, 32'd21};
	{ k[0 ], k[1 ], k[2 ], k[3 ], k[4 ], k[5 ], k[6 ], k[7 ], k[8 ], k[9 ], k[10], k[11], k[12], k[13], k[14], k[15], 
      k[16], k[17], k[18], k[19], k[20], k[21], k[22], k[23], k[24], k[25], k[26], k[27], k[28], k[29], k[30], k[31], 
	  k[32], k[33], k[34], k[35], k[36], k[37], k[38], k[39], k[40], k[41], k[42], k[43], k[44], k[45], k[46], k[47], 
	  k[48], k[49], k[50], k[51], k[52], k[53], k[54], k[55], k[56], k[57], k[58], k[59], k[60], k[61], k[62], k[63]} <=
	{ 32'hd76aa478, 32'he8c7b756, 32'h242070db, 32'hc1bdceee, 32'hf57c0faf, 32'h4787c62a, 32'ha8304613, 32'hfd469501,
	  32'h698098d8, 32'h8b44f7af, 32'hffff5bb1, 32'h895cd7be, 32'h6b901122, 32'hfd987193, 32'ha679438e, 32'h49b40821,
	  32'hf61e2562, 32'hc040b340, 32'h265e5a51, 32'he9b6c7aa, 32'hd62f105d, 32'h02441453, 32'hd8a1e681, 32'he7d3fbc8,
	  32'h21e1cde6, 32'hc33707d6, 32'hf4d50d87, 32'h455a14ed, 32'ha9e3e905, 32'hfcefa3f8, 32'h676f02d9, 32'h8d2a4c8a,
	  32'hfffa3942, 32'h8771f681, 32'h6d9d6122, 32'hfde5380c, 32'ha4beea44, 32'h4bdecfa9, 32'hf6bb4b60, 32'hbebfbc70,
	  32'h289b7ec6, 32'heaa127fa, 32'hd4ef3085, 32'h04881d05, 32'hd9d4d039, 32'he6db99e5, 32'h1fa27cf8, 32'hc4ac5665,
	  32'hf4292244, 32'h432aff97, 32'hab9423a7, 32'hfc93a039, 32'h655b59c3, 32'h8f0ccc92, 32'hffeff47d, 32'h85845dd1,
	  32'h6fa87e4f, 32'hfe2ce6e0, 32'ha3014314, 32'h4e0811a1, 32'hf7537e82, 32'hbd3af235, 32'h2ad7d2bb, 32'heb86d391};
end

always@(posedge clk)begin
    if(~reset_n) begin
        P <= S_MAIN_INIT;
		prev_btn_level <= 1;
		end
    else begin
		P <= P_next;
		prev_btn_level <= btn_level;
		end
end
    
assign btn_pressed = (btn_level == 1 && prev_btn_level == 0);

always@(*)begin
    case (P)
        S_MAIN_INIT:
            if (init_counter == 1000) P_next = S_MAIN_WAIT;
			else P_next = S_MAIN_INIT;
		S_MAIN_WAIT:
			if (btn_pressed == 1) P_next = S_MAIN_IDLE;
			else P_next = S_MAIN_WAIT;
		S_MAIN_IDLE:
			P_next = S_MAIN_RESET;
		S_MAIN_RESET:
			P_next = S_MAIN_MEMSET;
		S_MAIN_MEMSET:
			P_next = S_MAIN_MEMCPY;
		S_MAIN_MEMCPY:
			P_next = S_MAIN_BREAK;
		S_MAIN_BREAK:
			P_next = S_MAIN_IF_ELSE;
		S_MAIN_IF_ELSE:
			P_next = S_MAIN_ASSIGN1;
		S_MAIN_ASSIGN1:
			P_next = S_MAIN_ROTATE;
		S_MAIN_ROTATE:
			P_next = S_MAIN_ASSIGN2;
		S_MAIN_ASSIGN2:
			if (done == 1) P_next = S_MAIN_ADD_CHUNK;
			else P_next = S_MAIN_IF_ELSE;
		S_MAIN_ADD_CHUNK:
			P_next = S_MAIN_STORE;
		S_MAIN_STORE:
			P_next = S_MAIN_COMPARE;
		S_MAIN_COMPARE:
			P_next = S_MAIN_BUF;
		S_MAIN_BUF:
			if (finish == 1) P_next = S_MAIN_SHOW;
			else P_next = S_MAIN_IDLE;
		S_MAIN_SHOW:
			P_next = S_MAIN_SHOW;
    endcase
end

always @(posedge clk) begin
	if (~reset_n) init_counter <= 0;
	if (P == S_MAIN_INIT) init_counter <= init_counter + 1;
	else init_counter <= 0;
end

always @(posedge clk) begin
    if (P == S_MAIN_WAIT && P_next == S_MAIN_IDLE) begin
        start <= 1;
        end
    if (start == 1 && P != S_MAIN_SHOW)  time_counter <= (time_counter == 100000) ? 0 : time_counter + 1;
    else time_counter <= time_counter;
    if (time_counter == 100000) begin 
        if (timer[6] != 8'h39) begin timer[6] <= timer[6] + 1; end
        else if (timer[5] != 8'h39) begin timer[5] <= timer[5] + 1; timer[6] <= 8'h30; end
        else if (timer[4] != 8'h39) begin timer[4] <= timer[4] + 1; timer[6] <= 8'h30; timer[5] <= 8'h30; end
        else if (timer[3] != 8'h39) begin timer[3] <= timer[3] + 1; timer[6] <= 8'h30; timer[5] <= 8'h30; timer[4] <= 8'h30; end
        else if (timer[2] != 8'h39) begin timer[2] <= timer[2] + 1; timer[6] <= 8'h30; timer[5] <= 8'h30; timer[4] <= 8'h30; timer[3] <= 8'h30; end
        else if (timer[1] != 8'h39) begin timer[1] <= timer[1] + 1; timer[6] <= 8'h30; timer[5] <= 8'h30; timer[4] <= 8'h30; timer[3] <= 8'h30; timer[2] <= 8'h30; end
        else if (timer[0] != 8'h39) begin timer[0] <= timer[0] + 1; timer[6] <= 8'h30; timer[5] <= 8'h30; timer[4] <= 8'h30; timer[3] <= 8'h30; timer[2] <= 8'h30; timer[1] <= 8'h30; end
        end
end

always @(posedge clk) begin
	if (P == S_MAIN_WAIT && P_next == S_MAIN_IDLE) begin
		{ index[0], index[1], index[2], index[3], index[4], index[5], index[6], index[7] } <=
		//{"3","1","4","1","4","8","1","0"};
		{ 8'h30, 8'h30, 8'h30, 8'h30, 8'h30, 8'h30, 8'h30, 8'h30};
		end else if (P == S_MAIN_BUF && P_next == S_MAIN_IDLE) begin
			if (index[7] != 8'h39) index[7] <= index[7] + 1;
			else if (index[6] != 8'h39) begin index[6] <= index[6] + 1; index[7] <= 8'h30; end
			else if (index[5] != 8'h39) begin index[5] <= index[5] + 1; index[7] <= 8'h30; index[6] <= 8'h30; end
			else if (index[4] != 8'h39) begin index[4] <= index[4] + 1; index[7] <= 8'h30; index[6] <= 8'h30; index[5] <= 8'h30; end
			else if (index[3] != 8'h39) begin index[3] <= index[3] + 1; index[7] <= 8'h30; index[6] <= 8'h30; index[5] <= 8'h30; index[4] <= 8'h30; end
			else if (index[2] != 8'h39) begin index[2] <= index[2] + 1; index[7] <= 8'h30; index[6] <= 8'h30; index[5] <= 8'h30; index[4] <= 8'h30; index[3] <= 8'h30; end
			else if (index[1] != 8'h39) begin index[1] <= index[1] + 1; index[7] <= 8'h30; index[6] <= 8'h30; index[5] <= 8'h30; index[4] <= 8'h30; index[3] <= 8'h30; index[2] <= 8'h30; end
			else if (index[0] != 8'h39) begin index[0] <= index[0] + 1; index[7] <= 8'h30; index[6] <= 8'h30; index[5] <= 8'h30; index[4] <= 8'h30; index[3] <= 8'h30; index[2] <= 8'h30; index[1] <= 8'h30; end
			end     
end

always @(posedge clk) begin
	if (P == S_MAIN_MEMSET) begin
		{ msg[0  ], msg[1  ], msg[2  ], msg[3  ], msg[4  ], msg[5  ], msg[6  ], msg[7  ], msg[8  ], msg[9  ], 
		  msg[10 ], msg[11 ], msg[12 ], msg[13 ], msg[14 ], msg[15 ], msg[16 ], msg[17 ], msg[18 ], msg[19 ], 
		  msg[20 ], msg[21 ], msg[22 ], msg[23 ], msg[24 ], msg[25 ], msg[26 ], msg[27 ], msg[28 ], msg[29 ], 
		  msg[30 ], msg[31 ], msg[32 ], msg[33 ], msg[34 ], msg[35 ], msg[36 ], msg[37 ], msg[38 ], msg[39 ], 
		  msg[40 ], msg[41 ], msg[42 ], msg[43 ], msg[44 ], msg[45 ], msg[46 ], msg[47 ], msg[48 ], msg[49 ], 
		  msg[50 ], msg[51 ], msg[52 ], msg[53 ], msg[54 ], msg[55 ], msg[56 ], msg[57 ], msg[58 ], msg[59 ], 
		  msg[60 ], msg[61 ], msg[62 ], msg[63 ], msg[64 ], msg[65 ], msg[66 ], msg[67 ], msg[68 ], msg[69 ], 
		  msg[70 ], msg[71 ], msg[72 ], msg[73 ], msg[74 ], msg[75 ], msg[76 ], msg[77 ], msg[78 ], msg[79 ], 
		  msg[80 ], msg[81 ], msg[82 ], msg[83 ], msg[84 ], msg[85 ], msg[86 ], msg[87 ], msg[88 ], msg[89 ], 
		  msg[90 ], msg[91 ], msg[92 ], msg[93 ], msg[94 ], msg[95 ], msg[96 ], msg[97 ], msg[98 ], msg[99 ], 
		  msg[100], msg[101], msg[102], msg[103], msg[104], msg[105], msg[106], msg[107], msg[108], msg[109], 
		  msg[110], msg[111], msg[112], msg[113], msg[114], msg[115], msg[116], msg[117], msg[118], msg[119]} <=
		{8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 
		 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 
		 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 
		 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 
		 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 
		 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 
		 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 
		 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0, 8'h0};
		end
    if (P == S_MAIN_MEMCPY) begin
        { msg[0], msg[1], msg[2], msg[3], msg[4], msg[5], msg[6], msg[7], msg[8]} <=
        { index[0], index[1], index[2], index[3], index[4], index[5], index[6], index[7], 8'd128} ;
        msg[56] <= {8'd64};
        end
end

always @(posedge clk) begin
	if (P == S_MAIN_BREAK) begin
		w[0 ] <= { msg[3 ], msg[2 ], msg[1 ], msg[0 ]};
		w[1 ] <= { msg[7 ], msg[6 ], msg[5 ], msg[4 ]};
		w[2 ] <= { msg[11], msg[10], msg[9 ], msg[8 ]};
		w[3 ] <= { msg[15], msg[14], msg[13], msg[12]};
		w[4 ] <= { msg[19], msg[18], msg[17], msg[16]};
		w[5 ] <= { msg[23], msg[22], msg[21], msg[20]};
		w[6 ] <= { msg[27], msg[26], msg[25], msg[24]};
		w[7 ] <= { msg[31], msg[30], msg[29], msg[28]};
		w[8 ] <= { msg[35], msg[34], msg[33], msg[32]};
		w[9 ] <= { msg[39], msg[38], msg[37], msg[36]};
		w[10] <= { msg[43], msg[42], msg[41], msg[40]};
		w[11] <= { msg[47], msg[46], msg[45], msg[44]};
		w[12] <= { msg[51], msg[50], msg[49], msg[48]};
		w[13] <= { msg[55], msg[54], msg[53], msg[52]};
		w[14] <= { msg[59], msg[58], msg[57], msg[56]};
		w[15] <= { msg[63], msg[62], msg[61], msg[60]};
		end
end

always @(posedge clk) begin
	if (P == S_MAIN_IF_ELSE) begin
		if (i < 16) begin
			f = (b & c) | ((~b) & d);
			g = i;
		end else if (i < 32) begin
			f = (d & b) | ((~d) & c);
			g = (5*i + 1) % 16;
		end else if (i < 48) begin
			f = b ^ c ^ d;
			g = (3*i + 5) % 16;
		end else begin
			f = c ^ (b | (~d));
			g = (7*i) % 16;
		end
	end
end

always @(posedge clk) begin
    if (P == S_MAIN_BREAK) begin c <= h2; d <= h3; end
	if (P == S_MAIN_ASSIGN1) begin
		temp = d;
		d = c;
		c = b;
		x = a + f + k[i] + w[g];
		y = r[i];
		end
end

always @(posedge clk) begin
	if (P == S_MAIN_ROTATE) begin
		z = (((x) << (y)) | ((x) >> (32 - (y))));
		end
end

always @(posedge clk) begin
    if (P == S_MAIN_RESET) begin  i <= 32'd0; done <= 0; end
    if (P == S_MAIN_ADD_CHUNK)  done <= 0;
    if (P == S_MAIN_BREAK) begin a <= h0; b <= h1; end
	if (P == S_MAIN_ASSIGN2) begin
		b = b + z;
		a = temp;
		if (i == 32'd0) begin i <= 32'd1; done <= 0;end
        else if (i == 32'd1 ) begin i <= 32'd2 ; done <= 0; end
        else if (i == 32'd2 ) begin i <= 32'd3 ; done <= 0; end
        else if (i == 32'd3 ) begin i <= 32'd4 ; done <= 0; end
        else if (i == 32'd4 ) begin i <= 32'd5 ; done <= 0; end
        else if (i == 32'd5 ) begin i <= 32'd6 ; done <= 0; end
        else if (i == 32'd6 ) begin i <= 32'd7 ; done <= 0; end
        else if (i == 32'd7 ) begin i <= 32'd8 ; done <= 0; end
        else if (i == 32'd8 ) begin i <= 32'd9 ; done <= 0; end
        else if (i == 32'd9 ) begin i <= 32'd10; done <= 0; end
        else if (i == 32'd10) begin i <= 32'd11; done <= 0; end
        else if (i == 32'd11) begin i <= 32'd12; done <= 0; end
        else if (i == 32'd12) begin i <= 32'd13; done <= 0; end
        else if (i == 32'd13) begin i <= 32'd14; done <= 0; end
        else if (i == 32'd14) begin i <= 32'd15; done <= 0; end
        else if (i == 32'd15) begin i <= 32'd16; done <= 0; end
        else if (i == 32'd16) begin i <= 32'd17; done <= 0; end
        else if (i == 32'd17) begin i <= 32'd18; done <= 0; end
        else if (i == 32'd18) begin i <= 32'd19; done <= 0; end
        else if (i == 32'd19) begin i <= 32'd20; done <= 0; end
        else if (i == 32'd20) begin i <= 32'd21; done <= 0; end
        else if (i == 32'd21) begin i <= 32'd22; done <= 0; end
        else if (i == 32'd22) begin i <= 32'd23; done <= 0; end
        else if (i == 32'd23) begin i <= 32'd24; done <= 0; end
        else if (i == 32'd24) begin i <= 32'd25; done <= 0; end
        else if (i == 32'd25) begin i <= 32'd26; done <= 0; end
        else if (i == 32'd26) begin i <= 32'd27; done <= 0; end
        else if (i == 32'd27) begin i <= 32'd28; done <= 0; end
        else if (i == 32'd28) begin i <= 32'd29; done <= 0; end
        else if (i == 32'd29) begin i <= 32'd30; done <= 0; end
        else if (i == 32'd30) begin i <= 32'd31; done <= 0; end
        else if (i == 32'd31) begin i <= 32'd32; done <= 0; end
        else if (i == 32'd32) begin i <= 32'd33; done <= 0; end
        else if (i == 32'd33) begin i <= 32'd34; done <= 0; end
        else if (i == 32'd34) begin i <= 32'd35; done <= 0; end
        else if (i == 32'd35) begin i <= 32'd36; done <= 0; end
        else if (i == 32'd36) begin i <= 32'd37; done <= 0; end
        else if (i == 32'd37) begin i <= 32'd38; done <= 0; end
        else if (i == 32'd38) begin i <= 32'd39; done <= 0; end
        else if (i == 32'd39) begin i <= 32'd40; done <= 0; end
        else if (i == 32'd40) begin i <= 32'd41; done <= 0; end
        else if (i == 32'd41) begin i <= 32'd42; done <= 0; end
        else if (i == 32'd42) begin i <= 32'd43; done <= 0; end
        else if (i == 32'd43) begin i <= 32'd44; done <= 0; end
        else if (i == 32'd44) begin i <= 32'd45; done <= 0; end
        else if (i == 32'd45) begin i <= 32'd46; done <= 0; end
        else if (i == 32'd46) begin i <= 32'd47; done <= 0; end
        else if (i == 32'd47) begin i <= 32'd48; done <= 0; end
        else if (i == 32'd48) begin i <= 32'd49; done <= 0; end
        else if (i == 32'd49) begin i <= 32'd50; done <= 0; end
        else if (i == 32'd50) begin i <= 32'd51; done <= 0; end
        else if (i == 32'd51) begin i <= 32'd52; done <= 0; end
        else if (i == 32'd52) begin i <= 32'd53; done <= 0; end
        else if (i == 32'd53) begin i <= 32'd54; done <= 0; end
        else if (i == 32'd54) begin i <= 32'd55; done <= 0; end
        else if (i == 32'd55) begin i <= 32'd56; done <= 0; end
        else if (i == 32'd56) begin i <= 32'd57; done <= 0; end
        else if (i == 32'd57) begin i <= 32'd58; done <= 0; end
        else if (i == 32'd58) begin i <= 32'd59; done <= 0; end
        else if (i == 32'd59) begin i <= 32'd60; done <= 0; end
        else if (i == 32'd60) begin i <= 32'd61; done <= 0; end
        else if (i == 32'd61) begin i <= 32'd62; done <= 0; end
        else if (i == 32'd62) begin i <= 32'd63; done <= 1; end
        else if (i == 32'd63) begin i <= 32'd64; done <= 1; end
		end
end

always @(posedge clk) begin 
    if (P == S_MAIN_RESET) begin
		h0 <= 32'h67452301;
		h1 <= 32'hefcdab89;
		h2 <= 32'h98badcfe;
		h3 <= 32'h10325476;
		end
	if (P == S_MAIN_ADD_CHUNK) begin
		h0 <= h0 + a;
        h1 <= h1 + b;
        h2 <= h2 + c;
        h3 <= h3 + d;
        flag<= 1;
		end
end

always @(posedge clk) begin
	if (P == S_MAIN_RESET) begin
        { hash[0 ], hash[1 ], hash[2 ], hash[3 ], hash[4 ], hash[5 ], hash[6 ], hash[7 ], 
           hash[8 ], hash[9 ], hash[10], hash[11], hash[12], hash[13], hash[14], hash[15]} <=
        { 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 
          8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'd0};
        end
	if (P == S_MAIN_STORE) begin
		hash[0 ] <= h0[7 :0 ];
		hash[1 ] <= h0[15:8 ];
		hash[2 ] <= h0[23:16];
		hash[3 ] <= h0[31:24];
		hash[4 ] <= h1[7 :0 ];
		hash[5 ] <= h1[15:8 ];
		hash[6 ] <= h1[23:16];
		hash[7 ] <= h1[31:24];
		hash[8 ] <= h2[7 :0 ];
		hash[9 ] <= h2[15:8 ];
		hash[10] <= h2[23:16];
		hash[11] <= h2[31:24];
		hash[12] <= h3[7 :0 ];
		hash[13] <= h3[15:8 ];
		hash[14] <= h3[23:16];
		hash[15] <= h3[31:24];
		end
end

always @(posedge clk) begin 
    if (P == S_MAIN_RESET) finish <= 0;
	if (P == S_MAIN_COMPARE) begin
		if ( hash[0 ] == passwd_hash[0  :7  ] && hash[1 ] == passwd_hash[8  :15 ] && hash[2 ] == passwd_hash[16 :23 ] && hash[3 ] == passwd_hash[24 :31 ] && 
			 hash[4 ] == passwd_hash[32 :39 ] && hash[5 ] == passwd_hash[40 :47 ] && hash[6 ] == passwd_hash[48 :55 ] && hash[7 ] == passwd_hash[56 :63 ] && 
			 hash[8 ] == passwd_hash[64 :71 ] && hash[9 ] == passwd_hash[72 :79 ] && hash[10] == passwd_hash[80 :87 ] && hash[11] == passwd_hash[88 :95 ] && 
		     hash[12] == passwd_hash[96 :103] && hash[13] == passwd_hash[104:111] && hash[14] == passwd_hash[112:119] && hash[15] == passwd_hash[120:127] ) 
			 finish <= 1;
			 else finish <= 0;
		end
end

always @(posedge clk) begin
	if (~reset_n) begin
		row_A = "Press BTN3 To   ";
		row_B = "Crack The Passwd";
		end else if (P == S_MAIN_WAIT) begin
		row_A <= "Press BTN3 To   ";
		row_B <= "Crack The Passwd";
		end else if (P == S_MAIN_SHOW) begin
		row_A <= { "P", "a", "s", "s", "w", "d", ":", " ", index[0], index[1], index[2], index[3], index[4], index[5], index[6], index[7]};
		row_B <= { "T", "i", "m", "e", ":", " ", timer[0], timer[1], timer[2], timer[3], timer[4], timer[5], timer[6], " ", "m", "s"};
		end else if (P == S_MAIN_COMPARE) begin
        row_A <= "Press BTN2 To   ";
        row_B <= "Fuck this world ";
        end else begin
		row_A <= "Cracking........";
		row_B <= "Password........";
		end
end
    
endmodule

