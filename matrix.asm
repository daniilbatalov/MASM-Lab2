			title		matrix
			assume		cs:code, ss:s, ds:d

s			segment		stack
			dw			128 dup (?)
s			ends

d 			segment
a			dw			10 dup (10 dup (?))
n			dw			?
ma 			dw			?

string 		db			255, 0, 255 dup (?)
errmsg		db			'Error! Invalid character!', 0DH, 0AH, '$'
negflag		dw			?

msgx		db 			'Enter the next element of matrix: $'
msgn		db 			'Enter the matrix order (<= 10): $'
msgm		db 			'Enter m: $'
msgo 		db			'Original matrix:', 0DH, 0AH, '$'
msgr		db			'Result matrix:', 0DH, 0AH, '$'
d			ends

code		segment
cr = 0DH
lf = 0AH

IntegerOut	proc
			push		cx
			push		bx

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

			pop			bx
			pop			cx
			ret
IntegerOut	endp

IntegerIn	proc
			push		dx
			push		si
			push		bx

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

PrintSpace	proc
			push		ax
			push		dx

			mov			ah, 02H
			mov			dl, 20H
			int			21H

			pop			dx
			pop			ax
			ret
PrintSpace	endp

PrintMatrix proc
			xor			si, si
			mov			cx, n

outer_pnt:	push		cx
			mov			cx, n
			xor			bx, bx

inner_pnt:	mov			ax, a[si+bx]
			Call		IntegerOut
			Call		PrintSpace

			add			bx, 2
			loop		inner_pnt
			Call		NewLine
			add			si, 10
			pop			cx
			loop		outer_pnt

			ret			
PrintMatrix endp

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

outer_ent:	push		cx
			mov			cx, n
			xor			bx, bx
inner_ent:	mov 		ah, 9
			lea			dx, msgx
			int			21H
			Call		IntegerIn
			Call		NewLine			
			mov			a[si+bx], ax
			add			bx, 2
			loop		inner_ent
			Call		NewLine
			add			si, 20
			pop			cx
			loop		outer_ent

			mov 		ah, 9
			lea			dx, msgm
			int			21H

			Call		IntegerIn
			Call		NewLine			
			mov			ma, ax

			mov 		ah, 9
			lea			dx, msgo
			int			21H
			Call		PrintMatrix

			xor			si, si
			mov			cx, n

outer:		push		cx
			mov			cx, n
			xor			bx, bx
inner:		mov			ax, a[si+bx]
			cmp			ax, ma
			jg			skip

			mov			ax, cx			;AX = n - j, STACK = n - i => AX+STACK = 2n - (i + j), (AX+STACK) mod 2 = (i + j) mod 2
			pop			dx
			add			ax, dx
			push 		dx
			test		ax, 1
			jnz			skip

			mov			a[si+bx], 0

skip:		add			bx, 2
			loop		inner
			add			si, 20
			pop			cx
			loop		outer

			mov 		ah, 9
			lea			dx, msgr
			int			21H
			Call		PrintMatrix

exit:		mov			ah, 4CH
			int			21H			
code		ends
			end			start