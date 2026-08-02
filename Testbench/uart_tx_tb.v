`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Bhuvika
// Module Name: UART_TX_tb
// Description:
// Testbench for Configurable UART Transmitter
//////////////////////////////////////////////////////////////////////////////////
module UART_TX_tb;
// Parameters
parameter DATA_WIDTH = 8;
parameter CLK_FREQ   = 100_000_000;
// Testbench Signals
reg clk;
reg reset;
reg tx_start;
reg [DATA_WIDTH-1:0] tx_data;
reg [2:0] baud_sel;
reg [2:0] data_bits;
reg [1:0] parity_type;
reg stop_bits;
wire baud_tick;
wire sample_tick;
wire tx;
wire busy;
// Clock Generation (100 MHz)
always #5 clk = ~clk;
// Baud Rate Generator
Baud_Rate_Generator
#(
   .CLK_FREQ(CLK_FREQ)
)
BRG
(
    .clk(clk),
    .reset(reset),
    .baud_sel(baud_sel),
    .baud_tick(baud_tick),
    .sample_tick(sample_tick)
);
// UART Transmitter
UART_TX
#(
    .DATA_WIDTH(DATA_WIDTH)
)
DUT
(
    .clk(clk),
    .reset(reset),
    .baud_tick(baud_tick),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .data_bits(data_bits),
    .parity_type(parity_type),
    .stop_bits(stop_bits),
    .tx(tx),
    .busy(busy)
);
// Test Procedure
initial
begin
    // Initialize
    clk         = 1'b0;
    reset       = 1'b1;
    tx_start    = 1'b0;
    tx_data     = 8'h00;
    baud_sel    = 3'd4;      //115200 baud
    data_bits   = 3'd8;
    parity_type = 2'b00;
    stop_bits   = 1'b0;
    // Reset
    #100;
    reset = 1'b0;
    // Test 1 : 8N1
    #100;
    tx_data = 8'h55;
    tx_start = 1'b1;
    #10;
    tx_start = 1'b0;
    wait(busy == 0);
    // Test 2 : 8E1
    #100000;
    parity_type = 2'b01;
    tx_data = 8'hA5;
    tx_start = 1'b1;
    #10;
    tx_start = 1'b0;
    wait(busy == 0);
    // Test 3 : 8O2
    #100000;
    parity_type = 2'b10;
    stop_bits = 1'b1;
    tx_data = 8'h3C;
    tx_start = 1'b1;
    #10;
    tx_start = 1'b0;
    wait(busy == 0);
    // Test 4 : 7E1
    #100000;
    data_bits = 3'd7;
    parity_type = 2'b01;
    stop_bits = 1'b0;
    tx_data = 8'b01010101;
    tx_start = 1'b1;
    #10;
    tx_start = 1'b0;
    wait(busy == 0);
    // Test 5 : 5N1
    #100000;
    data_bits = 3'd5;
    parity_type = 2'b00;
    stop_bits = 1'b0;
    tx_data = 8'b00010101;
    tx_start = 1'b1;
    #10;
    tx_start = 1'b0;
    wait(busy == 0);
    // End Simulation
    #100000;
    $stop;
end
endmodule