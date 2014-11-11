CC65 = /usr/local/bin
AS65 = $(CC65)/ca65
LD65 = $(CC65)/ld65
EMU := fceu
CC = gcc
ifdef COMSPEC
DOTEXE=.exe
else
DOTEXE=
endif
CFLAGS = -std=gnu99 -Wall -DNDEBUG -O
CFLAGS65 = 
objdir = obj/nes
srcdir = src
imgdir = tilesets

objlist = reset
objlistntsc = $(foreach o,$(objlist),$(objdir)/$(o).o)

.PHONY: run

run: dpcmsplit.nes
	$(EMU) $<

$(objdir)/%.o: $(srcdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

map.txt dpcmsplit.prg: nes.ini $(objlistntsc)
	$(LD65) -C $^ -m map.txt -o dpcmsplit.prg

$(objdir)/ac16.chr: $(imgdir)/ac16.png
	tools/pilbmp2nes.py -H 16 $< $@

%.nes: %.prg %.chr
	cat $^ > $@

dpcmsplit.chr: $(objdir)/ac16.chr
	cat $(objdir)/ac16.chr $(objdir)/ac16.chr > $@

