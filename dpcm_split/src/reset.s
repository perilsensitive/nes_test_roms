.p02
.include "src/nes.h"

OAM = $200

.segment "INESHDR"
.byt 'N','E','S',$1A
.byt 1, 1, 0, 0

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "ZEROPAGE"
irqs: .res 1
nmis: .res 1
irq_lag: .res 1
enable_timer: .res 1

.segment "CODE"
.proc irq_handler
  bit $4015  ; acknowledge dpcm irq
  inc irqs

  ; restart IRQ as the last thing in the handler
  pha
  lda enable_timer
  sta $4015
  pla  
  rti
.endproc

.proc nmi_handler
  inc nmis
  rti
.endproc

.proc reset_handler
  sei  ; IRQs while initializing hardware: OFF!
  ldx #$00
  stx PPUCTRL  ; Vblank NMI: OFF!
  stx PPUMASK  ; Rendering: OFF!
  stx $4015    ; DPCM and tone generators: OFF!
  stx enable_timer  ; ISR functionality: OFF!
  lda #$40
  sta $4017  ; APU IRQ: OFF!
  lda $4015  ; DPCM: ACK!
  cld  ; Decimal mode on famiclones: OFF!
  lda PPUSTATUS  ; Vblank NMI: ACK!
  dex
  txs  ; Stack: TOP!

vwait1:
  lda PPUSTATUS
  bpl vwait1
  
  ; Clear zero page and sprite page
  ; (the demo doesn't use anything else)
  ldx #0
  txa
clear_zeropage:
  sta $00,x
  inx
  bne clear_zeropage
  lda #$F0
clear_OAM:
  sta OAM,x
  inx
  bne clear_OAM
vwait2:
  lda PPUSTATUS
  bpl vwait2

  ; Clear a nametable
  lda #$20
  sta PPUADDR
  stx PPUADDR
  txa
clear_vram:
  .repeat 4
    sta PPUDATA
  .endrepeat
  inx
  bne clear_vram
  
  ; Write a green-tinted palette to the PPU to show that the program
  ; counter has reached this point
  lda #$3F
  sta PPUADDR
  ldx #$00
  stx PPUADDR
set_initial_palette:
  lda initial_palette,x
  sta PPUDATA
  inx
  cpx #32
  bcc set_initial_palette
  
  jsr sayHello
  
  
  ; # START ###############################################

  ; set up sprite 0
  lda #$00
  sta PPUMASK
  lda #$4F
  sta OAM
  lda #$5D
  sta OAM+1
  lda #$00
  sta OAM+2
  lda #$60
  sta OAM+3

  lda #%10000000   ; nmi enable
  sta PPUCTRL

  lda #$0F
  sta $4015

  lda #$8F
  sta $4010
  lda #0
  sta $4012
  lda #0
  sta $4013

  lda #$1F
  sta enable_timer
  sta $4015
  cli

  lda #$80
  sta PPUCTRL
  lda #$0
  sta PPUSCROLL
  sta PPUSCROLL
  lda #%00011110
  sta PPUMASK
forever:
  lda nmis
:
  cmp nmis
  beq :-
  lda #$00
  sta $2003
  lda #>OAM
  sta OAM_DMA
  lda #0
  sta PPUSCROLL
  sta PPUSCROLL
  lda #%10000000
  sta PPUCTRL

  ; Wait for sprite zero
  sei
wait_end_frame:
  bit PPUSTATUS
  bvs wait_end_frame
wait_for_sprite_0:
  bit PPUSTATUS
  bmi forever
  bvc wait_for_sprite_0

  ; Waste a little time waiting for the right point on the scanline
  inc     nmis
  dec     nmis
  inc     nmis
  dec     nmis
  inc     nmis
  dec     nmis
  lda     nmis
  sta PPUSCROLL

  ; Count how long it takes from to DMC IRQ
  lda $4015
  cli
  ldy #$00
  sty irqs
count_lag:
  iny
  lda irqs
  beq count_lag
  sty irq_lag

  ; Wait for ten IRQs to have passed
  lda #10
wait_for_irq:
  cmp irqs
  bcs wait_for_irq
  sei
  lda irq_lag
  eor #$FF
  adc #$40
  tay
LC24D:
  lda irqs
  dey
  bne     LC24D
  lda     #$00
  sta     PPUSCROLL
  sta     PPUSCROLL
  ldx     #$1F
  stx     PPUMASK
  inc     nmis
  dec     nmis
  dex
  stx     PPUMASK
  cli

  jmp forever
.endproc

.proc sayHello
  lineIdx = 2
  vramDstHi = 3
  vramDstLo = 4
  
  lda #0
  sta lineIdx
  lda #$20
  sta vramDstHi
  lda #$A2
  sta vramDstLo
  
lineloop:
  ldx lineIdx
  lda helloLines,x
  sta 0
  inx
  lda helloLines,x
  sta 1
  inx
  stx lineIdx
  ora #0  ; skip null pointers
  beq skipLine
  lda vramDstHi
  ldx vramDstLo
  jsr puts
skipLine:
  
  lda vramDstLo
  clc
  adc #64
  sta vramDstLo
  lda vramDstHi
  adc #0
  sta vramDstHi
  lda lineIdx
  cmp #20
  bcc lineloop
  
  lda PPUSTATUS
  lda #$80
  sta PPUCTRL
  lda nmis
:
  cmp nmis
  beq :-
  lda PPUSTATUS

  rts
.endproc

.proc puts
  sta PPUADDR
  stx PPUADDR
  pha
  txa
  pha
  ldy #0
copyloop1:
  lda (0),y
  beq after_copyloop1
  asl a
  sta PPUDATA
  iny
  bne copyloop1
after_copyloop1:
  
  pla
  clc
  adc #32
  tax
  pla
  adc #0
  sta PPUADDR
  stx PPUADDR
  ldy #0
copyloop2:
  lda (0),y
  beq after_copyloop2
  sec
  rol a
  sta PPUDATA
  iny
  bne copyloop2
after_copyloop2:
  rts
.endproc

.segment "RODATA"
initial_palette:
  .byt $0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A
  .byt $0A,$16,$26,$36,$0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A,$0A,$1A,$2A,$3A
helloLines:
  .addr hello1, 0, hello2, hello3, hello4, hello5, hello6, hello7, 0, hello8

hello1: .byt "Dear nesdev,",0
hello2: .byt "Look at me! I'm Codemasters!",0
hello3: .byt "I can split the screen in 2",0
hello4: .byt "places without a mapper IRQ,",0
hello5: .byt "as long as I don't play",0
hello6: .byt "sampled sound.",0
hello7: .byt "",0
hello8: .byt "          Your friend, Pino",0

.segment "DMC"
.align 64
.byt $AA
