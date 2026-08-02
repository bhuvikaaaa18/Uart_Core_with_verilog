`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Bhuvika
// Module Name: UART_Core
// Description:
// Top-Level UART Core
// Features:
//  - Configurable Baud Rate
//  - 5 / 6 / 7 / 8 Data Bits
//  - None / Even / Odd Parity
//  - 1 / 2 Stop Bits
//  - Integrated Baud Rate Generator
//  - Integrated UART Transmitter
//  - Integrated UART Receiver
//////////////////////////////////////////////////////////////////////////////////

module UART_Core
#(
    parameter DATA_WIDTH = 8,
    parameter CLK_FREQ   = 100_000_000
)
(
    // System Signals
    input clk,
    input reset,
    // Baud Rate Configuration
    input [2:0] baud_sel,
    // UART Configuration
    input [2:0] data_bits,
    input [1:0] parity_type,
    input stop_bits,
    // Transmitter Interface
    input tx_start,
    input  [DATA_WIDTH-1:0] tx_data,
    output tx,
    output tx_busy,
    // Receiver Interface
    input rx,
    output [DATA_WIDTH-1:0] rx_data,
    output rx_done,
    output rx_busy,
    output parity_error,
    output framing_error
);
// Internal Signals
wire baud_tick;
wire sample_tick;
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
TX
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
    .busy(tx_busy)
);
// UART Receiver
UART_RX
#(
    .DATA_WIDTH(DATA_WIDTH)
)
RX
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
    .busy(rx_busy),
    .parity_error(parity_error),
    .framing_error(framing_error)
);
endmodule