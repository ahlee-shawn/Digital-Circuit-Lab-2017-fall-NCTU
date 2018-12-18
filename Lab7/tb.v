`timescale 1ns / 1ps
  
module tb();

reg clk;
reg reset_n;
reg [3:0] usr_btn;
wire [3:0] usr_led;


wire spi_ss;
wire spi_sck;
wire spi_mosi;
reg  spi_miso;

wire LCD_RS;
wire LCD_RW;
wire LCD_E;
wire [3:0] LCD_D;
reg  uart_rx;
wire uart_tx;
lab7 uut(
    .clk(clk),
    .reset_n(reset_n),
    .usr_btn(usr_btn),
    .usr_led(usr_led),
    .spi_ss(spi_ss),
    .spi_sck(spi_sck),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .LCD_RS(LCD_RS),
    .LCD_RW(LCD_RW),
    .LCD_E(LCD_E),
    .LCD_D(LCD_D),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx)
);


    always
    begin
        #5 clk = ~clk;
    
     end
     
     
     integer i;
     initial begin
     clk = 0;
     reset_n = 1;
     usr_btn = 0;
     spi_miso = 0;
      
       for(i=0;i<512;i=i+1)begin
         uut.ram0.RAM[i] = 0;
       end
       uut.ram0.RAM[0 ] = "M";
       uut.ram0.RAM[1 ] = "A";
       uut.ram0.RAM[2 ] = "T";
       uut.ram0.RAM[3 ] = "X";
       uut.ram0.RAM[4 ] = "_";
       uut.ram0.RAM[5 ] = "T";
       uut.ram0.RAM[6 ] = "A";
       uut.ram0.RAM[7 ] = "G";
       uut.ram0.RAM[8 ] = 8'h0D;
       uut.ram0.RAM[9 ] = 8'h0A;
       uut.ram0.RAM[10] = "E";
       uut.ram0.RAM[11] = "1";
       uut.ram0.RAM[12 ] = 8'h0D;
       uut.ram0.RAM[13 ] = 8'h0A;
       uut.ram0.RAM[14 ] = "6";
       uut.ram0.RAM[15 ] = "B";
       uut.ram0.RAM[16 ] = 8'h0D;
       uut.ram0.RAM[17 ] = 8'h0A;
       uut.ram0.RAM[18 ] = "D";
       uut.ram0.RAM[19 ] = "7";
       uut.ram0.RAM[20 ] = 8'h0D;
       uut.ram0.RAM[21 ] = 8'h0A;
       uut.ram0.RAM[22 ] = "1";
       uut.ram0.RAM[23 ] = "D";
       uut.ram0.RAM[24 ] = 8'h0D;
       uut.ram0.RAM[25 ] = 8'h0A;
       uut.ram0.RAM[26 ] = "B";
       uut.ram0.RAM[27 ] = "6";
       uut.ram0.RAM[28 ] = 8'h0D;
       uut.ram0.RAM[29 ] = 8'h0A;
       uut.ram0.RAM[30 ] = "0";
       uut.ram0.RAM[31 ] = "C";
       uut.ram0.RAM[32 ] = 8'h0D;
       uut.ram0.RAM[33 ] = 8'h0A;
       uut.ram0.RAM[34 ] = "5";
       uut.ram0.RAM[35 ] = "5";
       uut.ram0.RAM[36 ] = 8'h0D;
       uut.ram0.RAM[37 ] = 8'h0A;
       uut.ram0.RAM[38 ] = "2";
       uut.ram0.RAM[39 ] = "D";
       uut.ram0.RAM[40 ] = 8'h0D;
       uut.ram0.RAM[41 ] = 8'h0A;
       uut.ram0.RAM[42 ] = "1";
       uut.ram0.RAM[43 ] = "E";
       uut.ram0.RAM[44 ] = 8'h0D;
       uut.ram0.RAM[45 ] = 8'h0A;
       uut.ram0.RAM[46 ] = "E";
       uut.ram0.RAM[47 ] = "8";
       uut.ram0.RAM[48 ] = 8'h0D;
       uut.ram0.RAM[49 ] = 8'h0A;
       uut.ram0.RAM[50 ] = "8";
       uut.ram0.RAM[51 ] = "0";
       uut.ram0.RAM[52 ] = 8'h0D;
       uut.ram0.RAM[53 ] = 8'h0A;
       uut.ram0.RAM[54 ] = "2";
       uut.ram0.RAM[55 ] = "7";
       uut.ram0.RAM[56 ] = 8'h0D;
       uut.ram0.RAM[57 ] = 8'h0A;
       uut.ram0.RAM[58 ] = "A";
       uut.ram0.RAM[59 ] = "6";
       uut.ram0.RAM[60 ] = 8'h0D;
       uut.ram0.RAM[61 ] = 8'h0A;
       uut.ram0.RAM[62 ] = "3";
       uut.ram0.RAM[63 ] = "4";
       uut.ram0.RAM[64 ] = 8'h0D;
       uut.ram0.RAM[65 ] = 8'h0A;
       uut.ram0.RAM[66 ] = "D";
       uut.ram0.RAM[67 ] = "B";
       uut.ram0.RAM[68 ] = 8'h0D;
       uut.ram0.RAM[69 ] = 8'h0A;
       uut.ram0.RAM[70 ] = "B";
       uut.ram0.RAM[71 ] = "7";
       uut.ram0.RAM[72 ] = 8'h0D;
       uut.ram0.RAM[73 ] = 8'h0A;
       uut.ram0.RAM[74 ] = "B";
       uut.ram0.RAM[75 ] = "9";
       uut.ram0.RAM[76 ] = 8'h0D;
       uut.ram0.RAM[77 ] = 8'h0A;
       uut.ram0.RAM[78 ] = "0";
       uut.ram0.RAM[79 ] = "A";
       uut.ram0.RAM[80 ] = 8'h0D;
       uut.ram0.RAM[81 ] = 8'h0A;
       uut.ram0.RAM[82 ] = "8";
       uut.ram0.RAM[83 ] = "E";
       uut.ram0.RAM[84 ] = 8'h0D;
       uut.ram0.RAM[85 ] = 8'h0A;
       uut.ram0.RAM[86 ] = "9";
       uut.ram0.RAM[87 ] = "8";
       uut.ram0.RAM[88 ] = 8'h0D;
       uut.ram0.RAM[89 ] = 8'h0A;
       uut.ram0.RAM[90 ] = "7";
       uut.ram0.RAM[91 ] = "3";
       uut.ram0.RAM[92 ] = 8'h0D;
       uut.ram0.RAM[93 ] = 8'h0A;
       uut.ram0.RAM[94 ] = "9";
       uut.ram0.RAM[95 ] = "9";
       uut.ram0.RAM[96 ] = 8'h0D;
       uut.ram0.RAM[97 ] = 8'h0A;
       uut.ram0.RAM[98 ] = "B";
       uut.ram0.RAM[99 ] = "0";
       uut.ram0.RAM[100] = 8'h0D;
       uut.ram0.RAM[101] = 8'h0A;
       uut.ram0.RAM[102] = "F";
       uut.ram0.RAM[103] = "8";
       uut.ram0.RAM[104] = 8'h0D;
       uut.ram0.RAM[105] = 8'h0A;
       uut.ram0.RAM[106] = "3";
       uut.ram0.RAM[107] = "8";
       uut.ram0.RAM[108] = 8'h0D;
       uut.ram0.RAM[109] = 8'h0A;
       uut.ram0.RAM[110] = "7";
       uut.ram0.RAM[111] = "6";
       uut.ram0.RAM[112] = 8'h0D;
       uut.ram0.RAM[113] = 8'h0A;
       uut.ram0.RAM[114] = "0";
       uut.ram0.RAM[115] = "B";
       uut.ram0.RAM[116] = 8'h0D;
       uut.ram0.RAM[117] = 8'h0A;
       uut.ram0.RAM[118] = "A";
       uut.ram0.RAM[119] = "0";
       uut.ram0.RAM[120] = 8'h0D;
       uut.ram0.RAM[121] = 8'h0A;
       uut.ram0.RAM[122] = "6";
       uut.ram0.RAM[123] = "E";
       uut.ram0.RAM[124] = 8'h0D;
       uut.ram0.RAM[125] = 8'h0A;
       uut.ram0.RAM[126] = "B";
       uut.ram0.RAM[127] = "C";
       uut.ram0.RAM[128] = 8'h0D;
       uut.ram0.RAM[129] = 8'h0A;
       uut.ram0.RAM[130] = "0";
       uut.ram0.RAM[131] = "2";
       uut.ram0.RAM[132] = 8'h0D;
       uut.ram0.RAM[133] = 8'h0A;
       uut.ram0.RAM[134] = "D";
       uut.ram0.RAM[135] = "3";
       uut.ram0.RAM[136] = 8'h0D;
       uut.ram0.RAM[137] = 8'h0A;
       uut.ram0.RAM[138] = 8'h0D;
       uut.ram0.RAM[139] = 8'h0A;


  
     
     
     #30;
     reset_n = 0;
     #30;
     reset_n = 1;
          end
     

endmodule
