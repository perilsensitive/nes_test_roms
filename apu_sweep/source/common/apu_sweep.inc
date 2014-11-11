; Shell for listening tests

CUSTOM_PLAY=1 ; for NSF build
.include "shell.inc"

.ifndef CUSTOM_TEXT
	text:   .byte "2. Should be nearly silent.",0
.endif

main:
	jsr show_instructions
	jsr short_tone
	jsr test_main
	jsr short_tone
	jsr console_show
	rts


; Prints instructions for test
show_instructions:
	.ifdef BUILD_DEVCART
		rts
	.endif
	
	setw addr,filename
	jsr print_str_addr
	print_str " listening test",{newline,newline}
	
	print_str "1. Should play short tone.",{newline,newline}
	
	setw addr,text
	jsr print_str_addr
	print_str {newline,newline}
	
	print_str "3. Should play short tone.",{newline,newline}
	
	print_str "Some clicking might occur between the two tones."
	print_str "Also, a faint tone might be audible through headphones."
	print_str newline,newline
	
	.ifndef BUILD_NSF
		delay_msec 1000
		delay_msec 1000
		delay_msec 1000
	.endif
	
	rts


; Makes short tone, with silence on either side
short_tone:
	mov $4015,#0
	delay_msec 300
	mov $4015,#$01
	mov $4000,#$BF
	mov $4001,#$7F
	mov $4002,#$6F
	mov $4003,#$00
	delay_msec 300
	mov $4015,#0
	mov $4000,#$B0
	delay_msec 300
	rts


; Decrements 16-bit temp in constant time
; Time: 18 cycles
.macro dec_tempw
	lda temp
	sec
	sbc #1
	sta temp
	lda temp+1
	sbc #0
	sta temp+1
.endmacro

; Be sure user code doesn't cross pages, affecting timing
.align 256
