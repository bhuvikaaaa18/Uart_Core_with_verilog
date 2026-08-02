`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Bhuvika
// Module Name: UART_RX_tb
// Description:
// Testbench for Configurable UART Receiver
//////////////////////////////////////////////////////////////////////////////////

module UART_RX_tb;
// PARAMETERS
parameter DATA_WIDTH = 8;
parameter CLK_FREQ   = 100_000_000;
// TESTBENCH SIGNALS
reg clk;
reg reset;
reg rx;
reg [2:0] baud_sel;
reg [2:0] data_bits;
reg [1:0] parity_type;
reg stop_bits;
wire baud_tick;
wire sample_tick;
wire [DATA_WIDTH-1:0] rx_data;
wire rx_done;
wire busy;
wire parity_error;
wire framing_error;
// CLOCK GENERATION (100 MHz)
always
begin
    #5 clk = ~clk;
end
// BAUD RATE GENERATOR
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
// UART RECEIVER
UART_RX
#(
    .DATA_WIDTH(DATA_WIDTH)
)
DUT
(
    .clk(clk),
    .reset(reset),
    .sample_tick(sample_tick),
    .rx(rx),
    .data_bits(data_bits),
    .parity_type(parity_type),
    .stop_bits(stop_bits),
    .rx_data(rx_data),
    .rx_done(rx_done),
    .busy(busy),
    .parity_error(parity_error),
    .framing_error(framing_error)
);
// INITIAL BLOCK
initial
begin
    // Initialize Signals
    clk = 1'b0;
    reset = 1'b1;
    rx = 1'b1;                 // UART Line Idle
    baud_sel = 3'd4;           // 115200 Baud
    data_bits   = 3'd8;        // 8 Data Bits
    parity_type = 2'b00;       // No Parity
    stop_bits   = 1'b0;        // 1 Stop Bit
    // Apply Reset
    #100;
    reset = 1'b0;
    // Wait for Receiver to Stabilize
    repeat(32)
        @(posedge sample_tick);  
    // Test 1 
    // Data      : 0x55
    data_bits   = 3'd8;        // 8 Data Bits
    parity_type = 2'b00;       // No Parity
    stop_bits   = 1'b0;        // 1 Stop Bit

    // Start Bit
    rx = 1'b0;
    repeat(16)
        @(posedge sample_tick);

    // Data Bit 0 (LSB = 1)
    rx = 1'b1;
    repeat(16)
        @(posedge sample_tick);

    // Data Bit 1
    rx = 1'b0;
    repeat(16)
        @(posedge sample_tick);

    // Data Bit 2
    rx = 1'b1;
    repeat(16)
        @(posedge sample_tick);

    // Data Bit 3
    rx = 1'b0;
    repeat(16)
        @(posedge sample_tick);

    // Data Bit 4
    rx = 1'b1;
    repeat(16)
        @(posedge sample_tick);

    // Data Bit 5
    rx = 1'b0;
    repeat(16)
        @(posedge sample_tick);

    // Data Bit 6
    rx = 1'b1;
    repeat(16)
        @(posedge sample_tick);

    // Data Bit 7 (MSB)
    rx = 1'b0;
    repeat(16)
        @(posedge sample_tick);

    // Stop Bit
    rx = 1'b1;
    repeat(16)
        @(posedge sample_tick);

    // Wait for Receiver to Finish
    wait(rx_done == 1'b1);
    repeat(16)
        @(posedge sample_tick);
    // Test 2
    // Data      : 0xA5
    data_bits   = 3'd8;        // 8 Data Bits
    parity_type = 2'b01;       // Even Parity
    stop_bits   = 1'b0;        // 1 Stop Bit

    // Test 3
    // Data      : 0x3C
    data_bits   = 3'd8;        // 8 Data Bits
    parity_type = 2'b10;       // Odd Parity
    stop_bits   = 1'b1;        // 2 Stop Bits

    // Test 4
    // Data      : 0x55
    data_bits   = 3'd7;        // 7 Data Bits
    parity_type = 2'b01;       // Even Parity
    stop_bits   = 1'b0;        // 1 Stop Bit

    // Test 5
    // Data      : 0x15
    data_bits   = 3'd5;        // 5 Data Bits
    parity_type = 2'b00;       // No Parity
    stop_bits   = 1'b0;        // 1 Stop Bit

    // Test 6
    // Parity Error Test
    data_bits   = 3'd8;        // 8 Data Bits
    parity_type = 2'b01;       // Even Parity
    stop_bits   = 1'b0;        // 1 Stop Bit
    // Send an incorrect parity bit.
    // Verify:
    // parity_error = 1
    
    // Test 7
    // Framing Error Test
    data_bits   = 3'd8;        // 8 Data Bits
    parity_type = 2'b00;       // No Parity
    stop_bits   = 1'b0;        // 1 Stop Bit
    // Send Stop Bit = 0 instead of 1.
    // Verify:
    // framing_error = 1
    
    #1000;
    $stop;
end
endmodule