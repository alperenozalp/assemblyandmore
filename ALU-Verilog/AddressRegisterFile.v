`timescale 1ns / 1ps
module AddressRegisterFile(
    input [15:0] I,
    input [1:0] OutCSel,
    input [1:0] OutDSel,
    input [2:0] FunSel,
    input [2:0] RegSel,
    input Clock,
    output reg [15:0] OutC,
    output reg [15:0] OutD
    );
    wire [15:0] PCO;
    wire [15:0] ARO;
    wire [15:0] SPO;
    reg PCE;
    reg ARE;
    reg SPE;
    Register PC(.E(PCE),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(PCO));
    Register AR(.E(ARE),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(ARO));
    Register SP(.E(SPE),.FunSel(FunSel),.I(I),.Clock(Clock),.Q(SPO));
    always @(*) begin
        SPE=~RegSel[0];
        ARE=~RegSel[1];
        PCE=~RegSel[2];
        case(OutCSel)
            3'b00,3'b01:begin
                OutC=PCO;
            end
            3'b10:begin
                OutC=ARO;
            end
            3'b11:begin
                OutC=SPO;
            end
        endcase
        case(OutDSel)
            3'b00,3'b01:begin
                OutD=PCO;
            end
            3'b10:begin
                OutD=ARO;
            end
            3'b11:begin
                OutD=SPO;
            end
        endcase        
    end
    
endmodule