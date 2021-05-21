IDEAL ; Made by Tom Ronen - 2019
MODEL small
STACK 100h
DATASEG
	bhlm db 0                        ;boolean that contains if the user chose the hard level 
	belm db 0						 ;boolean  ||     ||     || ||   ||    || ||  easy level
	
	;BMP's files:
	filename db 'win.bmp',0          ; BMP's name
	filename2 db 'lose3.bmp',0  	 ;  ||
	filename3 db 'draw3.bmp',0       ;  ||
	filehandle dw ?                 
	Header db 54 dup (0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup (0)
	ErrorMsg db 'Error', 13, 10,'$'
	;end of BNP's files
	
	x dw 95 ;give the location of the x axis- get the value from the user
	y dw 40 ;give the location of the y axis - get the value from the user
	xl dw 255 ;give the location of the x axis for the board 
	yl dw 190 ;give the location of the y axis for the board
	xr dw 260 ;give the location of the x axis for the board different lines
	yr dw 75  ;give the location of the y axis for the board different lines
	
	;colors for the board, X, box
	color db 4 
	color2 db 2 
	color1 db 1
	color3 db 3
	color4 db 4
	colorb db 5
	;end colors for the board, X, box
	
	xS dw ? ;give the location of the x axis- get the value from the user anther line
	yS dw ? ;give the location of the y axis- get the value from the user another line
	xt dw 150d ; give the location for the box printer proc - x axis 
	yt dw 40d  ; give the location for the box printer proc - y axis
	TimesToPrintX db 20d ;hendels the number of time to print the x loop
	TimesToPrintLN db 180d ;hendels the number of time to print the board loop
	TimesToPrintLNC db 200d ;hendels the number of time to print the board loop -2
	ccSR db 0; counter 
	ccSR2 db 0; counter
	counter1 db 0 ; counter
	;keep the squares that have been used by x or by Box
	existP1 db 0;
	existP2 db 0;
	existP3 db 0;
	existP4 db 0;
	existP5 db 0;
	existP6 db 0;
	existP7 db 0;
	existP8 db 0;
	existP9 db 0;
	; end keep the squares that have been used by x or by Box
	; the array for the places that x caught  - for the bot - hard level, and for checking who won
	EPX db 0,0,0,0,0,0,0,0,0;
	; the array for the places that box caught - for the bot - hard level, and for checking who won
	EPY db ?,?,?,?,?,?,?,?,?;
	boolW db 0;tells the code if user won - boolean
	boolL db 0;tells the code if user lost  - boolean
	xz dw 1 ;x for deleting old picture in black
	yz dw 1 ;y for deleting old picture in black
	startMessage db "																			", 13, 10
				 db "																			", 13, 10
				 db "																			", 13, 10
				 db "																			", 13, 10
				 db "																			", 13, 10
				 db "    WELCOM       ---------------------------------------     YOU ARE:      ", 13, 10 ;Line 1
				 db "    TO THE       ---------------------------------------       THE -x-     ", 13, 10 ;Line 2
				 db " FINAL PROJECT  TTT III  CCC  TTT  AA   CCC     TTT  OO  EEE               ", 13, 10 ;Line 3
				 db " OF TOM RONEN    T   I  CC  -- T  AAAA CC    --  T  O  O EE                ", 13, 10 ;Line 4
				 db "                 T  III  CCC   T AA  AA CCC      T   OO  EEE               ", 13, 10 ;Line 5
				 db "                                                                           ", 13, 10 ;Line 6
				 db "                                                                           ", 13, 10 ;Line 7
				 db "---------------------------------------------------------------------------", 13, 10 ;Line 8
				 db " |TIC-TAC-TOE|                          |1|2|3|                            ", 13, 10 ;Line 9
				 db " IN ORDER TO CHOOSE A SQUARE            |4|5|6|                            ", 13, 10 ;Line 10
				 db " TAP THE NUMBERS ON THE NUMBER-BAR      |7|8|9|                            ", 13, 10 ;Line 12
				 db " - THE MAIN KEYBOARDE                                                      ", 13, 10 ;Line 13
				 db "                    PRESS 1 FOR EASY LEVEL AND 2 FOR A HARDER              ", 13, 10 ;Line 14
				 db "																", 13, 10
				 db "																						", 13, 10
				 db "																			$", 13, 10
CODESEG
proc OpenFile
; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp OpenFile

proc OpenFile3
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset filename3
int 21h
jc openerror
mov [filehandle], ax
ret
openerror3:
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
endp OpenFile3

proc OpenFile2
; Open file
mov ah, 3Dh
xor al, al
mov dx, offset filename2
int 21h
jc openerror2
mov [filehandle], ax
ret
openerror2:
mov dx, offset ErrorMsg
mov ah, 9h
int 21h
ret
endp OpenFile2

proc ReadHeader
; Read BMP file header, 54 bytes
mov ah,3fh
mov bx, [filehandle]
mov cx,54
mov dx,offset Header
int 21h
ret
endp ReadHeader

proc ReadPalette
; Read BMP file color palette, 256 colors * 4 bytes (400h)
mov ah,3fh
mov cx,400h
mov dx,offset Palette
int 21h
ret
endp ReadPalette

proc CopyPal

mov si,offset Palette
mov cx,256
mov dx,3C8h
mov al,0
out dx,al
inc dx
PalLoop:
mov al,[si+2] ; Get red value.
shr al,2 ; Max. is 255, but video palette maximal
; value is 63. Therefore dividing by 4.
out dx,al ; Send it.
mov al,[si+1] ; Get green value.
shr al,2
out dx,al ; Send it.
mov al,[si] ; Get blue value.
shr al,2
out dx,al ; Send it.
add si,4 ; Point to next color.
loop PalLoop
ret
endp CopyPal

proc CopyBitmap
mov ax, 0A000h
mov es, ax
mov cx,200
PrintBMPLoop:
push cx
mov di,cx
shl cx,6
shl di,8
add di,cx
mov ah,3fh
mov cx,320
mov dx,offset ScrLine
int 21h
cld ; Clear direction flag, for movsb
mov cx,320
mov si,offset ScrLine
rep movsb ; Copy line to the screen
pop cx
loop PrintBMPLoop
ret
endp CopyBitmap
;;;;;;;;;;;;;;;;;;;;;; 

;----- The next procedure printing the x---------
;;;;;;;;;;;;;;;;;;;;;;
proc xTopCornerL
push ax 
	mov cx,[x]
	mov [xS],cx
	xor cx, cx   ; cx=0
	mov cx,[y]
	mov [yS],cx
	xor cx,cx
	mov cl, [TimesToPrintX] ; we use cl, not cx, since TimesToPrintX is byte long 
printxL2:
		xor ax,ax
		xor bx,bx
		push cx
		mov bh,0h 
		mov cx,[x] 
		mov dx,[y] 
		mov al,[color] 
		mov ah,0ch 
		int 10h	
		inc [x]
		inc [y]
		pop cx 		
		loop printxL2
		
		xor ax,ax
		xor bx,bx
		mov ax,[xS]
		mov [x],ax
		mov bx,[yS]
		add bx,20d;maybe sub
		mov [y],bx
		xor ax,ax
		xor bx,bx
		mov[TimesToPrintX],20
		xor cx,cx
	    mov cl,[TimesToPrintX]
printxL:
		push cx
		mov bh,0h 
		mov cx,[x] 
		mov dx,[y] 
		mov al,[color] 
		mov ah,0ch 
		int 10h	
		inc [x]
		dec [y]
		pop cx 		
		loop printxL
		
pop ax		
ret
endp xTopCornerL
;;;;;;;;;;;;;;;;;;;;;; 

;----- the next procedure is printing the board ---------
;;;;;;;;;;;;;;;;;;;;;;
proc board
		xor cx,cx
	    mov cl,[TimesToPrintLNC]
printlinesC:
		push cx
		mov bh,0h 
		mov cx,[xr] 
		mov dx,[yr] 
		mov al,[color2] 
		mov ah,0ch 
		int 10h	
		dec [xr]
		pop cx 		
		loop PrintlinesC
		;2פס אופקי
		xor ax,ax
		xor bx,bx
		xor cx,cx
	    mov cl,[TimesToPrintLNC]
		mov [yr],135
		mov [xr],260
printlinesC2:
		push cx
		mov bh,0h 
		mov cx,[xr] 
		mov dx,[yr] 
		mov al,[color2] 
		mov ah,0ch 
		int 10h	
		dec [xr]
		pop cx 		
		loop PrintlinesC2
		xor ax,ax
		xor bx,bx
		;פס רוחבי
		xor cx,cx
	    mov cl,[TimesToPrintLN]
		mov[xl],190
		mov[yl],190	
printlines2:
		push cx
		mov bh,0h 
		mov cx,[xl] 
		mov dx,[yl] 
		mov al,[color2] 
		mov ah,0ch 
		int 10h	
		dec [yl]
		pop cx 		
		loop Printlines2
		xor ax,ax
		xor bx,bx
			;פס רוחבי2	
		xor cx,cx
	    mov cl,[TimesToPrintLN]
		mov[xl],130
		mov[yl],190	
printlines3:
		push cx
		mov bh,0h 
		mov cx,[xl] 
		mov dx,[yl] 
		mov al,[color2] 
		mov ah,0ch 
		int 10h	
		dec [yl]
		pop cx 		
		loop Printlines3
ret
endp board
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is printing the box ---------
;;;;;;;;;;;;;;;;;;;;;;
proc box
push ax
mov cl,20d
printLineb2:
push cx
mov cl,20d	
	printLineb1:
	push cx
	mov bh,0h
	mov cx,[xt] 
	mov dx,[yt] 
	mov al,[color3] 
	mov ah,0ch 
	int 10h
	inc[xt]
	pop cx 
loop printLineb1
inc [yt]
sub [xt],20d
pop cx
loop printLineb2
pop ax
ret
endp box
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure checks where the user wanted to put the x ---------
;;;;;;;;;;;;;;;;;;;;;;
proc placeX
	cmp al,'1'
	je a1

	cmp al,'2'
	je a2
	
	cmp al,'3'
	je a3
	
	cmp al,'4'
	je a1b

	cmp al,'5'
	je a2b
	
	cmp al,'6'
	je a3b
	
	cmp al,'7'
	je a1c
	
	cmp al,'8'
	je a2c
	
	cmp al,'9'
	je a3c
	
a1:
	call AddCheck
	call saverx
	call Aa1
	jmp ExitPlace3

a2:
	call AddCheck
	call saverx
	call Aa2
	jmp ExitPlace3
a3:
	call AddCheck
	call saverx
	call Aa3
	jmp ExitPlace3
a1b:
	call AddCheck
	call saverx
	call Ab1
	jmp ExitPlace3
a2b:
	call AddCheck
	call saverx
	call Ab2
	jmp ExitPlace3
a3b:
	call AddCheck
	call saverx
	call Ab3
	jmp ExitPlace3
a1c:
	call AddCheck
	call saverx
	call Ac1
	jmp ExitPlace3
a2c:
	call AddCheck
	call saverx
	call Ac2
	jmp ExitPlace3
a3c:
	call AddCheck
	call saverx
	call Ac3
	jmp ExitPlace3

ExitPlace3:	
ret
endp placeX
;;;;;;;;;;;;;;;;;;;;;; 

;-----The next procedure is giving the x and y values for the printing in accordance to the "place x" results ---------
;;;;;;;;;;;;;;;;;;;;;;
proc Aa1
mov [x],95d
mov [y],40d
call xTopCornerL
ret
endp Aa1

proc Aa2
mov [x],150d
mov [y],40d
call xTopCornerL
ret
endp Aa2

proc Aa3
mov [x],230d
mov [y],40d
call xTopCornerL
ret
endp Aa3

proc Ab1
mov [x],95d
mov [y],100d
call xTopCornerL
ret
endp Ab1

proc Ab2
mov [x],150d
mov [y],100d
call xTopCornerL
ret
endp Ab2

proc Ab3
mov [x],230d
mov [y],100d
call xTopCornerL
ret
endp Ab3

proc Ac1
mov [x],95d
mov [y],160d
call xTopCornerL
ret
endp Ac1

proc Ac2
mov [x],150d
mov [y],160d
call xTopCornerL
ret
endp Ac2

proc Ac3
mov [x],230d
mov [y],160d
call xTopCornerL
ret
endp Ac3
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is getting the number of the square that the user wanted to put in the - x ---------
;;;;;;;;;;;;;;;;;;;;;;
proc enterPlaceX
	mov ah,7
	int 21h
	call CheckPCH
	call PlaceX
ret 
endp enterPlaceX
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is checking if the square that the 
;user wanted to put in, has been catched by himself or by the bot earlier---------
;;;;;;;;;;;;;;;;;;;;;;

proc CheckPCH
	cmp al,'1'
	je e21
	
	cmp al,'2'
	je e22
	
	cmp al,'3'
	je e23

	cmp al,'4'
	je e24
	
	cmp al,'5'
	je e25
	
	cmp al,'6'
	je e26
	
	cmp al,'7'
	je e27
	
	cmp al,'8'
	je e28
	
	cmp al,'9'
	je e29

	cmp [ccSR],9d
	je ready2
	
;	jmp starter2
jumperHelp2:
	call enterPlaceX
	jmp ready2
starter2:

e21:
	cmp [existP1],1d 
	je jumperHelp2
	jmp ready2
e22:
	cmp [existP2],1d
	je jumperHelp2
	jmp ready2
e23:	
	cmp [existP3],1d
	je jumperHelp2
	jmp ready2
e24:	
	cmp [existP4],1d
	je jumperHelp2
	jmp ready2
e25:	
	cmp [existP5],1d
	je jumperHelp2
	jmp ready2
e26:
	cmp [existP6],1d
	je jumperHelp2
	jmp ready2
e27:
	cmp [existP7],1d
	je jumperHelp2
	jmp ready2
e28:	
	cmp [existP8],1d
	je jumperHelp2
	jmp ready2
e29:
	cmp [existP9],1d
	je jumperHelp2
ready2:
ret
endp CheckPCH
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is checking what square the bot wanted to put in   ---------
;;;;;;;;;;;;;;;;;;;;;;

proc PlaceB
	cmp al,1
	je b1

	cmp al,2
	je b2
	
	cmp al,3
	je b3
	
	cmp al,4
	je b1b

	cmp al,5
	je b2b
	
	cmp al,6
	je b3b
	
	cmp al,7
	je b1c
	
	cmp al,8
	je b2c
	
	cmp al,9
	je b3c
	
b1:
	call AddCheckY
	call saver
	call Ba1
	jmp ExitPlace

b2:
	call AddCheckY
	call saver
	call Ba2
	jmp ExitPlace
b3:
	call AddCheckY
	call saver
	call Ba3
	jmp ExitPlace
b1b:
	call AddCheckY
	call saver
	call Bb1
	jmp ExitPlace
b2b:
	call AddCheckY
	call saver
	call Bb2
	jmp ExitPlace
b3b:
	call AddCheckY
	call saver
	call Bb3
	jmp ExitPlace
b1c:
	call AddCheckY
	call saver
	call Bc1
	jmp ExitPlace
b2c:
	call AddCheckY
	call saver
	call Bc2
	jmp ExitPlace
b3c:
	call AddCheckY
	call saver
	call Bc3
	jmp ExitPlace

ExitPlace:	
	ret
endp PlaceB
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedures giving x and y values for printing ---------
;;;;;;;;;;;;;;;;;;;;;;
proc Ba1

mov [xt],95d
mov [yt],40d

call Box
ret
endp Ba1

proc Ba2

	mov [xt],150d
	mov [yt],40d

	call Box
ret
endp Ba2

proc Ba3

	mov [xt],230d
	mov [yt],40d

	call Box
ret
endp Ba3

proc Bb1

	mov [xt],95d
	mov [yt],100d

	call Box
ret
endp Bb1

proc Bb2

	mov [xt],150d
	mov [yt],100d

	call Box
ret
endp Bb2

proc Bb3

	mov [xt],230d
	mov [yt],100d

	call Box
ret
endp Bb3

proc Bc1

	mov [xt],95d
	mov [yt],160d

	call Box
ret
endp Bc1

proc Bc2

	mov [xt],150d
	mov [yt],160d

	call Box
	ret
endp Bc2

proc Bc3

	mov [xt],230d
	mov [yt],160d

	call Box
	ret
endp Bc3
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is saving the squares that has been catched by the bot ---------
;;;;;;;;;;;;;;;;;;;;;;
proc saver

	cmp al,1d
	je cc1

	cmp al,2d
	je cc2

	cmp al,3d
	je cc3

	cmp al,4d
	je cc4

	cmp al,5d
	je cc5

	cmp al,6d
	je cc6

	cmp al,7d
	je cc7

	cmp al,8d
	je cc8

	cmp al,9d
	je cc9
cc1:
	mov [existP1],1d
	jmp ExitProc3
cc2:
	mov [existP2],1d
	jmp ExitProc3
cc3:
mov [existP3],1d
	jmp ExitProc3
cc4:
mov [existP4],1d
	jmp ExitProc3
cc5:
mov [existP5],1d
	jmp ExitProc3
cc6:
mov [existP6],1d
	jmp ExitProc3
cc7:
mov [existP7],1d
	jmp ExitProc3
cc8:
mov [existP8],1d
	jmp ExitProc3
cc9:
	mov [existP9],1d
	jmp ExitProc3
ExitProc3:

ret
endp saver
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is saving the squares that has been catched by the user ---------
;;;;;;;;;;;;;;;;;;;;;;
proc saverX

	cmp al,'1'
	je ccx1

	cmp al,'2'
	je ccx2

	cmp al,'3'
	je ccx3

	cmp al,'4'
	je ccx4

	cmp al,'5'
	je ccx5

	cmp al,'6'
	je ccx6

	cmp al,'7'
	je ccx7

	cmp al,'8'
	je ccx8

	cmp al,'9'
	je ccx9
ccx1:
	mov [existP1],1d
	jmp ExitProc4
ccx2:
	mov [existP2],1d
	jmp ExitProc4
ccx3:
mov [existP3],1d
	jmp ExitProc4
ccx4:
mov [existP4],1d
	jmp ExitProc4
ccx5:
mov [existP5],1d
	jmp ExitProc4
ccx6:
mov [existP6],1d
	jmp ExitProc4
ccx7:
mov [existP7],1d
	jmp ExitProc4
ccx8:
mov [existP8],1d
	jmp ExitProc4
ccx9:
	mov [existP9],1d
	jmp ExitProc4
ExitProc4:
	

ret
endp saverX
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure creating a random number, check if the number is legalfor the current game
;and sending the values for printing - inly for the easy level ---------
;;;;;;;;;;;;;;;;;;;;;;
proc randomC

random:

	mov bx, 12
	xor cx, cx
	mov ax, 40h
	mov es, ax
	mov ax, [es:06ch]
	xor al, [byte cs:bx]
	and al, 00001111b

	cmp al,8d
	jg random
	
	inc al

	cmp al,1d
	je e1
	
	cmp al,2d
	je e2
	
	cmp al,3d
	je e3
	
	cmp al,4d
	je e4
	
	cmp al,5d
	je e5
	
	cmp al,6d
	je e6
	
	cmp al,7d
	je e7
	
	cmp al,8d
	je e8
	
	cmp al,9d
	je e9

	jmp starter
jumperHelp:
	jmp random
starter:

e1:
	cmp [existP1],1d
	je random
	jmp ready
e2:
	cmp [existP2],1d
	je random
	jmp ready
e3:	
	cmp [existP3],1d
	je random
	jmp ready
e4:	
	cmp [existP4],1d
	je random
	jmp ready
e5:	
	cmp [existP5],1d
	je random
	jmp ready
e6:
	cmp [existP6],1d
	je random
	jmp ready
e7:
	cmp [existP7],1d
	je jumperHelp
	jmp ready
e8:	
	cmp [existP8],1d
	je jumperHelp
	jmp ready
e9:
	cmp [existP9],1d
	je jumperHelp
	

ready:
	call PlaceB
ret
endp randomC
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is saving the numbers for the x to  the x array  ---------
;;;;;;;;;;;;;;;;;;;;;;
proc AddCheck

	cmp al,'1'
	je d1 
	cmp al,'2'
	je d2
	cmp al,'3'
	je d3
	cmp al,'4'
	je d4
	cmp al,'5'
	je d5
	cmp al,'6'
	je d6
	cmp al,'7'
	je d7
	cmp al,'8'
	je d8
	cmp al,'9'
	je d9

d1:
	mov [EPX],1d
	jmp finish
d2:
	mov [EPX+1],1d
	jmp finish
d3:
	mov [EPX+2],1d
	jmp finish
d4:
	mov [EPX+3],1d
	jmp finish
d5:
	mov [EPX+4],1d
	jmp finish
d6:
	mov [EPX+5],1d
	jmp finish
d7:
	mov [EPX+6],1d
	jmp finish
d8:
	mov [EPX+7],1d
	jmp finish
d9:
	mov [EPX+8],1d
	jmp finish
finish:
ret
endp AddCheck
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is saving the numbers for the y to the y array  ---------
;;;;;;;;;;;;;;;;;;;;;;
proc AddCheckY

	cmp al,1
	je y1 
	cmp al,2
	je y2
	cmp al,3
	je y3
	cmp al,4
	je y4
	cmp al,5
	je y5
	cmp al,6
	je y6
	cmp al,7
	je y7
	cmp al,8
	je y8
	cmp al,9
	je y9

y1:
	mov [EPY],1d
	jmp finish2
y2:
	mov [EPY+1],1d
	jmp finish2
y3:
	mov [EPY+2],1d
	jmp finish2
y4:
	mov [EPY+3],1d
	jmp finish2
y5:
	mov [EPY+4],1d
	jmp finish2
y6:
	mov [EPY+5],1d
	jmp finish2
y7:
	mov [EPY+6],1d
	jmp finish2
y8:
	mov [EPY+7],1d
	jmp finish2
y9:
	mov [EPY+8],1d
	jmp finish2
finish2:
ret
endp AddCheckY
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is checking if the y won - with the y array  ---------
;;;;;;;;;;;;;;;;;;;;;;
proc CheckY
	cmp [EPY],1d
	je yOnLn1
	jmp ySch1
yOnLn1:
	cmp [EPY+1],1d  
	je yOnLn2
	jmp ySch1
yOnLn2:
	cmp [EPY+2],1d
	je yPrintWX2
	jmp ySch1

ySch1:
	cmp [EPY],1d
	je yOnLn3
	jmp ySch2
yOnLn3:
	cmp [EPY+4],1d  
	je yOnLn4
	jmp ySch2
yOnLn4:
	cmp [EPY+8],1d
	je yPrintWX2
	jmp ySch2
ySch2:
	cmp [EPY+3],1d
	je yOnLn5
	jmp ySch3
yOnLn5:
	cmp [EPY+4],1d
	je yOnLn6
	jmp ySch3
yOnLn6:
	cmp [EPY+5],1d
	je yPrintWX2
	jmp ySch3
yPrintWX2:
	call YW
	jmp yAreEq
ySch3:
	cmp [EPY+6],1d
	je yOnLn7
	jmp ySch4
yOnLn7:
	cmp [EPY+7],1d
	je yOnLn8
	jmp ySch4
yOnLn8:
	cmp [EPY+8],1d
	je yPrintWX2
	jmp ySch4
ySch4:
	cmp [EPY+2],1d
	je yOnLn9
	jmp ySch5
yOnLn9:
	cmp [EPY+4],1d
	je yOnLn10
	jmp ySch5
yOnLn10:
	cmp [EPY+6],1d
	je yPrintWX2
	jmp ySch5
ySch5:
	cmp [EPY],1d
	je yOnLn11
	jmp ySch6
yOnLn11:
	cmp [EPY+3],1d
	je yOnLn12
	jmp ySch6
yOnLn12:
	cmp [EPY+6],1d
	je yPrintWX2
	jmp ySch6
yPrintWX:
	call YW
	jmp yAreEq
ySch6:
	cmp [EPY+1],1d
	je yOnLn13
	jmp ySch7
yOnLn13:
	cmp [EPY+4],1d
	je yOnLn14
	jmp ySch7
yOnLn14:
	cmp [EPY+7],1d
	je yPrintWX
	jmp ySch7
ySch7:
	cmp [EPY+2],1d
	je yOnLn15
	jmp yAreEq
yOnLn15:
	cmp [EPY+5],1d
	je yOnLn16
	jmp yAreEq
yOnLn16:
	cmp [EPY+8],1d
	je yPrintWX
	jmp yAreEq
yAreEq:
	ret
endp CheckY

;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is checking if the x won - with the x array  ---------
;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;
proc Check
	cmp [EPX],1d
	je OnLn1
	jmp Sch1
OnLn1:
	cmp [EPX+1],1d  
	je OnLn2
	jmp Sch1
OnLn2:
	cmp [EPX+2],1d
	je PrintWX2
	jmp Sch1

Sch1:
	cmp [EPX],1d
	je OnLn3
	jmp Sch2
OnLn3:
	cmp [EPX+4],1d  
	je OnLn4
	jmp Sch2
OnLn4:
	cmp [EPX+8],1d
	je PrintWX2
	jmp Sch2
Sch2:
	cmp [EPX+3],1d
	je OnLn5
	jmp Sch3
OnLn5:
	cmp [EPX+4],1d
	je OnLn6
	jmp Sch3
OnLn6:
	cmp [EPX+5],1d
	je PrintWX2
	jmp Sch3
PrintWX2:
	call XW
	jmp AreEq
Sch3:
	cmp [EPX+6],1d
	je OnLn7
	jmp Sch4
OnLn7:
	cmp [EPX+7],1d
	je OnLn8
	jmp Sch4
OnLn8:
	cmp [EPX+8],1d
	je PrintWX2
	jmp Sch4
Sch4:
	cmp [EPX+2],1d
	je OnLn9
	jmp Sch5
OnLn9:
	cmp [EPX+4],1d
	je OnLn10
	jmp Sch5
OnLn10:
	cmp [EPX+6],1d
	je PrintWX2
	jmp Sch5
Sch5:
	cmp [EPX],1d
	je OnLn11
	jmp Sch6
OnLn11:
	cmp [EPX+3],1d
	je OnLn12
	jmp Sch6
OnLn12:
	cmp [EPX+6],1d
	je PrintWX2
	jmp Sch6
PrintWX:
	call XW
	jmp AreEq
Sch6:
	cmp [EPX+1],1d
	je OnLn13
	jmp Sch7
OnLn13:
	cmp [EPX+4],1d
	je OnLn14
	jmp Sch7
OnLn14:
	cmp [EPX+7],1d
	je PrintWX
	jmp Sch7
Sch7:
	cmp [EPX+2],1d
	je OnLn15
	jmp AreEq
OnLn15:
	cmp [EPX+5],1d
	je OnLn16
	jmp AreEq
OnLn16:
	cmp [EPX+8],1d
	je PrintWX
	jmp AreEq
AreEq:
	ret
endp Check
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is opening the pictures when x won  ---------
;;;;;;;;;;;;;;;;;;;;;;
proc XW
mov [boolW],1d
	mov  cx, 35d
mov     dx, 1000H
mov     ah, 86H
int 15H
;mov cl,'win.bmp'
;mov [filename],cl
call OpenFile
call ReadHeader
call ReadPalette
call CopyPal
call CopyBitmap
	ret
endp XW
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is opening the picture when the y won  ---------
;;;;;;;;;;;;;;;;;;;;;;
proc YW
mov [boolW],1d
	mov  cx, 35d
mov     dx, 1000H
mov     ah, 86H
int 15H
call OpenFile2
call ReadHeader
call ReadPalette
call CopyPal
call CopyBitmap
	ret
endp YW
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is the actual game - easy mode  ---------
;;;;;;;;;;;;;;;;;;;;;;
proc fb1

	call enterPlaceX
	call randomC
	call enterPlaceX
	call randomC
	call enterPlaceX
	;check1-x
	call Check
	;check if x-won 
	cmp [boolW],1d
	je AIfA
	;game again
	call randomC
	;check if  y won
	call CheckY
	cmp [boolW],1d
	je AIfA
	;game again
	call enterPlaceX
	;check if x or y won
	call CheckY
	cmp [boolW],1d
	je AIfA
	call Check
	cmp [boolW],1d
	je AIfA
	;game again
	call randomC
	;check
	call CheckY
	cmp [boolW],1d
	je AIfA
	;game
	call enterPlaceX
	;
	call Check
	cmp [boolW],1d
	je AIfA
	;
	call Draw
AIfA:

finished:
ret
endp fb1
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is deleting the picture   ---------
;;;;;;;;;;;;;;;;;;;;;;

proc ZeroS
push ax
mov cl,200
printLineb22:
push cx
mov cx,320d	
	printLineb12:
		push cx
		mov bh,0h
		mov cx,[xz] 
		mov dx,[yz] 
		mov al,255d
		mov ah,0ch 
		int 10h
		inc[xz]
		pop cx 
	loop printLineb12
mov [xz],1
inc [yz]
pop cx
loop printLineb22
pop ax
ret 
endp zeroS
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is creating the tie picture   ---------
;;;;;;;;;;;;;;;;;;;;;;
proc Draw
	mov  cx, 35d
	mov  dx, 1000H
	mov  ah, 86H
	int 15H
	call OpenFile3
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
ret
endp Draw
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is deleting and restarting every information in the parameters   ---------
;;;;;;;;;;;;;;;;;;;;;;
proc SData
	mov [belm],0
	mov [bhlm],0
	mov [boolW],0
	mov [colorb],5
	mov [color4],4
	mov [color3],3
	mov [color2],2
	mov [color1],1
	mov [color],4
	mov [EPX],0
	mov [EPX+1],0
	mov [EPX+2],0	
	mov [EPX+3],0
	mov [EPX+4],0
	mov [EPX+5],0
	mov [EPX+6],0
	mov [EPX+7],0
	mov [EPX+8],0
	mov [EPY],0
	mov [EPY+1],0
	mov [EPY+2],0	
	mov [EPY+3],0
	mov [EPY+4],0
	mov [EPY+5],0
	mov [EPY+6],0
	mov [EPY+7],0
	mov [EPY+8],0
	mov [existP1],0
	mov [existP2],0
	mov [existP3],0	
	mov [existP4],0
	mov [existP5],0
	mov [existP6],0
	mov [existP7],0
	mov [existP8],0
	mov [existP9],0
	mov [xl],255
	mov [yl],190
	mov [xr],260
	mov [yr],75
	mov [xz],0
	mov [yz],0
ret 
endp SData
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure checking what level the user wants---------
;;;;;;;;;;;;;;;;;;;;;;
proc CheckL
cl1:
	mov ah,7h
	int 21h
	cmp al,'1'
	je cf
	cmp al,'2'
	je chl
	jmp cl1
cf:
	mov [belm],1d
	jmp finish5 
chl:
	mov [bhlm],1d
finish5:
	
ret 
endp CheckL
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is the hard level bot:
;first it checks for a pair of 2 in a row  -  boxs, if he finds a pair he is placing a box there in order to win, if he cant find any 
; pair of boxes, he checking for a pair of - X and if he finds he is protecting by putting box there
;, else he is placing a random number. I covered up all of the potential pairs LOL I have no life---------
;;;;;;;;;;;;;;;;;;;;;;
proc HLevel

staChl:

yll2tc:
	;;;;;;;;;;;;;;;
	cmp [existP8],1d
	je yll4
	;;;;;;;;;;;;;;;
	cmp [EPY+6],1d
	je yll3
	jmp yll4
yll3:
	cmp [EPY+8],1d
	je yll3p
	jmp yll4
yll3p:
	mov al,8
	call PlaceB
	jmp fin
yll4:
	;;;;;;;;;;;;;;;
	cmp [existP2],1d
	je yll6
	;;;;;;;;;;;;;;;
	cmp [EPY],1d
	je yll5
	jmp yll6
yll5:
	cmp [EPY+2],1d
	je yll5p
	jmp yll6
yll5p:
	mov al,2
	call PlaceB
	jmp fin	
yll6:
	;;;;;;;;;;;;;;;
	cmp [existP5],1d
	je yll8
	;;;;;;;;;;;;;;;
	cmp [EPY+3],1d
	je yll7
	jmp yll8
yll7:
	cmp [EPY+5],1d
	je yll7p
	jmp yll8
yll7p:
	mov al,5
	call PlaceB
	jmp fin
yll8:
	;;;;;;;;;;;;;;;
	cmp [existP4],1d
	je yll21;
	;;;;;;;;;;;;;;;
	cmp [EPY],1d
	je yll9
	jmp yll21;
yll9:
	cmp [EPY+6],1d
	je yll9p
	jmp yll21;
yll9p:
	mov al,4
	call PlaceB
	jmp fin
yll21:
	;;;;;;;;;;;;;;;
	cmp [existP5],1d
	je yll23;
	;;;;;;;;;;;;;;;
	cmp [EPY+1],1d
	je yll22
	jmp yll23;
yll22:
	cmp [EPY+7],1d
	je yll22p
	jmp yll23;
yll22p:
	mov al,5
	call PlaceB
	jmp fin
yll23:
	;;;;;;;;;;;;;;;
	cmp [existP6],1d
	je yll25;
	;;;;;;;;;;;;;;;
	cmp [EPY+2],1d
	je yll24
	jmp yll25;
yll24:
	cmp [EPY+8],1d
	je yll24p
	jmp yll25;
yll24p:
	mov al,6
	call PlaceB
	jmp fin
yll25:
	;;;;;;;;;;;;;;;
	cmp [existP5],1d
	je yll27;
	;;;;;;;;;;;;;;;
	cmp [EPY+2],1d
	je yll26
	jmp yll27;
yll26:
	cmp [EPY+6],1d
	je yll26p
	jmp yll27;
yll26p:
	mov al,5
	call PlaceB
	jmp fin
yll27:
	;;;;;;;;;;;;;;;
	cmp [existP5],1d
	je yStartStage2;
	;;;;;;;;;;;;;;;
	cmp [EPY],1d
	je yll28
	jmp yStartStage2;
yll28:
	cmp [EPY+8],1d
	je yll28p
	jmp yStartStage2;
yll28p:
	mov al,5
	call PlaceB
	jmp fin
;;;;;
yStartStage2: 
	;;;;;;;;;;;;;;;
	cmp [existP3],1d
	je yl1tc
	;;;;;;;;;;;;;;;
	cmp [EPY],1d
	je yl1t
	jmp yl1tc
yl1t:	
	cmp [EPY+1],1d
	je yl1tr
	jmp yl1tc
yl1tr:
	mov al,3
	call PlaceB
	jmp fin
yl1tc:
	;;;;;;;;;;;;;;;
	cmp [existP6],1d
	je yl1b
	;;;;;;;;;;;;;;;
	cmp [EPY+3],1d
	je yl1tc2
	jmp yl1b
yl1tc2:	
	cmp [EPY+4],1d
	je yl1tcr
	jmp yl1b
yl1tcr:	
	mov al,6
	call PlaceB
	jmp fin
yl1b:
	;;;;;;;;;;;;;;;
	cmp [existP9],1d
	je yl2t
	;;;;;;;;;;;;;;;
	cmp [EPY+6],1d
	je yl1b2
	jmp yl2t
yl1b2:	
	cmp [EPY+7],1d
	je yl1br
	jmp yl2t
yl1br:	
	mov al,9
	call PlaceB
	jmp fin
yl2t:
	;;;;;;;;;;;;;;;
	cmp [existP1],1d
	je yl2c
	;;;;;;;;;;;;;;;
	cmp [EPY+1],1d
	je yl2t2
	jmp yl2c
yl2t2:	
	cmp [EPY+2],1d
	je yl2tr
	jmp l2c
yl2tr:	
	mov al,1
	call PlaceB
	jmp fin
yl2c:
	;;;;;;;;;;;;;;;
	cmp [existP4],1d
	je yl2b
	;;;;;;;;;;;;;;;
	cmp [EPY+4],1d
	je yl2c2
	jmp yl2b
yl2c2:	
	cmp [EPY+5],1d
	je yl2cr
	jmp yl2b
yl2cr:	
	mov al,4
	call PlaceB
	jmp fin
yl2b:
	;;;;;;;;;;;;;;;;;;;;;;;;;
	cmp [existP7],1d
	je yl3t
	;;;;;;;;;;;;;;;
	cmp [EPY+7],1d
	je yl2b2
	jmp yl3t
yl2b2:	
	cmp [EPY+8],1d
	je yl2br
	jmp yl3t
yl2br:	
	mov al,7
	call PlaceB
	jmp fin
yl3t:
	;;;;;;;;;;;;;;;
	cmp [existP7],1d
	je yl3c
	;;;;;;;;;;;;;;;
	cmp [EPY],1d
	je yl3t2
	jmp yl3c
yl3t2:	
	cmp [EPY+3],1d
	je yl3tr
	jmp yl3c
yl3tr:	
	mov al,7
	call PlaceB
	jmp fin
yl3c:
	;;;;;;;;;;;;;;;
	cmp [existP8],1d
	je yl3b
	;;;;;;;;;;;;;;;
	cmp [EPY+1],1d
	je yl3c2
	jmp yl3b
yl3c2:	
	cmp [EPY+4],1d
	je yl3cr
	jmp yl3b
yl3cr:	
	mov al,8
	call PlaceB
	jmp fin
yl3b:
	;;;;;;;;;;;;;;;
	cmp [existP9],1d
	je yl4t
	;;;;;;;;;;;;;;;
	cmp [EPY+2],1d
	je yl3b2
	jmp yl4t
yl3b2:	
	cmp [EPY+5],1d
	je yl3br
	jmp yl4t
yl3br:	
	mov al,9
	call PlaceB
	jmp fin
yl4t:
	;;;;;;;;;;;;;;;
	cmp [existP1],1d
	je yl4c
	;;;;;;;;;;;;;;;
	cmp [EPY+3],1d
	je yl4t2
	jmp yl4c
yl4t2:	
	cmp [EPY+6],1d
	je yl4tr
	jmp yl4c
yl4tr:	
	mov al,1
	call PlaceB
	jmp fin
yl4c:
	;;;;;;;;;;;;;;;
	cmp [existP2],1d
	je yl4b
	;;;;;;;;;;;;;;;
	cmp [EPY+4],1d
	je yl4c2
	jmp yl4b
yl4c2:	
	cmp [EPY+7],1d
	je yl4cr
	jmp yl4b
yl4cr:	
	mov al,2
	call PlaceB
	jmp fin
yl4b:
	;;;;;;;;;;;;;;;
	cmp [existP3],1d
	je yl5a
	;;;;;;;;;;;;;;;
	cmp [EPY+5],1d
	je yl4b2
	jmp yl5a
yl4b2:	
	cmp [EPY+8],1d
	je yl4br
	jmp yl5a
yl4br:	
	mov al,3
	call PlaceB
	jmp fin
yl5a:
	;;;;;;;;;;;;;;;
	cmp [existP9],1d
	je yl5b
	;;;;;;;;;;;;;;;
	cmp [EPY],1d
	je yl5a2
	jmp yl5b
yl5a2:	
	cmp [EPY+4],1d
	je yl5ar 
	jmp yl5b
yl5ar:	
	mov al,9
	call PlaceB
	jmp fin
yl5b:
	;;;;;;;;;;;;;;;
	cmp [existP1],1d
	je yl5c
	;;;;;;;;;;;;;;;
	cmp [EPY+8],1d
	je yl5b2
	jmp yl5c
yl5b2:	
	cmp [EPY+4],1d
	je yl5br
	jmp yl5c
yl5br:	
	mov al,1
	call PlaceB
	jmp fin
yl5c:
	;;;;;;;;;;;;;;;
	cmp [existP3],1d
	je yl5d
	;;;;;;;;;;;;;;;
	cmp [EPY+6],1d
	je yl5c2
	jmp yl5d
yl5c2:	
	cmp [EPY+4],1d
	je yl5cr
	jmp yl5d
yl5cr:	
	mov al,3
	call PlaceB
	jmp fin
yl5d:
	;;;;;;;;;;;;;;;
	cmp [existP7],1d
	je ll2tc
	;;;;;;;;;;;;;;;
	cmp [EPY+2],1d
	je yl5d2
	jmp ll2tc
yl5d2:	
	cmp [EPY+4],1d
	je yl5dr
	jmp ll2tc
yl5dr:	
	mov al,7
	call PlaceB
	jmp fin

ll2tc:
	;;;;;;;;;;;;;;;
	cmp [existP8],1d
	je ll4
	;;;;;;;;;;;;;;;
	cmp [EPX+6],1d
	je ll3
	jmp ll4
ll3:
	cmp [EPX+8],1d
	je ll3p
	jmp ll4
ll3p:
	mov al,8
	call PlaceB
	jmp fin
ll4:
	;;;;;;;;;;;;;;;
	cmp [existP2],1d
	je ll6
	;;;;;;;;;;;;;;;
	cmp [EPX],1d
	je ll5
	jmp ll6
ll5:
	cmp [EPX+2],1d
	je ll5p
	jmp ll6
ll5p:
	mov al,2
	call PlaceB
	jmp fin	
ll6:
	;;;;;;;;;;;;;;;
	cmp [existP5],1d
	je ll8
	;;;;;;;;;;;;;;;
	cmp [EPX+3],1d
	je ll7
	jmp ll8
ll7:
	cmp [EPX+5],1d
	je ll7p
	jmp ll8
ll7p:
	mov al,5
	call PlaceB
	jmp fin
ll8:
	;;;;;;;;;;;;;;;
	cmp [existP4],1d
	je ll21;
	;;;;;;;;;;;;;;;
	cmp [EPX],1d
	je ll9
	jmp ll21;
ll9:
	cmp [EPX+6],1d
	je ll9p
	jmp ll21;
ll9p:
	mov al,4
	call PlaceB
	jmp fin
ll21:
	;;;;;;;;;;;;;;;
	cmp [existP5],1d
	je ll23;
	;;;;;;;;;;;;;;;
	cmp [EPX+1],1d
	je ll22
	jmp ll23;
ll22:
	cmp [EPX+7],1d
	je ll22p
	jmp ll23;
ll22p:
	mov al,5
	call PlaceB
	jmp fin
ll23:
	;;;;;;;;;;;;;;;
	cmp [existP6],1d
	je ll25;
	;;;;;;;;;;;;;;;
	cmp [EPX+2],1d
	je ll24
	jmp ll25;
ll24:
	cmp [EPX+8],1d
	je ll24p
	jmp ll25;
ll24p:
	mov al,6
	call PlaceB
	jmp fin
ll25:
	;;;;;;;;;;;;;;;
	cmp [existP5],1d
	je ll27;
	;;;;;;;;;;;;;;;
	cmp [EPX+2],1d
	je ll26
	jmp ll27;
ll26:
	cmp [EPX+6],1d
	je ll26p
	jmp ll27;
ll26p:
	mov al,5
	call PlaceB
	jmp fin
ll27:
	;;;;;;;;;;;;;;;
	cmp [existP5],1d
	je StartStage2;
	;;;;;;;;;;;;;;;
	cmp [EPX],1d
	je ll28
	jmp StartStage2;
ll28:
	cmp [EPX+8],1d
	je ll28p
	jmp StartStage2;
ll28p:
	mov al,5
	call PlaceB
	jmp fin
;;;;;
StartStage2: 
	;;;;;;;;;;;;;;;
	cmp [existP3],1d
	je l1tc
	;;;;;;;;;;;;;;;
	cmp [EPX],1d
	je l1t
	jmp l1tc
l1t:	
	cmp [EPX+1],1d
	je l1tr
	jmp l1tc
l1tr:
	mov al,3
	call PlaceB
	jmp fin
l1tc:
	;;;;;;;;;;;;;;;
	cmp [existP6],1d
	je l1b
	;;;;;;;;;;;;;;;
	cmp [EPX+3],1d
	je l1tc2
	jmp l1b
l1tc2:	
	cmp [EPX+4],1d
	je l1tcr
	jmp l1b
l1tcr:	
	mov al,6
	call PlaceB
	jmp fin
l1b:
	;;;;;;;;;;;;;;;
	cmp [existP9],1d
	je l2t
	;;;;;;;;;;;;;;;
	cmp [EPX+6],1d
	je l1b2
	jmp l2t
l1b2:	
	cmp [EPX+7],1d
	je l1br
	jmp l2t
l1br:	
	mov al,9
	call PlaceB
	jmp fin
l2t:
	;;;;;;;;;;;;;;;
	cmp [existP1],1d
	je l2c
	;;;;;;;;;;;;;;;
	cmp [EPX+1],1d
	je l2t2
	jmp l2c
l2t2:	
	cmp [EPX+2],1d
	je l2tr
	jmp l2c
l2tr:	
	mov al,1
	call PlaceB
	jmp fin
l2c:
	;;;;;;;;;;;;;;;
	cmp [existP4],1d
	je l2b
	;;;;;;;;;;;;;;;
	cmp [EPX+4],1d
	je l2c2
	jmp l2b
l2c2:	
	cmp [EPX+5],1d
	je l2cr
	jmp l2b
l2cr:	
	mov al,4
	call PlaceB
	jmp fin
l2b:
	;;;;;;;;;;;;;;;;;;;;;;;;;
	cmp [existP7],1d
	je l3t
	;;;;;;;;;;;;;;;
	cmp [EPX+7],1d
	je l2b2
	jmp l3t
l2b2:	
	cmp [EPX+8],1d
	je l2br
	jmp l3t
l2br:	
	mov al,7
	call PlaceB
	jmp fin
l3t:
	;;;;;;;;;;;;;;;
	cmp [existP7],1d
	je l3c
	;;;;;;;;;;;;;;;
	cmp [EPX],1d
	je l3t2
	jmp l3c
l3t2:	
	cmp [EPX+3],1d
	je l3tr
	jmp l3c
l3tr:	
	mov al,7
	call PlaceB
	jmp fin
l3c:
	;;;;;;;;;;;;;;;
	cmp [existP8],1d
	je l3b
	;;;;;;;;;;;;;;;
	cmp [EPX+1],1d
	je l3c2
	jmp l3b
l3c2:	
	cmp [EPX+4],1d
	je l3cr
	jmp l3b
l3cr:	
	mov al,8
	call PlaceB
	jmp fin
l3b:
	;;;;;;;;;;;;;;;
	cmp [existP9],1d
	je l4t
	;;;;;;;;;;;;;;;
	cmp [EPX+2],1d
	je l3b2
	jmp l4t
l3b2:	
	cmp [EPX+5],1d
	je l3br
	jmp l4t
l3br:	
	mov al,9
	call PlaceB
	jmp fin
l4t:
	;;;;;;;;;;;;;;;
	cmp [existP1],1d
	je l4c
	;;;;;;;;;;;;;;;
	cmp [EPX+3],1d
	je l4t2
	jmp l4c
l4t2:	
	cmp [EPX+6],1d
	je l4tr
	jmp l4c
l4tr:	
	mov al,1
	call PlaceB
	jmp fin
l4c:
	;;;;;;;;;;;;;;;
	cmp [existP2],1d
	je l4b
	;;;;;;;;;;;;;;;
	cmp [EPX+4],1d
	je l4c2
	jmp l4b
l4c2:	
	cmp [EPX+7],1d
	je l4cr
	jmp l4b
l4cr:	
	mov al,2
	call PlaceB
	jmp fin
l4b:
	;;;;;;;;;;;;;;;
	cmp [existP3],1d
	je l5a
	;;;;;;;;;;;;;;;
	cmp [EPX+5],1d
	je l4b2
	jmp l5a
l4b2:	
	cmp [EPX+8],1d
	je l4br
	jmp l5a
l4br:	
	mov al,3
	call PlaceB
	jmp fin
l5a:
	;;;;;;;;;;;;;;;
	cmp [existP9],1d
	je l5b
	;;;;;;;;;;;;;;;
	cmp [EPX],1d
	je l5a2
	jmp l5b
l5a2:	
	cmp [EPX+4],1d
	je l5ar 
	jmp l5b
l5ar:	
	mov al,9
	call PlaceB
	jmp fin
l5b:
	;;;;;;;;;;;;;;;
	cmp [existP1],1d
	je l5c
	;;;;;;;;;;;;;;;
	cmp [EPX+8],1d
	je l5b2
	jmp l5c
l5b2:	
	cmp [EPX+4],1d
	je l5br
	jmp l5c
l5br:	
	mov al,1
	call PlaceB
	jmp fin
l5c:
	;;;;;;;;;;;;;;;
	cmp [existP3],1d
	je l5d
	;;;;;;;;;;;;;;;
	cmp [EPX+6],1d
	je l5c2
	jmp l5d
l5c2:	
	cmp [EPX+4],1d
	je l5cr
	jmp l5d
l5cr:	
	mov al,3
	call PlaceB
	jmp fin
l5d:
	;;;;;;;;;;;;;;;
	cmp [existP7],1d
	je rand
	;;;;;;;;;;;;;;;
	cmp [EPX+2],1d
	je l5d2
	jmp rand
l5d2:	
	cmp [EPX+4],1d
	je l5dr
	jmp rand
l5dr:	
	mov al,7
	call PlaceB
	jmp fin
rand:
	mov bx, 12
	xor cx, cx
	mov ax, 40h
	mov es, ax
	mov ax, [es:06ch]
	xor al, [byte cs:bx]
	and al, 00001111b

	cmp al,8d
	jg rand
	
	inc al

	cmp al,1d
	je e31
	
	cmp al,2d
	je e32
	
	cmp al,3d
	je e33
	
	cmp al,4d
	je e34
	
	cmp al,5d
	je e35
	
	cmp al,6d
	je e36
	
	cmp al,7d
	je e37
	
	cmp al,8d
	je e38
	
	cmp al,9d
	je e39

	jmp starter3
jumperHelp3:
	jmp rand
starter3:

e31:
	cmp [existP1],1d
	je rand
	jmp ready3
e32:
	cmp [existP2],1d
	je rand
	jmp ready3
e33:	
	cmp [existP3],1d
	je rand
	jmp ready3
e34:	
	cmp [existP4],1d
	je rand
	jmp ready3
e35:	
	cmp [existP5],1d
	je rand
	jmp ready3
e36:
	cmp [existP6],1d
	je rand
	jmp ready3
e37:
	cmp [existP7],1d
	je jumperHelp3
	jmp ready3
e38:	
	cmp [existP8],1d
	je jumperHelp3
	jmp ready3
e39:
	cmp [existP9],1d
	je jumperHelp3
	

ready3:
	call PlaceB
fin:
ret
endp HLevel
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure is actual hard game ---------
;;;;;;;;;;;;;;;;;;;;;;
proc HlStart
	call enterPlaceX
	call HLevel
	call enterPlaceX
	call HLevel
	call enterPlaceX
	;check1-x
	call Check
	;check if x-won 
	cmp [boolW],1d
	je AIfA2
	;game again
	call HLevel
	;check if  y won
	call CheckY
	cmp [boolW],1d
	je AIfA2
	;game again
	call enterPlaceX
	;check if x or y won
	call CheckY
	cmp [boolW],1d
	je AIfA2
	call Check
	cmp [boolW],1d
	je AIfA2
	;game again
	call HLevel
	;check
	call CheckY
	cmp [boolW],1d
	je AIfA2
	;game
	call enterPlaceX
	;
	call Check
	cmp [boolW],1d
	je AIfA2
	;
	call Draw
AIfA2:

finished2:	
	ret
endp HlStart
;;;;;;;;;;;;;;;;;;;;;; 

;-----the next procedure calling the different levels of game in accordance to what the user wants  ---------
;;;;;;;;;;;;;;;;;;;;;;
proc Caller
	cmp [belm],1d
	je ce
	cmp [bhlm],1d
	je chh
ce:
	call fb1
	jmp ended
chh:
	call HlStart
ended:
ret 
endp Caller

start:
	mov ax, @data 
	mov ds, ax


	;call xTopCornerL
	xor ax,ax
	xor bx,bx
	xor cx,cx
	
	
startA:
	call SData
	mov ax, 2 
	int 10h 
	;
	mov dx,offset startMessage
	mov ah,9h
	int 21h
	call CheckL
	;Graphic mode 
	mov ax, 13h 
	int 10h 
	
	call board
	call Caller
	
	mov ah,7 
	int 21h
	cmp al,'1'
	je Ag
	jmp finished7
Ag:
	call ZeroS
	jmp startA
finished7:
	;back to text mode
    mov ax, 2 
	int 10h 

;rightfile!!
exit:
	mov ax, 4c00h
	int 21h
END start
