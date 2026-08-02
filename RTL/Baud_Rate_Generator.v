`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Bhuvika
// Module Name: Baud_Rate_Generator
// Description:
// Generates:
// 1. baud_tick   : 1x baud rate tick (UART TX)
// 2. sample_tick : 16x oversampling tick (UART RX)
//////////////////////////////////////////////////////////////////////////////////

module Baud_Rate_Generator #(
    parameter integer CLK_FREQ    = 100_000_000,
    parameter integer OVERSAMPLE  = 16
)(
    input  wire       clk,
    input  wire       reset,
    input  wire [2:0] baud_sel,

    output reg        baud_tick,
    output reg        sample_tick
);
    //----------------------------------------------------------
    // Registers
    //----------------------------------------------------------
    reg [2:0]  baud_sel_prev;
    reg [31:0] baud_rate;
    reg [31:0] baud_divider;
    reg [31:0] oversample_divider;
    reg [31:0] baud_count;
    reg [31:0] oversample_count;
    //----------------------------------------------------------
    // Baud Rate Selection
    //----------------------------------------------------------
    always @(*) begin
        case (baud_sel)
            3'd0: baud_rate = 32'd9600;
            3'd1: baud_rate = 32'd19200;
            3'd2: baud_rate = 32'd38400;
            3'd3: baud_rate = 32'd57600;
            3'd4: baud_rate = 32'd115200;
            3'd5: baud_rate = 32'd230400;
            3'd6: baud_rate = 32'd460800;
            3'd7: baud_rate = 32'd921600;
            default: baud_rate = 32'd9600;
        endcase
    end
    //----------------------------------------------------------
    // Divider Calculation
    //----------------------------------------------------------
    always @(*) begin
        baud_divider       = CLK_FREQ / baud_rate;
        oversample_divider = CLK_FREQ / (baud_rate * OVERSAMPLE);
    end
    //----------------------------------------------------------
    // Counter & Tick Generation
    //----------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            baud_sel_prev <= baud_sel;
            baud_count        <= 32'd0;
            oversample_count  <= 32'd0;
            baud_tick         <= 1'b0;
            sample_tick       <= 1'b0;
        end
        // Restart counters if baud rate changes
        else if (baud_sel != baud_sel_prev) begin
            baud_count        <= 32'd0;
            oversample_count  <= 32'd0;
            baud_tick         <= 1'b0;
            sample_tick       <= 1'b0;
        end
        else begin
            //----------------------------
            // Baud Tick Generator (1x)
            //----------------------------
            if (baud_count == baud_divider - 1) begin
                baud_count <= 32'd0;
                baud_tick  <= 1'b1;
            end
            else begin
                baud_count <= baud_count + 1'b1;
                baud_tick  <= 1'b0;
            end
            //----------------------------
            // Sample Tick Generator (16x)
            //----------------------------
            if (oversample_count == oversample_divider - 1) begin
                oversample_count <= 32'd0;
                sample_tick      <= 1'b1;
            end
            else begin
                oversample_count <= oversample_count + 1'b1;
                sample_tick      <= 1'b0;
            end
        end
    end
endmodule