include svgscript.f

800e 800e viewport

s" windrose.svg" {svg
: rm rmoveto ;
: rl rlineto ;
: FS gsave setgray nzfill grestore stroke ;
: halfray
   gsave 0e 100e rm 0e -100e rl 45e rotate 30e 0e rl
   closepath FS grestore ;
: ray
   gsave 0.5e halfray grestore
   gsave -1e 1e scale 0.9e halfray grestore ;
: star 4 0 do ray 90e rotate loop ;
: windrose
   currentpoint translate gsave 0.9e 0.9e scale
   45e rotate star grestore star ;
400e 300e moveto windrose
svg}

s" hilbert.svg" {svg

: S 0e 8e rlineto currentpoint stroke moveto ;
: T 90e rotate ;
: TM T 1e -1e scale ;

: H
   TM fdup 0e f> if 1e f- recurse S TM recurse S recurse
     T S -1e 1e scale recurse 180e rotate 1e f+ then TM ;

400e 400e moveto 5e H fdrop

svg}

s" text.svg" {svg

: verdana s" Verdana" 42.5e selectfont ;
: helvetica s" Helvetica" 42.5e selectfont ;
: times s" Times New Roman" 42.5e selectfont ;
: T moveto show ;

verdana s" SvgScript" 400e 400e T
helvetica s" SvgScript" 400e 450e T
times s" SvgScript" 400e 500e T

svg}

s" heart.svg" {svg

fvariable 'size

: size 'size f@ ;

: offset size 4e f/ ;

: RelativeHeart
   'size f! 0e 0e moveto
   size size offset size offset f+ 0e size rcurveto
   offset fnegate offset size fnegate 0e 0e size
   fnegate rcurveto ;

: inch 72e f* ;

4.25e inch 1e inch translate
8e inch RelativeHeart
1.0e 0.0e 0.5e setcolor nzfill

svg}

s" boxes.svg" {svg

0.1e setgray 1e inch 1.0e inch 3e inch 3e inch rectfill
0.3e setgray 2e inch 2.5e inch 3e inch 3e inch rectfill
0.5e setgray 3e inch 4.0e inch 3e inch 3e inch rectfill
0.7e setgray 4e inch 5.5e inch 3e inch 3e inch rectfill
0.9e setgray 5e inch 7.0e inch 3e inch 3e inch rectfill

svg}
