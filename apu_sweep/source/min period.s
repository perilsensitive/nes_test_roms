; Tests minimum period cutoff. When channel's raw period is less than
; 8, channel DAC receives 0 and sweep unit won't modify channel's period.
; Otherwise, channel plays.

CHAN=$4000

CUSTOM_TEXT=1
.include "apu_sweep.inc"

text:   .byte "2. Should play silence, another short tone, then a continuous "
	.byte "tone without any dropouts (volume may vary and may have regular"
	.byte "clicking sound).",0

.macro test sweep,pitch
	ldx #sweep
	ldy #pitch
	jsr make_tone
.endmacro

test_main:
	mov $4000,#$B0
	mov $4004,#$B0
	
	test $00,$07
	test $08,$07
	test $88,$07
	test $89,$08    ; sweep will lower period immediately to < 8
	test $A1,$07    ; sweep won't raise period
	delay_msec 500  ; give time for buggy sweep to modify period
	
	jsr short_tone
	
	test $00,$FF    ; reliably generate tone
	test $00,$08
	test $09,$08    ; sweep target < 8 but doesn't silence channel
	test $88,$08
	test $00,$FF    ; reliably generate tone
	mov $4015,#0
	
	rts

; Generates tone by toggling duty to manually generate low-frequency
; square wave.
.align 256
make_tone:
	; Get square to known phase for better consistency
	mov CHAN+1,#88
	mov CHAN+2,#0
	mov CHAN+3,#0
	delay 800
	
	; Set up square and clock sweep
	mov $4015,#$03
	mov CHAN+0,#$BF
	stx CHAN+1
	sty CHAN+2
	mov CHAN+3,#0
	mov $4017,#$C0
	mov $4017,#$C0
	
	; Toggle duty, then reset duty continuously for half cycle
	mov temp,#0
	ldy #0
	lda #$BF
@loop:
	delay 5         ; keep secondary tone a harmonic of main one
			; so it sounds more normal
	
	eor #$40        ; toggle duty
	sta CHAN+0

:       sty CHAN+3      ; keep resetting duty so timer can't clock it
	dex
	bne :-
	
	dec temp
	bne @loop
	
	rts

; nes_run_record "{active}" -d 20000 -t 4000; exit
