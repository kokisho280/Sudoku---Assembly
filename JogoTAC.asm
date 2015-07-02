PILHA	SEGMENT PARA STACK 'STACK'
	db 2048 dup(?)
PILHA	ENDS

DADOS	SEGMENT PARA 'DATA'
	invalido	db	'Valor invalido$'
	jogoinf		db	'Navegacao com setas:$'
	ganhou		db	'Parabens ganhou o jogo!!!$'	

	array		db	81 dup (?)

	jogo		db	'1 2 3  4 5 6  7 8 9$'

	nome1		db	'Rodolfo Lima  .:21170826$'
	nome2		db	'Ricardo Dinis .:21170949$'
	vers		db	'v1.00$'
	confsai		db	'Sim[s]		      Nao[n]$'
	tras		db	'Menu principal [m]$'
	exit		db	'Tem a certeza que deseja sair?$'
	msg2		db	'Regras do SUDOKU$'
	resul		db	'Resultados pessoais$'
	joga		db	'A jogar SUDOKU$'
	sai		db	'Sair SUDOKU$'
	tit1		db	'.---..-..-..--. .----..-.,-..-..-.$'
	tit2		db	'\ \  | || |||\ \| || || ` / | || |$'
	tit3		db	' \ \ | || |||/ /| || || . \ | || |$'
	tit4		db	'`---``----``--- `----``- `-``----`$'
	tit5		db	'______________________________$'
	Erro_Open       db      'Erro ao tentar abrir o ficheiro$'
        Erro_Ler_Msg    db      'Erro ao tentar ler do ficheiro$'
        Erro_Close      db      'Erro ao tentar fechar o ficheiro$'
        Fich         	db      'INICIO.txt',0
	fichjo		db	'Jogo.txt',0
	fichhe		db	'Ajuda.txt',0
        HandleFich      dw      0
        car_fich        db      ?
	Msg_tecla	db	'A tecla premida foi$'
	Tecla		db	?
	

DADOS	ENDS

CODIGO	SEGMENT PARA 'CODE'
	ASSUME CS:CODIGO, DS:DADOS, SS:PILHA



goto_XY MACRO	col,lin		;mete o curso nas coordenadas enviadas na chamada
	mov	ah,02h
	mov	bh, 0
	mov	dl,col
	mov	dh,lin
	int	10h
endM









limpa	PROC			;1versao escreve no ecra inteiro ' '
	mov	cx,25*80	;2versao escreve no ecra inteiro ' ', mete fundo preto e letras brancas
	xor	bx,bx
	xor	ax,ax
	mov	ah,' '
	mov	al, 00001111b
	

apaga:	
	mov	es:[bx],ah
	mov	es:[bx+1],al
	add	bx,2
	


	;mov	ah,02h
	;mov	dl,' '
	;int	21h
loop apaga
	RET
limpa	ENDP





titulo	PROC			;escreve o titulo e mete desde da linha 1 a linha 5 letra cor azul

	xor	bx,bx
	xor	ax,ax
	mov	al, 00011111b
	mov	bx,160
	mov	cx,320
cor:
	mov	es:[bx+1],al
	add	bx,2
	
loop cor




	goto_XY 74,4		;versao
	mov	ah,09h
	lea	dx,vers
	int	21h
	

	goto_XY 16,1		;1 linha titulo
	mov	ah,09h
	lea	dx,tit1
	int	21h
	goto_XY 16,2		;2 linha titulo
	mov	ah,09h
	lea	dx,tit2
	int	21h
	goto_XY 16,3		;3 linha titulo
	mov	ah,09h
	lea	dx,tit3
	int	21h	
	goto_XY 16,4		;4 linha titulo
	mov	ah,09h
	lea	dx,tit4
	int	21h
	goto_XY 28,5		;5 linha titulo
	mov	ah,09h
	lea	dx,tit5
	int	21h

	RET
titulo	ENDP

nomecor PROC





	xor	si,si		;local do nomes azul
	mov	al, 00011111b
	mov	bx,3616
	mov	si,bx
	add	si,160
	mov	cx,32
azu:
	mov	es:[bx+1],al
	mov	es:[si+1],al
	add	bx,2
	add	si,2
loop azu

	RET
nomecor ENDP


mprincipal PROC			;escreve para voltar menuprincipal
	goto_XY	10,23
	mov	ah,09h
	lea	dx,tras
	int	21h
	RET
mprincipal ENDP


teclas	PROC			;recebe teclas
espt:
	mov   ah,0bh            ;funcao que verifica o buffer do teclado
        int   21h
        cmp   al,0ffh           ;Ve se tem Tecla no Buffer
        jne   espt         	;Enquanto não tem tem tecla no buffer,espera
        mov   ah,08h            ;Funcao para ler do teclado/buffer
        int   21h            
        cmp   al,0  		;Ve se a tecla lida=0 (estendida)
	RET
