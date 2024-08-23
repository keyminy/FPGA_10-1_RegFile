`timescale 1ns / 1ps


module DataPath (
    input clk,
    input reset,
    // input sumsrcmuxsel,
	input rfsrcmuxsel,
    input rfwe,
    input [1:0] waddr,
    input [1:0] raddr1,
    input [1:0] raddr2,
    input outLoad,
    output iLe10,
    output [7:0] outport
);
    wire [7:0] w_adderresult;
    wire [7:0] w_rfsrcmuxout, w_rfreaddata1, w_rfreaddata2;

    mux_2x1 U_regSrcMuxsel (
        .sel(rfsrcmuxsel),
        .x0 (w_adderresult),
        .x1 (8'b1),
        .y  (w_rfsrcmuxout)
    );
    registerFile U_rf (
        .clk(clk),
        .we(rfwe),
        .waddr(waddr),
        .raddr1(raddr1),
        .raddr2(raddr2),
        .wdata(w_rfsrcmuxout),
        //
        .rdata1(w_rfreaddata1),
        .rdata2(w_rfreaddata2)
    );

    comparator U_iLe10 (
        .a (w_rfreaddata1),
        .b (8'd10),
        .le(iLe10)
    );

    adder U_adder (
        .a(w_rfreaddata1),
        .b(w_rfreaddata2),
        .y(w_adderresult)
    );

    register U_outreg (
        .clk(clk),
        .reset(reset),
        .load(outLoad),
        .d(w_adderresult),
        .q(outport)
    );

endmodule


module registerFile (
    input             clk,
    input             we,
    input       [1:0] waddr,
    input       [1:0] raddr1,
    input       [1:0] raddr2,
    input       [7:0] wdata,
    //
    output      [7:0] rdata1,
    output      [7:0] rdata2
);
    reg [7:0] regFile[0:3];


    always @(posedge clk) begin
        if(we) regFile[waddr] <= wdata;
    end
 
    assign rdata1 = (raddr1 != 0) ? regFile[raddr1] : 8'b0;
    assign rdata2 = (raddr2 != 0) ? regFile[raddr2] : 8'b0;
    
endmodule

module mux_2x1 (
    input             sel,
    input       [7:0] x0,
    input       [7:0] x1,
    output reg  [7:0] y
);
    always @(*) begin
        case (sel)
            1'b0: y = x0; 
            1'b1: y = x1; 
        endcase
    end
endmodule

module register (
    input             clk,
    input             reset,
    input             load,
    input       [7:0] d,
    output reg  [7:0] q
);
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            q <= 0;
        end else begin
            if(load) q <= d;
            else q <= q; // remain 자기 자신
        end
    end
endmodule

module comparator (
    input       [7:0] a,
    input       [7:0] b,
    output            le
);
    assign le = (a <= b)? 1 : 0;
endmodule

module adder (
    input  [7:0] a,
    input  [7:0] b,
    output [7:0] y
);
    assign y = a+b;
endmodule

