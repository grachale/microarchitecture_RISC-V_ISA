module imm_decoder (
        input [31:7] inst,
        input [2:0]  immControl,

        output reg [31:0] imm
);

always @(*)

begin

    case ( immControl )

    'b001: imm = 0;               // R - type ( add, sub...)
    'b010: imm = { {21{inst [31]}}, inst [30:25], inst [24:21], inst [20] };    // I - type ( addi, lw, jalr... )
    'b011: imm = { {21{inst [31]}}, inst [30:25], inst [11:8], inst [7] }; // S - type
    'b100: imm = { {20{inst [31]}}, inst [7], inst [30:25], inst [11:8], 1'b0 }; // B  - type
    'b101: imm = { inst [31], inst [30:20], inst [19:12], {12{1'b0}} }; // U - type
    'b110: imm = { {12{inst[31]}}, inst [19:12], inst [20], inst [30:25], inst [24:21], 1'b0 }; // J - type 


    endcase;



end     


endmodule