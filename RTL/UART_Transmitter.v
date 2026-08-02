`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Bhuvika
// Module Name: UART_TX
// Description:
// Configurable UART Transmitter
// Features:
//  - 5/6/7/8 Data Bits
//  - None / Even / Odd Parity
//  - 1 / 2 Stop Bits
//  - Baud Tick Driven
//  - Busy Flag
//  - Two State FSM
//////////////////////////////////////////////////////////////////////////////////

module UART_TX #(  parameter DATA_WIDTH = 8)(
input clk,
input reset,
input baud_tick,
input tx_start,
input [DATA_WIDTH-1:0] tx_data,
// Configuration
input [2:0] data_bits,// 3'd5 = 5 bits  3'd6 = 6 bits   3'd7 = 7 bits   3'd8 = 8 bits
input [1:0] parity_type,// 00 = None  01 = Even  10 = Odd
input stop_bits,// 0 = 1 stop bit  1 = 2 stop bits
output reg tx,
output reg busy
);
// FSM STATES
localparam IDLE      = 1'b0;
localparam TRANSMIT  = 1'b1;
reg state;
// INTERNAL REGISTERS
reg [DATA_WIDTH-1:0] shift_reg;
reg [4:0] frame_count;
reg [3:0] data_length;// Current number of data bits
reg [4:0] frame_length;// Total frame length
reg parity_enable;
reg parity_bit;
// DATA LENGTH DECODER
always @(*) begin
    case(data_bits)
        3'd5:
            data_length = 5;
        3'd6:
            data_length = 6;
        3'd7:
            data_length = 7;
        default:
            data_length = 8;
    endcase
end
// FRAME LENGTH CALCULATION
// Frame:START  + DATA + PARITY + STOP
always @(*)
begin
    frame_length = 1 + data_length;//start bit
    if(parity_enable)
        frame_length = frame_length + 1;
    if(stop_bits)
        frame_length = frame_length + 2;
    else
        frame_length = frame_length + 1;
end
// PARITY GENERATOR
always @(*) begin
    case(parity_type)
        2'b00:
        begin
            parity_enable = 1'b0;
            parity_bit    = 1'b0;
        end
        2'b01:
        begin
            parity_enable = 1'b1;
            case(data_length)
                4'd5:
                    parity_bit = ^tx_data[4:0];
                4'd6:
                    parity_bit = ^tx_data[5:0];
                4'd7:
                    parity_bit = ^tx_data[6:0];
                default:
                    parity_bit = ^tx_data[7:0];
            endcase
        end
        2'b10:
        begin
            parity_enable = 1'b1;
            case(data_length)
                4'd5:
                    parity_bit = ~(^tx_data[4:0]);
                4'd6:
                    parity_bit = ~(^tx_data[5:0]);
                4'd7:
                    parity_bit = ~(^tx_data[6:0]);
                default:
                    parity_bit = ~(^tx_data[7:0]);
            endcase
        end
        default:
        begin
            parity_enable = 1'b0;
            parity_bit    = 1'b0;
        end
    endcase
end
// UART TRANSMITTER FSM
always @(posedge clk) begin
    if(reset)
    begin
        state       <= IDLE;
        tx          <= 1'b1;
        busy        <= 1'b0;
        shift_reg   <= {DATA_WIDTH{1'b0}};
        frame_count <= 5'd0;
    end
    else
    begin
        case(state)
        IDLE:// IDLE STATE
        begin
            tx          <= 1'b1;
            busy        <= 1'b0;
            frame_count <= 5'd0;
            if(tx_start)
            begin
                shift_reg <= tx_data;
                frame_count <= 5'd0;
                busy <= 1'b1;
                state <= TRANSMIT;
            end
        end
        TRANSMIT: // TRANSMIT STATE
        begin
            busy <= 1'b1;
            if(baud_tick)
            begin  
                if(frame_count == 0)// START BIT
                begin
                    tx <= 1'b0;
                    frame_count <= frame_count + 1'b1;
                end
                else if(frame_count <= data_length)// DATA BITS
                begin
                    tx <= shift_reg[0];
                    shift_reg <= shift_reg >> 1;
                    frame_count <= frame_count + 1'b1;
                end
                else if(parity_enable &&
                        frame_count == (data_length + 1))// PARITY BIT
                begin
                    tx <= parity_bit;
                    frame_count <= frame_count + 1'b1;
                end
                else if(frame_count >= (data_length + 1 + parity_enable))// STOP BIT(S)
                begin
                    tx <= 1'b1;
                    if(frame_count == frame_length-1) // LAST STOP BIT
                    begin
                        state <= IDLE;
                        busy <= 1'b0;
                        frame_count <= 5'd0;
                    end
                    else
                    begin
                        frame_count <= frame_count + 1'b1;
                    end
                end
            end   // baud_tick
        end       // TRANSMIT
        default:// DEFAULT SAFETY STATE
        begin
            state <= IDLE;
            tx <= 1'b1;
            busy <= 1'b0;
            frame_count <= 5'd0;
        end
        endcase
    end
end
endmodule