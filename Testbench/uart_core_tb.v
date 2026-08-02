`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Bhuvika
// Module Name: UART_Core_tb
// Description:
// Testbench for UART Core
// Loopback Test:
// TX -----> RX
//////////////////////////////////////////////////////////////////////////////////

module UART_Core_tb;
// PARAMETERS
parameter DATA_WIDTH = 8;
parameter CLK_FREQ   = 100_000_000;
// TESTBENCH SIGNALS
reg clk;
reg reset;
reg [2:0] baud_sel;
reg [2:0] data_bits;
reg [1:0] parity_type;
reg stop_bits;
reg tx_start;
reg [DATA_WIDTH-1:0] tx_data;
wire tx_busy;
wire rx_busy;
wire tx;
wire rx;
wire [DATA_WIDTH-1:0] rx_data;
wire rx_done;
wire parity_error;
wire framing_error;
// LOOPBACK CONNECTION
assign rx = tx;
// CLOCK GENERATION (100 MHz)
always
begin
    #5 clk = ~clk;
end
// UART CORE
UART_Core
#(
    .DATA_WIDTH(DATA_WIDTH),
    .CLK_FREQ(CLK_FREQ)
)
DUT
(
    .clk(clk),
    .reset(reset),
    .baud_sel(baud_sel),
    .data_bits(data_bits),
    .parity_type(parity_type),
    .stop_bits(stop_bits),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy),
    .rx(rx),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .rx_busy(rx_busy),
    .parity_error(parity_error),
    .framing_error(framing_error)
);
// TEST SEQUENCE
initial
begin
    // Initialize Signals
    clk = 1'b0;
    reset = 1'b1;
    baud_sel = 3'd4;          // 115200 Baud
    data_bits   = 3'd8;       // 8 Data Bits
    parity_type = 2'b00;      // No Parity
    stop_bits   = 1'b0;       // 1 Stop Bit
    tx_start = 1'b0;
    tx_data  = 8'h00;
    // Apply Reset
    #100;
    reset = 1'b0;
    #100;
    
    // Test 1
    // Baud Rate : 115200
    // Data Bits : 8
    // Parity    : None
    // Stop Bits : 1
    // Data      : 0x55
    tx_data = 8'h55;
    tx_start = 1'b1;
    //@(posedge clk);
    #50;
    tx_start = 1'b0;
    // Wait for Complete Reception
    wait(rx_done == 1'b1);
    // Display Results
    $display("-------------------------------------------");
    $display("UART LOOPBACK TEST");
    $display("-------------------------------------------");
    $display("Transmitted Data = %h", tx_data);
    $display("Received Data    = %h", rx_data);
    $display("Parity Error     = %b", parity_error);
    $display("Framing Error    = %b", framing_error);
    $display("-------------------------------------------");
    // Compare Results
    if(rx_data == tx_data &&
       parity_error == 1'b0 &&
       framing_error == 1'b0)
    begin
        $display("TEST 1 PASSED");
    end
    else
    begin
        $display("TEST 1 FAILED");
    end
    // Wait Before Next Test
    #10000;///here
        //////////////////////////////////////////////////////////
    // Test 2
    //
    // Baud Rate : 115200
    // Data Bits : 8
    // Parity    : Even
    // Stop Bits : 1
    // Data      : 0xA5
    //////////////////////////////////////////////////////////

    data_bits   = 3'd8;
    parity_type = 2'b01;      // Even Parity
    stop_bits   = 1'b0;

    tx_data  = 8'hA5;

    tx_start = 1'b1;
    //@(posedge clk);
    #50;
    tx_start = 1'b0;

    wait(rx_done == 1'b1);

    $display("-------------------------------------------");
    $display("TEST 2");
    $display("Transmitted Data = %h", tx_data);
    $display("Received Data    = %h", rx_data);
    $display("Parity Error     = %b", parity_error);
    $display("Framing Error    = %b", framing_error);

    if(rx_data == tx_data &&
       parity_error == 1'b0 &&
       framing_error == 1'b0)
        $display("TEST 2 PASSED");
    else
        $display("TEST 2 FAILED");

    #10000;

    //////////////////////////////////////////////////////////
    // Test 3
    //
    // Baud Rate : 115200
    // Data Bits : 8
    // Parity    : Odd
    // Stop Bits : 2
    // Data      : 0x3C
    //////////////////////////////////////////////////////////

    data_bits   = 3'd8;
    parity_type = 2'b10;      // Odd Parity
    stop_bits   = 1'b1;       // 2 Stop Bits

    tx_data = 8'h3C;

    tx_start = 1'b1;
    //@(posedge clk);
    #50;
    tx_start = 1'b0;

    wait(rx_done == 1'b1);

    $display("-------------------------------------------");
    $display("TEST 3");
    $display("Transmitted Data = %h", tx_data);
    $display("Received Data    = %h", rx_data);
    $display("Parity Error     = %b", parity_error);
    $display("Framing Error    = %b", framing_error);

    if(rx_data == tx_data &&
       parity_error == 1'b0 &&
       framing_error == 1'b0)
        $display("TEST 3 PASSED");
    else
        $display("TEST 3 FAILED");

    //////////////////////////////////////////////////////////
    // End Simulation
    //////////////////////////////////////////////////////////

    #10000;

    $display("-------------------------------------------");
    $display("ALL UART CORE TESTS COMPLETED");
    $display("-------------------------------------------");

    $stop;

end

endmodule