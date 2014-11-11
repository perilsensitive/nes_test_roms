; Tests sweep subtract mode.

CUSTOM_TEXT=1
.include "apu_sweep.inc"

text:   .byte "2. Should play continuous tone (with slight periodic clicks)."
	.byte "Half way through the pitch might lower very slightly.",0

test_main:
	mov $4001,#$00  ; clock sweep in case it had period of 8
	ldy #9
:       mov $4017,#$C0  ; synchronize apu
	dey
	bne :-
	
	mov $4015,#$01  ; enable square 1
	mov $4000,#$BF  ; volume = 15
	
	lda #0          ; test for period lsb = $ff
	jsr run_test
	
	lda #1          ; test for period lsb = $00
	jsr run_test
	
	mov $4015,#0    ; silence

	rts

run_test:
	sta temp
	ldy #7          ; y = current sweep shift
:
	lda table_l,y   ; square period
	clc
	adc temp
	sta $4002
	lda table_h,y
	sta $4003
	tya             ; sweep mode
	ora #$88
	sta $4001
	mov $4017,#$C0  ; clock sweep
	lda temp        ; set period high byte based on expected low byte
	clc             ; result is either $100 or $0FF
	adc #1
	sta $4003
	mov $4001,#0    ; disable sweep
	delay_msec 200
	dey
	bpl :-
	rts
	
	; Period that will yield $xFF after one sweep clock
	; while in subtract mode with given shift.
	; sweep shift 0   1   2   3   4   5   6   7
table_h:      .byte   1,  4,  2,  2,  2,  2,  2,  2
table_l:      .byte $FF,$00,$AA,$49,$22,$10,$08,$04

; nes_run_record "{active}" -d 20000 -t 2000; exit
