`timescale 1ns / 1ps


module ControlUnit(
    input               clk,
    input               reset,
    input               iLe10,
    //
    output reg          rfsrcmuxsel,
    output reg          rfwe,
    output reg    [1:0] waddr,
    output reg    [1:0] raddr1,
    output reg    [1:0] raddr2,
    output reg          outLoad
    // output reg [1:0] alu_sel
    );
    localparam S0 = 3'd0;
    localparam S1 = 3'd1;
    localparam S2 = 3'd2;
    localparam S3 = 3'd3;
    localparam S4 = 3'd4;
    localparam S5 = 3'd5;
    localparam S6 = 3'd6;
    localparam HALT = 3'd7;
    reg [2:0] state,next_state;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= S0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            //S0: R1 = 0(i=0)
            S0: next_state = S1;
            // S1: R2 = 0(sum=0)
            S1: next_state = S2; 
            // S2: R2 = R2 + R1(sum = sum + i)
            S2: next_state = S3;
            //S3: R3 = 1(just one)
            S3: next_state = S4;
            //S4: R1 = R1 + R3(i = i + 1)
            S4: begin
                if(iLe10) next_state = S5;
                else next_state = HALT;
            end
            //S5: output=R2(output=sum)
            S5: next_state = S2;
        endcase
    end

    always @(*) begin
        // prevent latch
        rfsrcmuxsel = 1'd0;
        raddr1 = 2'd0;
        raddr2 = 2'd0;
        waddr = 2'd0;
        rfwe = 1'd0;
        outLoad = 1'd0;
        // asel = 0;
        case (state)
            S0:begin // R1 = 0(i=0)
                rfsrcmuxsel = 1'd0;
                raddr1      = 2'd0;
                raddr2      = 2'd0;
                waddr       = 2'd1;
                rfwe        = 1'd1;
                outLoad     = 1'd0;
            end 
            S1:begin // R2 = 0(sum=0)
                rfsrcmuxsel = 1'd0;
                raddr1      = 2'd0;
                raddr2      = 2'd0;
                waddr       = 2'd2;
                rfwe        = 1'd1;
                outLoad     = 1'd0;
            end
            S2:begin // R2 = R2 + R1(sum = sum + i)
                rfsrcmuxsel = 1'd0;
                raddr1      = 2'd2;
                raddr2      = 2'd1;
                waddr       = 2'd2;
                rfwe        = 1'd1;
                outLoad     = 1'd0;
            end
            S3: begin // R3 = 1(just one)
                rfsrcmuxsel = 1'd1;
                raddr1      = 2'd0;
                raddr2      = 2'd0;
                waddr       = 2'd3;
                rfwe        = 1'd1;
                outLoad     = 1'd0;
            end
            S4:begin // R1 = R1 + R3(i= i + 1)
                rfsrcmuxsel = 1'd0;
                raddr1      = 2'd1;
                raddr2      = 2'd3;
                waddr       = 2'd1;
                rfwe        = 1'd1;
                outLoad     = 1'd0;
            end
            S5: begin // output=R2(output=sum)
                rfsrcmuxsel = 1'd0;
                raddr1      = 2'd2;
                raddr2      = 2'd0;
                waddr       = 2'd0;
                rfwe        = 1'd0;
                outLoad     = 1'd1;
            end
            HALT: begin
                rfsrcmuxsel = 1'd0;
                raddr1      = 2'd0;
                raddr2      = 2'd0;
                waddr       = 2'd0;
                rfwe        = 1'd0;
                outLoad     = 1'd0;
            end
        endcase
    end
endmodule
