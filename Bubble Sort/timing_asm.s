        AREA    Timing_Code, CODE, READONLY
        ALIGN
        THUMB
        EXPORT  Systick_Start_asm
        EXPORT  Systick_Stop_asm
		EXPORT	SysTick_Handler ; When the correct time comes,
		EXTERN	ticks
		EXTERN 	SystemCoreClock
SysTick_Handler 	FUNCTION
					PUSH	{LR}			;returning address
					PUSH	{R0,R1}			;push r0 and r1 for dont lose.
					LDR		R0,=ticks		;address of ticks
					LDR		R1,[R0]			;value of the ticks
					ADDS	R1,#1			;ticks++
					STR		R1,[R0]			;store back the value of the ticks in the address of the ticks
					POP		{R0,R1}			;restore saved registers
					POP		{PC}			;return
					ENDFUNC

Systick_Start_asm 	FUNCTION				
					PUSH	{LR}			;return address			
					PUSH 	{R0-R3}			;push r0-r3 for do not lose
					LDR		R0,=ticks		;address of ticks
					MOVS	R1,#0			;r1 = 0
					STR		R1,[R0]			;store the 0 on the address of ticks
					LDR 	R0,=0xE000E010	;r0 = address
					LDR 	R1,=100000		;r1 = 100000
					LDR		R2,=SystemCoreClock 	;r2 = SystemCoreCLock
					LDR		R2,[R2]			;value in r2		

					PUSH	{R0}			;push 0xE000E010
					MOVS 	R3,#0			;r3 = 0 as a counter
					MOVS	R0,R2			;r0 = value of  systemcoreclock
divloop
					CMP		R0,R1			;value of systemcoreclock > 100000 ? 
					BLT		divdone			;if systemcoreclock is less than 100000 go divdone
					SUBS	R0,R1			;systemcoreclock - 100000
					ADDS	R3,#1			;R3++ 
					B		divloop			;go divloop again, until systemcoreclock less than 100000
divdone
					POP     {R0}			;R0 = 0xE000E010
					LDR 	R1,=0x00000007	;r1 = 7
					STR		R1,[R0]			;store the r1 on the 0xE000E010
					SUBS	R3,#1			;r3--, r3 is the answer of division
					STR		R3,[R0,#4]		;store the r3 on the 0xE000E010 + 4 
					MOVS	R1,#0			;r1 = 0
					STR		R1,[R0,#8]		;store r1(0) on the 0xE000E010 + 8 
					POP		{R0-R3}			;restore saved registers
					POP		{PC}			;return
					ENDFUNC

Systick_Stop_asm 	FUNCTION
					PUSH	{LR}			;return value
					PUSH	{R1-R3}			;push r0-r3 for do not lose
					LDR 	R0,=0xE000E010	;r0 = address
					LDR  	R2,=0xFFFFFFFC	;for mask 
					LDR		R1,[R0]			;value of 0xE000E010
					ANDS	R1,R1,R2		;r1 and FFFFFFFC , clear
					STR		R1,[R0]			;store the new r1 in  0xE000E010
					LDR  	R0,=ticks		;address of ticks
					LDR		R1,[R0]			;value of ticks
					MOVS	R2,#0			;r2 = 0
					STR		R2,[R0]			;store 0 on ticks, clear ticks
					MOVS	R0,R1			;r0 = ticks value as a return
					POP		{R1-R3}			;restore saved registers
					POP		{PC}			;return
					ENDFUNC
					END
		
		
		