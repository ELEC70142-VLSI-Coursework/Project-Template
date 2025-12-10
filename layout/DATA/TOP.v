module TOP(
    input  wire pad_clk_ext,
    input  wire pad_clk_sel,
    inout  wire pad_clk_out,
    input  wire pad_rst_n,   
 
    input  wire pad_scan_en,
    input  wire pad_scan_testmode,
    input  wire pad_scan_di,
    output wire pad_scan_do,

    input  wire [3:0] pad_pll_select,
    input  wire pad_pll_clk_i,
    output wire pad_pll_clk_o,

    inout  wire [24:0] pad_gpio
);


wire clk;                   // System clock
wire clk_ext;               // External clock from pad
wire clk_sel;               // Clock select from pad
wire rst_n;                 // Active low reset from pad

wire scan_en;               // Scan enable from pad
wire scan_testmode;         // Scan test mode from pad
wire scan_di;               // Scan data in from pad
wire scan_do;               // Scan data out to pad

wire oscillator_clk;        // Clock from oscillator pad feeding PLL
wire pll_clk;               // Clock from PLL
wire [3:0] pll_select;      // PLL frequency select from pad

wire [24:0] gpio_out;       // GPIO output signals to pads
wire [24:0] gpio_pullen;    // GPIO pull-up enable signals
wire [24:0] gpio_dir;       // GPIO direction signals
wire [24:0] gpio_in;        // GPIO input signals from pads


// assign clk = clk_sel ? pll_clk : clk_ext;
CKMUX2D1BWP7T clk_mux(.I0 (clk_ext), .I1 (pll_clk), .S (clk_sel),
       .Z (clk));


/////////////////////////////////////////////////////////////////
// Instantiate Design Top Module
/////////////////////////////////////////////////////////////////
/**
*       Minimum connections to the design top module
*        - clk,
*        - rst_n,
*        - scan_en,
*        - scan_testmode,
*        - scan_di,
*        - scan_do,
*       
*       Connect other GPIO signals as needed and configure their
*       direction and pull-up/down settings in the GPIO Configuration
*/


// ----> DESIGN TOP MODULE INSTANCE HERE




/////////////////////////////////////////////////////////////////
// GPIO Configuration
/////////////////////////////////////////////////////////////////

// DIRECION 0 = OUTPUT, 1 = INPUT
// PULL_EN 0 = DISABLED, 1 = ENABLED

// GPIO 0
assign gpio_pullen[0] = 1'b0;
assign gpio_dir[0]    = 1'b0;
// GPIO 1
assign gpio_pullen[1] = 1'b0;
assign gpio_dir[1]    = 1'b0;
// GPIO 2
assign gpio_pullen[2] = 1'b0;
assign gpio_dir[2]    = 1'b0;
// GPIO 3
assign gpio_pullen[3] = 1'b0;
assign gpio_dir[3]    = 1'b0;
// GPIO 4
assign gpio_pullen[4] = 1'b0;
assign gpio_dir[4]    = 1'b0;
// GPIO 5
assign gpio_pullen[5] = 1'b0; 
assign gpio_dir[5]    = 1'b0;
// GPIO 6
assign gpio_pullen[6] = 1'b0;
assign gpio_dir[6]    = 1'b0;
// GPIO 7
assign gpio_pullen[7] = 1'b0;   
assign gpio_dir[7]    = 1'b0;
// GPIO 8
assign gpio_pullen[8] = 1'b0;
assign gpio_dir[8]    = 1'b0;
// GPIO 9
assign gpio_pullen[9] = 1'b0;
assign gpio_dir[9]    = 1'b0;
// GPIO 10
assign gpio_pullen[10] = 1'b0;
assign gpio_dir[10]    = 1'b0;
// GPIO 11
assign gpio_pullen[11] = 1'b0;
assign gpio_dir[11]    = 1'b0;
// GPIO 12
assign gpio_pullen[12] = 1'b0;
assign gpio_dir[12]    = 1'b0;
// GPIO 13
assign gpio_pullen[13] = 1'b0;
assign gpio_dir[13]    = 1'b0;
// GPIO 14
assign gpio_pullen[14] = 1'b0;
assign gpio_dir[14]    = 1'b0;
// GPIO 15
assign gpio_pullen[15] = 1'b0;
assign gpio_dir[15]    = 1'b0;
// GPIO 16
assign gpio_pullen[16] = 1'b0;
assign gpio_dir[16]    = 1'b0;
// GPIO 17
assign gpio_pullen[17] = 1'b0;
assign gpio_dir[17]    = 1'b0;
// GPIO 18
assign gpio_pullen[18] = 1'b0;
assign gpio_dir[18]    = 1'b0;
// GPIO 19
assign gpio_pullen[19] = 1'b0;
assign gpio_dir[19]    = 1'b0;
// GPIO 20
assign gpio_pullen[20] = 1'b0;
assign gpio_dir[20]    = 1'b0;
// GPIO 21
assign gpio_pullen[21] = 1'b0;
assign gpio_dir[21]    = 1'b0;
// GPIO 22
assign gpio_pullen[22] = 1'b0;
assign gpio_dir[22]    = 1'b0;
// GPIO 23
assign gpio_pullen[23] = 1'b0;
assign gpio_dir[23]    = 1'b0;
// GPIO 24
assign gpio_pullen[24] = 1'b0;
assign gpio_dir[24]    = 1'b0;


