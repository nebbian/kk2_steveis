.def Item		= r17

AdvancedSettings2:

bsux11:	call LcdClear
	
	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1,0		;servo on arm
	lrv Y1,1
	mPrintString bsux1
	ldz eeServoOnArm
	call GetEeVariable8 
	brflagfalse xl, bsux30
	mPrintString bsux28
	rjmp bsux31sm
bsux30:	mPrintString bsux29


bsux31sm:	lrv X1, 0		;SL Stick Mixing
	lrv Y1, 10
	mPrintString bsux2
	ldz eeSlPgainRate
	call GetEeVariable8
	tst xl
	brne bsux32sm

	mPrintString srr7	;off
	rjmp bsux32

bsux32sm:	cpi xl, 0x04
	brne bsux33sm

	mPrintString srr8	;low
	rjmp bsux32

bsux33sm:	cpi xl, 0x01
	brne bsux34sm

	mPrintString srr10	;high
	rjmp bsux32

bsux34sm:	mPrintString srr9	;medium
	rjmp bsux32

bsux32:

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString bsux6

	;print selector
	ldzarray bsux7*2, 4, Item
	lpm t, z+
	sts X1, t
	lpm t, z+
	sts Y1, t
	lpm t, z+
	sts X2, t
	lpm t, z
	sts Y2, t
	lrv PixelType, 0
	call HilightRectangle

	call LcdUpdate

	call GetButtonsBlocking

	cpi t, 0x08		;BACK?
	brne bsux8
	ret	

bsux8:	cpi t, 0x04		;PREV?
	brne bsux9	
	dec Item
	brpl bsux10
	ldi Item, 0
bsux10:	rjmp bsux11	

bsux9:	cpi t, 0x02		;NEXT?
	brne bsux12
	inc Item
	cpi item, 2		; Select the first item when we press "next" on the last one
	brne bsux13
	ldi Item, 0
bsux13:	rjmp bsux11	

bsux12:	cpi t, 0x01		;CHANGE?
	brne bsux14

	cpi Item, 0		; If the first menu item is currently active, then..
	brne bsux15

	ldzarray eeServoOnArm, 1, Item	;toggle flag
	call GetEeVariable8
	ldi t, 0x80
	eor xl, t
	ldzarray eeServoOnArm, 1, Item
	call StoreEeVariable8

	rjmp bsux11


bsux15:
	cpi Item, 1		; If the second menu item is currently active, then..
	brne bsux14

	rcall SetReductionRate
	rjmp bsux11



bsux14: rjmp bsux11	; Start loop again


SetReductionRate:
	call LcdClear

	lrv PixelType, 1
	lrv FontSelector, f6x8

	lrv X1, 46				;Header
	lrv Y1, 5
	mPrintString srr1

	lrv X1, 0
	lrv Y1, 17
	mPrintString srr2

	lrv X1, 0
	lrv Y1, 26
	mPrintString srr3

	lrv X1, 0
	lrv Y1, 35
	mPrintString srr4

	;footer
	lrv X1, 0
	lrv Y1, 57
	mPrintString srr6

	call LcdUpdate

	call GetButtonsBlocking
	andi t, 0x07				;OFF is zero
	mov xl, t
	ldz eeSlPgainRate
	call StoreEeVariable8
	call ReleaseButtons
	ret


bsux1:	.db "Servos On Arm  : ", 0
bsux2:	.db "SL Stick Mixing: ", 0
bsux6:	.db "BACK PREV NEXT CHANGE", 0
bsux28:	.db "Yes",0
bsux29:	.db "No",0,0

srr1:	.db "CHANGE", 0, 0
srr2:	.db "Select reduction rate", 0
srr3:	.db "for SL P-gain used in", 0
srr4:	.db "SL Stick Mixing mode.", 0
srr6:	.db "OFF  LOW  MEDIUM HIGH", 0
srr7:	.db "Off", 0
srr8:	.db "Low", 0
srr9:	.db "Med.", 0, 0
srr10:	.db "High", 0, 0



bsux7:	.db 100, 0, 122, 9
	.db 100, 9, 122, 18

.undef Item