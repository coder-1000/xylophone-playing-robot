/*Keyboard*/

/*counter is r11*/

/*Read the make code, then the break code */

/*Read the interrupt enable bit*/
/*What do I do with the read interrupt pending bit?*/
/*Check the read interrupt pending*/

/*Enable the IRQ line 7 */
/*Set 0 in the ctrl register for read interrupts*/
/*How do I acknowledge the read interrupts?*/


/*start by checking the data received after checking for interrupts three times*/

.equ  PS_2, 0xFF200100
movia r8, PS_2
movi r1,1 		#setting 1 in the enable bit for reading interrupts
movi r3,3
wrctl ctl0, r0 	#enable read interrupts -- is this setting the PIE bit?
wrctl ctl3, 128 #enables the IRQ line 7 for the PS_2
stwio r1,4(r8)	#enable the read interrupts -- do we manually set this?
				

loop:

/*Acknowledge first interrupt*/
/*Enable the read interrupt enable*/

/* poll for valid bit*/

good:
ldwio r9, 0(r8)			#get the value from base+4 of the PS_2
srli r9,r9,15			#shift to get the valid bit for reading data
andi r9,r9,0x1			#extract the valid bit
bne r9,r1,good			# if the valid bit is not equal to 1, then keep polling

/*Read the data itself*/

ldwio r9,0(r8)
andi  r12, r9, 0x00FF 	/* Data read is now in r12 */
bne r11,r3,loop