//////////////////////////////////////////////////////////////////
// PLL instantiation
//////////////////////////////////////////////////////////////////

PLL_25M_400M pll(
    .input_clk(oscillator_clk),
    .reset(rst_n), 
    .f_out(pll_clk), 
    .div_sel(pll_select),
    .CP_20u_Bias(pll_bias_1),
    .CP_OP_1u_bias(pll_bias_2),
    .DVDD(VDD),  // Digital VDD
    .VSS(VSS),
    .VDD(VDD)   
);


/////////////////////////////////////////////////////////////////
// Instantiate the Padframe IO Pads
/////////////////////////////////////////////////////////////////


// GPIOs
PDUW0408SCDG GPIO_0 (.I(gpio_out[0] ), .DS(1'b0), .OEN(gpio_dir[0] ), .PAD(pad_gpio[0] ), .C(gpio_in[0] ), .PE(gpio_pullen[0] ), .IE(gpio_dir[0] ));
PDUW0408SCDG GPIO_1 (.I(gpio_out[1] ), .DS(1'b0), .OEN(gpio_dir[1] ), .PAD(pad_gpio[1] ), .C(gpio_in[1] ), .PE(gpio_pullen[1] ), .IE(gpio_dir[1] ));
PDUW0408SCDG GPIO_2 (.I(gpio_out[2] ), .DS(1'b0), .OEN(gpio_dir[2] ), .PAD(pad_gpio[2] ), .C(gpio_in[2] ), .PE(gpio_pullen[2] ), .IE(gpio_dir[2] ));
PDUW0408SCDG GPIO_3 (.I(gpio_out[3] ), .DS(1'b0), .OEN(gpio_dir[3] ), .PAD(pad_gpio[3] ), .C(gpio_in[3] ), .PE(gpio_pullen[3] ), .IE(gpio_dir[3] ));
PDUW0408SCDG GPIO_4 (.I(gpio_out[4] ), .DS(1'b0), .OEN(gpio_dir[4] ), .PAD(pad_gpio[4] ), .C(gpio_in[4] ), .PE(gpio_pullen[4] ), .IE(gpio_dir[4] ));
PDUW0408SCDG GPIO_5 (.I(gpio_out[5] ), .DS(1'b0), .OEN(gpio_dir[5] ), .PAD(pad_gpio[5] ), .C(gpio_in[5] ), .PE(gpio_pullen[5] ), .IE(gpio_dir[5] ));
PDUW0408SCDG GPIO_6 (.I(gpio_out[6] ), .DS(1'b0), .OEN(gpio_dir[6] ), .PAD(pad_gpio[6] ), .C(gpio_in[6] ), .PE(gpio_pullen[6] ), .IE(gpio_dir[6] ));
PDUW0408SCDG GPIO_7 (.I(gpio_out[7] ), .DS(1'b0), .OEN(gpio_dir[7] ), .PAD(pad_gpio[7] ), .C(gpio_in[7] ), .PE(gpio_pullen[7] ), .IE(gpio_dir[7] ));
PDUW0408SCDG GPIO_8 (.I(gpio_out[8] ), .DS(1'b0), .OEN(gpio_dir[8] ), .PAD(pad_gpio[8] ), .C(gpio_in[8] ), .PE(gpio_pullen[8] ), .IE(gpio_dir[8] ));
PDUW0408SCDG GPIO_9 (.I(gpio_out[9] ), .DS(1'b0), .OEN(gpio_dir[9] ), .PAD(pad_gpio[9] ), .C(gpio_in[9] ), .PE(gpio_pullen[9] ), .IE(gpio_dir[9] ));
PDUW0408SCDG GPIO_10(.I(gpio_out[10]), .DS(1'b0), .OEN(gpio_dir[10]), .PAD(pad_gpio[10]), .C(gpio_in[10]), .PE(gpio_pullen[10]), .IE(gpio_dir[10]));
PDUW0408SCDG GPIO_11(.I(gpio_out[11]), .DS(1'b0), .OEN(gpio_dir[11]), .PAD(pad_gpio[11]), .C(gpio_in[11]), .PE(gpio_pullen[11]), .IE(gpio_dir[11]));
PDUW0408SCDG GPIO_12(.I(gpio_out[12]), .DS(1'b0), .OEN(gpio_dir[12]), .PAD(pad_gpio[12]), .C(gpio_in[12]), .PE(gpio_pullen[12]), .IE(gpio_dir[12]));
PDUW0408SCDG GPIO_13(.I(gpio_out[13]), .DS(1'b0), .OEN(gpio_dir[13]), .PAD(pad_gpio[13]), .C(gpio_in[13]), .PE(gpio_pullen[13]), .IE(gpio_dir[13]));
PDUW0408SCDG GPIO_14(.I(gpio_out[14]), .DS(1'b0), .OEN(gpio_dir[14]), .PAD(pad_gpio[14]), .C(gpio_in[14]), .PE(gpio_pullen[14]), .IE(gpio_dir[14]));
PDUW0408SCDG GPIO_15(.I(gpio_out[15]), .DS(1'b0), .OEN(gpio_dir[15]), .PAD(pad_gpio[15]), .C(gpio_in[15]), .PE(gpio_pullen[15]), .IE(gpio_dir[15]));
PDUW0408SCDG GPIO_16(.I(gpio_out[16]), .DS(1'b0), .OEN(gpio_dir[16]), .PAD(pad_gpio[16]), .C(gpio_in[16]), .PE(gpio_pullen[16]), .IE(gpio_dir[16]));
PDUW0408SCDG GPIO_17(.I(gpio_out[17]), .DS(1'b0), .OEN(gpio_dir[17]), .PAD(pad_gpio[17]), .C(gpio_in[17]), .PE(gpio_pullen[17]), .IE(gpio_dir[17]));
PDUW0408SCDG GPIO_18(.I(gpio_out[18]), .DS(1'b0), .OEN(gpio_dir[18]), .PAD(pad_gpio[18]), .C(gpio_in[18]), .PE(gpio_pullen[18]), .IE(gpio_dir[18]));
PDUW0408SCDG GPIO_19(.I(gpio_out[19]), .DS(1'b0), .OEN(gpio_dir[19]), .PAD(pad_gpio[19]), .C(gpio_in[19]), .PE(gpio_pullen[19]), .IE(gpio_dir[19]));
PDUW0408SCDG GPIO_20(.I(gpio_out[20]), .DS(1'b0), .OEN(gpio_dir[20]), .PAD(pad_gpio[20]), .C(gpio_in[20]), .PE(gpio_pullen[20]), .IE(gpio_dir[20]));
PDUW0408SCDG GPIO_21(.I(gpio_out[21]), .DS(1'b0), .OEN(gpio_dir[21]), .PAD(pad_gpio[21]), .C(gpio_in[21]), .PE(gpio_pullen[21]), .IE(gpio_dir[21]));
PDUW0408SCDG GPIO_22(.I(gpio_out[22]), .DS(1'b0), .OEN(gpio_dir[22]), .PAD(pad_gpio[22]), .C(gpio_in[22]), .PE(gpio_pullen[22]), .IE(gpio_dir[22]));
PDUW0408SCDG GPIO_23(.I(gpio_out[23]), .DS(1'b0), .OEN(gpio_dir[23]), .PAD(pad_gpio[23]), .C(gpio_in[23]), .PE(gpio_pullen[23]), .IE(gpio_dir[23]));
PDUW0408SCDG GPIO_24(.I(gpio_out[24]), .DS(1'b0), .OEN(gpio_dir[24]), .PAD(pad_gpio[24]), .C(gpio_in[24]), .PE(gpio_pullen[24]), .IE(gpio_dir[24]));



// CLOCK
PDUW0408SCDG CLK_EXT    (.I(1'b0), .DS(1'b0), .OEN(1'b1), .PAD(pad_clk_ext), .C(clk_ext), .PE(1'b0), .IE(1'b1));
PDUW0408SCDG CLK_SEL    (.I(1'b0), .DS(1'b0), .OEN(1'b1), .PAD(pad_clk_sel), .C(clk_sel), .PE(1'b0), .IE(1'b1));
PDUW0408SCDG CLK_OUT    (.I(clk),  .DS(1'b0), .OEN(1'b0), .PAD(pad_clk_out), .C(),        .PE(1'b0), .IE(1'b0));

// RESET
PDUW0408SCDG RESET_N    (.I(1'b0),    .DS(1'b0), .OEN(1'b1), .PAD(pad_rst_n),   .C(rst_n),   .PE(1'b0), .IE(1'b1));

// SCAN CHAIN
PDUW0408SCDG SCAN_EN    (.I(1'b0),    .DS(1'b0), .OEN(1'b1), .PAD(pad_scan_en),       .C(scan_en),       .PE(1'b0), .IE(1'b1));
PDUW0408SCDG SCAN_TSTMD (.I(1'b0),    .DS(1'b0), .OEN(1'b1), .PAD(pad_scan_testmode), .C(scan_testmode), .PE(1'b0), .IE(1'b1));
PDUW0408SCDG SCAN_DI    (.I(1'b0),    .DS(1'b0), .OEN(1'b1), .PAD(pad_scan_di),       .C(scan_di),       .PE(1'b0), .IE(1'b1));
PDUW0408SCDG SCAN_DO    (.I(scan_do), .DS(1'b0), .OEN(1'b0), .PAD(pad_scan_do),       .C(),              .PE(1'b0), .IE(1'b0));

// PLL     
PXOE2CDG     PLL_CLK_IN(.XC(oscillator_clk), .XO(pad_pll_clk_o), .XI(pad_pll_clk_i), .XE(1'b1)); //     input XI, XE; output XC, XO;
PDUW0408SCDG PLL_CTRL_0(.I(1'b0),        .DS(1'b0), .OEN(1'b1), .PAD(pad_pll_select[0]), .C(pll_select[0]), .PE(1'b0), .IE(1'b1));
PDUW0408SCDG PLL_CTRL_1(.I(1'b0),        .DS(1'b0), .OEN(1'b1), .PAD(pad_pll_select[1]), .C(pll_select[1]), .PE(1'b0), .IE(1'b1));
PDUW0408SCDG PLL_CTRL_2(.I(1'b0),        .DS(1'b0), .OEN(1'b1), .PAD(pad_pll_select[2]), .C(pll_select[2]), .PE(1'b0), .IE(1'b1));
PDUW0408SCDG PLL_CTRL_3(.I(1'b0),        .DS(1'b0), .OEN(1'b1), .PAD(pad_pll_select[3]), .C(pll_select[3]), .PE(1'b0), .IE(1'b1));

PVDD2ANA PLL_BIAS_1(.AVDD(pll_bias_1));  // PLL Bias 1
PVDD2ANA PLL_BIAS_2(.AVDD(pll_bias_2));  // PLL Bias 2


// POWER AND GROUND PADS
PVDD1CDG vdd_core_1 (.VDD(VDD));  // Core power supply
PVDD1CDG vdd_core_2 (.VDD(VDD));  // Core power supply

PVDD2CDG vdd_io_1 ();             // I/O Power Supply
PVDD2CDG vdd_io_2 ();             // I/O Power Supply

PVDD2POC vdd_poc ();              // Power-On-Control

PVSS3CDG vss_1 (.VSS(VSS));       // Ground
PVSS3CDG vss_2 (.VSS(VSS));       // Ground



/////////////////////////////////////////////////////////////////
// Instantiate the Bond Pads
/////////////////////////////////////////////////////////////////
PAD60LU_SL BPAD_GPIO_0 ();
PAD60LU_SL BPAD_GPIO_1 ();
PAD60LU_SL BPAD_GPIO_2 ();
PAD60LU_SL BPAD_GPIO_3 ();
PAD60LU_SL BPAD_GPIO_4 ();
PAD60LU_SL BPAD_GPIO_5 ();
PAD60LU_SL BPAD_GPIO_6 ();
PAD60LU_SL BPAD_GPIO_7 ();
PAD60LU_SL BPAD_GPIO_8 ();
PAD60LU_SL BPAD_GPIO_9 ();
PAD60LU_SL BPAD_GPIO_10 ();
PAD60LU_SL BPAD_GPIO_11 ();
PAD60LU_SL BPAD_GPIO_12 ();
PAD60LU_SL BPAD_GPIO_13 ();
PAD60LU_SL BPAD_GPIO_14 ();
PAD60LU_SL BPAD_GPIO_15 ();
PAD60LU_SL BPAD_GPIO_16 ();
PAD60LU_SL BPAD_GPIO_17 ();
PAD60LU_SL BPAD_GPIO_18 ();
PAD60LU_SL BPAD_GPIO_19 ();
PAD60LU_SL BPAD_GPIO_20 ();
PAD60LU_SL BPAD_GPIO_21 ();
PAD60LU_SL BPAD_GPIO_22 ();
PAD60LU_SL BPAD_GPIO_23 ();
PAD60LU_SL BPAD_GPIO_24 ();


PAD60LU_SL BPAD_CLK_EXT ();
PAD60LU_SL BPAD_CLK_SEL ();
PAD60LU_SL BPAD_CLK_OUT ();

PAD60LU_SL BPAD_RESET_N ();

PAD60LU_SL BPAD_SCAN_EN ();
PAD60LU_SL BPAD_SCAN_TSTMD ();
PAD60LU_SL BPAD_SCAN_DI ();
PAD60LU_SL BPAD_SCAN_DO ();

PAD60LU_SL BPAD_PLL_CLK_I ();
PAD60LU_SL BPAD_PLL_CLK_O ();

PAD60LU_SL BPAD_PLL_CTRL_0 ();
PAD60LU_SL BPAD_PLL_CTRL_1 ();
PAD60LU_SL BPAD_PLL_CTRL_2 ();
PAD60LU_SL BPAD_PLL_CTRL_3 ();
PAD60LU_SL BPAD_PLL_BIAS_1 ();
PAD60LU_SL BPAD_PLL_BIAS_2 ();

PAD60LU_SL BPAD_vdd_core_1 ();
PAD60LU_SL BPAD_vdd_core_2 ();
PAD60LU_SL BPAD_vdd_io_1 ();
PAD60LU_SL BPAD_vdd_io_2 ();
PAD60LU_SL BPAD_vdd_poc ();
PAD60LU_SL BPAD_vss_1 ();
PAD60LU_SL BPAD_vss_2 ();

endmodule