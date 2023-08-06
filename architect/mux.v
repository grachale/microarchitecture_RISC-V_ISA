module mux (
    input [31:0] srcA,
    input [31:0] srcB,
    input select,

    output reg [31:0] outMux
);

always @ (*)
begin
    outMux = srcA;

    if ( select )
    begin
        outMux = srcB;
    end 


end

    
endmodule