teclas	ENDP


mdback	PROC			;altera fundo se valor for diferente '0'
	xor	di,di
	cmp	ah,'0'
	je	saitt
	mov	al,00001111b
	mov	di,dx
	
	mov	es:[di+1],al
	

saitt:
	RET
mdback	ENDP




;--------------------------------Programa--------------------------------------



INICIO:


	MOV	AX, DADOS
	MOV	DS, AX
	mov   ax,0b800h
	mov   es,ax
	
;--------------------------------MenuInicial-----------------------------------

menu:	goto_XY	0,0
	CALL	limpa
	goto_XY 0,0
	
	xor	bx,bx		;formatacao inicial da linha 1 a 5 para azul
	xor	ax,ax
	mov	al, 00011111b
	mov	bx,160
	mov	cx,320
cor:
	mov	es:[bx+1],al
	add	bx,2
	
loop cor
	

	CALL	nomecor
	
	
	xor	si,si		;barras brancas
	mov	al, 01111111b
	mov	bx,1760

	mov	cx,15
bra:
	mov	es:[bx+1],al
	mov	es:[bx+321],al
	mov	es:[bx+641],al
	mov	es:[bx+961],al
	add	bx,2
	
loop bra


	mov     ah,3dh		;funcao testa ficheiro
        mov     al,0
        lea     dx,Fich
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax

        jmp     ler_ciclo

erro_abrir:
        mov     ah,09h
        lea     dx,Erro_Open
        int     21h
        jmp     FIM

ler_ciclo:
	
        mov     ah,3fh		;le o ficheiro ate acabar
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
	jc	erro_ler
	cmp	ax,0		;se comparacao verdadeira esta no ->EOF(end of file)
	je	fecha_ficheiro
        mov     ah,02h
	mov	dl,car_fich
	int	21h
	jmp	ler_ciclo

erro_ler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h
fecha_ficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
	goto_XY	30,18
	jnc	esptecla

	mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
	jmp	FIM


esptecla:
        mov   ah,0bh            ;funcao que verifica o buffer do teclado
        int   21h
        cmp   al,0ffh           ;Ve se tem Tecla no Buffer
        jne   esptecla         	;Enquanto não tem tem tecla no buffer,espera
        mov   ah,08h            ;Funcao para ler do teclado/buffer
        int   21h            
        cmp   al,0              ;Ve se a tecla lida=0 (estendida)
        jne   tecla_simples     ;Se nao era estendida trata tecla
        mov   ah,08h            ;sendo estendida volta a ler codigo
        int   21h
	
tecla_simples:			;testa teclas menu principal
	mov   tecla,al
	CMP	al,'j'
	je	jogar
	cmp	al,'s'
	je	sair
	cmp	al,'a'
	je	ajuda
	;cmp	al,'r'
	;je	resultados
	jmp	esptecla	;caso nao prima nenhuma delas volta atras e pede ate que uma delas for premida 



       

;--------------------------------Jogar-----------------------------------------
       

jogar:	goto_XY	0,0
	CALL limpa
	CALL titulo
	goto_XY 44,7
	mov	ah,09h		;escreve subtitulo
	lea	dx,joga
	int	21h


	mov	ax,0		;System clock para dx
	int	1ah
	
	mov	ax,dx
	xor	dx,dx
	mov	bx,5
	div	bx		;divide valor clock pelo numero 'jogos'
	add	dl,30h
	add	dl,1		;dl fica com valor de 0 a n.jogos-1 passa-se para o caracter e add 1 para ficar com range 1 a n.jogos

	push	dx		;resultado para pilha



	mov     ah,3dh		;le ficheiro... em cima
        mov     al,0
        lea     dx,Fichjo
        int     21h
        jc      erro_abrir
        mov     HandleFich,ax
        jmp     lerciclo



lerciclo:
        mov     ah,3fh
        mov     bx,HandleFich
	mov	cx,1


	lea	dx,car_fich
	
	
	int     21h
	jc	erroler

	
	cmp	car_fich,'J'	;compara pa saber kando e 'J' inicio de numeros de jogo
	je	compara
	
	
	cmp	ax,0		;EOF?
	je	fecha_ficheiro



	jmp	lerciclo

compara:
	
	mov     ah,3fh
        mov     bx,HandleFich
	mov	cx,1


	lea	dx,car_fich
	
	
	int     21h
	jc	erro_ler
	
	
	pop	bx		;vai buscar valor guardado na pilha para bx
	
	
	cmp	car_fich,bl	;compara numero do jogo
	je	lejogo
	push	bx		;mete novamente na pilha
	cmp	ax,0		;EOF?
	je	fechaficheiro



	jmp	lerciclo




