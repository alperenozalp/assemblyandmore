`timescale 1ns / 1ps
module Register(
    input E,
    input [2:0] FunSel,
    input [15:0] I,
    input Clock,
    output reg [15:0] Q
);

always @(posedge Clock) begin
    case(FunSel)
        3'b000 : begin
            if (E) Q = Q-1;
        end
        3'b001: begin
            if (E) Q = Q + 1;
        end
        3'b010: begin
            if (E) Q = I;
        end
        3'b011: begin
            if (E) Q = 0;
        end
        3'b100: begin
            if(E)begin 
            Q[15:8]=8'b0;
            Q[7:0] = I[7:0]; 
            end
        end
        3'b101: begin
            if (E) Q[7:0] = I[7:0];
        end
        3'b110: begin
            if (E) Q[15:8] = I[7:0];
        end
        3'b111: begin
            if (E) begin
                Q[7:0] = I[7:0];
                if (I[7])
                Q[15:8] = 8'b11111111;
                else
                Q[15:8]=8'b0;      
            end
        end
    endcase
end

endmodule