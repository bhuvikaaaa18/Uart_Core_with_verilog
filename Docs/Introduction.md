# UART (Universal Asynchronous Receiver Transmitter)

## Overview

UART (Universal Asynchronous Receiver Transmitter) is one of the most widely used serial communication protocols for exchanging data between digital devices. Unlike synchronous communication protocols, UART does not require a separate clock line. Instead, both the transmitter and receiver are configured with the same baud rate before communication begins.

Communication occurs over two independent signals:

- **TX** – Transmit line
- **RX** – Receive line

Since the communication is asynchronous, synchronization is achieved using **Start** and **Stop** bits.

---

# UART Frame Format

A UART frame consists of:

```

| Start | Data | Optional Parity | Stop |

```

Example (8 Data Bits, No Parity, 1 Stop Bit)

```

Idle  Start      Data (LSB First)          Stop
____    _     _ _ _ _ _ _ _ _              ______
    |__| |_|_| |_| |_| |_| |_| |__________|

```

Frame Components

| Field | Description |
|-------|-------------|
| Start Bit | Logic 0 indicating beginning of frame |
| Data Bits | 5, 6, 7 or 8 bits |
| Parity Bit | Optional error detection |
| Stop Bits | 1 or 2 logic-high bits |

---

# Baud Rate

The baud rate defines the number of transmitted symbols per second.

Common baud rates include:

- 9600
- 19200
- 38400
- 57600
- 115200

The baud period is

```

Bit Time = 1 / Baud Rate

```

Example

For 115200 baud,

```

Bit Time ≈ 8.68 µs

```

---

# UART Transmitter

The transmitter converts parallel data into a serial stream.

Operation:

1. Wait for `tx_start`
2. Send Start bit
3. Send data bits (LSB first)
4. Send parity bit (optional)
5. Send Stop bit(s)
6. Return to Idle

---

# UART Receiver

The receiver converts serial data back into parallel form.

Operation:

1. Detect Start bit
2. Confirm Start bit at its center
3. Sample each data bit
4. Verify parity (optional)
5. Verify Stop bit(s)
6. Assert `rx_done`

---

# 16× Oversampling

Instead of sampling only once per bit, the receiver samples each bit sixteen times.

Advantages:

- Improved noise immunity
- Better timing tolerance
- Reduced bit errors
- Reliable start-bit validation

The receiver samples near the middle of each bit (approximately the 8th sample).

---

# Baud Rate Generator

The baud rate generator divides the system clock into:

- Baud Tick (1×)
- Sample Tick (16×)

Baud Tick drives the transmitter.

Sample Tick drives the receiver.

---

# UART Core Architecture

```

                +----------------------+
                | Baud Rate Generator  |
                +----------+-----------+
                           |
          +----------------+----------------+
          |                                 |
      baud_tick                       sample_tick
          |                                 |
          v                                 v
    +-------------+                  +-------------+
    | UART_TX     |                  | UART_RX     |
    +------+------+                  +------+------+
           |                                |
           +------------- TX ----------------+
                         |
                        RX
                         |
                  Received Data

```

---

# Features Implemented

- Synthesizable Verilog-2001
- Configurable baud rate
- Configurable data width (5/6/7/8)
- None / Even / Odd parity
- 1 or 2 stop bits
- 16× oversampling receiver
- Busy flag
- Parity error detection
- Framing error detection
- Modular architecture
- Top-level UART Core

---

# Verification

The UART Core was verified using a loopback configuration.

```

UART_TX -----> UART_RX

```

The following configurations were tested:

- 8-bit, No Parity, 1 Stop Bit
- 8-bit, Even Parity, 1 Stop Bit
- 8-bit, Odd Parity, 2 Stop Bits

All tests successfully transmitted and received data with no parity or framing errors.

---

# Future Enhancements

- TX FIFO
- RX FIFO
- APB3 Interface
- Register File
- Interrupt Controller
- SoC Integration