global main
extern puts
extern printf
extern fopen
extern fclose
extern fread
extern gets

section .data

    mensajeDeSolicitudDeArchivo 		   db 	10,"Ingrese el nombre de archivo: ",0
    mensajeDeSolicitudDeModo               db   10,"Ingrese modo ordenamiento: Ascendente [A] o Descendente [D]: ",0
    modoDeOrdenamiento                     db 	" ",0
    ASCENDENTE                  		   db 	"A",0
	DESCENDENTE              			   db   "D",0
    modoDeAperturaDeArchivo                db   "rb",0
    handleFile                             dq   0
    mensajeDeErrorAperturaDeArchivo		   db   10,"Error en la apertura de archivo",10,0,
    
    registro          times    1      db   "",0   ;longitud total del registro: 1 byte
    registroAux dq 0

    lenVector              dd  0

    longitudDelRegistro     dd  30
    posVector   dq 0
    
    ;*** Para debug
    mensajeLeyendo              db      "__Leyendo registro...",0
    mensajeCerrandoArchivo      db      10,"[Cerrando] archivo...",0
    mensajeNumeroGuardado       db      "El numero guardado en la posicion %d es: %d",10,0
    ; debug   db  "posVector: %i",10,0
    linea			db	"|%X| ",0

section .bss
    nombreDeArchivo				resb 	30
    ; posVector 		    		resd	1
	vector		    times	30	resd	1

	num1	 				resd	1
	num2	 				resd	1
	aux	 					resd	1

section .text

main:
    mov rbp, rsp; for correct debugging
    ;write your code here

    call    obtenerInformacionDeArchivoYOrdenamiento

    mov 	dword[posVector], 1
    call    leerRegistrosDelArchivo
    
    mov 	dword[posVector], 1
    call    imprimirVector

    jmp     endProg
    
errorAperturaDeArchivo:
    mov     rcx, mensajeDeErrorAperturaDeArchivo
    sub     rsp, 32
    call    printf
    add     rsp, 32
    jmp     main
    
cerrarArchivo:
    mov     rcx, mensajeCerrandoArchivo
    call    imprimirMensaje

    mov     rcx,[handleFile]
    sub     rsp,32
    call    fclose
    add     rsp,32
    
endProg:
ret



;------------------;
; Rutinas internas ;
;------------------;

solicitarIngresoDeNombreDeArchivo:
    mov     rcx, mensajeDeSolicitudDeArchivo
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret

guardarNombreDeArchivoIngresado:
    mov     rcx, nombreDeArchivo
    sub     rsp, 32
    call    gets
    add     rsp, 32
ret

solicitarIngresoDeModoDeOrdenamiento:
    mov     rcx, mensajeDeSolicitudDeModo
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret

guardarModoDeOrdenamiento:
    mov     rcx, modoDeOrdenamiento
    sub     rsp, 32
    call    gets
    add     rsp, 32
ret

solicitarYGuardarOrdenamientoHastaQueSeaValido:
    call    solicitarIngresoDeModoDeOrdenamiento
    call    guardarModoDeOrdenamiento

    mov ah, byte[modoDeOrdenamiento]
	cmp ah, byte[ASCENDENTE]
	je 	finDeIngresoDeModo

	mov ah, byte[modoDeOrdenamiento]
	cmp ah, byte[DESCENDENTE]
	jne solicitarYGuardarOrdenamientoHastaQueSeaValido

finDeIngresoDeModo:
ret

obtenerInformacionDeArchivoYOrdenamiento:
    call    solicitarIngresoDeNombreDeArchivo
    call    guardarNombreDeArchivoIngresado
    call    solicitarYGuardarOrdenamientoHastaQueSeaValido
ret


abrirArchivo:
    mov     rcx, nombreDeArchivo
    mov     rdx, modoDeAperturaDeArchivo
    sub     rsp, 32
    call    fopen
    add     rsp, 32
ret

leerRegistro:
    mov     rcx, registro
    mov     rdx, 1 ;cant de bytes a leer
    mov     r8, 1 ;leer registro por registro
    mov     r9,[handleFile] ;handler del archivo
    sub     rsp,32
    call    fread
    add     rsp,32
ret

leerRegistrosDelArchivo:
    call    abrirArchivo
    cmp     rax, 0
    jle     errorAperturaDeArchivo
    mov     [handleFile], rax

leerProximoRegistro:
    call    leerRegistro
    
    cmp     rax, 0
    jle     cerrarArchivo
        ; mov     rcx,mensajeLeyendo
        ; call    imprimirMensaje

        call    imprimirNumeroQueSeEstariaGuardando

    inc     dword[lenVector]
    call    llenarVector
    jmp     leerProximoRegistro
ret

llenarVector:
    ; mov     rcx, debug
    ; mov     rdx, [posVector]
    ; sub     rsp, 32
    ; call    printf
    ; add     rsp, 32

    mov     eax, [posVector]
    dec     eax
    imul    dword[longitudDelRegistro]
    lea     eax, [vector+eax]

    mov     edx, dword[registroAux]
    mov     dword[eax], edx

    inc     dword[posVector]

ret


imprimirVector:
    mov     eax, dword[posVector]
    dec     eax
    imul    dword[longitudDelRegistro]
    lea     eax, [vector+eax]

    mov     rcx,mensajeNumeroGuardado
    mov     rdx,[posVector] ;posicion
    mov     r8d,dword[eax] ;valor guardado
    sub     rsp, 32
    call    printf
    add     rsp, 32
    
    inc     dword[posVector]
    mov     eax, dword[lenVector]
    cmp     dword[posVector], eax
    jle     imprimirVector

ret

imprimirMensaje: 
    sub     rsp, 32
    call    puts
    add     rsp, 32
ret

imprimirNumeroQueSeEstariaGuardando:
    ;debug de lo que se esta leyendo

    mov al,[registro] ; copias en reg de 8 bits AL
    cbw ; convierto a 16 bits, queda en AX
    cwde ; convierto a 32, queda en EAX
    cdqe ; convierto a 64, queda en RAX
    mov [registroAux], rax

    mov		rcx,linea			;Parametro 1: dir del texto a imprimir por pantalla
    sub 	rdx,rdx
    mov		rdx,[registroAux]				;Parametro 2: dato a ser formateado como numero entero decimal
    sub     rsp, 32
    call	printf
    add     rsp, 32

    ; fin debug
ret