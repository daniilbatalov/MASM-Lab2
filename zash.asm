			xor			di, di
			xor			bx, bx
			mov			cl, M
			xor			ch, ch

oul:		push		cl
			mov			cl, N
			mov			si, 3
			mov			dx, word ptr a
			mov			al, byte ptr a+2
inl:		cmp			al, (a+2)[bx+si]
			jl			skip
			je			equal
			mov			dx, word ptr a[bx+si]
			mov			al, byte ptr (a+2)[bx+si]
			jmp			skip
equal:		cmp			dx, a[bx+si]
			jbe			skip
			mov			dx, word ptr a[bx+si]
skip:		add			si, 3
			loop		inl
			cbw
			mov			word ptr b[di],  dx
			mov			word ptr (b+2)[di], ax
			add			di, 4
			add			bx, 60
			pop			cl
			loop		oul