lejogo:
	push	bx
	
	;mov	bx,cx

	cmp	ax,0		;EOF?
	je	fechaficheiro



	

ler:
	mov     ah,3fh
        mov     bx,HandleFich

        mov     cx,1			;so ler numeros de 0 a 9
	


        lea     dx,car_fich
	
	
	int     21h
	jc	erro_ler
	cmp	car_fich,'0'
	jb	nnumero
	cmp	car_fich,'9'
	ja	nnumero
	cmp	ax,0		;EOF?
	je	fechaficheiro
	mov     dl,car_fich	;o que carregou do ficheiro mete dl

	mov	array[si],dl	;dl para array
	inc	si
	cmp	si,81		;81x tamanho do tabuleiro jogo sudoku
	je	fechaficheiro
nnumero:

	
	jmp	ler



erroler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h

fechaficheiro:
	
	
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
        jnc     segue

        mov     ah,09h
        lea     dx,Erro_Close
        Int     21h


segue:





	xor	bx,bx		;fundo a azul na area de voltar menu principal
	xor	ax,ax
	mov	al, 00011111b
	mov	bx,3680
	mov	cx,28
az:
	mov	es:[bx+1],al
	add	bx,2
	
loop az

	xor	bx,bx
	xor	ax,ax
	mov	al, 01110000b
	;1490
	mov	bx,1494		;Quadrado para o tabuleiro
	mov	cx,23
qua:
	
	mov	es:[bx+1],al	;faz coluna a coluna altera a formatacao da celula
	mov	es:[bx+161],al
	mov	es:[bx+321],al
	mov	es:[bx+481],al
	mov	es:[bx+641],al
	mov	es:[bx+801],al
	mov	es:[bx+961],al
	mov	es:[bx+1121],al
	mov	es:[bx+1281],al
	mov	es:[bx+1441],al
	mov	es:[bx+1601],al
	mov	es:[bx+1761],al
	mov	es:[bx+1921],al


salto:	add	bx,2
	
loop qua



	xor	dx,dx
	mov	bx,1658
	xor	ax,ax
	xor	si,si
	mov	cx,3

	
qua1:	mov	dx,bx		;escreve tabuleiro no ecra vindo de array
	mov	ah,array[si]	;faz coluna a coluna e de quadrado em quadrado (3)
	mov	es:[bx],ah
	CALL	mdback
	mov	ah,array[si+9]
	mov	es:[bx+160],ah
	add	dx,160
	CALL	mdback
	mov	ah,array[si+18]
	mov	es:[bx+160*2],ah
	add	dx,160
	CALL	mdback
	mov	ah,array[si+27]
	mov	es:[bx+160*4],ah
	add	dx,320
	CALL	mdback
	mov	ah,array[si+36]
	mov	es:[bx+160*5],ah
	add	dx,160
	CALL	mdback
	mov	ah,array[si+45]
	mov	es:[bx+160*6],ah
	add	dx,160
	CALL	mdback
	mov	ah,array[si+54]
	mov	es:[bx+160*8],ah
	add	dx,320
	CALL	mdback
		
	add	bx,4
	inc	si
loop	qua1			;dividir porque o jump destination era muito longe (igual nos 2 blocos seguintes)


	xor	dx,dx
	mov	bx,1658
	xor	ax,ax
	;xor	si,si
	mov	cx,3
	sub	si,3


quaf1:
	mov	dx,bx

	mov	ah,array[si+63]
	mov	es:[bx+160*9],ah
	add	dx,1440
	CALL	mdback
	mov	ah,array[si+72]
	mov	es:[bx+160*10],ah
	add	dx,160
	CALL	mdback
	
	add	bx,4
	inc	si
loop	quaf1




	
	mov	cx,3
	add	bx,2

qua2:	mov	dx,bx
	mov	ah,array[si]
	mov	es:[bx],ah
	CALL	mdback
	
	mov	ah,array[si+9]
	mov	es:[bx+160],ah
	add	dx,160
	CALL	mdback

	mov	ah,array[si+18]
	mov	es:[bx+160*2],ah
	add	dx,160
	CALL	mdback

	mov	ah,array[si+27]
	mov	es:[bx+160*4],ah
	add	dx,320
	CALL	mdback

	mov	ah,array[si+36]
	mov	es:[bx+160*5],ah
	add	dx,160
	CALL	mdback

	mov	ah,array[si+45]
	mov	es:[bx+160*6],ah
	add	dx,160
	CALL	mdback

	mov	ah,array[si+54]
	mov	es:[bx+160*8],ah
	add	dx,320
	CALL	mdback

	
	
	add	bx,4
	inc	si
