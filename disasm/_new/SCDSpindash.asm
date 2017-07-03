;Sonic_SpinDash:
		btst	#0,$39(a0)
		bne.s	Sonic_SpinDashLaunch
		cmpi.b	#8,$1C(a0) ;check to see if your ducking
		bne.s	@return
		move.b	($FFFFF603).w,d0
		andi.b	#%01110000,d0
		beq.w	@return
		move.b	#1,$1C(a0)
		move.w	#0,$3A(a0)
		move.w	#$D3,d0
		jsr		(PlaySound_Special).l ; Play spindash charge sound
		addq.l	#4,sp
		bset	#0,$39(a0)
 
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
 
	@return:
		rts	
; ---------------------------------------------------------------------------
 
Sonic_SpinDashLaunch:
		move.b	#2,$1C(a0) ;charging spindash animation (walking to running to spindash sprites)
		move.b	#$E,$16(a0)			; Setup collision range
		move.b	($FFFFF602).w,d0
		btst	#1,d0
		bne.w	Sonic_SpinDashCharge
		bclr	#0,$39(a0)	; stop Dashing
		cmpi.b	#$1E,$3A(a0)	; have we been charging long enough?
		bne.s	Sonic_SpinDash_Stop_Sound	; if not, branch
		move.b	#$22,$1C(a0) ;charging spindash animation (walking to running to spindash sprites)

Sonic_SpinDashLaunch2:
		move.b	#2,$1C(a0)	; launches here (spindash sprites)
		bset	#2,$22(a0)			; set rolling bit
		move.b	#$E,$16(a0)			; Setup collision range
		move.w	#1,$10(a0)	; force X speed to nonzero for camera lag's benefit
		move.w	#$0A00,$14(a0)	;Set sonic's speed
		move.w	$14(a0),d0
		subi.w	#$800,d0
		add.w	d0,d0
		andi.w	#$1F00,d0
		neg.w	d0
		addi.w	#$2000,d0
		;move.w	d0,(v_cameralag).w
		btst	#0,$22(a0)
		beq.s	@dontflip
		neg.w	$14(a0)
	;	jmp 	Obj01_DoRoll
 
@dontflip:
		;bset	#2,$22(a0)
		bclr	#7,$22(a0)
		move.w	#$D4,d0
		jsr		(PlaySound_Special).l
		move.w	#$D6,d0
		jsr		(PlaySound_Special).l
		bra.w	Sonic_SpinDashResetScr
; ---------------------------------------------------------------------------
 
Sonic_SpinDashCharge:				; If still charging the dash...
		cmpi.b	#$1E,$3A(a0)
		beq.s	Sonic_SpinDashResetScr
		addi.b	#1,$3A(a0)
		jmp 	Sonic_SpinDashResetScr
		
Sonic_SpinDash_Stop_Sound:
		move.w	#$D4,d0
		jsr		(PlaySound_Special).l
		move.b	#$13,$16(a0)

Sonic_SpinDashResetScr:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,($FFFFF73E).w
		beq.s	@finish
		bcc.s	@skip
		addq.w	#4,($FFFFF73E).w
 
	@skip:
		subq.w	#2,($FFFFF73E).w
 
	@finish:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		rts
		