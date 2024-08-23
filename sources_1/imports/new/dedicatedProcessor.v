`timescale 1ns / 1ps

module dedicatedProcessor(
    input clk,
    input reset,
    output [7:0] outport
    );

    wire iLe10;
    wire w_rfsrcmuxsel;
    wire w_rfwe;
    wire [2:0] waddr;
    wire [2:0] raddr1;
    wire [2:0] raddr2;
    wire outLoad;

    // wire sumSrcMuxSel;
    // wire iSrcMuxSel;
    // wire sumLoad;
    // wire iLoad;
    // wire outLoad;
    // wire adderSrcMuxSel;
    
    ControlUnit U_CU(
    .clk(clk),
    .reset(reset),
    .iLe10(iLe10),
    //
    .rfsrcmuxsel(w_rfsrcmuxsel),
    .rfwe(w_rfwe),
    .waddr(waddr),
    .raddr1(raddr1),
    .raddr2(raddr2),
    .outLoad(outLoad)
    // output reg [1:0] alu_sel
    );

    DataPath U_DP(
        .clk(clk),
        .reset(reset),
	    .rfsrcmuxsel(w_rfsrcmuxsel),
        .rfwe(w_rfwe),
        .waddr(waddr),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .outLoad(outLoad),
        //
        .iLe10(iLe10),
        .outport(outport)
    );
endmodule


