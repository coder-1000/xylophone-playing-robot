Code

# r14: push_buttons address

.equ PUSHBUTTONS, 0xFF200050

.global	_start

.data
song1:	# first hword is number of steps to go, next is direction (forward is 1, reversed is -1)
	.hword 3, 1
	.hword 1, -1
	.hword 1, -1
	.word 0
	# .skip 
  
.text
_start:	
	movia sp, 0x03FFFFFC  # initialize stack pointer

poll_button0:
	movia r14,PUSHBUTTONS
	# keep polling KEY[0] until it goes high
	ldwio r8,0(r14)
	andi r8,r8, 1	# only take value of KEY[0]
	beq r8,r0,poll_button0
	
	# if KEY[0] is pressed, send move_instructions to lego until we hit word 0, then we go back to poll KEY[0]
	
	movia r15,song1
loop_move_instructions:
	ldwio r8,0(r15)
	beq r8,r0,poll_button0
	ldhio r8,0(r15)	# first we get number of steps
	mov r4,r8
	ldhio r8,2(r15)	# next we get direction
	mov r5,r8
	
	subi sp,sp,4
	stwio r15,0(sp)
	call move_steps
	ldwio r15,0(sp)
	addi sp,sp,4
	
	addi r15,r15,4
	br loop_move_instructions
	
/*Registers used*
r8: address of the GPIO
r4: receiving register1
r5:receiving direction
r13: current value of sensors
r14: counter
r15:threshold*/

.equ ADDR_JP1, 0xFF200060	#address GPIO JP1

move_steps:
	subi sp,sp,4
	stwio ra,0(sp)
	
	movi r15,9
	movi r14,0

	movia r8, ADDR_JP1
	

	movia r9, 0x07F557FF	#set direction to all output
	stwio r9, 4(r8)
	
	movia r9, 0xFFFEFFFF	#enable sensor 3, disable all motors
	stwio r9, 0(r8)	
	call check_sensors

	condition:	
		/*check whether the sensor is higher than threshold*/

		beq r14,r4, STOP
		call check_direction
		blt r13, r15, WHITE	#it's in the light region
		bge r13,r15, BLACK	#it's in the dark region
		
	WHITE:
		call check_sensors
		bge r13,r15,counter
		br WHITE
	
	BLACK: 
		call check_sensors
		blt r13,r15,counter
		br BLACK
	
	counter:
		addi r14,r14,1
		br condition
	
	
	check_direction:
		blt r5,r0,REVERSE
		bge r5,r0,FORWARD
		
	FORWARD:
		/*Set the motor to run in the forward direction after checking the sensors*/
		movia r9, 0xFFFEFFFC	#motor0 enabled (bit 0=0), direction set to forward (bit1 =0)
		stwio r9, 0(r8)
		ret
		
	REVERSE:
		/*Set the motor to run in the reverse direction after checking the sensors*/
		movia r9, 0xFFFEFFFE	#motor0 enabled (bit 0=0), direction set to reverse (bit1 =1)
		stwio r9, 0(r8)
	ret
	
	check_sensors:
	/*check if the sensor has changed*/
	/*get current value of the sensor3*/
	
	loop:
		ldwio r13, 0(r8)
		srli r16,r13,17		#17 bit is valid for sensor 3
		andi r16,r16,0x1		#extract the valid bit
		bne  r0,r16,loop		#wait for valid bit to be low
	good:
		srli r13,r13,27		#shift to the right by 27 so that the 4-bit sensor value can be extracted
		andi r13,r13,0x0F	
	ret
	
	STOP:
		/*Stop the motors*/
		movia r9, 0xFFFEFFFF	#motor0 disabled (bit 0=1)
		stwio r9, 0(r8)	
		
		ldwio ra,0(sp)
		addi sp,sp,4
		ret	# return to get the next move_instructions