module regCLK (
    input CLK,
    input reset,
    input [31:0] src,

    output [31:0] dest
);

reg [31:0] register;

assign dest = register;

always @ (posedge CLK)
    register = src;

always @ (*)
    if (reset == 1)
        register = 0;

    
endmodule