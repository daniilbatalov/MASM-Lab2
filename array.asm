			title		array
			assume		cs:code, ss:s, ds:d

s			segment		stack
			dw			128 dup (?)
s			ends

d			segment
a			dw			100 dup (?)
n			dw			?

string 		db			255, 0, 255 dup (?)
errmsg		db			'Error! Invalid character!', 0DH, 0AH, '$'
negflag		dw			?

msgx		db 			'Enter the next element of array: $'
msgn		db 			'Enter the number of elements in array (<= 100): $'
msgr		db			'Result: $'
msgz		db			'There was no positive elements on even positions. The result is undefined.$'
d			ends

code		segment

cr = 0DH
lf = 0AH

IntegerOut	proc
			xor			cx, cx
			mov			bx,	10
			cmp			ax, 0
			jge			m0
			neg			ax
			push		ax
			mov			ah,	2
			mov			dl,	'-'
			int			21H
			pop			ax

m0:			inc			cx
			xor			dx, dx
			div			bx
			push		dx
			or			ax, ax
			jnz			m0

m11:		pop 		dx
			add			dx, '0'
			mov			ah,	2
			int			21H
			loop		m11
			ret
IntegerOut	endp

IntegerIn	proc
startp:		push		dx
			push		si
			push		bx

			mov			ah, 0AH
			lea			dx, string
			int 		21H

			xor			ax, ax
			lea			si, string+2
			mov			negflag, ax
			cmp			byte ptr [si], '-'
			jne			m2

			not			negflag
			inc			si
			jmp			m
m2:			cmp			byte ptr [si], '+'
			jne			m
			inc			si
m:			cmp			byte ptr [si], cr
			je			exl
			cmp			byte ptr [si], '0'
			jb			err
			cmp			byte ptr [si], '9'
			ja			err

			mov			bx, 10
			mul			bx

			sub			byte ptr [si], '0'
			add			al, [si]
			adc			ah, 0

			inc			si
			jmp			m

err:		lea 		dx, errmsg
			mov			ah, 9
			int			21H
			jmp			startp

exl:		cmp			negflag, 0
			je 			ex
			neg			ax

ex: 		pop			bx
			pop			si
			pop			dx
			
			ret
IntegerIn	endp

NewLine		proc
			push		ax
			push		dx

			mov			ah, 02H
			mov			dl, 0AH
			int			21H

			mov			ah, 02H
			mov			dl, 0DH
			int			21H

			pop			dx
			pop			ax
			ret
NewLine		endp			

start:		mov			ax, d
			mov			ds, ax

			mov 		ah, 9
			lea			dx, msgn
			int			21H

			Call		IntegerIn
			Call		NewLine			
			mov			n, ax
			xor			si, si
			mov			cx, n

ent:		mov 		ah, 9
			lea			dx, msgx
			int			21H
			Call		IntegerIn
			Call		NewLine			
			mov			a[si], ax
			add			si, 2
			loop		ent

			mov			ax, n
			test		ax, 1
			jz			evn
			inc			ax
evn:		mov			cx, 2
			cwd
			idiv		cx
			mov			cx, ax

			xor			ax, ax
			xor			dx, dx	
			xor			si, si
iter:		cmp			a[si], 0
			jle			ng
			add			ax, a[si]
			inc			dx
ng:			add			si, 4
			loop  		iter

			cmp			dx, 0
			je			zer
			
			mov			cx, dx
			cwd
			idiv		cx
			push		ax

			mov 		ah, 9
			lea			dx, msgr
			int			21H			
			pop			ax
			Call		IntegerOut
			jmp			exit

zer:		mov			ah, 9
			lea			dx, msgz
			int			21H

exit:		mov			ah, 4CH
			int			21H			
code		ends
			end			start