		btst   	#0,$39(a0)		; already Spin Dashing?
		bne.w	loc2_1AC8E		; if set, branch
		cmpi.b	#8,$1C(a0)		; is anim duck
		bne.s	locret2_1AC8C		; if not, return
		move.b	($FFFFF603).w,d0	; read controller
		andi.b	#$70,d0			; pressing A/B/C ?
		beq.w	locret2_1AC8C		; if not, return

Dropdash_To_Spindash:
		move.b	#$1F,$1C(a0)		; set Spin Dash anim (9 in s2)
		move.w	#$D1,d0			; spin sound ($E0 in s2)
		jsr	(PlaySound_Special).l	; play spin sound
		addq.l	#4,sp			; increment stack ptr
		bset 	#0,$39(a0)		; set Spin Dash flag
		move.w	#0,$3A(a0)		; set charge count to 0
		cmpi.b	#$C,$28(a0)		; ??? oxygen remaining?
		move.b	#2,($FFFFD1DC).w	; Set the Spin Dash dust animation to $2
 
loc2_1AC84:
		jsr	Sonic_LevelBound
		jsr	Sonic_AnglePos
 
locret2_1AC8C:
		rts	

Dropdash_Activate:
		move.b	($FFFFF604).w,d0	; read controller
		andi.b	#$70,d0			; pressing A/B/C ?
		beq.w	locret2_1AC8C		; if not, return
		addq.l	#4,sp			; increment stack ptr
		bset 	#0,$39(a0)		; set Spin Dash flag
		move.w	#0,$3A(a0)		; set charge count to 0
		cmpi.b	#$C,$28(a0)		; ??? oxygen remaining?
		bra.s 	loc2_1AC84

; ---------------------------------------------------------------------------
 
loc2_1AC8E:
		move.b	#$1F,$1C(a0)
		move.b	($FFFFF602).w,d0	; read controller
		btst	#1,d0			; check down button
		bne.w	loc2_1AD30		; if set, branch
		move.b	#$E,$16(a0)		; $16(a0) is height/2
		move.b	#7,$17(a0)		; $17(a0) is width/2
		move.b	#2,$1C(a0)		; set animation to roll
		addq.w	#5,$C(a0)		; $C(a0) is Y coordinate
		bclr 	#0,$39(a0)		; clear Spin Dash flag
		moveq	#0,d0
		move.b	$3A(a0),d0		; copy charge count
		add.w	d0,d0			; double it
		move.w	spdsh_norm(pc,d0.w),$14(a0) ; get normal speed
		tst.b	($FFFFFE19).w		; is sonic super?
		beq.s	loc2_1ACD0		; if no, branch
		move.w	spdsh_super(pc,d0.w),$14(a0) ; get super speed
 
loc2_1ACD0:					; TODO: figure this out
		move.w	$14(a0),d0		; get inertia
		subi.w	#$800,d0		; subtract $800
		add.w	d0,d0			; double it
		andi.w	#$1F00,d0		; mask it against $1F00
		neg.w	d0			; negate it
		addi.w	#$2000,d0		; add $2000
		move.w	d0,($FFFFC904).w	; move to $EED0
		btst	#0,$22(a0)		; is sonic facing right?
		beq.s	loc2_1ACF4		; if not, branch
		neg.w	$14(a0)			; negate inertia
 
loc2_1ACF4:
		bset	#2,$22(a0)		; set unused (in s1) flag
		move.b	#0,($FFFFD1DC).w	; clear Spin Dash dust animation
		move.w	#$BC,d0			; spin release sound
		jsr	(PlaySound_Special).l	; play it!
		move.b	#8,($FFFFFF5B).w 	; set afterimage counter to 8
		bra.s	loc2_1AD78
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
spdsh_norm:
		dc.w  $800		; 0
		dc.w  $880		; 1
		dc.w  $900		; 2
		dc.w  $980		; 3
		dc.w  $A00		; 4
		dc.w  $A80		; 5
		dc.w  $B00		; 6
		dc.w  $B80		; 7
		dc.w  $C00		; 8
 
spdsh_super:
		dc.w  $B00		; 0
		dc.w  $B80		; 1
		dc.w  $C00		; 2
		dc.w  $C80		; 3
		dc.w  $D00		; 4
		dc.w  $D80		; 5
		dc.w  $E00		; 6
		dc.w  $E80		; 7
		dc.w  $F00		; 8
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
 
loc2_1AD30:				; If still charging the dash...
		tst.w	$3A(a0)		; check charge count
		beq.s	loc2_1AD48	; if zero, branch
		move.w	$3A(a0),d0	; otherwise put it in d0
		lsr.w	#5,d0		; shift right 5 (divide it by 32)
		sub.w	d0,$3A(a0)	; subtract from charge count
		bcc.s	loc2_1AD48	; ??? branch if carry clear
		move.w	#0,$3A(a0)	; set charge count to 0
 
loc2_1AD48:
		move.b	($FFFFF603).w,d0	; read controller
		andi.b	#$70,d0			; pressing A/B/C?
		beq.w	loc2_1AD78		; if not, branch
		move.w	#$1F00,$1C(a0)		; reset spdsh animation
		move.w	#$D1,d0			; was $E0 in sonic 2
		move.b	#2,$FFFFD1DC.w	; Set the Spin Dash dust animation to $2.
		jsr	(PlaySound_Special).l	; play charge sound
		addi.w	#$200,$3A(a0)		; increase charge count
		cmpi.w	#$800,$3A(a0)		; check if it's maxed
		bcs.s	loc2_1AD78		; if not, then branch
		move.w	#$800,$3A(a0)		; reset it to max
 
loc2_1AD78:
		addq.l	#4,sp			; increase stack ptr
		cmpi.w	#$60,($FFFFF73E).w
		beq.s	loc2_1AD8C
		bcc.s	loc2_1AD88
		addq.w	#4,($FFFFF73E).w
 
loc2_1AD88:
		subq.w	#2,($FFFFF73E).w
 
loc2_1AD8C:
		jsr	Sonic_LevelBound
		jsr	Sonic_AnglePos
		;move.w	#$60,($FFFFF73E).w	; reset looking up/down
		rts
; End of function Sonic_SpinDash