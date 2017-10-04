
/*Making the motor move*/


	.global	_start

	.equ ADDR_JP1, 0xFF200060	#address GPIO JP1
	
	movia r8, ADDR_JP1

	movia r9, 0x07F557FF	#set direction to all output
	stwio r9, 4(r8)

	movia r9, 0xFFFEFFF3	#motor1 enabled (bit 0=0), direction set to forward (bit1 =0)
	stwio r9, 0(r8)	
	
	call timer
	
	movia r9, 0xFFFEFFFB	#motor1 enabled (bit 0=0), direction set to reverse (bit1 =1)
	stwio r9, 0(r8)	
	
	call timer
	
	movia r9, 0xFFFEFFFF	#enable sensor 3, disable all motors
	stwio r9, 0(r8)	
	
	

/*Timer*/


timer:

	addi sp, sp, -24
	stw ra, 0(sp)
	stw r2, 4(sp)
	stw r3, 8(sp)
	stw r7, 12(sp)
	stw r4, 16(sp)
	stw r6, 20(sp)
	
	movia r7, 0xFF202000
	addi r2, r0, 0x8
	stwio r2, 4(r7)
	movi r4, 4
	addi r2, r0, %lo (262150) 
	addi r3, r0, %hi (262150)

	stwio r2, 8(r7)
	stwio r3, 12(r7)
	stwio r4, 4(r7)
Loop:
	ldwio r6, 0(r7)
	andi r6, r6, 0x1
	beq r6, r0, Loop


	addi r2, r0, 0x8
	stwio r2, 4(r7)
	stwio r0, 0(r7)
	
	ldw r6, 20(sp)
	ldw r4, 16(sp)
	ldw r7, 12(sp)
	ldw r3, 8(sp)
	ldw r2, 4(sp)
	ldw ra, 0(sp)
	
	addi sp, sp, 24

	ret