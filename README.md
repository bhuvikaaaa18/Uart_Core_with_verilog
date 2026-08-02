# Configurable UART Core in Verilog

A synthesizable UART Core written in Verilog with configurable baud rate, data length, parity, and stop bits. The design is modular and intended to serve as the foundation for a SoC-ready UART peripheral with an APB interface.

## Features

- Verilog-2001
- Synthesizable
- Configurable baud rates
- Configurable data length (5/6/7/8 bits)
- None / Even / Odd parity
- 1 or 2 stop bits
- 16× oversampling receiver
- Modular architecture
- Individual testbenches
- UART Core loopback verification

## Project Structure

RTL/
- Baud_Rate_Generator.v
- UART_TX.v
- UART_RX.v
- UART_Core.v

Testbench/
- Baud_Rate_Generator_tb.v
- UART_TX_tb.v
- UART_RX_tb.v
- UART_Core_tb.v

## Tested Configuration

Clock Frequency : 100 MHz

Supported Baud Rates

- 9600
- 19200
- 38400
- 57600
- 115200

## Future Work

- TX FIFO
- RX FIFO
- APB3 Interface
- Interrupt Controller
- UART Registers
- SoC Integration

## Tools Used

- Vivado
- Verilog HDL
