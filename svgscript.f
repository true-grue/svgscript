\ Author: Peter Sovietov
\ SvgScript 20090105, PostScript-like graphics in Forth

1024 constant #gstates
8192 constant #segments

16 floats constant /gstate
3 floats constant /segment

create gstate0 #gstates /gstate * allot
create path0 #segments /segment * allot
create tm 6 floats allot

variable gstate

: :gstate ( n - a) floats gstate @ + ;
: 'ctm ( - a) gstate @ ;
: 'newpath ( - a) 6 :gstate ;
: 'path ( - a) 7 :gstate ;
: 'subpath ( - a) 8 :gstate ;
: 'rgb ( - a) 9 :gstate ;
: 'linewidth ( - a) 12 :gstate ;
: 'fontfamily ( - a) 13 :gstate ;
: 'fontsize ( - a) 15 :gstate ;

: /path ( - #) 'path @ 'newpath @ - ;
: gsave gstate @ dup /gstate + dup gstate ! /gstate move ;
: grestore
   gstate @ gstate0 - if /gstate negate gstate +! then ;

: ctm@ ( n - f: x) floats 'ctm + f@ ;
: ctm:a ( - f: a) 0 ctm@ ;
: ctm:b ( - f: b) 1 ctm@ ;
: ctm:c ( - f: c) 2 ctm@ ;
: ctm:d ( - f: d) 3 ctm@ ;
: ctm:x ( - f: x) 4 ctm@ ;
: ctm:y ( - f: y) 5 ctm@ ;

: :cp ( n - a) floats 'path @ + ;
: 'o ( - a) -3 :cp ;
: 'x ( - a) -2 :cp ;
: 'y ( - a) -1 :cp ;

: 'x0 ( - a) -2 floats 'subpath @ + ;
: 'y0 ( - a) -1 floats 'subpath @ + ;

: tm@ ( n - f: x) floats tm + f@ ;
: tm:a ( - f: a) 0 tm@ ;
: tm:b ( - f: b) 1 tm@ ;
: tm:c ( - f: c) 2 tm@ ;
: tm:d ( - f: d) 3 tm@ ;
: tm:x ( - f: x) 4 tm@ ;
: tm:y ( - f: y) 5 tm@ ;

: :tm! ( f: x s: n) floats tm + f! ;
: tm:a! ( f: a) 0 :tm! ;
: tm:b! ( f: b) 1 :tm! ;
: tm:c! ( f: c) 2 :tm! ;
: tm:d! ( f: d) 3 :tm! ;
: tm:x! ( f: x) 4 :tm! ;
: tm:y! ( f: y) 5 :tm! ;

: 6f! ( f: a b c d x y s: a)
   dup 5 floats + do i f! -1 floats +loop ;
: ctm! ( f: a b c d x y) 'ctm 6f! ;
: tm! ( f: a b c d x y) tm 6f! ;
: identctm 1e 0e 0e 1e 0e 0e ctm! ;
: transform
   'x f@ fdup ctm:a f* 'y f@ ctm:c f* f+ ctm:x f+ 'x f!
   ctm:b f* 'y f@ ctm:d f* f+ ctm:y f+ 'y f! ;
: det(ctm) ( - f: n)
   ctm:a ctm:d f* ctm:b ctm:c f* f-
   fdup f0= abort" undefinedresult" ;
: -tm:a! ( f: d - f: d) ctm:d fover f/ tm:a! ;
: -tm:b! ( f: d - f: d) ctm:b fnegate fover f/ tm:b! ;
: -tm:c! ( f: d - f: d) ctm:c fnegate fover f/ tm:c! ;
: -tm:d! ( f: d - f: d) ctm:a fover f/ tm:d! ;
: -tm:x! ctm:x tm:a f* ctm:y tm:c f* f+ fnegate tm:x! ;
: -tm:y! ctm:x tm:b f* ctm:y tm:d f* f+ fnegate tm:y! ;
: -tm
   det(ctm) -tm:a! -tm:b! -tm:c! -tm:d! fdrop -tm:x! -tm:y! ;
: itransform ( - f: x y)
   -tm 'x f@ tm:a f* 'y f@ tm:c f* f+ tm:x f+
   'x f@ tm:b f* 'y f@ tm:d f* f+ tm:y f+ ;

: ctm:a' ( - f: a) tm:a ctm:a f* tm:b ctm:c f* f+ ;
: ctm:b' ( - f: b) tm:a ctm:b f* tm:b ctm:d f* f+ ;
: ctm:c' ( - f: c) tm:c ctm:a f* tm:d ctm:c f* f+ ;
: ctm:d' ( - f: d) tm:c ctm:b f* tm:d ctm:d f* f+ ;
: ctm:x' ( - f: x) tm:x ctm:a f* tm:y ctm:c f* f+ ctm:x f+ ;
: ctm:y' ( - f: y) tm:x ctm:b f* tm:y ctm:d f* f+ ctm:y f+ ;
: ctm* ctm:a' ctm:b' ctm:c' ctm:d' ctm:x' ctm:y' ctm! ;

: translate ( f: x y)
   1e tm:a! 0e tm:b! 0e tm:c! 1e tm:d! tm:y! tm:x! ctm* ;
: scale ( f: x y)
   0e tm:b! 0e tm:c! 0e tm:x! 0e tm:y! tm:d! tm:a! ctm* ;
: >rad ( f: d - f: r) 0.0174532925e f* ;
: rotate ( f: n)
   >rad fdup fcos tm:a! fdup fsin tm:b! fdup fnegate
   fsin tm:c! fcos tm:d! 0e tm:x! 0e tm:y! ctm* ;

: path? /path 0= abort" nocurrentpoint" ;
: +segment ( f: x y) path? /segment 'path +! 'y f! 'x f! ;
: oldpath ( - a)
   gstate @ gstate0 = if path0 exit then -9 :gstate @ ;
: newpath oldpath dup 'newpath ! 'path ! 0 'subpath ! ;
: currentpoint ( - f: x y) path? itransform ;
: /newpath ( - #) 'path @ oldpath - ;
: +moveto
   /newpath if 'o @ 0= if exit then then /segment 'path +! ;
: moveto ( f: x y)
   +moveto 'y f! 'x f! 0 'o ! transform 'path @ 'subpath ! ;
: >absolute ( f: x y - f: x' y')
   currentpoint frot f+ frot frot f+ fswap ;
: rmoveto ( f: x y) >absolute moveto ;
: lineto ( f: x y) +segment 1 'o ! transform ;
: rlineto ( f: x y) >absolute lineto ;
: +curveto ( f: x y) +segment 2 'o ! transform ;
: curveto ( f: x1 y1 x2 y2 x3 y3)
   tm! tm:a tm:b +curveto tm:c tm:d +curveto
   tm:x tm:y +curveto ;
: rcurveto ( f: x1 y1 x2 y2 x3 y3)
   0 :cp 6f! 0 :cp f@ 1 :cp f@ >absolute 2 :cp f@ 3 :cp f@
   >absolute 4 :cp f@ 5 :cp f@ >absolute curveto ;
: closepath
   'subpath @ if 'x0 f@ 'y0 f@ +segment 1 'o !
     0 'subpath ! then ;

: setlinewidth ( f: n) 'linewidth f! ;
: setcolor ( f: r g b)
   0 2 do 255e f* fround f>d drop 'rgb i floats + ! -1 +loop ;
: setgray ( f: n) fdup fdup setcolor ;
: selectfont ( s n f: n)
   ctm:d f* fabs 'fontsize f! 'fontfamily 2! ;
: initgraphics
   gstate0 gstate ! identctm newpath 0e setgray
   1e setlinewidth s" " 0e selectfont ;

\ SVG output

8 constant /f

variable svg:fd

fvariable svg:width
fvariable svg:height

: >svg ( s n) svg:fd @ write-file throw ;
: l>svg ( s n) svg:fd @ write-line throw ;
: n>svg ( n) s>d dup >r dabs <# #s r> sign #> >svg ;
: f>svg ( f: n)
   pad /f represent 0= if 2drop exit then if s" -" >svg then
   s" 0." >svg pad /f >svg s" e" >svg n>svg ;

: '>svg s" ' " >svg ;
: ,>svg s" ," >svg ;
: bl>svg s"  " >svg ;

: xy>svg ( a - a')
   float+ dup f@ f>svg ,>svg float+ dup f@ f>svg float+ ;
: moveto>svg ( a - #) s" M" >svg xy>svg drop 1 ;
: lineto>svg ( a - #) s" L" >svg xy>svg drop 1 ;
: curveto>svg ( a - #)
   s" C" >svg xy>svg bl>svg xy>svg bl>svg xy>svg drop 3 ;

create otable ' moveto>svg , ' lineto>svg , ' curveto>svg ,

: segment>svg ( a - #) dup @ cells otable + @ execute ;
: path>svg
   s" <path d='" >svg 'path @ 'newpath @
   do i segment>svg /segment * +loop '>svg ;
: linewidth>svg
   s" stroke-width='" >svg 'linewidth f@ f>svg '>svg ;
: rgb>svg
   s" rgb(" >svg 'rgb dup @ n>svg ,>svg float+ dup @ n>svg
   ,>svg float+ @ n>svg s" )" >svg ;
: stroke>svg s" stroke='" >svg rgb>svg '>svg ;
: fill>svg s" fill='" >svg rgb>svg '>svg ;
: stroke
   /path if path>svg stroke>svg linewidth>svg
     s" fill='none'/>" l>svg then newpath ;
: nzfill
   /path if path>svg fill>svg s" stroke='none'/>" l>svg then
   newpath ;

: txy>svg
   s" x='" >svg 'x0 f@ f>svg '>svg s" y='" >svg 'y0 f@ f>svg
   '>svg ;
: show>svg
   txy>svg fill>svg s" font-family='" >svg 'fontfamily 2@ >svg
   '>svg s" font-size='" >svg 'fontsize f@ f>svg s" '>" >svg ;
: show ( s n)
   path? s" <text " >svg show>svg >svg s" </text>" l>svg ;

: viewport>svg
   s" width='" >svg svg:width f@ f>svg s" ' height='" >svg
   svg:height f@ f>svg '>svg ;
: svgheader
   s" <?xml version='1.0'?><svg " >svg viewport>svg
   s" xmlns='http://www.w3.org/2000/svg'>" l>svg ;
: +svg
   svgheader initgraphics 1e 0e 0e -1e 0e svg:height f@ ctm! ;
: -svg s" </svg>" l>svg ;

: viewport ( f: x y) svg:height f! svg:width f! ;

: {svg ( s n) w/o create-file throw svg:fd ! +svg ;
: svg} -svg svg:fd @ close-file throw ;

400e 400e viewport

\ SvgScript extensions

: rectpath ( f: x y w h)
   newpath tm:y! tm:x! moveto tm:x tm:y fover 0e rlineto
   0e fswap rlineto fnegate 0e rlineto closepath ;
: rectstroke ( f: x y w h) gsave rectpath stroke grestore ;
: rectfill ( f: x y w h) gsave rectpath nzfill grestore ;
