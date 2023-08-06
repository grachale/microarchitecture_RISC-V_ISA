module reg32 (
    input CLK,
    input WE3,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,

    output reg [31:0] RD1,
    output reg [31:0] RD2

);

reg [31:0] registers [31:0];
registers [0] = 0;    

always @(posedge CLK)
begin

    RD1[31:0] = registers [A1[4:0]];
    RD2[31:0] = registers [A2[4:0]];


    if (WE3)
    begin
        registers [A3[4:0]] = WD3[31:0];
    end
    


end
    
endmodule