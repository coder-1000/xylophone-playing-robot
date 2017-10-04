.equ ADDR_AUDIODACFIFO, 0xFF203040

.global _start

_start:
movia r2, ADDR_AUDIODACFIFO
movi r9,0
movi r10, 5000

#Set up the square wave's positive pulse
preloop1:
movia r3, 99999999
movia r4, 0x55


#Send 22 outputs to the FIFO
loop1:
stwio r3, 8(r2)
stwio r3, 12(r2)
subi r4, r4, 1
addi r9,r9,1
beq r4, r0, preloop2
beq r9,r10,END
br loop1


#Set up the square wave's negative pulse
preloop2:
movia r3, -99999999
movia r4, 0x55


#Send 22 outputs to the FIFO
loop2:
stwio r3, 8(r2)
stwio r3, 12(r2)
subi r4, r4, 1
addi r9,r9,1
beq r9,r10,END
beq r4, r0, preloop1
br loop2

END:

br END

