module top (	input         clk, reset,
		output [31:0] data_to_mem, address_to_mem,
		output        write_enable);

	wire [31:0] pc, instruction, data_from_mem;

	inst_mem  imem(pc[7:2], instruction);
	data_mem  dmem(clk, write_enable, address_to_mem, data_to_mem, data_from_mem);
	processor CPU(clk, reset, pc, instruction, write_enable, address_to_mem, data_to_mem, data_from_mem);
endmodule

//-------------------------------------------------------------------
module data_mem (input clk, we,
		 input  [31:0] address, wd,
		 output [31:0] rd);

	reg [31:0] RAM[63:0];

	initial begin
		$readmemh ("memfile_data.hex",RAM,0,63);
	end

	assign rd=RAM[address[31:2]]; // word aligned

	always @ (posedge clk)
		if (we)
			RAM[address[31:2]]<=wd;
endmodule

//-------------------------------------------------------------------
module inst_mem (input  [5:0]  address,
		 output [31:0] rd);

	reg [31:0] RAM[63:0];
	initial begin
		$readmemh ("memfile_inst.hex",RAM,0,63);
	end
	assign rd=RAM[address]; // word aligned
endmodule
`default_nettype none
module processor( input         clk, reset,
                  output [31:0] PC,
                  input  [31:0] instruction,
                  output        WE,
                  output [31:0] address_to_mem,
                  output [31:0] data_to_mem,
                  input  [31:0] data_from_mem
                );
    //... write your code here ...
wire [31:0] rs1, rs2;
// reg [31:0] four = 'b100;

wire BranchBeq; 
wire BranchJal;
wire BranchJalr;
wire RegWrite;
wire MemToReg;
wire MemWrite;
wire [3:0] ALUControl;
wire ALUSrc;
wire [2:0]immControl;
wire BranchLui;
wire Auipc;
wire [31:0] afterPlus;

wire [31:0] PCPlus4;

wire [31:0] BranchTarget;

wire [31:0] PCn;

wire BranchOutcome;
wire BranchJalx;

wire [31:0]ALUOut;
wire zero;
wire [31:0] ourPC;

wire [31:0] res;

wire [31:0] ImmOp;
wire [31:0] afterMux;
wire [31:0] toWD3;
wire [31:0] afterMuxImmRes;

wire [31:0] SrcA;
wire [31:0] SrcB;


BranchOutcomeM BranchOutcomeMXY ( BranchBeq, zero, BranchJalx, BranchOutcome );
BranchJalxM BranchJalxMXY ( BranchJalr, BranchJal, BranchJalx );



mux muxForPCn( PCPlus4[31:0], BranchTarget [31:0], BranchOutcome, PCn [31:0] );
regCLK regCLKForPC ( clk, reset, PCn[31:0], PC[31:0] );

assign ourPC = PC;

sum4 sumFour ( ourPC, PCPlus4[31:0] );

reg32 reg32XY (clk, RegWrite, instruction[19:15], instruction[24:20], instruction[11:7], toWD3[31:0], SrcA[31:0], rs2 );
imm_decoder imm_decoderXY ( instruction [31:7], immControl, ImmOp[31:0] );  
ControlUnit ControlUnitXY ( instruction[31:0], BranchBeq, BranchJal, BranchJalr, RegWrite, MemToReg, WE, ALUControl [3:0], ALUSrc, immControl [2:0], BranchLui, Auipc );


mux muxForAfterMuxImmRes ( res[31:0], ImmOp[31:0], BranchLui, afterMuxImmRes [31:0] );
mux muxForWD3 ( afterMuxImmRes [31:0], BranchTarget [31:0], Auipc, toWD3[31:0] );

assign data_to_mem = rs2;

mux muxForSrcB ( rs2, ImmOp[31:0], ALUSrc, SrcB[31:0]);

ALU ALUXY( SrcA[31:0], SrcB [31:0], ALUControl [3:0], address_to_mem[31:0], zero );
sum sumForAfterPlus ( ourPC, ImmOp[31:0], afterPlus[31:0] );

mux muxForBranchTarget ( afterPlus[31:0], address_to_mem[31:0], BranchJalr, BranchTarget[31:0] );


mux muxForAfterMux ( address_to_mem[31:0], PCPlus4[31:0], BranchJalx, afterMux[31:0] );


mux muxForRes ( afterMux[31:0], data_from_mem[31:0], MemToReg, res[31:0] );


endmodule

//... add new modules here ...


module BranchOutcomeM (
    input BranchBeq,
    input zero,
    input BranchJalx,

    output reg BranchOutcome

);

    always @ (*)
    begin
    BranchOutcome = ( ( BranchBeq & zero ) | BranchJalx);        
    end



endmodule

module BranchJalxM (
    input BranchJalr,
    input BranchJal,

    output reg BranchJalx

);

    always @ (*)
    begin
    BranchJalx = ( BranchJalr | BranchJal );       
    end



endmodule

module ALU (
    input  [31:0] SrcA, SrcB,
    input  [3:0] ALUControl,

    output reg [31:0] ALUResult,
    output reg zero
);


always @(*)
begin
    zero = 0;

    case ( ALUControl )

        'b0001: ALUResult = SrcA + SrcB;
        'b0010: ALUResult = SrcA & SrcB;
        'b0011: ALUResult = SrcA - SrcB;
        'b0100: ALUResult = $signed(SrcA) < $signed(SrcB);
        'b0101: ALUResult = SrcA / SrcB;
        'b0110: ALUResult = SrcA % SrcB;
        'b0111: ALUResult = SrcA >>> SrcB;
        'b1000: ALUResult = SrcA << SrcB;
        'b1001: ALUResult = SrcA >> SrcB;
        'b1111: ALUResult = 0;

    endcase;


    if ( ALUResult == 0 ) begin
        zero = 1;
    end

end

    
endmodule

module ControlUnit (
    input [31:0] inst,

    output reg BranchBeq, 
    output reg BranchJal,
    output reg BranchJalr,
    output reg RegWrite,
    output reg MemToReg,
    output reg MemWrite, 
    output reg [3:0] ALUControl,
    output reg ALUSrc,
    output reg [2:0]immControl,
    output reg BranchLui,
    output reg Auipc
);

always @(*)
begin 

    if (inst [6:0] == 'b0110011) // 9 instr
    begin
        if ( inst [31:25] == 'b0000000) // add, and, slt, sll, srl
        begin
            if ( inst [14:12] == 'b000 ) // add
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b0001; // +
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end else if ( inst [14:12] == 'b111 ) // and
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b0010; // &
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
             end else if ( inst [14:12] == 'b010 ) // slt
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b0100; // <
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end else if ( inst [14:12] == 'b001 ) // sll
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b1000; // <<
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end else if ( inst [14:12] == 'b101 ) // srl
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b1001; // >>
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end
        end else if ( inst [31:25] == 'b0100000 ) // sub, sra
        begin
            if ( inst [14:12] == 'b000 ) // sub
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b0011; // -
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end else if ( inst [14:12] == 'b101 ) // sra
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b0111; // >>>
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end
        end else if ( inst [31:25] == 'b0000001 ) // div, rem
        begin
            if ( inst [14:12] == 'b100 ) // div
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b0101; // /
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end else if ( inst [14:12] == 'b110 ) // rem
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b0110; // %
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end
        end

    end else if ( inst [6:0] == 'b0010011 ) // addi
    begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b1;
        MemToReg    = 'b0;
        MemWrite    = 'b0;
        ALUControl  = 'b0001; // +
        ALUSrc      = 'b1;
        immControl  = 'b010; // I
        BranchLui   = 'b0;
        Auipc       = 'b0;
    end else if ( inst [6:0] == 'b1100011 ) // beq, blt
    begin 
        if ( inst [14:12] == 'b000 )        // beq
        begin
        BranchBeq   = 'b1;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b0;
        MemToReg    = 'b0;
        MemWrite    = 'b0;
        ALUControl  = 'b0011; // -
        ALUSrc      = 'b0;
        immControl  = 'b100;  // B
        BranchLui   = 'b0;
        Auipc       = 'b0;
        end else if ( inst [14:12] == 'b100) // blt
        begin
        BranchBeq   = 'b1;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b0;
        MemToReg    = 'b0;
        MemWrite    = 'b0;
        ALUControl  = 'b0100; // <
        ALUSrc      = 'b0;
        immControl  = 'b100;  // B
        BranchLui   = 'b0;
        Auipc       = 'b0;
        end

    end else if ( inst [6:0]  == 'b0000011) // lw
    begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b1;
        MemToReg    = 'b1;
        MemWrite    = 'b0;
        ALUControl  = 'b0001; // +
        ALUSrc      = 'b1;
        immControl  = 'b010;  // I
        BranchLui   = 'b0;
        Auipc       = 'b0;
    end else if ( inst [6:0] == 'b0100011 ) // sw
     begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b0;
        MemToReg    = 'b1;
        MemWrite    = 'b1;
        ALUControl  = 'b0001; // +
        ALUSrc      = 'b1;
        immControl  = 'b011;  // S
        BranchLui   = 'b0;
        Auipc       = 'b0;
    end else if ( inst [6:0] == 'b0110111 ) // lui
      begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b1;
        MemToReg    = 'b0;
        MemWrite    = 'b0;
        ALUControl  = 'b1111; // nothing
        ALUSrc      = 'b0;
        immControl  = 'b101;  // U
        BranchLui   = 'b1;
        Auipc       = 'b0;
    end else if ( inst [6:0] == 'b1101111 ) // jal
      begin
        BranchBeq   = 'b0;
        BranchJal   = 'b1;
        BranchJalr  = 'b0;
        RegWrite    = 'b1;
        MemToReg    = 'b0;
        MemWrite    = 'b0;
        ALUControl  = 'b1111; // nothing
        ALUSrc      = 'b0;
        immControl  = 'b110;  // J
        BranchLui   = 'b0;
        Auipc       = 'b0;
     end else if ( inst [6:0] == 'b1100111 ) // jalr
      begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b1;
        RegWrite    = 'b1;
        MemToReg    = 'b0;
        MemWrite    = 'b0;
        ALUControl  = 'b0001; // +
        ALUSrc      = 'b1;
        immControl  = 'b010;  // I
        BranchLui   = 'b0;
        Auipc       = 'b0;
    end else if ( inst [6:0] == 'b0010111 ) // auipc
      begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b1;
        MemToReg    = 'b0;
        MemWrite    = 'b0;
        ALUControl  = 'b1111; // nothing
        ALUSrc      = 'b0;
        immControl  = 'b101;  // U
        BranchLui   = 'b0;
        Auipc       = 'b1;
        end  
end   
    
endmodule

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

initial 
registers [ 0 ] = 0;

always @ (*)
begin
    RD1[31:0] = registers [A1[4:0]];
    RD2[31:0] = registers [A2[4:0]];
end


always @(posedge CLK)
begin

    registers [0] = 0;  

    if (WE3)
    begin
        registers [A3[4:0]] = WD3[31:0];
    end
    registers [0] = 0; 
  

end
    
endmodule


module mux (
    input [31:0] srcA,
    input [31:0] srcB,
    input select,

    output reg [31:0] outMux
);

always @ (*)
begin
    

    if ( select == 1 )
    begin
        outMux = srcB;
    end else
    begin 
        outMux = srcA;
    end


end

    
endmodule

module regCLK (
    input CLK,
    input reset,
    input [31:0] src,

    output reg [31:0] dest
);


always @ (posedge CLK) begin
    dest = src;
    if (reset == 1)
        dest = 0;
end
    
endmodule


module sum (
    input [31:0] srcA,
    input [31:0] srcB,

    output [31:0] dest
    
);

assign dest = srcA + srcB;
    
endmodule

module sum4 (
    input [31:0] srcA,

    output [31:0] dest
    
);

assign dest = srcA + 4;
    
endmodule

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



`default_nettype wire