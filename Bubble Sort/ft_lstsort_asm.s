; Function: ft_lstsort_asm
; Parameters:
;   R0 - Pointer to the list (address of t_list *)
;   R1 - Pointer to comparison function (address of int (*f_comp)(int, int))
        AREA    Sorting_Code, CODE, READONLY
        ALIGN
        THUMB
        EXPORT  ft_lstsort_asm

ft_lstsort_asm 	FUNCTION
				PUSH	{LR}		;return value
				PUSH	{R0}		;address of root
				MOVS	R4,#0		;using for comparision, last sorted node
				LDR		R0,[R0]		;first node of the array
				PUSH	{R0}		;it will be the current node
				MOVS	R7,R1		;r7 = f_comp, always
loop			
				POP		{R3}		;address of current node
				LDR		R6,[R3,#4]	;address of the next node
				CMP		R6,R4		;if next node is the last sorted element, that means next element is already sorted so, we can go back the start
				BEQ		startagain	;start again with first element
				LDR		R0,[R3]		;value of the current node
				LDR		R1,[R6]		;value of the next node
				PUSH	{R3}		;push r3 for do not lose
				BLX		R7			;f_comp
				POP		{R3}		;take back R3
				CMP 	R0,#0		;currentnode.value > nextnode.value ? 
				BEQ		secondswap	;if it is true go swap
				MOVS	R5,R3		;change the prev node
				PUSH	{R6}		;will be the current node
				B		loop				
				;current node is greater that next node so we need to swap these two node:
secondswap		POP		{R0}		;root
				PUSH	{R0}		;root
				LDR		R0,[R0]		;address of the first node
				CMP		R0,R3		;if r3 equals first node that means we need to change root
				BEQ		changeroot				
				LDR 	R0,[R6,#4]	;Address of the next node of next node
				STR		R0,[R3,#4]	;currentnode.next = nextnode.next.next
				STR		R6,[R5,#4]	;prevnode.next = nextnode;
				STR		R3,[R6,#4]	;nextnode.next = currentnode
				MOVS	R5,R6		;will be the prev node in next iteration
				PUSH	{R3}		;will be the current node in next iteration
				B 		loop		;go loop
changeroot		POP    	{R0}
				PUSH	{R0}
				LDR		R2,[R6,#4]	;Address of the next node of next node
				STR		R2,[R3,#4]	;currentnode.next = nextnode.next.next
				STR		R3,[R6,#4]	;nextnode.next = currentnode
				STR		R6,[R0]		;now root point to new first node
				MOVS 	R5,R6		;r5 = prevnode, always
				PUSH	{R3}		;will be the current node
				B 		loop
startagain		POP		{R0}		;root
				PUSH	{R0}		;root
				LDR		R0,[R0]		;first node
				CMP		R0,R3		;if r5 equals to r3,that means array is sorted
				BEQ		stop		;go stop
				MOVS 	R4,R3		;change the last sorted node
				PUSH 	{R0}		;starting address of the array
				B 		loop		;go bubble, and start from beginning
				
							
stop			POP		{R0}		;root
				MOVS 	R1,R7		;r1 = f_comp
				POP		{PC}		;r0 = root , r1 = f_comp, pc = LR
				ENDFUNC
