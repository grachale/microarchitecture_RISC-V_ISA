module sum (
    input [31:0] srcA,
    input [31:0] srcB,

    output [31:0] dest
    
);

assign dest = srcA + srcB;
    
endmodule