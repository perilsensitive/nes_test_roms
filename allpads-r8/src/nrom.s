.segment "INESHDR"
.include "nes2header.inc"
nes2prg 32768
nes2chrram 8192
nes2mapper 0
nes2mirror 'V'
nes2tv 'N','P'
nes2end

.segment "VECTORS"
.import nmi_handler, reset_handler, irq_handler
.addr nmi_handler, reset_handler, irq_handler

.rodata
.export font_chr
.exportzp FONT_NUM_TILES
font_chr: .incbin "obj/nes/fizzter.chr.pb53"
FONT_NUM_TILES = 160
