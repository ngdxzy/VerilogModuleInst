`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/07/07 09:44:03
// Design Name: 
// Module Name: Meta_Detector
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Meta_Detector#(
    parameter BB = 1
)(
    input clk,
    input shifting_clk,
    input reset,
    input dut_wire,

    output [15:0] Counts,
    output reg ready,
    input re
    );
    parameter AA = 1;
    localparam M = 16'd10000;

    reg [1:0] rising_detector;
    reg meta_reg;
    reg [1:0] meta_synchronizer;
    
    wire rising_edge;

    always @ (posedge shifting_clk) begin
        if(reset == 1) begin
            meta_reg <= 0;
        end
        else begin
            meta_reg <= dut_wire;
        end
    end

    always @ (posedge clk) begin
        if(reset == 1) begin
            meta_synchronizer <= 0;
        end
        else begin
            meta_synchronizer <= {meta_synchronizer[0], meta_reg};
        end
    end
    
    always @ (posedge clk) begin
        if(reset == 1) begin
            rising_detector <= 0;
        end
        else begin
            rising_detector <= {rising_detector[0],dut_wire};
        end
    end

    assign rising_edge = rising_detector == 2'b01;

            
    localparam IDLE = 4'd1;
    localparam CHECK = 4'd2;
    localparam LATCH = 4'd4;
    localparam CLR = 4'd8;

    reg [4-1 : 0] state,next_state;
    reg load;
    reg start;
    
    wire done;
    wire [31:0] P_out;
    reg [31:0] Probability;

    always @ (posedge clk) begin
        if(rst == 1) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end
    always @ (*) begin
        load = 0;
        start = 0;
        next_state = state
        case(state)
        IDLE:begin
            start = 0;
            next_state = CHECK;
        end
        CHECK:begin
            start = 1;
            if (done == 1'b1) begin
                next_state = LATCH;
            end
        end
        LATCH:begin
            load = 1;
            next_state = CLR;
        end
        CLR:begin
            start = 0;
            next_state = IDLE;
        end
        default:begin
            next_state = IDLE;
        end
        endcase
    end
    
    ETS_Adder inst_ETS_Adder(
        .clk(clk),
        .reset(reset),
        .Average(M),
        .data_in(meta_synchronizer[1]),
        .data(),
        .en_count(rising_edge),
        .start(start),
        .done(done)
    );
    
    always @ (posedge clk) begin
        if (reset == 1) begin
            Probability <= 0;
            ready <= 0;
        end
        else begin
            if (re == 1) begin
                ready <= 0;
            end
            else (load) begin
                Probability <= P_out[15:0];
                ready <= 1;
            end
        end
    end
endmodule
