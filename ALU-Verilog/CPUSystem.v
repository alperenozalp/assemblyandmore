`timescale 1ns / 1ps
module CPUSystem(input Clock,input Reset,output [7:0] T);
wire SC_Reset;
wire [15:0] timer;
wire [2:0] ARF_FunSel;
wire [2:0] ARF_RegSel;
wire [1:0] ARF_OutCSel;
wire [1:0] ARF_OutDSel;
wire [2:0] RF_OutASel;
wire [2:0] RF_OutBSel;
wire [2:0] RF_FunSel;
wire [3:0] RF_ScrSel;
wire [3:0] RF_RegSel;
wire [1:0] MuxASel;
wire [1:0] MuxBSel;
wire MuxCSel;
wire Mem_CS;
wire Mem_WR;
wire IR_LH;
wire IR_Write;
wire [15:0] IROut;
wire [63:0]decoded_OpCode;
wire [1:0] RSEL;
wire S;
wire [2:0] SREG1;
wire [2:0] SREG2;
wire [2:0] DSTREG;
wire [3:0] ALU_Flags;
wire [4:0] ALU_FunSel;
wire Flags_WF;
assign T=timer[7:0];

Sequence_Counter SC(.Clock(Clock),.Reset(SC_Reset),.timer(timer));

OpCode_decode decoder(.timer(timer),.IR(IROut),.OpCode(IROut[15:10]),
.decoded_OpCode(decoded_OpCode),.RSel(RSEL),.S(S),.DSTREG(DSTREG),.SREG1(SREG1),.SREG2(SREG2),.Clock(Clock));

execute executer(.MuxCSel(MuxCSel),.MuxBSel(MuxBSel),
.MuxASel(MuxASel),.timer(timer),.D(decoded_OpCode),.ALU_Flags(ALU_Flags),
.ALU_FunSel(ALU_FunSel),.Flags_WF(Flags_WF),.RSEL(RSEL),.SC_Reset(SC_Reset),
.RF_OutASel(RF_OutASel),.RF_OutBSel(RF_OutBSel),.RF_FunSel(RF_FunSel),
.RF_ScrSel(RF_ScrSel),.RF_RegSel(RF_RegSel),.Mem_WR(Mem_WR),.Mem_CS(Mem_CS),
.DSTREG(DSTREG),.SREG1(SREG1),.SREG2(SREG2),.S(S),.Clock(Clock),.ARF_OutCSel(ARF_OutCSel),
.ARF_OutDSel(ARF_OutDSel),.ARF_FunSel(ARF_FunSel),.ARF_RegSel(ARF_RegSel));

ArithmeticLogicUnitSystem _ALUSystem(.RF_OutASel(RF_OutASel),.RF_OutBSel(RF_OutBSel),
.RF_FunSel(RF_FunSel),.RF_ScrSel(RF_ScrSel),.RF_RegSel(RF_RegSel),.ARF_OutCSel(ARF_OutCSel),
.ARF_OutDSel(ARF_OutDSel),.ARF_FunSel(ARF_FunSel),.ARF_RegSel(ARF_RegSel),.ALU_FunSel(ALU_FunSel),
.ALU_WF(Flags_WF),.IR_LH(IR_LH),.IR_Write(IR_Write),.Mem_WR(Mem_WR),.Mem_CS(Mem_CS),.MuxASel(MuxASel),
.MuxBSel(MuxBSel),.MuxCSel(MuxCSel),.Clock(Clock),.IROut(IROut));

fetch fetch(.timer(timer),.ARF_FunSel(ARF_FunSel),.ARF_RegSel(ARF_RegSel),.OutCSel(OutCSel),
.OutDSel(OutDSel),.Mem_CS(Mem_CS),.Mem_WR(Mem_WR),.IR_LH(IR_LH),.IR_Write(IR_Write),.Clock(Clock));
assign ALU_Flags[3:0]=_ALUSystem.ALU.FlagsOut[3:0];

always@(negedge Reset)begin
    _ALUSystem.ARF.PC.Q=16'd0;
    _ALUSystem.ARF.AR.Q=16'd0;
    _ALUSystem.ARF.SP.Q=16'd0;
    _ALUSystem.RF.R1.Q=16'd0;
    _ALUSystem.RF.R2.Q=16'd0;
    _ALUSystem.RF.R3.Q=16'd0;
    _ALUSystem.RF.R4.Q=16'd0;
    _ALUSystem.RF.S1.Q=16'd0;
    _ALUSystem.RF.S2.Q=16'd0;
    _ALUSystem.RF.S3.Q=16'd0;
    _ALUSystem.RF.S4.Q=16'd0;
end
endmodule


module fetch(
    input wire [15:0] timer,
    output reg [2:0] ARF_FunSel,
    output reg [2:0] ARF_RegSel,
    output reg [1:0] OutCSel,
    output reg [1:0] OutDSel,
    output reg Mem_CS,
    output reg Mem_WR,
    output reg IR_LH,
    output reg IR_Write,
    input wire Clock
);
    always @(posedge Clock)    
    begin
        if(timer[0])
        begin
            OutDSel <= 2'b10;
            OutCSel <= 2'bZZ;
            Mem_CS <= 1'b0;
            Mem_WR <= 1'b0;
            IR_LH <= 1'b0;
            IR_Write <= 1'b1;
            ARF_RegSel <= 3'b101;
            ARF_FunSel <= 3'b001; 
        end
         if(timer[1])
               begin
               OutDSel <= 2'b10;
               OutCSel <= 2'bZZ;
               Mem_CS <= 1'b0;
               Mem_WR <= 1'b0;
               IR_LH <= 1'b1;
               IR_Write <= 1'b1;
               ARF_RegSel <= 3'b101; 
        end
        end
endmodule
module OpCode_decode(
    input wire [15:0] timer,
    input [15:0] IR,    
    input wire [5:0] OpCode,
    output reg [63:0] decoded_OpCode,
    output reg [1:0] RSel,
    output reg S,
    output reg [2:0] DSTREG,
    output reg [2:0] SREG1,
    output reg [2:0] SREG2,
    input wire Clock
);

always @(*) begin
    if (1) begin
        case (OpCode)
        6'h00: decoded_OpCode = 64'h0000000000000001;
        6'h01: decoded_OpCode = 64'h0000000000000002;
        6'h02: decoded_OpCode = 64'h0000000000000004;
        6'h03: decoded_OpCode = 64'h0000000000000008;
        6'h04: decoded_OpCode = 64'h0000000000000010;
        6'h05: decoded_OpCode = 64'h0000000000000020;
        6'h06: decoded_OpCode = 64'h0000000000000040;
        6'h07: decoded_OpCode = 64'h0000000000000080;
        6'h08: decoded_OpCode = 64'h0000000000000100;
        6'h09: decoded_OpCode = 64'h0000000000000200;
        6'h0A: decoded_OpCode = 64'h0000000000000400;
        6'h0B: decoded_OpCode = 64'h0000000000000800;
        6'h0C: decoded_OpCode = 64'h0000000000001000;
        6'h0D: decoded_OpCode = 64'h0000000000002000;
        6'h0E: decoded_OpCode = 64'h0000000000004000;
        6'h0F: decoded_OpCode = 64'h0000000000008000;
        6'h10: decoded_OpCode = 64'h0000000000010000;
        6'h11: decoded_OpCode = 64'h0000000000020000;
        6'h12: decoded_OpCode = 64'h0000000000040000;
        6'h13: decoded_OpCode = 64'h0000000000080000;
        6'h14: decoded_OpCode = 64'h0000000000100000;
        6'h15: decoded_OpCode = 64'h0000000000200000;
        6'h16: decoded_OpCode = 64'h0000000000400000;
        6'h17: decoded_OpCode = 64'h0000000000800000;
        6'h18: decoded_OpCode = 64'h0000000001000000;
        6'h19: decoded_OpCode = 64'h0000000002000000;
        6'h1A: decoded_OpCode = 64'h0000000004000000;
        6'h1B: decoded_OpCode = 64'h0000000008000000;
        6'h1C: decoded_OpCode = 64'h0000000010000000;
        6'h1D: decoded_OpCode = 64'h0000000020000000;
        6'h1E: decoded_OpCode = 64'h0000000040000000;
        6'h1F: decoded_OpCode = 64'h0000000080000000;
        6'h20: decoded_OpCode = 64'h0000000100000000;
        6'h21: decoded_OpCode = 64'h0000000200000000;           
        default: decoded_OpCode = 64'hXXXXXXXXXXXXXXX;
        endcase
        
    end
    else begin
        decoded_OpCode = 64'dX; 
    end
        
   if (timer[2]) begin
      if (decoded_OpCode[0] || decoded_OpCode[1]|| decoded_OpCode[2] || decoded_OpCode[3] || decoded_OpCode[4] || decoded_OpCode[18] || decoded_OpCode[19] || decoded_OpCode[30] || decoded_OpCode[31] || decoded_OpCode[32] || decoded_OpCode[33] == 1 )
        begin
            RSel <= IR[9:8];
       end
       else begin
                S <= IR[9];
                DSTREG <= IR[8:6];
                SREG1 <= IR[5:3];
                SREG2 <= IR[2:0];
            end
        end
    end
endmodule

module Sequence_Counter(input Clock, input Reset,output reg [15:0] timer);
    
  always @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            timer = 16'h0000; // Reset the counter to 0
        end
        else begin
            if (timer == 16'hFFFF) begin
                timer <= 16'h0000; 
            end
            else begin
                timer <= timer + 1; // Increment the counter
            end
        end
    end
   
endmodule

module execute(

    input [15:0] timer,
    input[2:0] DSTREG, SREG1, SREG2,
    input [1:0] RSEL,
    input S, Clock, 
    input[63:0] D,
    
    output reg [3:0] ALU_Flags,
    output reg [1:0] ARF_OutCSel, ARF_OutDSel,
    output reg MuxCSel,
    output reg [1:0]  MuxBSel, MuxASel,
    output reg [4:0] ALU_FunSel,
    output reg Flags_WF,
    output reg [2:0] RF_OutASel, RF_OutBSel,
    output reg [2:0] RF_FunSel,
    output reg [3:0] RF_ScrSel, RF_RegSel,
    output reg Mem_WR, Mem_CS,
    output reg [3:0] ARF_FunSel,
    output reg [3:0] ARF_RegSel,
    output reg  SC_Reset,
    output reg ALU_WF
);

always @(*) begin
    case(D)
        64'h0000000000000020||64'h0000000000000040:begin //Increment and Decrement
            //Load to PC and Increment
            if(DSTREG==3'b000&&SREG1==3'b000)begin        
                if(timer[2])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b001)begin        
                if(timer[2])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b010)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxBSel=2'b01;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b011)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxBSel=2'b01;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b100)begin        
                if(timer[2])begin
                    RF_OutASel=3'b000;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b101)begin        
                if(timer[2])begin
                    RF_OutASel=3'b001;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b110)begin        
                if(timer[2])begin
                    RF_OutASel=3'b010;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b111)begin        
                if(timer[2])begin
                    RF_OutASel=3'b011;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            //Load to PC and Increment
            if(DSTREG==3'b001&&SREG1==3'b000)begin        
                if(timer[2])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b001)begin        
                if(timer[2])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b010)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxBSel=2'b01;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b011)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxBSel=2'b01;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b100)begin        
                if(timer[2])begin
                    RF_OutASel=3'b000;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b101)begin        
                if(timer[2])begin
                    RF_OutASel=3'b001;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b110)begin        
                if(timer[2])begin
                    RF_OutASel=3'b010;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b111)begin        
                if(timer[2])begin
                    RF_OutASel=3'b011;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b011;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            //Load to SP and Increment
            if(DSTREG==3'b010&&SREG1==3'b000)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxBSel=2'b01;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b110;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b001)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxBSel=2'b01;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b110;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b010)begin        
                if(timer[2])begin
                    ARF_RegSel=3'b110;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b011)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxBSel=2'b01;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b110;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b100)begin        
                if(timer[2])begin
                    RF_OutASel=3'b000;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b110; 
                end
                if(timer[3])begin
                    ARF_RegSel=3'b110;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b101)begin        
                if(timer[2])begin
                    RF_OutASel=3'b001;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b110;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b110;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b110)begin        
                if(timer[2])begin
                    RF_OutASel=3'b010;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b110;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b110;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b111)begin        
                if(timer[2])begin
                    RF_OutASel=3'b011;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b110;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b110;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            //Load to AR and Increment
            if(DSTREG==3'b011&&SREG1==3'b000)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxBSel=2'b01;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b101;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b001)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxBSel=2'b01;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b101;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b010)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxBSel=2'b01;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b101;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b011)begin        
                if(timer[3])begin
                    ARF_RegSel=3'b101;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b100)begin        
                if(timer[2])begin
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b101; 
                end
                if(timer[3])begin
                    ARF_RegSel=3'b101;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b101)begin        
                if(timer[2])begin
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b101;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b101;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b110)begin        
                if(timer[2])begin
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b101;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b101;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b111)begin        
                if(timer[2])begin
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b101;
                end
                if(timer[3])begin
                    ARF_RegSel=3'b101;
                    if(64'h0000000000000020)
                        ARF_FunSel=3'b001;
                    else
                        ARF_FunSel=3'b000;
                end
            end
            //Load to R1 and Increment
            if(DSTREG==3'b100&&SREG1==3'b000)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b0111;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b001)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b0111;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b010)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b0111;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b011)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b0111;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b100)begin        
                if(timer[2])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b0111;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b101)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b0111;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b0111;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b110)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b0111;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b0111;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b111)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b0111;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b0111;
                end
            end
            //Load To R2 and Increment
            if(DSTREG==3'b101&&SREG1==3'b000)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1011;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b001)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1011;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b010)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1011;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b011)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1011;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b100)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1011;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1011;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b101)begin        
                if(timer[2])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1011;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b110)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1011;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1011;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b111)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1011;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1011;
                end
            end
            //Load To R3 and Increment
            if(DSTREG==3'b110&&SREG1==3'b000)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1101;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b001)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1101;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b010)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1101;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b011)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1101;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b100)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1101;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1101;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b101)begin
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1101;
                end        
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1101;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b110)begin        
                if(timer[2])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1101;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b111)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1101;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1101;
                end
            end
            
            //Load to R3 and Increment
            if(DSTREG==3'b111&&SREG1==3'b000)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1110;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b001)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1110;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b010)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1110;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b011)begin        
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1110;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b100)begin        
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1110;
                end
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1110;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b101)begin
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1110;
                end        
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1110;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b110)begin  
                if(timer[2])begin
                   ALU_FunSel=5'b10000;
                   MuxASel=2'b00;
                   RF_FunSel=3'b010;
                   RF_RegSel=4'b1110;
                end      
                if(timer[3])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1110;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b111)begin        
                if(timer[2])begin
                   if(64'h0000000000000020)
                        RF_FunSel=3'b001;
                   else
                        RF_FunSel=3'b000;
                   RF_RegSel=4'b1110;
                   SC_Reset=1;
                end
            end
        end
        //LSL,LSR,ASR,CSL,CSR,NOT,MOVS
        64'h0000000000000080||64'h0000000000000100||64'h0000000000000200||64'h0000000000000400||64'h0000000000000800||64'h0000000000004000||64'h0000000001000000:
        begin       
            if(DSTREG==3'b000&&SREG1==3'b000)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b001)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b000&&SREG1==3'b010)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b000&&SREG1==3'b011)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b000&&SREG1==3'b100)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b101)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b110)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b000&&SREG1==3'b111)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b000)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b001)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b001&&SREG1==3'b010)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b001&&SREG1==3'b011)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b001&&SREG1==3'b100)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b101)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b110)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b001&&SREG1==3'b111)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b011;
                    ARF_FunSel=3'b010;
                end
            end
            //Load to SP
            if(DSTREG==3'b010&&SREG1==3'b000)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b001)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b010&&SREG1==3'b010)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b010&&SREG1==3'b011)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b010&&SREG1==3'b100)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b101)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b110)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b010&&SREG1==3'b111)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b110;
                    ARF_FunSel=3'b010;
                end
            end
            //Load to AR
            if(DSTREG==3'b011&&SREG1==3'b000)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b001)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b011&&SREG1==3'b010)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b011&&SREG1==3'b011)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                    SC_Reset=1;

                end
            end
            if(DSTREG==3'b011&&SREG1==3'b100)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b101)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b110)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b011&&SREG1==3'b111)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxBSel=2'b00;
                    ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                end
            end
            //Load To R1
            if(DSTREG==3'b100&&SREG1==3'b000)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b001)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                    SC_Reset=1;

                end
            end   
            if(DSTREG==3'b100&&SREG1==3'b010)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                    SC_Reset=1;
                end
            end  
            if(DSTREG==3'b100&&SREG1==3'b011)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                    SC_Reset=1;
                end
            end 
            if(DSTREG==3'b100&&SREG1==3'b100)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                    SC_Reset=1;
                end
            end 
            if(DSTREG==3'b100&&SREG1==3'b101)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b110)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b100&&SREG1==3'b111)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b0111;
                    SC_Reset=1;
                end
            end
            //Load To R2
            if(DSTREG==3'b101&&SREG1==3'b000)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b001)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                    SC_Reset=1;

                end
            end   
            if(DSTREG==3'b101&&SREG1==3'b010)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                    SC_Reset=1;
                end
            end  
            if(DSTREG==3'b101&&SREG1==3'b011)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                    SC_Reset=1;
                end
            end 
            if(DSTREG==3'b101&&SREG1==3'b100)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                    SC_Reset=1;
                end
            end 
            if(DSTREG==3'b101&&SREG1==3'b101)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b110)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b101&&SREG1==3'b111)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1011;
                    SC_Reset=1;
                end
            end
            //Load to R3
            if(DSTREG==3'b110&&SREG1==3'b000)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b001)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                    SC_Reset=1;

                end
            end   
            if(DSTREG==3'b110&&SREG1==3'b010)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                    SC_Reset=1;
                end
            end  
            if(DSTREG==3'b110&&SREG1==3'b011)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                    SC_Reset=1;
                end
            end 
            if(DSTREG==3'b110&&SREG1==3'b100)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                    SC_Reset=1;
                end
            end 
            if(DSTREG==3'b110&&SREG1==3'b101)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b110)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b110&&SREG1==3'b111)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1101;
                    SC_Reset=1;
                end
            end

            //Load To R4
            if(DSTREG==3'b111&&SREG1==3'b000)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b001)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                    SC_Reset=1;

                end
            end   
            if(DSTREG==3'b111&&SREG1==3'b010)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b11;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                    SC_Reset=1;
                end
            end  
            if(DSTREG==3'b111&&SREG1==3'b011)begin
                if(timer[2])begin
                    ARF_OutCSel=2'b10;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;           
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                    SC_Reset=1;
                end
            end 
            if(DSTREG==3'b111&&SREG1==3'b100)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                    SC_Reset=1;
                end
            end 
            if(DSTREG==3'b111&&SREG1==3'b101)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b110)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                    SC_Reset=1;
                end
            end
            if(DSTREG==3'b111&&SREG1==3'b111)begin
                if(timer[2])begin
                    ALU_WF=1;
                    if(64'h0000000000000080)
                        ALU_FunSel=5'b11011;
                    else if(64'h0000000000000100)
                        ALU_FunSel=5'b11100;
                    else if(64'h0000000000000200)
                        ALU_FunSel=5'b11101;    
                    else if(64'h0000000000000400)
                        ALU_FunSel=5'b11110;    
                    else if(64'h0000000000000800)
                        ALU_FunSel=5'b11111;
                    else if(64'h0000000000004000)
                        ALU_FunSel=5'b10010;
                    else if(64'h0000000001000000)
                        ALU_FunSel=5'b10000;
                end
                if(timer[3])begin         
                    MuxASel=2'b00;
                    RF_FunSel=3'b010;
                    RF_RegSel=4'b1110;
                    SC_Reset=1;
                end
            end
        end
            //AND,ORR,XOR,NAND,ADD,ADC,SUB,ADDS,SUBS,ANDS,ORRS,XORS,
        64'h0000000000001000||64'h0000000000002000||64'h0000000000008000||64'h0000000000010000||64'h0000000000200000||64'h0000000000400000||64'h0000000000800000||64'h0000000002000000||64'h0000000004000000||64'h0000000008000000||64'h0000000010000000||64'h0000000020000000:
        begin
            if(DSTREG==3'b000||3'b001||3'b010||3'b011)begin
                if(timer[2])begin
                    if(SREG1==3'b000)begin 
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b0111;
                    end
                    if(SREG1==3'b001)begin 
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b0111;
                    end
                    if(SREG1==3'b010)begin 
                        ARF_OutCSel=2'b11;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b0111;
                    end
                    if(SREG1==3'b011) begin
                        ARF_OutCSel=2'b10;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b0111;
                    end
                end
                if(timer[3])begin
                    if(SREG2==3'b000) begin
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b1011;
                    end
                    if(SREG2==3'b001)begin 
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b1011;
                    end
                    if(SREG2==3'b010)begin
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b1011;
                    end
                    if(SREG2==3'b011)begin 
                        ARF_OutCSel=2'b11;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b1011;
                    end
                end
                if(timer[4])begin
                    if(SREG1==3'b000) RF_OutASel=3'b100;
                    else if(SREG1==3'b001) RF_OutASel=3'b100;
                    else if(SREG1==3'b010) RF_OutASel=3'b100;
                    else if(SREG1==3'b011) RF_OutASel=3'b100;
                    //Load R1,R2,R3,R4 TO RF_OUTA
                    else if(SREG1==3'b100) RF_OutASel=3'b000;
                    else if(SREG1==3'b101) RF_OutASel=3'b001;
                    else if(SREG1==3'b110) RF_OutASel=3'b010;
                    else if(SREG1==3'b111) RF_OutASel=3'b011;

                    if(SREG2==3'b000) RF_OutBSel=3'b101;
                    else if(SREG2==3'b001) RF_OutBSel=3'b101;
                    else if(SREG2==3'b010) RF_OutBSel=3'b101;
                    else if(SREG2==3'b011) RF_OutBSel=3'b101;
                    //Load R1,R2,R3,R4 TO RF_OUTB
                    else if(SREG2==3'b100) RF_OutBSel=3'b000;
                    else if(SREG2==3'b101) RF_OutBSel=3'b001;
                    else if(SREG2==3'b110) RF_OutBSel=3'b010;
                    else if(SREG2==3'b111) RF_OutBSel=3'b011;

                    case(D)
                        64'h0000000000001000:ALU_FunSel=5'b10111;//and
                        64'h0000000000002000:ALU_FunSel=5'b11000;//orr
                        64'h0000000000008000:ALU_FunSel=5'b11001;//XOR
                        64'h0000000000010000:ALU_FunSel=5'b11010;//nand
                        64'h0000000000200000:ALU_FunSel=5'b10100;//A+B
                        64'h0000000000400000:ALU_FunSel=5'b10101;//A+B+CARRY
                        64'h0000000000800000:ALU_FunSel=5'b10110;//A-B
                        64'h0000000002000000:begin
                        ALU_FunSel=5'b10100;
                        if(S==1)ALU_WF=1;//A+B FLAGS
                        end
                        64'h0000000004000000:begin
                        ALU_FunSel=5'b10110;
                        if(S==1)ALU_WF=1;//A-B FLAGS
                        end
                        64'h0000000008000000:begin
                        ALU_FunSel=5'b10111;
                        if(S==1)ALU_WF=1;//AND FLAGS
                        end
                        64'h0000000010000000:begin
                        ALU_FunSel=5'b11000;
                        if(S==1)ALU_WF=1;//ORR FLAGS CHANGE
                        end
                        64'h0000000020000000:begin
                        ALU_FunSel=5'b11001;
                        if(S==1)ALU_WF=1;//XOR FLAGS
                        end
                    endcase
                end
                if(timer[5])begin
                    MuxBSel=2'b00;
                    if(DSTREG==3'b000||3'b001) ARF_RegSel=3'b011;
                    if(DSTREG==3'b010) ARF_RegSel=3'b110;
                    if(DSTREG==3'b011) ARF_RegSel=3'b101;
                    ARF_FunSel=3'b010;
                end
            end
            if(DSTREG==3'b100||3'b101||3'b110||3'b111)begin
                if(timer[2])begin
                    if(SREG1==3'b000)begin 
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b0111;
                    end
                    if(SREG1==3'b001)begin 
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b0111;
                    end
                    if(SREG1==3'b010)begin 
                        ARF_OutCSel=2'b11;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b0111;
                    end
                    if(SREG1==3'b011) begin
                        ARF_OutCSel=2'b10;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b0111;
                    end
                end
                if(timer[3])begin
                    if(SREG2==3'b000) begin
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b1011;
                    end
                    if(SREG2==3'b001)begin 
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b1011;
                    end
                    if(SREG2==3'b010)begin
                        ARF_OutCSel=2'b00;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b1011;
                    end
                    if(SREG2==3'b011)begin 
                        ARF_OutCSel=2'b11;
                        MuxASel=2'b01;
                        RF_FunSel=3'b010;
                        RF_ScrSel=4'b1011;
                    end
                end
                if(timer[4])begin
                    if(SREG1==3'b000) RF_OutASel=3'b100;
                    else if(SREG1==3'b001) RF_OutASel=3'b100;
                    else if(SREG1==3'b010) RF_OutASel=3'b100;
                    else if(SREG1==3'b011) RF_OutASel=3'b100;
                    //Load R1,R2,R3,R4 TO RF_OUTA
                    else if(SREG1==3'b100) RF_OutASel=3'b000;
                    else if(SREG1==3'b101) RF_OutASel=3'b001;
                    else if(SREG1==3'b110) RF_OutASel=3'b010;
                    else if(SREG1==3'b111) RF_OutASel=3'b011;

                    if(SREG2==3'b000) RF_OutBSel=3'b101;
                    else if(SREG2==3'b001) RF_OutBSel=3'b101;
                    else if(SREG2==3'b010) RF_OutBSel=3'b101;
                    else if(SREG2==3'b011) RF_OutBSel=3'b101;
                    //Load R1,R2,R3,R4 TO RF_OUTB
                    else if(SREG2==3'b100) RF_OutBSel=3'b000;
                    else if(SREG2==3'b101) RF_OutBSel=3'b001;
                    else if(SREG2==3'b110) RF_OutBSel=3'b010;
                    else if(SREG2==3'b111) RF_OutBSel=3'b011;

                    case(D)
                        64'h0000000000001000:ALU_FunSel=5'b10111;//and
                        64'h0000000000002000:ALU_FunSel=5'b11000;//orr
                        64'h0000000000008000:ALU_FunSel=5'b11001;//XOR
                        64'h0000000000010000:ALU_FunSel=5'b11010;//nand
                        64'h0000000000200000:ALU_FunSel=5'b10100;//A+B
                        64'h0000000000400000:ALU_FunSel=5'b10101;//A+B+CARRY
                        64'h0000000000800000:ALU_FunSel=5'b10110;//A-B
                        64'h0000000002000000:begin
                        ALU_FunSel=5'b10100;
                        if(S==1)ALU_WF=1;//A+B FLAGS
                        end
                        64'h0000000004000000:begin
                        ALU_FunSel=5'b10110;
                        if(S==1)ALU_WF=1;//A-B FLAGS
                        end
                        64'h0000000008000000:begin
                        ALU_FunSel=5'b10111;
                        if(S==1)ALU_WF=1;//AND FLAGS
                        end
                        64'h0000000010000000:begin
                        ALU_FunSel=5'b11000;
                        if(S==1)ALU_WF=1;//ORR FLAGS CHANGE
                        end
                        64'h0000000020000000:begin
                        ALU_FunSel=5'b11001;
                        if(S==1)ALU_WF=1;//XOR FLAGS
                        end
                    endcase
                end
                if(timer[5])begin
                    MuxASel=2'b00;
                    if(DSTREG==3'b100) RF_RegSel=4'b0111;
                    if(DSTREG==3'b101) RF_RegSel=4'b1011;
                    if(DSTREG==3'b110) RF_RegSel=4'b1101;
                    if(DSTREG==3'b111) RF_RegSel=4'b1110;
                    ARF_FunSel=3'b010;
                end
            end
        end
        //BX
        64'h0000000040000000:begin
            if(timer[2])begin
                ARF_OutCSel=2'b00;
                MuxASel=2'b01;
                RF_FunSel=3'b010;
                RF_ScrSel=4'b0111;
            end
            if(timer[3])begin
                RF_OutASel=3'b100;
                ALU_FunSel=5'b10000;
            end
            if(timer[4])begin
                MuxCSel=1'b0;
                ARF_OutDSel=2'b11;
                Mem_CS=0;
                Mem_WR=1;
            end
            if(timer[5])begin
                ARF_FunSel=3'b001;
                ARF_RegSel=3'b110;
                ARF_OutDSel=2'b11;
                MuxCSel=1'b1;
                Mem_CS=0;
                Mem_WR=1;
            end
            if(timer[6])begin
                ARF_FunSel=3'b000;
                ARF_RegSel=3'b110;

                if(RSEL==2'b00)begin
                    RF_OutASel=3'b000;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(RSEL==2'b01)begin
                    RF_OutASel=3'b001;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(RSEL==2'b10)begin
                    RF_OutASel=3'b010;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                if(RSEL==2'b11)begin
                    RF_OutASel=3'b011;
                    ALU_FunSel=5'b10000;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                end
                SC_Reset=1;
            end
        end
        //BL
        64'h0000000080000000:begin
            if(timer[2])begin
                ARF_OutDSel=2'b11;
                Mem_WR=0;
                Mem_CS=0;
                MuxBSel=2'b10;
                ARF_FunSel=3'b100;
                ARF_RegSel=3'b011;
            end
            if(timer[3])begin
                ARF_FunSel=3'b001;
                ARF_RegSel=3'b110;
                ARF_OutDSel=2'b11;
                Mem_WR=0;
                Mem_CS=0;
                MuxBSel=2'b10;
            end
            if(timer[4])begin
                ARF_FunSel=3'b110;
                ARF_RegSel=3'b011;
            end
            if(timer[5])begin
                ARF_FunSel=3'b000;
                ARF_RegSel=3'b110;
                SC_Reset=1;
            end
        end
        //POP
        64'h0000000000000008:begin
            if(timer[2])begin
                ARF_OutDSel=2'b11;
                Mem_CS=0;
                Mem_WR=0;
            end
            if(timer[3])begin
                MuxASel=2'b10;
                if(RSEL==2'b00)begin
                    RF_FunSel=3'b100;
                    RF_RegSel=4'b0111;
                end
                if(RSEL==2'b01)begin
                    RF_FunSel=3'b100;
                    RF_RegSel=4'b1011;
                end
                if(RSEL==2'b10)begin
                    RF_FunSel=3'b100;
                    RF_RegSel=4'b1101;
                end
                if(RSEL==2'b11)begin
                    RF_FunSel=3'b100;
                    RF_RegSel=4'b1110;
                end
            end
            if(timer[4])begin
                ARF_FunSel=3'b001;
                ARF_RegSel=3'b110;
                ARF_OutDSel=2'b11;
                Mem_CS=0;
                Mem_WR=0;
            end
            if(timer[5])begin
                MuxASel=2'b10;
                if(RSEL==2'b00)begin
                    RF_FunSel=3'b110;
                    RF_RegSel=4'b0111;
                end
                if(RSEL==2'b01)begin
                    RF_FunSel=3'b110;
                    RF_RegSel=4'b1011;
                end
                if(RSEL==2'b10)begin
                    RF_FunSel=3'b110;
                    RF_RegSel=4'b1101;
                end
                if(RSEL==2'b11)begin
                    RF_FunSel=3'b110;
                    RF_RegSel=4'b1110;
                end
                SC_Reset=1;
            end
        end
        //PSH
        64'h0000000000000010:begin
            if(timer[2])begin
                if(RSEL==2'b00)begin
                    RF_OutASel=3'b000;
                end
                if(RSEL==2'b01)begin
                    RF_OutASel=3'b001;

                end
                if(RSEL==2'b10)begin
                    RF_OutASel=3'b010;
                    
                end
                if(RSEL==2'b11)begin
                    RF_OutASel=3'b011;
                end
                ALU_FunSel=5'b10000;
            end
            if(timer[3])begin
                MuxCSel=1'b1;
                ARF_OutDSel=2'b11;
                Mem_CS=0;
                Mem_WR=1;
            end
            if(timer[4])begin
                ARF_FunSel=3'b000;
                ARF_RegSel=3'b110;
            end
            if(timer[5])begin
                MuxCSel=1'b0;
                ARF_OutDSel=2'b11;
                Mem_CS=0;
                Mem_WR=1;
                SC_Reset=1;
            end
        end
        //BRA
        64'h0000000000000001:begin
            if(timer[2])begin
                MuxASel=2'b11;
                RF_FunSel=3'b010;
                RF_ScrSel=4'b0111;
            end
            if(timer[3])begin
                ARF_OutCSel=2'b00;
                MuxASel=2'b01;
                RF_FunSel=3'b010;
                RF_ScrSel=4'b1011;

            end
            if(timer[4])begin
                RF_OutASel=3'b100;
                RF_OutBSel=3'b101;
                ALU_FunSel=5'b10100;
                MuxBSel=2'b00;
                ARF_FunSel=3'b010;
                ARF_RegSel=3'b011;
                SC_Reset=1;
            end
        end
        //BNE
        64'h0000000000000002:begin
            if(ALU_Flags[3]==0)begin
                if(timer[2])begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b1011;

                end
                if(timer[4])begin
                    RF_OutASel=3'b100;
                    RF_OutBSel=3'b101;
                    ALU_FunSel=5'b10100;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                    SC_Reset=1;
                end
            end
        end
        //BEQ
        64'h0000000000000004:begin
            if(ALU_Flags[3]==1)begin
                if(timer[2])begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b0111;
                end
                if(timer[3])begin
                    ARF_OutCSel=2'b00;
                    MuxASel=2'b01;
                    RF_FunSel=3'b010;
                    RF_ScrSel=4'b1011;

                end
                if(timer[4])begin
                    RF_OutASel=3'b100;
                    RF_OutBSel=3'b101;
                    ALU_FunSel=5'b10100;
                    MuxBSel=2'b00;
                    ARF_FunSel=3'b010;
                    ARF_RegSel=3'b011;
                    SC_Reset=1;
                end
            end
        end
        //MOVH
        64'h0000000000020000:begin
            if(timer[2])begin
                if(DSTREG==3'b000)begin
                    MuxBSel=2'b11;
                    ARF_FunSel=3'b110;
                    ARF_RegSel=3'b011;
                end
                if(DSTREG==3'b001)begin
                    MuxBSel=2'b11;
                    ARF_FunSel=3'b110;
                    ARF_RegSel=3'b011;
                end
                if(DSTREG==3'b010)begin
                    MuxBSel=2'b11;
                    ARF_FunSel=3'b110;
                    ARF_RegSel=3'b110;
                end
                if(DSTREG==3'b011)begin
                    MuxBSel=2'b11;
                    ARF_FunSel=3'b110;
                    ARF_RegSel=3'b101;
                end
                if(DSTREG==3'b100)begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b110;
                    RF_RegSel=4'b0111;
                end
                if(DSTREG==3'b101)begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b110;
                    RF_RegSel=4'b1011;
                end
                if(DSTREG==3'b110)begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b110;
                    RF_RegSel=4'b1101;
                end
                if(DSTREG==3'b111)begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b110;
                    RF_RegSel=4'b1110;
                end
                SC_Reset=1;
            end
        end
        64'h0000000000100000:begin
            if(timer[2])begin
                if(DSTREG==3'b000)begin
                    MuxBSel=2'b11;
                    ARF_FunSel=3'b101;
                    ARF_RegSel=3'b011;
                end
                if(DSTREG==3'b001)begin
                    MuxBSel=2'b11;
                    ARF_FunSel=3'b101;
                    ARF_RegSel=3'b011;
                end
                if(DSTREG==3'b010)begin
                    MuxBSel=2'b11;
                    ARF_FunSel=3'b101;
                    ARF_RegSel=3'b110;
                end
                if(DSTREG==3'b011)begin
                    MuxBSel=2'b11;
                    ARF_FunSel=3'b101;
                    ARF_RegSel=3'b101;
                end
                if(DSTREG==3'b100)begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b101;
                    RF_RegSel=4'b0111;
                end
                if(DSTREG==3'b101)begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b101;
                    RF_RegSel=4'b1011;
                end
                if(DSTREG==3'b110)begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b101;
                    RF_RegSel=4'b1101;
                end
                if(DSTREG==3'b111)begin
                    MuxASel=2'b11;
                    RF_FunSel=3'b101;
                    RF_RegSel=4'b1110;
                end
                SC_Reset=1;
            end
        end
        //LDR
        64'h0000000000040000:begin
            if(timer[2])begin
                ARF_OutDSel=2'b10;
                Mem_CS=0;
                Mem_WR=0;
                MuxASel=2'b10;
                RF_FunSel=3'b101;
                if(RSEL==2'b00)begin
                    RF_RegSel=4'b0111;
                end
                if(RSEL==2'b01)begin
                    RF_RegSel=4'b1011;
                end
                if(RSEL==2'b10)begin
                    RF_RegSel=4'b1101;
                end
                if(RSEL==2'b11)begin
                    RF_RegSel=4'b1110;
                end
            end
            if(timer[3])begin
                ARF_FunSel=3'b001;
                ARF_RegSel=3'b101;
                ARF_OutDSel=2'b10;
                Mem_CS=0;
                Mem_WR=0;
                MuxASel=2'b10;
                RF_FunSel=3'b110;
                if(RSEL==2'b00)begin
                    RF_RegSel=4'b0111;
                end
                if(RSEL==2'b01)begin
                    RF_RegSel=4'b1011;
                end
                if(RSEL==2'b10)begin
                    RF_RegSel=4'b1101;
                end
                if(RSEL==2'b11)begin
                    RF_RegSel=4'b1110;
                end
            end
            if(timer[4])begin
                ARF_FunSel=3'b000;
                ARF_RegSel=3'b101;
                SC_Reset=1;
            end
        end
        //STR
        64'h0000000000080000:begin
            if(timer[2])begin
                if(RSEL==2'b00)begin
                    RF_OutASel=3'b000;
                end
                if(RSEL==2'b01)begin
                    RF_OutASel=3'b001;
                end
                if(RSEL==2'b10)begin
                    RF_OutASel=3'b010;
                end
                if(RSEL==2'b11)begin
                    RF_OutASel=3'b011; 
                end
                ALU_FunSel=5'b10000;
                MuxCSel=1'b0;
                ARF_OutDSel=2'b10;
                Mem_CS=0;
                Mem_WR=1;
            end
            if(timer[3])begin
                ARF_FunSel=3'b001;
                ARF_RegSel=3'b101;
                if(RSEL==2'b00)begin
                    RF_OutASel=3'b000;
                end
                if(RSEL==2'b01)begin
                    RF_OutASel=3'b001;
                end
                if(RSEL==2'b10)begin
                    RF_OutASel=3'b010;
                end
                if(RSEL==2'b11)begin
                    RF_OutASel=3'b011; 
                end
                ALU_FunSel=5'b10000;
                MuxCSel=1'b1;
                ARF_OutDSel=2'b10;
                Mem_CS=0;
                Mem_WR=1;
                SC_Reset=1;
            end
        end
        //LDRIM
        64'h0000000100000000:begin
            if(timer[2])begin
                MuxASel=2'b11;
                RF_FunSel=3'b100;
                if(RSEL==2'b00)begin
                    RF_RegSel=4'b0111;
                end
                if(RSEL==2'b01)begin
                    RF_RegSel=4'b1011;
                end
                if(RSEL==2'b10)begin
                    RF_RegSel=4'b1101;
                end
                if(RSEL==2'b11)begin
                     RF_RegSel=4'b1110;
                end
                SC_Reset=1;
            end
        end
   endcase
end
endmodule