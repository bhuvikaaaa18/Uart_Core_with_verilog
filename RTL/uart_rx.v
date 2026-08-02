`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Bhuvika
//
// Module Name: UART_RX
// Description: Configurable UART Receiver with 16x Oversampling
//////////////////////////////////////////////////////////////////////////////////

module UART_RX #(parameter DATA_WIDTH = 8)
(
    input clk,
    input reset,
    input sample_tick,
    input rx,

    input [2:0] data_bits,
    input [1:0] parity_type,
    input stop_bits,

    output reg [DATA_WIDTH-1:0] rx_data,
    output reg rx_done,
    output reg busy,
    output reg parity_error,
    output reg framing_error
);

//================ FSM =================//

localparam IDLE    = 1'b0;
localparam RECEIVE = 1'b1;

reg state;

//================ Synchronizer =================//

reg rx_sync1;
reg rx_sync2;
reg rx_prev;

//================ Registers =================//

reg [DATA_WIDTH-1:0] shift_reg;

reg [3:0] sample_count;
reg [4:0] frame_count;

reg [3:0] data_length;
reg [4:0] frame_length;

reg parity_enable;
reg received_parity;
reg calculated_parity;

//================ RX Synchronizer =================//

always @(posedge clk)
begin
    if(reset)
    begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
        rx_prev  <= 1'b1;
    end
    else
    begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
        rx_prev  <= rx_sync2;
    end
end

//================ Configuration =================//

always @(*)
begin
    case(data_bits)
        3'd5: data_length = 5;
        3'd6: data_length = 6;
        3'd7: data_length = 7;
        default: data_length = 8;
    endcase
end

always @(*)
begin
    parity_enable = (parity_type != 2'b00);

    frame_length = 1 + data_length;

    if(parity_enable)
        frame_length = frame_length + 1;

    if(stop_bits)
        frame_length = frame_length + 2;
    else
        frame_length = frame_length + 1;
end

//================ UART Receiver =================//

always @(posedge clk)
begin

    if(reset)
    begin
        state            <= IDLE;
        busy             <= 1'b0;
        rx_done          <= 1'b0;

        parity_error     <= 1'b0;
        framing_error    <= 1'b0;

        shift_reg        <= {DATA_WIDTH{1'b0}};
        rx_data          <= {DATA_WIDTH{1'b0}};

        frame_count      <= 5'd0;
        sample_count     <= 4'd0;

        received_parity  <= 1'b0;
        calculated_parity<= 1'b0;
    end

    else
    begin

        rx_done <= 1'b0;

        case(state)

        //--------------------------------------------------
        // IDLE
        //--------------------------------------------------

        IDLE:
        begin

            busy          <= 1'b0;
            frame_count   <= 5'd0;
            sample_count  <= 4'd0;

            parity_error  <= 1'b0;
            framing_error <= 1'b0;

            // Detect falling edge of start bit

            if(rx_prev && !rx_sync2)
            begin
                state <= RECEIVE;
                busy  <= 1'b1;
            end

        end

        //--------------------------------------------------
        // RECEIVE
        //--------------------------------------------------

        RECEIVE:
        begin

            busy <= 1'b1;

            if(sample_tick)
            begin

                //--------------------------------------------------
                // START BIT
                //--------------------------------------------------

                if(frame_count == 0)
                begin

                    if(sample_count == 7)
                    begin

                        if(rx_sync2 == 1'b0)
                        begin
                            frame_count  <= 1;
                            sample_count <= 0;
                        end
                        else
                        begin
                            state        <= IDLE;
                            busy         <= 1'b0;
                            frame_count  <= 0;
                            sample_count <= 0;
                        end

                    end
                    else
                    begin
                        sample_count <= sample_count + 1'b1;
                    end

                end

                //--------------------------------------------------
                // RECEIVE DATA
                //--------------------------------------------------

                else if(frame_count <= data_length)
                begin

                    if(sample_count == 15)
                    begin

                        shift_reg[frame_count-1] <= rx_sync2;

                        frame_count  <= frame_count + 1'b1;
                        sample_count <= 4'd0;

                    end
                    else
                    begin
                        sample_count <= sample_count + 1'b1;
                    end

                end
                                //--------------------------------------------------
                // RECEIVE PARITY
                //--------------------------------------------------

                else if(parity_enable && (frame_count == (data_length + 1)))
                begin
                    if(sample_count == 15)
                    begin
                        received_parity <= rx_sync2;
                        frame_count <= frame_count + 1'b1;
                        sample_count <= 4'd0;
                    end
                    else
                    begin
                        sample_count <= sample_count + 1'b1;
                    end
                end

                //--------------------------------------------------
                // STOP BIT(S)
                //--------------------------------------------------

                else if(frame_count >= (data_length + 1 + parity_enable))
                begin
                    if(sample_count == 15)
                    begin

                        if(rx_sync2 != 1'b1)
                            framing_error <= 1'b1;

                        if(frame_count == (frame_length - 1))
                        begin

                            if(parity_enable)
                            begin
                                case(parity_type)
                                    2'b01:
                                    begin
                                        case(data_length)
                                            4'd5: calculated_parity = ^shift_reg[4:0];
                                            4'd6: calculated_parity = ^shift_reg[5:0];
                                            4'd7: calculated_parity = ^shift_reg[6:0];
                                            default: calculated_parity = ^shift_reg[7:0];
                                        endcase
                                    end

                                    2'b10:
                                    begin
                                        case(data_length)
                                            4'd5: calculated_parity = ~(^shift_reg[4:0]);
                                            4'd6: calculated_parity = ~(^shift_reg[5:0]);
                                            4'd7: calculated_parity = ~(^shift_reg[6:0]);
                                            default: calculated_parity = ~(^shift_reg[7:0]);
                                        endcase
                                    end

                                    default:
                                        calculated_parity = 1'b0;
                                endcase

                                if(calculated_parity != received_parity)
                                    parity_error <= 1'b1;
                            end

                            rx_data <= shift_reg;
                            rx_done <= 1'b1;
                            busy <= 1'b0;
                            frame_count <= 5'd0;
                            sample_count <= 4'd0;
                            state <= IDLE;

                        end
                        else
                        begin
                            frame_count <= frame_count + 1'b1;
                            sample_count <= 4'd0;
                        end
                    end
                    else
                    begin
                        sample_count <= sample_count + 1'b1;
                    end
                end

            end
        end

        //--------------------------------------------------
        // DEFAULT
        //--------------------------------------------------

        default:
        begin
            state <= IDLE;
            busy <= 1'b0;
            rx_done <= 1'b0;
            parity_error <= 1'b0;
            framing_error <= 1'b0;
            frame_count <= 5'd0;
            sample_count <= 4'd0;
            shift_reg <= {DATA_WIDTH{1'b0}};
        end

        endcase
    end
end

endmodule