loop	qua2

	sub	si,3
	sub	bx,12
	mov	cx,3


quaf2:
	mov	dx,bx

	mov	ah,array[si+63]
	mov	es:[bx+160*9],ah
	add	dx,1440
	CALL	mdback
	mov	ah,array[si+72]
	mov	es:[bx+160*10],ah
	add	dx,160
	CALL	mdback
	
	add	bx,4
	inc	si
loop	quaf2







	


	mov	cx,3
	add	bx,2

qua3:	mov	dx,bx
	mov	ah,array[si]
	mov	es:[bx],ah
	
	CALL	mdback
	
	mov	ah,array[si+9]
	mov	es:[bx+160],ah
	add	dx,160
	CALL	mdback

	mov	ah,array[si+18]
	mov	es:[bx+160*2],ah
	add	dx,160
	CALL	mdback

	mov	ah,array[si+27]
	mov	es:[bx+160*4],ah
	add	dx,320
	CALL	mdback

	mov	ah,array[si+36]
	mov	es:[bx+160*5],ah
	add	dx,160
	CALL	mdback

	mov	ah,array[si+45]
	mov	es:[bx+160*6],ah
	add	dx,160
	CALL	mdback

	mov	ah,array[si+54]
	mov	es:[bx+160*8],ah
	add	dx,320
	CALL	mdback


	add	bx,4
	inc	si
loop	qua3


	sub	bx,12
	mov	cx,3
	sub	si,3

quaf3:
	mov	dx,bx

	mov	ah,array[si+63]
	mov	es:[bx+160*9],ah
	add	dx,1440
	CALL	mdback
	mov	ah,array[si+72]
	mov	es:[bx+160*10],ah
	add	dx,160
	CALL	mdback
	
	add	bx,4
	inc	si
loop	quaf3




	


	;xor	ax,ax		;escreve um vector com formatacao diferente, teste
	;xor	si,si
	;xor	bx,bx
	;mov	bx,1368
	;mov	al,00001001b
;cic:	
	;mov	ah, joga[si]
	;cmp	ah,'$'
	;je	cont
	
	
	;mov	es:[bx],ah
	;mov	es:[bx+1],al
	;add	bx,2
	;inc	si
	;jmp	cic
	
	CALL mprincipal

	xor	dx,dx
	mov	dl,29		;coluna
	mov	dh,10		;linha
	push	dx
posicao:
	
	goto_XY	dl,dh		;posiciona cursor
	


espm:	
	CALL teclas
        jne   tecla_s	     	;Se nao era estendida trata tecla
        mov   ah,08h            ;sendo estendida volta a ler codigo
        int   21h

tecla_s:
	
	CMP	al,0dh		;enter
	je	celula

	CMP	al,'m'
	je	menu

	CMP	al,4bh		;seta left
	JE	left
	CMP	al,4dh		;seta right
	JE	right
	CMP	al,50h		;seta down
	JE	down
	CMP	al,48h		;seta up
	JE	up

	
	jmp	espm



left:	cmp	dl,29			;limite esquerdo
	je	posicao
	
	cmp	dl,36			;espacamento entre quadrados
	je	ttres

	cmp	dl,43			;espacamento entre quadrados
	je	ttres
	
	dec	dl
	dec	dl
	jmp	posicao

ttres:	dec	dl
	dec	dl
	dec	dl
	jmp	posicao




right:	cmp	dl,47			;limite direito
	je	posicao

	cmp	dl,33
	je	ftres

	cmp	dl,40
	je	ftres

	
	inc	dl
	inc	dl
	jmp	posicao

ftres:	inc	dl
	inc	dl
	inc	dl
	jmp	posicao



down:	cmp	dh,20			;limite inferior
	je	posicao

	cmp	dh,12			;espacamento entre quadrados
	je	ddois

	cmp	dh,16			;espacamento entre quadrados
	je	ddois


	inc	dh
	jmp	posicao

ddois:	inc	dh
	inc	dh
	jmp	posicao



up:	cmp	dh,10			;limite superior
	je	posicao

	cmp	dh,14
	je	udois

	cmp	dh,18
	je	udois
	dec	dh
	jmp	posicao


udois:	dec	dh
	dec 	dh

	jmp	posicao


celula:					;entra 'dentro' da celula
	
	mov	bh,dl			;contas para atraves do dx, que contem linhas e colunas chegar a posicao no 'array da memoria de video'
	add	bh,bh
	mov	al,dh
	mov	bl,160
	mul	bl
	mov	bl,bh
	mov	bh,0	

	add	ax,bx
	mov	bx,ax
	
	mov	al,es:[bx+1]

	cmp	al,00001111b
	je	posicao

	mov	al, 00111111b
	mov	es:[bx+1],al

