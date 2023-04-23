; Web Server (Site on Assembler)
global	_start

section	.text
_start:	
	push	ebp
	mov	ebp,esp
	sub	esp,0x400	;1024 bytes
	
	
	; socket(AF_INET, SOCK_STREAM, IP_PROTO)
	push	dword 0x00000000	;IP_PROTO
	push	dword 0x00000001	;SOCK_STREAM
	push	dword 0x00000002	;AF_INET

	mov	eax,102		;socket()
	mov	ebx,1		;SYS_SOCKET
	mov	ecx,esp		
	mov	edx,0
	int	0x80
	
	mov	esi,eax
	cmp	eax,-1
	je	near errn
	
	
	
	
	push    DWORD 0x00000000    ;; 4 bytes padding
	push    DWORD 0x00000000    ;; 4 bytes padding
	push    DWORD 0x00000000    ;; INADDR_ANY
	push    WORD 0xbeef         ;; port 61374
	push    WORD 0x0002         ;; AF_INET

	mov     ecx, esp            ;; save struct address

	; bind(fd, sockaddr_in, size)
	push    DWORD 0x00000010    ;; size of our sockaddr_in struct
	push    ecx                 ;; pointer to sockaddr_in struct
	push    esi                 ;; socket file descriptor

	mov     ecx, esp            ;; set ecx to bind() args to prep for socketcall syscall
	mov     eax, 102            ;; socketcall syscall number
	mov     ebx, 2	            ;; SYS_BIND call number
	int     0x80
	
	
	; listen(fd, 0)
	mov     eax,102
	mov     ebx,4          	    ;; SYS_LISTEN call number
	push    0x00000000          ;; listen() backlog argument (4 byte int)
	push    esi                 ;; socket fd
	mov     ecx, esp            ;; pointer to args for listen()
	int     0x80
	
	
	; fd = accept(fd, NULL, NULL)
	mov     eax,102
	mov     ebx,5               ;; SYS_ACCEPT call number
	push    DWORD 0x00000000
	push    DWORD 0x00000000
	push    esi                 ;; socket fd
	int     0x80
	mov	esi,eax
	
	
	; write(fd, msg_r, len_r)
	mov	eax,4
	mov	ebx,esi
	mov	ecx,msg_r
	mov	edx,len_r
	int	0x80
	
	
	; int close(int fd)
	mov	eax,6
	mov	ebx,esi
	int	0x80
	cmp	eax,-1
	je	near errn
	
	
	
	
	; write(STDOUT, msg, len)
	mov	eax,4		; write()
	mov	ebx,1		; 1-STDOUT
	mov	ecx,msg
	mov	edx,len
	int	0x80
	
	jmp	exit
	
	
errn:	mov	eax,4		; write()
	mov	ebx,1		; 1-STDOUT
	mov	ecx,msg_err
	mov	edx,len_err
	int	0x80	
	
exit:	mov	eax,1		; exit()
	mov	ebx,0		; exit code
	int	0x80
;---------------------------------------------------------	
section	.data

msg	db	"Heelo",0xA
len	equ	$-msg

msg_err	db	"Error socket",0xA
len_err	equ	$-msg_err

msg_r	db	"HTTP/1.1 200 OK",0xA,0xD,"Content-Type: text/html",0xA,0xD,0xA,0xD,"<H1>Heelo</H1>"
len_r	equ	$-msg_r

struc sockaddr_in, -0x30
    .sin_family:    resb 2  ;2bytes
    .sin_port:      resb 2  ;2bytes
    .sin_addr:      resb 4  ;4bytes
    .sin_zero:      resb 8  ;8bytes
endstruc

DATASIZE	equ	5

struc socket, -0x40
    .socketfd       resb 4
    .connectionfd   resb 4
    .count          resb 4
    .data           resb DATASIZE
endstruc
;---------------------------------------------------------
section	.bss
var	resb 4
