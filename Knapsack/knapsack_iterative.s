W_Capacity 	EQU 0x32	;W_Capacity = 50
SIZE 		EQU 0x3		;size = 3
	
			AREA my_array, DATA,readwrite	;area for data 
			ALIGN
dp_array	SPACE W_Capacity
dp_end
			AREA knapsack_iterative, code,readonly	;area for code
			ENTRY
			THUMB		
			ALIGN
__main		FUNCTION
			EXPORT __main
			;adjustments for start the function
			MOVS r7,#W_Capacity		;load Weight Capacity
			MOVS r6,#SIZE			;load size
			LSLS r6,#2				;multiply by 4 
			LSLS r7,#2				;multiply by 4
			ADDS r6,r6,#4			;n=n+1,
			MOVS r4,#4				;int i=1
			B knapsack				;go to knapsack
			
max 		POP{r2,r5}				;pop last 2 value at stack
			CMP r2,r5				;compare that values
			BGE max1				;if r2>=r5 go max1
			MOVS r0,r5				;write r5 to r0
			BX LR					;return link register
			
max1		MOVS r0,r2				;write r2 to r0
			BX LR					;return link register			
;adjustments for next step of inner loop			
decrease 	SUBS r3,r3,#4			;w--
			ADDS r4,r4,#4			;i++
			B innloop				;go back inloop
knapsack
outloop		CMP r4,r6				;compare i and n+1
			BGE return				;if i >= n+1 
			MOVS r3,r7				;w=W
innloop		CMP r3,#0				;compare w and 0
			BGE continue1			;if w>=0,so inner loop can still continue, go to continue1
			;innloop is no longer continue so make adjustments for outloop
			ADDS r4,r4,#4			;i++
			B outloop				;go to outloop
			
continue1	SUBS r4,r4,#4			;i-- to get data in array
			LDR r1,=weight_array	;load weight array to r1
			LDR r5,[r1,r4]			;weight[i-1]
			LSLS r5,#2				;multiply by 4
			;if block
			CMP r5,r3				;compare weight[i-1] and w
			BGT decrease			;if weight[i-1] is greater, go decrease
			LDR r1,=dp_array		;load dp to r1
			LDR r2,[r1,r3]			;dp[w]
			PUSH {r2}				;push dp[w]         
			SUBS r2,r3,r5			;r2 = w-weight[i-1]
			LDR r5,[r1,r2]			;dp[w-weight[i-1]]
			LDR r1,=profit_array	;load profit array to r1
			LDR r2,[r1,r4]			;r2 = profit[i-1]
			ADDS r5,r5,r2			;dp[w-weight[i-1]]+profit[i-1]
			PUSH{r5}				;push dp[w-weight[i-1]]+profit[i-1]
			BL max					;go to max for compare dp[w] and dp[w-weight[i-1]]+profit[i-1] 
			LDR r1,=dp_array		;load dp to r1
			STR r0,[r1,r3]			;dp[w] = max
			B decrease				;end of to inner loop, so go to decrease	
;the iterative function finished, make last adjustments  for final answer		
return     	LDR r1,=profit_array	;load profit array to r1 for final answer
			LDR r2,=weight_array	;load weight array to r2 for final answer
			LDR r3,=dp_array		;load dp array to r3 for final answer
			LDR r0,[r3,r7]			;load answer to r0 for final answer
stop		B stop					;end of the code, while(1)
			ALIGN
			ENDFUNC
						
profit_array DCD 60,100,120 		; write profit array
profit_end
weight_array DCD 10,20,30 			; write weight array
weight_end
			END