espv:	
	CALL teclas
        jne   tecla_n	     	;Se nao era estendida trata tecla
        mov   ah,08h            ;sendo estendida volta a ler codigo
        int   21h

tecla_n:
	
	CMP	al,1bh
	je	zero
	CMP	al,'1'	
	jb	espv
	cmp	al,'9'
	ja	espv
	
	
	
	mov	ah,al			;ah tem valor inserido, e bx tem posicao actual
	mov	si,bx			

	cmp	si,1818			;1 posicao 1 linha
	jb	linha1

	cmp	si,1978			;1 posicao 2 linha
	jb	linha2

	cmp	si,2298			;1 posicao 3 linha
	jb	linha3

	cmp	si,2458			;1 posicao 4 linha
	jb	linha4

	cmp	si,2618			;1 posicao 5 linha
	jb	linha5

	cmp	si,2938			;1 posicao 6 linha
	jb	linha6

	cmp	si,3098			;1 posicao 7 linha
	jb	linha7

	cmp	si,3258			;1 posicao 8 linha
	jb	linha8

	cmp	si,3300			;1 posicao 9 linha
	jb	linha9

linha1:
	mov	si,1658
	jmp	verlinha

linha2:
	mov	si,1818
	jmp	verlinha

linha3:
	mov	si,1978
	jmp	verlinha

linha4:
	mov	si,2298
	jmp	verlinha

linha5:
	mov	si,2458
	jmp	verlinha

linha6:
	mov	si,2618
	jmp	verlinha

linha7:
	mov	si,2938
	jmp	verlinha

linha8:
	mov	si,3098
	jmp	verlinha

linha9:
	mov	si,3258
	jmp	verlinha



verlinha:
	cmp	es:[si],ah		;compara com 1 posicao da linha
	je	normal
	cmp	es:[si+4],ah		;compara com 2 posicao da linha
	je	normal
	cmp	es:[si+8],ah
	je	normal
	
	cmp	es:[si+14],ah
	je	normal
	cmp	es:[si+18],ah
	je	normal
	cmp	es:[si+22],ah
	je	normal

	
	cmp	es:[si+28],ah
	je	normal
	cmp	es:[si+32],ah
	je	normal
	cmp	es:[si+36],ah		;compara com 9 posicao da linha
	je	normal
	




	mov	si,bx			

	mov	cx,11

	mov	di,1658		;(1,1)

comp1:		
	cmp	si,di		;se ta na 1 coluna
	je	coluna1
	add	di,160
loop comp1

	mov	cx,11
	mov	di,1662		;(1,2)

comp2:		
	cmp	si,di		;se ta na 2 coluna
	je	coluna2
	add	di,160
loop comp2

	mov	cx,11
	mov	di,1666		;(1,3)

comp3:		
	cmp	si,di		;se ta na 3 coluna
	je	coluna3
	add	di,160
loop comp3

	mov	cx,11
	mov	di,1672		;(1,4)

comp4:		
	cmp	si,di		;se ta na 4 coluna
	je	coluna4
	add	di,160
loop comp4

	mov	cx,11
	mov	di,1676		;(1,5)

comp5:		
	cmp	si,di		;se ta na 5 coluna
	je	coluna5
	add	di,160
loop comp5

	mov	cx,11
	mov	di,1680		;(1,6)

comp6:		
	cmp	si,di		;se ta na 6 coluna
	je	coluna6
	add	di,160
loop comp6

	mov	cx,11
	mov	di,1686		;(1,7)

comp7:		
	cmp	si,di		;se ta na 7 coluna
	je	coluna7
	add	di,160
loop comp7

	mov	cx,11
	mov	di,1690		;(1,8)

comp8:		
	cmp	si,di		;se ta na 8 coluna
	je	coluna8
	add	di,160
loop comp8

	mov	cx,11
	mov	di,1694		;(1,9)

comp9:		
	cmp	si,di		;se ta na 9 coluna
	je	coluna9
	add	di,160
loop comp9





	
coluna1:
	mov	si,1658
	je	vercoluna

coluna2:
	mov	si,1662
	je	vercoluna

coluna3:
	mov	si,1666
	je	vercoluna

coluna4:
	mov	si,1672
	je	vercoluna

coluna5:
	mov	si,1676
	je	vercoluna

coluna6:
	mov	si,1680
	je	vercoluna

coluna7:
	mov	si,1686
	je	vercoluna

coluna8:
	mov	si,1690
	je	vercoluna

