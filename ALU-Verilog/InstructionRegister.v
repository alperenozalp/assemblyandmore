`timescale 1ns / 1ps
module InstructionRegister(
    input LH,
    input Write,
    input [7:0] I,
    input Clock,
    output reg [15:0] IROut
    );
    always @(posedge Clock) begin 
        case(LH)
            1'b0: begin
                if(Write)begin
                    IROut[7:0] = I;
                end
            end
            1'b1:begin
                if(Write)begin
                    IROut[15:8] = I;               
                end
            end
        endcase
    
    end
    
    
endmodule