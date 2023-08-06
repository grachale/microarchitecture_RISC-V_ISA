module ALU (
    input  [31:0] SrcA, SrcB,
    input  [3:0] ALUControl,

    output reg [31:0] ALUResult,
    output reg zero
);

always @(*)
begin

    case ( ALUControl )

        0000: ALUResult = SrcA + SrcB;
        0001: ALUResult = SrcA & SrcB;
        0010: ALUResult = SrcA - SrcB;
        0011: ALUResult = SrcA < SrcB;
        0100: ALUResult = SrcA / SrcB;
        0101: ALUResult = SrcA % SrcB;
        0110: ALUResult = SrcA >>> SrcB;
        0111: ALUResult = SrcA << SrcB;
        1000: ALUResult = SrcA >> SrcB;

    endcase;
    zero = 0;
    if ( ALUResult == 0 ) begin
        zero = 1;
    end

end

    
endmodule