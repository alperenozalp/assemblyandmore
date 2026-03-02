W_Capacity 	EQU 0x32			;W_Capacity = 50
SIZE 		EQU 0x3				;SIZE = 3
		
			AREA knapsack_recursion, code,readonly
			ENTRY
			THUMB		
			ALIGN
__main 		FUNCTION
			EXPORT __main

			MOVS r0,#W_Capacity		;load Weight Capacity
			MOVS r1,#SIZE			;load size
			LSLS r1,#2				;multiply by four to reach word by word
			PUSH {r0,r1}			;push values to stack
			BL knsack				;called in main knsack(W,SIZE)
			POP {r0}				;max value 
			LDR r1,=profit_array	;load profit array
			LDR r2,=weight_array	;load weight array
			MOVS r3,#0				;move 0
			MOVS r4,#0				;move 0
			MOVS r5,#0				;move 0
			MOVS r6,#0				;move 0
			MOVS r7,#0				;move 0
stop		B stop					;while(1)		
	;return 0, base case for recursive
ret0		POP {r7}				;r7 for LR
			MOVS r3,#0				;r3=0
			PUSH {r3}				;push 0 to stack, that means result of current knapsack is 0
			BX r7					;return to LR, where the function is called		
	;when this function is called, there are two value at the top of stack
max			POP{r4,r3}				;r4 is profit[n-1]+knsack(w-weight[n-1],n-1), and r3 is knsack(w,n-1)
			CMP r4,r3				;compare r4 and r3
			BGE max1				;r4>=r3
			PUSH {r3}				;result of knsack(w-weight[n-1],n-1) + profit[n-1]
			BX LR					;return the link register
max1		PUSH {r4}				;result of knsack(W,n-1)
			BX LR					;return the link register

knsack		POP{r0,r1}				;pop last  
			PUSH {LR}				;pushed lr, it is going to use after other knsack function calls.
			CMP r0,#0				;compare W_capacity with 0
			BEQ ret0	  			;if W_capacity is 0, go return
			CMP r1,#0				;compare Size with 0
			BEQ ret0				;if size is 0, go return
			SUBS r1,r1,#4			;n=n-1
			LDR r3,=weight_array	;load weight array to r3
			LDR r4,[r3,r1]			;weight[n-1]
			CMP r4,r0				;weight[n-1] > w ? 
			BGT retkn				;if it is true, go first return knsack
			;else
			MOVS r5,r0				;move the value of r0 (W_capacity)  to r5
			MOVS r6,r1				;move the value of r1 (SIZE) to r6	
			PUSH {r5,r6}			;push r5 and r6
			PUSH{r0,r1}				;push r0 and r1
			;these operations made for keeping the current value of r1 and r0,so it can be use in next knsack
			BL knsack				;knsack(W,n-1)
			POP{r7}					;popped result of the knsack
			POP{r5,r6}				;popped r5 and r6, these values are the same as values used in the previous knsack (line 63)
			PUSH {r7}				;push result again to don't lose it
			LDR r3,=weight_array	;load weight array to r3
			LDR r4,[r3,r6]			;weight[n-1]
			SUBS r5,r5,r4			;w-weight[n-1]
			PUSH{r5,r6}				;pushed r5 and r6,current W_capacity - weight[n-1] and size
			PUSH{r5,r6}				;pushed r5 and r6 
			BL knsack				;knsack(w-weight[n-1],n-1)
			POP {r7}				;result of knsack
			POP {r5,r6}				;current values of w and size
			LDR r3,=profit_array	;load profit array
			LDR r4,[r3,r6]			;profit[n-1]
			ADDS r4,r4,r7			;knsack(w-weight[n-1],n-1) + profit[n-1]
			PUSH{r4}				;push knsack(w-weight[n-1],n-1) + profit[n-1]
			;now there are two value in the top of the stack, knsack(w-weight[n-1],n-1) + profit[n-1] and knsack(W,n-1)
			BL max					;branc link to max 
			POP{r4}					;pop the max value
			POP{r7}					;pop LR
			PUSH{r4}				;push back max value
			BX r7					;go the LR	
			;weight[n-1] > w 
retkn		PUSH {r0,r1}			;push w and n-1
			BL knsack				;kn(W,n-1)
			POP{r3}					;pop the result
			POP{r7}					;pop the LR
			PUSH {r3}				;push back the result
			BX r7					;go the LR
			ALIGN
			ENDFUNC					;end of the function

profit_array DCD 60,100,120 	; write profit array
profit_end

weight_array DCD 10,20,30	; write weight array
weight_end
			END