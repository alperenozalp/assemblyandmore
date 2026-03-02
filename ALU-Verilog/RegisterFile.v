`timescale 1ns / 1ps
module RegisterFile(
    input [15:0] I,
    input [2:0] OutASel,OutBSel,   
    input [2:0] FunSel,
    input [3:0] RegSel, ScrSel,
    input Clock,
    output reg [15:0] OutA,OutB
);
    reg R_1,R_2,R_3,R_4,S_1,S_2,S_3,S_4;
    wire [15:0] OR1,OR2,OR3,OR4,OS1,OS2,OS3,OS4;

    Register R1(.E(R_1),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(OR1));
    Register R2(.E(R_2),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(OR2));
    Register R3(.E(R_3),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(OR3));
    Register R4(.E(R_4),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(OR4));
    Register S1(.E(S_1),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(OS1));
    Register S2(.E(S_2),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(OS2));
    Register S3(.E(S_3),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(OS3));
    Register S4(.E(S_4),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(OS4));
    always @(*) begin
    R_4=~RegSel[0];
    R_3=~RegSel[1];
    R_2=~RegSel[2];
    R_1=~RegSel[3];
    S_4=~ScrSel[0];
    S_3=~ScrSel[1];
    S_2=~ScrSel[2];
    S_1=~ScrSel[3];
    case(OutASel) 
        3'b000:begin
            OutA=OR1;
        end
        3'b001:begin
            OutA=OR2;
        end
        3'b010:begin
            OutA=OR3;
        end
        3'b011:begin
            OutA=OR4;
        end       
        3'b100:begin
            OutA=OS1;
        end
        3'b101:begin
            OutA=OS2;
        end
        3'b110:begin
            OutA=OS3;
        end  
        3'b111:begin
            OutA=OS4;
        end               
    endcase
    case(OutBSel) 
        3'b000:begin
            OutB=OR1;
        end
        3'b001:begin
            OutB=OR2;
        end
        3'b010:begin
            OutB=OR3;
        end
        3'b011:begin
            OutB=OR4;
        end       
        3'b100:begin
            OutB=OS1;
        end
        3'b101:begin
            OutB=OS2;
        end
        3'b110:begin
            OutB=OS3;
        end  
        3'b111:begin
            OutB=OS4;
        end               
    endcase    
    end

    
endmodule


