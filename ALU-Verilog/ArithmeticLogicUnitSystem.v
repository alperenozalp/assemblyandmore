`timescale 1ns / 1ps
module ArithmeticLogicUnitSystem(
    input [1:0] MuxASel,
    input [1:0] MuxBSel,
    input MuxCSel,
    input Clock,
    input [2:0] RF_OutASel, RF_OutBSel, RF_FunSel,
    input [3:0] RF_RegSel, RF_ScrSel,
    input [4:0] ALU_FunSel,
    input ALU_WF,
    input [1:0] ARF_OutCSel, ARF_OutDSel,
    input [2:0] ARF_FunSel, ARF_RegSel,
    input IR_LH, IR_Write, Mem_WR, Mem_CS,
    input [15:0] IROut

);
reg [15:0] MuxAOut;
reg [15:0] MuxBOut;
reg [7:0] MuxCOut;
wire [15:0] OutA, OutB; 
wire [15:0] OutC, Address;
wire [15:0] ALUOut;
wire [3:0] FlagsOut;
wire [7:0] MemOut;  

    RegisterFile RF(
        .OutASel(RF_OutASel),   .OutBSel(RF_OutBSel),
        .RegSel(RF_RegSel),     .ScrSel(RF_ScrSel),
        .FunSel(RF_FunSel),     .I(MuxAOut), 
        .Clock(Clock),
        .OutA(OutA),         .OutB(OutB)
        
    );
    AddressRegisterFile ARF(
        .OutCSel(ARF_OutCSel),  .OutDSel(ARF_OutDSel),
        .FunSel(ARF_FunSel),    .RegSel(ARF_RegSel),
        .Clock(Clock),          .I(MuxBOut),                
        .OutC(OutC),        .OutD(Address)
    );
    ArithmeticLogicUnit ALU(
        .A(OutA),        .B(OutB),
        .FunSel(ALU_FunSel),.WF(ALU_WF),
        .Clock(Clock),     .ALUOut(ALUOut), 
        .FlagsOut(FlagsOut)       
           
    );
    Memory MEM(
        .Address(Address), .Data(MuxCOut),
        .WR(Mem_WR),        .CS(Mem_CS),      
        .Clock(Clock),      .MemOut(MemOut)              
    );
    InstructionRegister IR(
        .LH(IR_LH),     .Write(IR_Write),
        .I(MemOut),     .Clock(Clock),
        .IROut(IROut)
    );
    
    always @(*) begin
        case(MuxASel)
            2'b00:  MuxAOut = ALUOut;
            2'b01:  MuxAOut = OutC;
            2'b10: begin  
            MuxAOut = MemOut;
            MuxAOut[15:8]=8'b00000000;
            end
            2'b11:  MuxAOut = IROut[7:0];
        endcase
        case(MuxBSel)
            2'b00:  MuxBOut = ALUOut;
            2'b01:  MuxBOut = OutC;
            2'b10: begin  MuxBOut = MemOut;
            MuxBOut[15:8]=8'b00000000;
            end
            2'b11:  MuxBOut = IROut[7:0];
        endcase  
        case(MuxCSel)
             2'b0:  MuxCOut=ALUOut[7:0];                   
             2'b1:  MuxCOut=ALUOut[15:8];               
        endcase
        
    end
endmodule
