; Tests sweep add mode and silencing of square when resulting period is
; greater than $7FF.

CHAN=$4000

CUSTOM_TEXT=1
.include "apu_sweep.inc"

text:   .byte "2. Should make silence, short beep, several tones without "
	.byte "any silence between, then a tone sweep up.",0

test_main:
	mov $4015,#$03
	
	; Do things which shouldn't make any sound
	
	mov CHAN+2,#7   ; period = 7, should be silenced and not sweep
	sta CHAN+2
	mov CHAN+3,#0
	mov CHAN+0,#$BF ; volume = 15
	mov CHAN+1,#$A1 ; try to increase period using sweep
	delay_msec 200
	
	lda #1          ; maximum square periods + 1
	jsr test_cutoffs
	
	mov $4017,#$40  ; synchronize apu
	mov CHAN+2,#16  ; period = 16
	mov CHAN+3,#0
	mov CHAN+1,#$89 ; sweep period down to 7
	mov $4017,#$C0  ; clock sweep; period should be 7, resulting in silence
	mov CHAN+1,#$91 ; try to sweep period up in case it's 8 or more
	delay_msec 200
	
	jsr short_tone
	
	; Do things which shouldn't leave any silence
	
	mov $4015,#$03
	
	mov CHAN+1,#$08 ; sweep = subtract mode
	mov CHAN+2,#$FF ; period = $7ff shouldn't be silenced
	mov CHAN+3,#$7
	delay_msec 200
	
	lda #0          ; maximum square periods
	jsr test_cutoffs
	
	mov CHAN+2,#8   ; period = 8 should be audible and sweepable
	mov CHAN+1,#$91 ; sweep period up for lower, more-audible pitch
	mov CHAN+3,#0   ; start
	delay_msec 200
	
	mov $4015,#0    ; silence

	rts

test_cutoffs:
	sta temp
	ldy #7          ; y = current sweep shift
:       mov CHAN+0,#$B0 ; volume = 0
	sty CHAN+1      ; sweep shift
	lda cutoffs_l,y ; square period
	clc
	adc temp
	sta CHAN+2
	lda #0
	adc cutoffs_h,y
	sta CHAN+3
	mov CHAN+0,#$BF ; volume = 15
	delay_msec 200
	dey
	bpl :-
	rts
	
	; Maximum square period before silencing for each sweep shift
	; sweep shift 0   1   2   3   4   5   6   7
cutoffs_h:    .byte   3,  5,  6,  7,  7,  7,  7,  7
cutoffs_l:    .byte $FF,$55,$66,$1C,$87,$C1,$E0,$F0

; nes_run_record "{active}" -d 20000 -t 4000; exit
