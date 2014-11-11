; Initializes synchronization and enables NMI on PAL NES
; Preserved: X, Y
; Time: about 20 frames
init_nmi_sync_pal:
	; NMI will first occur within frame 2 after
	; synchronization
	lda #2
	sta nmi_sync_count
	
	; Disable interrupts and rendering
	sei
	lda #0
	sta $2000
	sta $2001
	
	; Coarse synchronize
	bit $2002
init_nmi_sync_pal_1:
	bit $2002
	bpl init_nmi_sync_pal_1
	
	; Synchronize to odd CPU cycle
	sta $4014
	bit <0
	
	; Fine synchronize
init_nmi_sync_pal_2:
	bit <0
	nop
	bit $2002
	bit $2002
	bpl init_nmi_sync_pal_2
	
	; Enable NMI
	lda #$80
	sta $2000
	
	rts


; Waits until NMI occurs.
; Preserved: A, X, Y
wait_nmi:
	pha
	
	; Reset high/low flag so NMI can depend on it
	bit $2002
	
	; NMI must not occur during taken branch, so we
	; only use branch to get out of loop.
	lda nmi_sync_count
wait_nmi_1:
	cmp nmi_sync_count
	bne wait_nmi_2
	jmp wait_nmi_1
wait_nmi_2:
	pla
	rts


; Must be called in NMI handler, before sprite DMA.
; Preserved: X, Y
begin_nmi_sync:
	lda nmi_sync_count
	and #$02
	beq begin_nmi_sync_1
begin_nmi_sync_1:
	rts


; Must be called after sprite DMA. Instructions before this
; must total 1715 (NTSC)/6900 (PAL) cycles, treating
; JSR begin_nmi_sync and STA $4014 as taking 10 cycles total) 
; Next instruction will begin 2286 (NTSC)/7471 (PAL) cycles
; after the cycle that the frame began in.
; Preserved: X, Y
end_nmi_sync:
	lda nmi_sync_count
	inc nmi_sync_count
	and #$02
	bne end_nmi_sync_1
end_nmi_sync_1:
	lda $2002
	bmi end_nmi_sync_2
end_nmi_sync_2:
	bmi end_nmi_sync_3
end_nmi_sync_3:
	rts


; Keeps track of synchronization on frames where no
; synchronization is needed (where begin_nmi_sync/end_nmi_sync
; aren't called).
; Preserved: A, X, Y
track_nmi_sync:
	inc nmi_sync_count
	rts