coluna9:
	mov	si,1694
	je	vercoluna




vercoluna:
	cmp	es:[si],ah		;compara com 1 posicao da 1linha
	je	normal

	cmp	es:[si+160],ah		;compara com 2 posicao da 1linha
	je	normal

	cmp	es:[si+160*2],ah	;compara com 3 posicao da 1linha
	je	normal

	cmp	es:[si+160*4],ah	;compara com 4 posicao da 1linha
	je	normal

	cmp	es:[si+160*5],ah	;compara com 5 posicao da 1linha
	je	normal

	cmp	es:[si+160*6],ah	;compara com 6 posicao da 1linha
	je	normal

	cmp	es:[si+160*8],ah	;compara com 7 posicao da 1linha
	je	normal

	cmp	es:[si+160*9],ah	;compara com 8 posicao da 1linha
	je	normal

	cmp	es:[si+160*10],ah	;compara com 9 posicao da 1linha
	je	normal




	mov	si,bx			

	mov	cx,3

	mov	di,1658		;(1,1)inicio quadrado 1


	
	
compqua1:		
	cmp	si,di		;ver se esta em alguma posicao do 1 quadrado
	je	quadrado1
	add	di,4
	
	cmp	si,di
	je	quadrado1
	add	di,4
	cmp	si,di
	je	quadrado1	
	
	sub	di,8
	add	di,160
loop compqua1


	mov	cx,3
	mov	di,1672		;inicio quadrado 2


	
	
compqua2:		
	cmp	si,di		;ver se esta em alguma posicao do 2 quadrado
	je	quadrado2
	add	di,4
	;cmp	si,di+4
	cmp	si,di
	je	quadrado2
	add	di,4
	cmp	si,di
	je	quadrado2
	;cmp	si,di+8
	sub	di,8
	add	di,160
loop compqua2


	mov	di,1686		;---
	mov	cx,3

	
	
compqua3:		
	cmp	si,di		;---
	je	quadrado3
	add	di,4
	;cmp	si,di+4
	cmp	si,di
	je	quadrado3
	add	di,4
	cmp	si,di
	je	quadrado3
	;cmp	si,di+8
	sub	di,8
	add	di,160
loop compqua3



	mov	di,2298		;---
	mov	cx,3

	
	
compqua4:		
	cmp	si,di		;---
	je	quadrado4
	add	di,4
	;cmp	si,di+4
	cmp	si,di
	je	quadrado4
	add	di,4
	cmp	si,di
	je	quadrado4
	;cmp	si,di+8
	sub	di,8
	add	di,160
loop compqua4


	mov	di,2312		;---
	mov	cx,3

	
	
compqua5:		
	cmp	si,di		;---
	je	quadrado5
	add	di,4
	;cmp	si,di+4
	cmp	si,di
	je	quadrado5
	add	di,4
	cmp	si,di
	je	quadrado5
	;cmp	si,di+8
	sub	di,8
	add	di,160
loop compqua5


	mov	di,2326		;---
	mov	cx,3

	
	
compqua6:		
	cmp	si,di		;---
	je	quadrado6
	add	di,4
	;cmp	si,di+4
	cmp	si,di
	je	quadrado6
	add	di,4
	cmp	si,di
	je	quadrado6
	;cmp	si,di+8
	sub	di,8
	add	di,160
loop compqua6


	mov	di,2938		;---
	mov	cx,3

	
	
compqua7:		
	cmp	si,di		;---
	je	quadrado7
	add	di,4
	;cmp	si,di+4
	cmp	si,di
	je	quadrado7
	add	di,4
	cmp	si,di
	je	quadrado7
	;cmp	si,di+8
	sub	di,8
	add	di,160
loop compqua7


	mov	di,2952		;---
	mov	cx,3

	
	
compqua8:		
	cmp	si,di		;---
	je	quadrado8
	add	di,4
	;cmp	si,di+4
	cmp	si,di
	je	quadrado8
	add	di,4
	cmp	si,di
	je	quadrado8
	;cmp	si,di+8
	sub	di,8
	add	di,160
loop compqua8


	mov	di,2966		;---
	mov	cx,3

	
	
compqua9:		
	cmp	si,di		;---
	je	quadrado9
	add	di,4
	;cmp	si,di+4
	cmp	si,di
	je	quadrado9
	add	di,4
	cmp	si,di
	je	quadrado9
	;cmp	si,di+8
	sub	di,8
	add	di,160
loop compqua9

quadrado1:
	mov	si,1658		;mete no inicio do respectivo quadrado
	je	verquadrado

quadrado2:
	mov	si,1672
	je	verquadrado

quadrado3:
	mov	si,1686
	je	verquadrado

