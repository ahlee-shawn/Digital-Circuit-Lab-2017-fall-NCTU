`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Dept. of Computer Science, National Chiao Tung University
// Engineer: Chun-Jen Tsai
// 
// Create Date: 2017/08/25 14:29:54
// Design Name: 
// Module Name: lab10
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: A circuit that show the animation of a moon moving across a city
//              night view on a screen through the VGA interface of Arty I/O card.
// 
// Dependencies: vga_sync, clk_divider, sram
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module lab10(
    input  clk,
    input  reset_n,
    input  [3:0] usr_btn,
    output [3:0] usr_led,

    // VGA specific I/O ports
    output VGA_HSYNC,
    output VGA_VSYNC,
    output [3:0] VGA_RED,
    output [3:0] VGA_GREEN,
    output [3:0] VGA_BLUE
    );

// Declare system variables
reg  [33:0] moon_clock;
wire [9:0]  pos_moon;
wire [9:0]  pos_firework_x_1;
wire [9:0]  pos_firework_y_1;
wire [9:0]  pos_firework_x_2;
wire [9:0]  pos_firework_y_2;
wire        moon_region;
wire        firework_region_1;
wire        firework_region_2;

// declare SRAM control signals
wire [16:0] sram_addr_image;
wire [16:0] sram_addr_moon;
wire [16:0] sram_addr_firework1;
wire [16:0] sram_addr_firework2;
wire [16:0] sram_addr_firework3;
wire [16:0] sram_addr_firework4;
wire [16:0] sram_addr_firework5;
wire [11:0] data_in;
wire [11:0] data_out_image;
wire [11:0] data_out_moon;
wire [11:0] data_out_firework1;
wire [11:0] data_out_firework2;
wire [11:0] data_out_firework3;
wire [11:0] data_out_firework4;
wire [11:0] data_out_firework5;
wire        sram_we, sram_en;

reg  [28:0] firework_counter = 29'b0;
reg  [2 :0] firework_frame = 3'b0;

// General VGA control signals
wire vga_clk;       // 50MHz clock for VGA control
wire video_on;      // when video_on is 0, the VGA controller is sending
                    // synchronization signals to the display device.
  
wire pixel_tick;    // when pixel tick is 1, we must update the RGB value
                    // based for the new coordinate (pixel_x, pixel_y)
  
wire [9:0] pixel_x; // x coordinate of the next pixel (between 0 ~ 639) 
wire [9:0] pixel_y; // y coordinate of the next pixel (between 0 ~ 479)
  
reg  [11:0] rgb_reg;  // RGB value for the current pixel
reg  [11:0] rgb_next; // RGB value for the next pixel
  
// Application-specific VGA signals
reg  [16:0] pixel_addr_image;
reg  [16:0] pixel_addr_moon;
reg  [16:0] pixel_addr_firework1;
reg  [16:0] pixel_addr_firework2;
reg  [16:0] pixel_addr_firework3;
reg  [16:0] pixel_addr_firework4;
reg  [16:0] pixel_addr_firework5;

// Declare the video buffer size
localparam VBUF_W = 320; // video buffer width
localparam VBUF_H = 240; // video buffer height
  
// Instiantiate a VGA sync signal generator
vga_sync vs0(
  .clk(vga_clk), .reset(~reset_n), .oHS(VGA_HSYNC), .oVS(VGA_VSYNC),
  .visible(video_on), .p_tick(pixel_tick),
  .pixel_x(pixel_x), .pixel_y(pixel_y)
);

clk_divider#(2) clk_divider0(
  .clk(clk),
  .reset(~reset_n),
  .clk_out(vga_clk)
);

// ------------------------------------------------------------------------
// The following code describes an initialized SRAM memory block that
// stores an 320x240 12-bit city image, plus a 64x40 moon image.
sram #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(VBUF_W*VBUF_H))
  ram0 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr_image), .data_i(data_in), .data_o(data_out_image));

sram_moon #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(64*40))
  ram1 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr_moon), .data_i(data_in), .data_o(data_out_moon));
		  
sram_firework1 #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(31*30))
  ram2 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr_firework1), .data_i(data_in), .data_o(data_out_firework1));
		  
sram_firework2 #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(31*30))
  ram3 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr_firework2), .data_i(data_in), .data_o(data_out_firework2));
  
sram_firework3 #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(31*30))
  ram4 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr_firework3), .data_i(data_in), .data_o(data_out_firework3));
		  
sram_firework4 #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(31*30))
  ram5 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr_firework4), .data_i(data_in), .data_o(data_out_firework4));
		  
sram_firework5 #(.DATA_WIDTH(12), .ADDR_WIDTH(17), .RAM_SIZE(31*30))
  ram6 (.clk(clk), .we(sram_we), .en(sram_en),
          .addr(sram_addr_firework5), .data_i(data_in), .data_o(data_out_firework5));

assign sram_we = usr_btn[3]; // In this demo, we do not write the SRAM. However,
                             // if you set 'sram_we' to 0, Vivado fails to synthesize
                             // ram0 as a BRAM -- this is a bug in Vivado.
assign sram_en = 1;          // Here, we always enable the SRAM block.
assign sram_addr_image = pixel_addr_image;
assign sram_addr_moon = pixel_addr_moon;
assign sram_addr_firework1 = pixel_addr_firework1;
assign sram_addr_firework2 = pixel_addr_firework2;
assign sram_addr_firework3 = pixel_addr_firework3;
assign sram_addr_firework4 = pixel_addr_firework4;
assign sram_addr_firework5 = pixel_addr_firework5;
assign data_in = 12'h000; // SRAM is read-only so we tie inputs to zeros.
// End of the SRAM memory block.
// ------------------------------------------------------------------------

// VGA color pixel generator
assign {VGA_RED, VGA_GREEN, VGA_BLUE} = rgb_reg;

// ------------------------------------------------------------------------
// An animation clock for the motion of the moon, upper bits of the
// moon clock is the x position of the moon in the VGA screen
//è¡¨ç¤º??ˆäº®?³ä¸Šè??
assign pos_moon = moon_clock[33:24];
//??™ç«å·¦ä?Šè??
assign pos_firework_x_1 = 10'd100;
assign pos_firework_y_1 = 10'd100;
assign pos_firework_x_2 = 10'd400;
assign pos_firework_y_2 = 10'd180;

always @(posedge clk) begin
	if (~reset_n || moon_clock[33:25] > VBUF_W + 64) moon_clock <= 0;
	else moon_clock <= moon_clock + 1;
end

always @(posedge clk) begin
	if (~reset_n || firework_counter >= 29'hFFFFF) firework_counter <= 0;
	else firework_counter <= firework_counter + 1;
end

always @(posedge clk) begin
	if (~reset_n) firework_frame <= 0;
	else if (firework_counter == 29'hFFFFE && firework_frame != 3'd4) firework_frame <= firework_frame + 1;
	else if (firework_counter == 29'hFFFFE && firework_frame == 3'd4) firework_frame <= 3'd0;
	else firework_frame <= firework_frame;
end
// End of the animation clock code.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// Video frame buffer address generation unit (AGU) with scaling control
// Note that the width x height of the moon image is 64x40, when scaled
// up to the screen, it becomes 128x80
assign moon_region = pixel_y >= 0 && pixel_y < 80 && (pixel_x + 127) >= pos_moon && pixel_x < pos_moon + 1;
assign firework_region_1 = pixel_x >= pos_firework_x_1 && pixel_x < (pos_firework_x_1 + 62) && pixel_y >= pos_firework_y_1 && pixel_y < (pos_firework_y_1 + 60);
assign firework_region_2 = pixel_x >= pos_firework_x_2 && pixel_x < (pos_firework_x_2 + 62) && pixel_y >= pos_firework_y_2 && pixel_y < (pos_firework_y_2 + 60);

always @ (posedge clk) begin
	if (~reset_n) pixel_addr_image <= 0;
	else pixel_addr_image <= (pixel_y >> 1) * VBUF_W + (pixel_x >> 1);
end

always @ (posedge clk) begin
	if (~reset_n) pixel_addr_moon <= 0;
	else if (moon_region) pixel_addr_moon <= ((pixel_y & 10'h2FE) << 5) + ((pixel_x - pos_moon + 127) >> 1);
end

always @ (posedge clk) begin
	if (~reset_n) pixel_addr_firework1 <= 0;
	else if (firework_region_1) pixel_addr_firework1 <= ((pixel_x - pos_firework_x_1) >> 1) + (((pixel_y - pos_firework_y_1) >> 1 ) * 31 );
	else if (firework_region_2) pixel_addr_firework1 <= ((pixel_x - pos_firework_x_2) >> 1) + (((pixel_y - pos_firework_y_2) >> 1 ) * 31 );
end

always @ (posedge clk) begin
	if (~reset_n) pixel_addr_firework2 <= 0;
	else if (firework_region_1) pixel_addr_firework2 <= ((pixel_x - pos_firework_x_1) >> 1) + (((pixel_y - pos_firework_y_1) >> 1 ) * 31 );
	else if (firework_region_2) pixel_addr_firework2 <= ((pixel_x - pos_firework_x_2) >> 1) + (((pixel_y - pos_firework_y_2) >> 1 ) * 31 );
end

always @ (posedge clk) begin
	if (~reset_n) pixel_addr_firework3 <= 0;
	else if (firework_region_1) pixel_addr_firework3 <= ((pixel_x - pos_firework_x_1) >> 1) + (((pixel_y - pos_firework_y_1) >> 1 ) * 31 );
	else if (firework_region_2) pixel_addr_firework3 <= ((pixel_x - pos_firework_x_2) >> 1) + (((pixel_y - pos_firework_y_2) >> 1 ) * 31 );
end

always @ (posedge clk) begin
	if (~reset_n) pixel_addr_firework4 <= 0;
	else if (firework_region_1) pixel_addr_firework4 <= ((pixel_x - pos_firework_x_1) >> 1) + (((pixel_y - pos_firework_y_1) >> 1 ) * 31 );
	else if (firework_region_2) pixel_addr_firework4 <= ((pixel_x - pos_firework_x_2) >> 1) + (((pixel_y - pos_firework_y_2) >> 1 ) * 31 );
end

always @ (posedge clk) begin
	if (~reset_n) pixel_addr_firework5 <= 0;
	else if (firework_region_1) pixel_addr_firework5 <= ((pixel_x - pos_firework_x_1) >> 1) + (((pixel_y - pos_firework_y_1) >> 1 ) * 31 );
	else if (firework_region_2) pixel_addr_firework5 <= ((pixel_x - pos_firework_x_2) >> 1) + (((pixel_y - pos_firework_y_2) >> 1 ) * 31 );
end
// End of the AGU code.
// ------------------------------------------------------------------------

// ------------------------------------------------------------------------
// Send the video data in the sram to the VGA controller
always @(posedge clk) begin
	if (pixel_tick) rgb_reg <= rgb_next;
end

always @(*) begin
	if (~video_on)
    rgb_next = 12'h000; // Synchronization period, must set RGB values to zero.
	else if (moon_region == 1) begin
		if (data_out_moon != 12'h0F0) rgb_next = data_out_moon;
		else rgb_next = data_out_image;
		end
	else if (firework_region_1 == 1) begin
		if (firework_frame == 3'd0) begin
			if (data_out_firework1 != 12'h000) rgb_next =data_out_firework1;
			else rgb_next = data_out_image;
			end
		if (firework_frame == 3'd1) begin
			if (data_out_firework2 != 12'h000) rgb_next =data_out_firework2;
			else rgb_next = data_out_image;
			end
		if (firework_frame == 3'd2) begin
			if (data_out_firework3 != 12'h000) rgb_next =data_out_firework3;
			else rgb_next = data_out_image;
			end
		if (firework_frame == 3'd3) begin
			if (data_out_firework4 != 12'h000) rgb_next =data_out_firework4;
			else rgb_next = data_out_image;
			end
		if (firework_frame == 3'd4) begin
			if (data_out_firework5 != 12'h000) rgb_next =data_out_firework5;
			else rgb_next = data_out_image;
			end
		end
	else if (firework_region_2 == 1) begin
		if (firework_frame == 3'd0) begin
			if (data_out_firework1 != 12'h000) rgb_next =data_out_firework1;
			else rgb_next = data_out_image;
			end
		if (firework_frame == 3'd1) begin
			if (data_out_firework2 != 12'h000) rgb_next =data_out_firework2;
			else rgb_next = data_out_image;
			end
		if (firework_frame == 3'd2) begin
			if (data_out_firework3 != 12'h000) rgb_next =data_out_firework3;
			else rgb_next = data_out_image;
			end
		if (firework_frame == 3'd3) begin
			if (data_out_firework4 != 12'h000) rgb_next =data_out_firework4;
			else rgb_next = data_out_image;
			end
		if (firework_frame == 3'd4) begin
			if (data_out_firework5 != 12'h000) rgb_next =data_out_firework5;
			else rgb_next = data_out_image;
			end
		end
	else rgb_next = data_out_image;
end
// End of the video data display code.
// ------------------------------------------------------------------------

endmodule
