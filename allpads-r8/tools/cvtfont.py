#!/usr/bin/env python3
import sys
from PIL import Image
import pilbmp2nes
import chnutils
import textwrap
import argparse

def parse_argv(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("GLYPHIMG",
                        help="font image (8x16 pixels per glyph, 2bpp indexed color)")
    parser.add_argument("CHRFILE",
                        help="CHR file")
    parser.add_argument("-o", metavar="HALVESFILE", default='-',
                        help="filename for halves table")
    parser.add_argument("--segment", metavar="SEGMENT", default="RODATA",
                        help="segment name for halves table")
    parser.add_argument("--prefix", metavar="PREFIX", default="",
                        help="prefix for halves table")
    parser.add_argument("--tile-add", metavar="N", type=int, default=0,
                        help="number to add to halves table entries")
    parser.add_argument("--near-dupes", action='store_true',
                        help="find tiles differing by few pixels")
    return parser.parse_args(argv[1:])

def ca65_bytearray(s):
    s = ['  .byte ' + ','.join("%3d" % ch for ch in s[i:i + 16])
         for i in range(0, len(s), 16)]
    return '\n'.join(s)

def intweight(b):
    wt = 0
    while b:
        wt += 1
        b = b & (b - 1)
    return wt

def near_dupes_report(utiles, nam):

    # Build translation from unique tile numbers back to tiles
    # within glyphs
    invnam = {}
    for tilenumber, utilenumber in enumerate(nam):
        invnam.setdefault(utilenumber, tilenumber)

    # Compare glyphs of all tiles
    wts = []
    for i, t1 in enumerate(utiles):
        for jminusiminus1, t2 in enumerate(utiles[i+1:]):
            j = jminusiminus1 + i + 1
            xors = [t1b ^ t2b for t1b, t2b in zip(t1, t2)]
            wt = sum(intweight(p0 | p1) for p0, p1 in zip(xors[:8], xors[8:]))
            if wt < 4:
                wts.append((wt, i, j))
    wts.sort()
    lines = ['; Similar tile report:']
        
    halfnames = ['top', 'bottom']
    for wt, i, j in wts:
        iglyph, jglyph = (invnam[t] >> 1 for t in (i, j))
        ihalf, jhalf = (halfnames[invnam[t] & 1] for t in (i, j))
        tiglyph, tjglyph = (
            r"%s='\''" % g if g == 7
            else "%s='%c'" % (g, g + 32) if g < 95
            else "%s" % g
            for g in (iglyph, jglyph)
        )
        lines.append("; %d diff in %d (%s %s), %d (%s %s)"
                     % (wt, i, tiglyph, ihalf, j, tjglyph, jhalf))
    return '\n'.join(lines)

def main(argv=None):
    args = parse_argv(argv or sys.argv)
    im = Image.open(args.GLYPHIMG)
    tiles = pilbmp2nes.pilbmp2chr(im, tileWidth=8, tileHeight=16)
    utiles, nam = chnutils.dedupe_chr(tiles)
    with open(args.CHRFILE, 'wb') as outfp:
        outfp.writelines(utiles)

    if args.near_dupes:
        ndr = near_dupes_report(utiles, nam)
    else:
        ndr = ''

    # Form tab
    if args.tile_add:
        nam = [n + args.tile_add for n in nam]
    tophalves, bottomhalves = nam[0::2], nam[1::2]
    topname, bottomname = [
        args.prefix + n for n in ('tophalves', 'bottomhalves')
    ]
    halvestablesrc = "\n".join((
        "; Generated by cvtfont.py from %s" % args.GLYPHIMG,
        '.segment "%s"' % args.segment,
        ".export %s, %s" % (topname, bottomname),
        topname + ":",
        ca65_bytearray(tophalves),
        bottomname + ":",
        ca65_bytearray(bottomhalves),
        ndr,
        ''
    ))
    if args.o == '-':
        sys.stdout.write(halvestablesrc)
    else:
        with open(args.o, 'w') as outfp:
            outfp.write(halvestablesrc)
    

if __name__=='__main__':
    main()
##    main("cvtfont.py --near-dupes ../tilesets/fizztertiny.png fizztertiny.chr".split())
