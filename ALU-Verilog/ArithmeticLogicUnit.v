`timescale 1ns / 1ps
module ArithmeticLogicUnit(
    input [15:0] A,
    input [15:0] B,
    input [4:0] FunSel,
    input WF,
    input Clock,
    output reg [15:0] ALUOut,
    output reg [3:0] FlagsOut
);


reg [16:0] temp16;
reg [8:0] temp8;



always @(*) begin
    case(FunSel)
        5'b00000: begin 
            ALUOut[7:0] = A[7:0];
            ALUOut[15:8] = 0;          
        end
        5'b00001: begin
            ALUOut[7:0] = B[7:0];
            ALUOut[15:8] = 0;
        end
        5'b00010: begin 
            ALUOut[7:0]= ~A[7:0];
            ALUOut[15:8] = 0;
        end
        5'b00011: begin 
            ALUOut[7:0] = ~B[7:0];
            ALUOut[15:8]=0; 
        end
        5'b00100: begin
            temp8[8:0] = A[7:0]+B[7:0];
            ALUOut[7:0] = A[7:0]+B[7:0];            
        end
        5'b00101: begin 
            temp8[8:0] = A[7:0]+B[7:0]+FlagsOut[2];
            ALUOut[7:0] = A[7:0]+B[7:0]+FlagsOut[2] ;
        end
        5'b00110: begin 
            ALUOut[7:0] = A[7:0]+~B[7:0]+1;
            temp8[8:0] = A[7:0]+~B[7:0]+1;            
        end
        5'b00111: begin 
            ALUOut[7:0] = A[7:0] & B[7:0];
            ALUOut[15:8] = 0;
        end
        5'b01000: begin 
            ALUOut[7:0] = A[7:0]|B[7:0];
            ALUOut[15:8] = 0;     
        end
        5'b01001: begin
            ALUOut[7:0] = A[7:0]^B[7:0];
            ALUOut[15:8] = 0; 
        end
        5'b01010: begin 
            ALUOut[7:0] = ~(A[7:0] & B[7:0]); 
            ALUOut[15:8] = 0; 
        end
        5'b01011: begin 
            ALUOut[7:0] = A[6:0] << 1;
            ALUOut[0]=0;
            ALUOut[15:8]=0;
        end
        5'b01100: begin 
            ALUOut[6:0] = A[7:1];
            ALUOut[7]= 0;
            ALUOut[15:8]=0;
            if(WF)begin
                if(A[0]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                       
            end 
        end
        5'b01101: begin 
            ALUOut[6:0] = A[7:1];
            ALUOut[7]= A[7];
            ALUOut[15:8]=0;
        end
        5'b01110: begin 
            ALUOut[7:1] = A[6:0];
            ALUOut[0]= FlagsOut[2];
            ALUOut[15:8]=0; 
        end
        5'b01111: begin
            ALUOut[6:0] = A[7:1];
            ALUOut[7] = FlagsOut[2];
            ALUOut[15:8]=0;       
        end
        5'b10000: begin 
            ALUOut = A; 
        end
        5'b10001: begin
            ALUOut = B;     
        end
        5'b10010: begin
            ALUOut = ~A; 
        end
        5'b10011: begin
            ALUOut = ~B; 
        end
        5'b10100: begin
            ALUOut = A + B;
            temp16 = A + B;
        end
        5'b10101: begin
            temp16 = A+B+FlagsOut[2];
            ALUOut = A+B+FlagsOut[2] ;
        end
        5'b10110: begin
            ALUOut = A+~B+1;
            temp16 = A+~B+1;      
        end
        5'b10111: begin
             ALUOut=A&B;      
        end
        5'b11000: begin
            ALUOut=A|B;
        end
        5'b11001: begin
            ALUOut=A^B;    
        end
        5'b11010: begin
            ALUOut=~(A&B);     
        end
        5'b11011: begin 
            ALUOut[15:1] = A[14:0];
            ALUOut[0]=0;
        end
        5'b11100: begin
            ALUOut[14:0] = A[15:1];
            ALUOut[15]= 0;     
        end
        5'b11101: begin
            ALUOut[14:0] = A[15:1];
            ALUOut[15]= A[15];    
        end
        5'b11110: begin 
            ALUOut[15:1] = A[14:0];
            ALUOut[0]= FlagsOut[2];         
        end
        5'b11111: begin 
            ALUOut[14:0] = A[15:1];
            ALUOut[15] = FlagsOut[2];               
        end
    endcase
end
always @(posedge Clock) begin
    case(FunSel)
        5'b00000: begin          
            if(WF)begin
                if(ALUOut[7] == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;  
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
            end
        end
        5'b00001: begin
            if(WF)begin
                if(ALUOut[7] == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;              
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
            end 
        end
        5'b00010: begin 
            if(WF)begin
                if(~A[7:0] == 0) FlagsOut[3]=1;
                else FlagsOut[3]=0;
                if(~A[7]==1) FlagsOut[1]=1;
                else FlagsOut[1]=0;
            end
        end
        5'b00011: begin 
            if(WF)begin
                if(~B[7:0] == 0) FlagsOut[3]=1;
                else FlagsOut[3]=0;
                if(~B[7]==1) FlagsOut[1]=1;
                else FlagsOut[1]=0;
            end 
        end
        5'b00100: begin
            if(WF)begin
                if((A[7]&B[7]&~ALUOut[7])|(~A[7]&~B[7]&ALUOut[7])) FlagsOut[0]=1;
                else FlagsOut[0]=0;
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(temp8[8]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0; 
                end            
        end
        5'b00101: begin 
            if(WF)begin
                if((A[7]&B[7]&~ALUOut[7])|(~A[7]&~B[7]&ALUOut[7])) FlagsOut[0]=1;
                else FlagsOut[0]=0;
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(temp8[8]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0; 
                end
        end
        5'b00110: begin 
            if(WF)begin
                if((A[7]&~B[7]&~ALUOut[7])|(~A[7]&B[7]&ALUOut[7]))FlagsOut[0]=1;
                else FlagsOut[0]=0;
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(temp8[8]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0; 
            end             
        end
        5'b00111: begin 
            if(WF)begin
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;          
            end
        end
        5'b01000: begin 
            if(WF)begin
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;              
            end          
        end
        5'b01001: begin
            if(WF)begin
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;       
            end
        end
        5'b01010: begin 
            if(WF)begin
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                
            end
        end
        5'b01011: begin 
            if(WF)begin
                if(A[7]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                    
            end     
        end
        5'b01100: begin 
            if(WF)begin
                if(A[0]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                       
            end 
        end
        5'b01101: begin 
            if(WF)begin
                if(A[0]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                       
            end
        end
        5'b01110: begin 
            if(WF)begin
                if(A[7]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;   
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;                    
            end      
        end
        5'b01111: begin
            if(WF)begin
                if(A[0]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;   
                if(ALUOut[7]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;                    
            end         
        end
        5'b10000: begin 
            if(WF)begin
                if(A == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                 
                if(A[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
            end 
        end
        5'b10001: begin
            if(WF)begin
                if(B == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;  
                if(B[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
            end         
        end
        5'b10010: begin
            if(WF)begin
                if(~A == 0) FlagsOut[3]=1;
                else FlagsOut[3]=0;
                if(~A[15]==1) FlagsOut[1]=1;
                else FlagsOut[1]=0;
            end
        end
        5'b10011: begin
            if(WF)begin
                 if(~B == 0) FlagsOut[3]=1;
                 else FlagsOut[3]=0;
                 if(~B[15]==1) FlagsOut[1]=1;
                 else FlagsOut[1]=0;
            end    
        end
        5'b10100: begin
            if(WF)begin
                if((A[15]&B[15]&~ALUOut[15])|(~A[15]&~B[15]&ALUOut[15])) FlagsOut[0]=1;
                else FlagsOut[0]=0;
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(temp16[16]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0; 
                end  
        end
        5'b10101: begin
            if(WF)begin
                if((A[15]&B[15]&~ALUOut[15])|(~A[15]&~B[15]&ALUOut[15])) FlagsOut[0]=1;
                else FlagsOut[0]=0;
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(temp16[16]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0; 
                end
        end
        5'b10110: begin
            if(WF)begin
                if((A[15]&~B[15]&~ALUOut[15])|(~A[15]&B[15]&ALUOut[15]))FlagsOut[0]=1;
                else FlagsOut[0]=0;
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(temp16[16]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0; 
            end                 
        end
        5'b10111: begin
             if(WF)begin
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;     
            end              
        end
        5'b11000: begin
            if(WF)begin
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;     
            end    
        end
        5'b11001: begin
            if(WF)begin
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;     
            end         
        end
        5'b11010: begin
            if(WF)begin
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;     
            end         
        end
        5'b11011: begin 
            if(WF)begin
                if(A[15]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                    
            end
        end
        5'b11100: begin
            if(WF)begin
                if(A[0]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                       
            end      
        end
        5'b11101: begin   
            if(WF)begin
                if(A[0]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;                       
            end
            
        end
        5'b11110: begin 
            if(WF)begin
                if(A[15]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;   
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;                    
            end           
        end
        5'b11111: begin     
            if(WF)begin
                if(A[0]==1)FlagsOut[2]=1;
                else FlagsOut[2]=0;
                if(ALUOut == 0)FlagsOut[3]=1;
                else FlagsOut[3]=0;   
                if(ALUOut[15]==1)FlagsOut[1]=1;
                else FlagsOut[1]=0;                    
            end           
        end
    endcase
end
endmodule
