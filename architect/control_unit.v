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
            ALUControl  = 'b0000; // +
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
            ALUControl  = 'b0001; // &
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
            ALUControl  = 'b0011; // <
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
            ALUControl  = 'b0111; // <<
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end else if ( inst [14:12] == 'b001 ) // srl
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b1000; // >>
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
            ALUControl  = 'b0010; // -
            ALUSrc      = 'b0;
            immControl  = 'b001; // R
            BranchLui   = 'b0;
            Auipc       = 'b0;
            end else if ( inst [14:12] == 'b001 ) // sra
            begin 
            BranchBeq   = 'b0;
            BranchJal   = 'b0;
            BranchJalr  = 'b0;
            RegWrite    = 'b1;
            MemToReg    = 'b0;
            MemWrite    = 'b0;
            ALUControl  = 'b0110; // >>>
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
            ALUControl  = 'b0100; // /
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
            ALUControl  = 'b0101; // %
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
        ALUControl  = 'b0000; // +
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
        ALUControl  = 'b0010; // -
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
        ALUControl  = 'b0011; // <
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
        MemToReg    = 'b0;
        MemWrite    = 'b0;
        ALUControl  = 'b0000; // +
        ALUSrc      = 'b0;
        immControl  = 'b010;  // I
        BranchLui   = 'b0;
        Auipc       = 'b0;
    end else if ( inst [6:0] == 'b0100011 ) // sw
     begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b0;
        MemToReg    = 'b0;
        MemWrite    = 'b1;
        ALUControl  = 'b0000; // +
        ALUSrc      = 'b0;
        immControl  = 'b011;  // S
        BranchLui   = 'b0;
        Auipc       = 'b0;
    end else if ( inst [6:0] == 'b0110111 ) // lui
      begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b0;
        RegWrite    = 'b0;
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
        ALUControl  = 'b0000; // +
        ALUSrc      = 'b1;
        immControl  = 'b010;  // I
        BranchLui   = 'b0;
        Auipc       = 'b0;
    end else if ( inst [6:0] == 'b0010111 ) // auipc
      begin
        BranchBeq   = 'b0;
        BranchJal   = 'b0;
        BranchJalr  = 'b1;
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