quadrado4:
	mov	si,2298
	je	verquadrado

quadrado5:
	mov	si,2312
	je	verquadrado

quadrado6:
	mov	si,2326
	je	verquadrado

quadrado7:
	mov	si,2938
	je	verquadrado

quadrado8:
	mov	si,2952
	je	verquadrado

quadrado9:
	mov	si,2966
	je	verquadrado



verquadrado:
	cmp	es:[si],ah		;compara com 1 posicao da 1linha
	je	normal

	cmp	es:[si+160],ah		;compara com 1 posicao da 2linha
	je	normal

	cmp	es:[si+160*2],ah	;compara com 1 posicao da 3linha
	je	normal

	cmp	es:[si+4],ah		;compara com 2 posicao da 1linha
	je	normal

	cmp	es:[si+4+160],ah	;compara com 2 posicao da 2linha
	je	normal

	cmp	es:[si+4+160*2],ah	;compara com 2 posicao da 3linha
	je	normal

	cmp	es:[si+8],ah		;compara com 3 posicao da 1linha
	je	normal

	cmp	es:[si+8+160],ah	;compara com 3 posicao da 2linha
	je	normal

	cmp	es:[si+8+160*2],ah	;compara com 3 posicao da 3linha
	je	normal



	mov	es:[bx],ah		;mete valor inserido(se passou nas comparacoes) na posicao
	
	
	jmp	celnormal		
normal:					;mensagem e sinal de valor invalido
	mov	al, 01110000b
	mov	es:[bx+1],al	
	push	dx
	mov 	ah,2h
	mov	dl,07h			;'imprimi' bell tone
	int	21h
	pop	dx
	xor	ax,ax			
	xor	si,si
	xor	bx,bx
	mov	bx,1868
	mov	al,01001111b
cic2:	
	mov	ah, invalido[si]
	cmp	ah,'$'
	je	posicao
	
	
	mov	es:[bx],ah
	mov	es:[bx+1],al
	add	bx,2
	inc	si
	jmp	cic2
	




celnormal:				;celula volta ao normal e apaga msg de valor invalido
	mov	al, 01110000b
	mov	es:[bx+1],al
	mov	si,1868
	mov	cx,14
	mov	ah,' '
	mov	al,00001111b
norin:

	mov	es:[si],ah
	mov	es:[si+1],al
	add	si,2

loop	norin





	

	mov	si,1658				;verificacao final ver se todos os valores estao entre 1...9
	


	

exte1:
	
	mov	cx,3
	

vf1:						;3 primeiras posicoes, depois caso nao teja no final da linha ve as proximas 3 etc
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf1


	cmp	si,1698				;final da 1 linha
	je	lin2


	add	si,2
	jmp	exte1


lin2:
	mov	si,1818
	
	
exte2:
	
	mov	cx,3
	

vf2:
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf2


	cmp	si,1858				;final da linha 2
	je	lin3


	add	si,2
	jmp	exte2



lin3:
	mov	si,1978
	
	
exte3:
	
	mov	cx,3
	

vf3:
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf3


	cmp	si,2018
	je	lin4


	add	si,2
	jmp	exte3


lin4:
	mov	si,2298
	
	
exte4:
	
	mov	cx,3
	

vf4:
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf4


	cmp	si,2338
	je	lin5


	add	si,2
	jmp	exte4


lin5:
	mov	si,2458
	
	
exte5:
	
	mov	cx,3
	

vf5:
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf5


	cmp	si,2498
	je	lin6


	add	si,2
	jmp	exte5


lin6:
	mov	si,2618
	
	
exte6:
	
	mov	cx,3
	

vf6:
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf6


	cmp	si,2658
	je	lin7


	add	si,2
	jmp	exte6



lin7:
	mov	si,2938
	
	
exte7:
	
	mov	cx,3
	

vf7:
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf7


	cmp	si,2978
	je	lin8


	add	si,2
	jmp	exte7


lin8:
	mov	si,3098
	
	
exte8:
	
	mov	cx,3
	

vf8:
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf8


	cmp	si,3138
	je	lin9


	add	si,2
	jmp	exte8


lin9:
	mov	si,3258
	
	
exte9:
	
	mov	cx,3
	

vf9:
	mov	al,'1'
	mov	ah,'9'
	cmp	es:[si],al
	jb	posicao
	cmp	es:[si],ah
	ja	posicao

	add	si,4
loop	vf9


	cmp	si,3298
	je	victoria


	add	si,2
	jmp	exte9




victoria:

	xor	ax,ax		;imprime msg de victoria e espera por 'm' do teclado para voltar po menu principal
	xor	si,si
	xor	bx,bx
	mov	bx,2188
	mov	al,00011111b
