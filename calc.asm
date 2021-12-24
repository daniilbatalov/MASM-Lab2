			title		calc
			assume		cs:cod, ds:d, ss:s

s			segment		stack
			dw			128 dup (?)
s			ends

d			segment
a			dw			?
b			dw			?

string 		db			255, 0, 255 dup (?)
errmsg		db			'Error! Invalid character!', 0DH, 0AH, '$'
negflag		dw			?

msgerr1		db			'Error! The first denominator is equal to zero!', 0DH, 0AH, '$'
msgerr2		db			'Error! The second denominator is equal to zero!', 0DH, 0AH, '$'

msga		db 			'Enter a: $'
msgb		db 			'Enter b: $'
d			ends
	
cod			segment
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
startp:		mov			ah, 0AH
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

ex: 		ret
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

			mov			ah, 9
			lea			dx, msga
			int			21H

			Call		IntegerIn
			mov			a, ax
			Call		NewLine

			mov 		ah, 9
			lea			dx, msgb
			int  		21H

			Call		IntegerIn
			mov			b, ax
			Call		NewLine

			mov			ax, a
			sub			ax, b
			cmp			ax, 0
			je			fnerr
			push		ax

			mov			ax, a
			add			ax, b
			cmp			ax, 0
			je			snerr
			mov			bx, ax		;BX = (A+B), STACK = (A-B)

			mov			ax, a
			mov			cx, 4
			cwd
			idiv		cx			
			add			ax, b		;AX = A/4 + B
			idiv		bx
			push		ax			;STACK =  [(A/4+B)/(A+B)]; [(A-B)]

			pop			ax
			pop			bx
			push		ax			;BX = [(A-B)]; STACK =  [(A/4+B)/(A+B)]

			mov			ax, a
			imul		ax
			mov			cx, 3
			imul		cx
			mov			cx, b
			imul		cx
			imul		cx
			inc			ax
			adc			dx, 0
			idiv		bx			;AX = (3A^2B^3+1)/(A-B); STACK =  [(A/4+B)/(A+B)]

			pop			bx
			sub			ax, bx

			Call		IntegerOut

			jmp			exit

fnerr:		mov			ah, 9
			lea 		dx, msgerr1
			int			21H
			jmp			start

snerr:		mov			ah, 9
			lea			dx,	msgerr2
			int			21H
			jmp			start

exit:		mov			ah, 4CH
			int			21H
cod			ends
			end			start