cic:	
	mov	ah, ganhou[si]
	cmp	ah,'$'
	je	ganh
	
	
	mov	es:[bx],ah
	mov	es:[bx+1],al
	add	bx,2
	inc	si
	jmp	cic

ganh:

esptec:	
	CALL teclas
        jne   tecla_ss	     	;Se nao era estendida trata tecla
        mov   ah,08h            ;sendo estendida volta a ler codigo
        int   21h

tecla_ss:
	

	CMP	al,'m'
	je	menu

jmp	esptec

zero:
	mov	ah,'0'		;caso pressione esc em cima meter valor '0' na celula
	mov	es:[bx],ah
	jmp	celnormal



;---------------------------------AJUDA------------------------------	

ajuda:	goto_XY	0,0
	CALL limpa
	CALL titulo
	

	goto_XY 42,7
	mov	ah,09h
	lea	dx,msg2
	int	21h
	xor	bx,bx		;area do m-menu principal azul
	xor	ax,ax
	mov	al, 00011111b
	mov	bx,3680
	mov	cx,28
blue:
	mov	es:[bx+1],al
	add	bx,2
	
loop blue

	CALL mprincipal

	goto_XY	0,10

	mov     ah,3dh		;funcao testa ficheiro
        mov     al,0
        lea     dx,Fichhe
        int     21h
        jc      errobrir
        mov     HandleFich,ax

        jmp     leciclo

errobrir:
        mov     ah,09h
        lea     dx,Erro_open
        int     21h
        jmp     FIM

leciclo:
	
        mov     ah,3fh		;le o ficheiro ate acabar
        mov     bx,HandleFich
        mov     cx,1
        lea     dx,car_fich
        int     21h
	jc	errler
	cmp	ax,0		;se comparacao verdadeira esta no ->EOF(end of file)
	je	fechficheiro
        mov     ah,02h
	mov	dl,car_fich
	int	21h
	jmp	leciclo

errler:
        mov     ah,09h
        lea     dx,Erro_Ler_Msg
        int     21h
fechficheiro:
        mov     ah,3eh
        mov     bx,HandleFich
        int     21h
	
	jnc	tm

	mov     ah,09h
        lea     dx,Erro_Close
        Int     21h
	jmp	FIM





	
tm:	goto_XY	30,23
	CALL teclas
        jne   nest	     	;Se nao era estendida trata tecla
        mov   ah,08h            ;sendo estendida volta a ler codigo
        int   21h

nest:
	
	CMP	al,'m'
	je	menu
	
	jmp	tm





;--------------------------------Resultados--------------------------------------


resultados:	goto_XY	0,0
	CALL limpa
	CALL titulo
	

	goto_XY 39,7
	mov	ah,09h
	lea	dx,resul
	int	21h
	xor	bx,bx		;area do m-menu principal azul
	xor	ax,ax
	mov	al, 00011111b
	mov	bx,3680
	mov	cx,28
blues:
	mov	es:[bx+1],al
	add	bx,2
	
loop blues

	CALL mprincipal
	goto_XY	30,23

	jmp 	tm

;--------------------------------Sair-------------------------------------------	

sair:	goto_XY	0,0
	CALL limpa
	CALL titulo
	goto_XY 47,7		;pergunta se deseja mmo sair da opcoes e escreve nomes
	mov	ah,09h
	lea	dx,sai
	int	21h
	goto_XY 15,15
	mov	ah,09h
	lea	dx,confsai
	int	21h
	
	goto_XY 48,22
	mov	ah,09h
	lea	dx,nome1
	int	21h
	goto_XY 48,23
	mov	ah,09h
	lea	dx,nome2
	int	21h
	
	goto_XY 15,11
	mov	ah,09h
	lea	dx,exit
	int	21h

	
	
	CALL nomecor

	xor	si,si		;barra brancas
	mov	al, 01110000b
	mov	bx,1760

	mov	cx,45
bran:
	cmp	cx,31
	jbe	fren
	mov	es:[bx+1],al
fren:	mov	es:[bx+641],al

	add	bx,2
	
loop bran



	goto_XY 45,11

esps:	
	CALL	teclas
        jne   tecla_sai	     	;Se nao era estendida trata tecla
        mov   ah,08h            ;sendo estendida volta a ler codigo
        int   21h

tecla_sai:
	
	
	CMP	al,'n'
	je	menu
	cmp	al,'s'
	je 	FIM
	jmp	esps



;--------------------------------FimPrograma--------------------------------------

	
FIM:	goto_XY 0,0
	CALL limpa
	goto_XY 0,0
	
	MOV	AH,4Ch
	INT	21h



CODIGO	ENDS
END	INICIO


