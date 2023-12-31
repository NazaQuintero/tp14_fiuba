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
    nroDeIteracion  dq 0
    posVector   dq 0
    posNum1     dq 0
    posNum2     dq 0
    swapped     dq 0
    

    mensajeEncabezadoBubbleSort     db  10,10,"############# BUBBLE SORT #############",0
    tituloAscendente                db     10,"############# ASCENDENTE  #############",10,0
    tituloDescendente               db     10,"############# DESCENDENTE #############",10,0
    
    ;*** Para debug
    mensajeLeyendo              db      "__Leyendo registro...",0
    mensajeCerrandoArchivo      db      10,"[Cerrando] archivo...",0
    mensajeNumeroGuardado       db      "El numero guardado en la posicion %d es: %d",10,0
    linea			db	"|%X| ",0
    mensajeIntercambio1     db 10,"{Se va a intercambiar la posicion [%d] = [%d] ",10, 0
    mensajeIntercambio2     db "con la posicion [%d] = [%d]}",10,0
    mensajeNum1EsMayor      db "El numero 1 es mayor!!!",10,0

    mensajeDebugCicloFor    db 10, "Dentro del ciclo For - iteracion [%d]",10,10,0

section .bss
    nombreDeArchivo				resb 	30
    ; posVector 		    		resd	1
	vector		    times	30	resd	1

	num1    resd 1
    num2    resd 1

section .text

main:
    mov rbp, rsp; for correct debugging
    ;write your code here

    call    obtenerInformacionDeArchivoYOrdenamiento

    mov 	dword[posVector], 1
    call    leerRegistrosDelArchivo
    
    mov 	dword[posVector], 1
    call    imprimirVector

    call    bubbleSort

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
    call    obtenerValorDePosicion

    mov     edx, dword[registroAux]
    mov     dword[eax], edx ; piso el valor de la direccion

    inc     dword[posVector]

ret


imprimirVector:
    call    imprimirPosicion
    
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

    mov al,[registro] ; copio en reg de 8 bits AL
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


;________ blubbleSort _________

bubbleSort:
    call    imprimirEncabezadoDeBubbleSort
    call    imprimirModoDeOrdenamiento
    ;test
    
    mov     dword[num1], 0
    mov     dword[num2], 0

    mov 	dword[nroDeIteracion], 1
    mov 	dword[posVector], 1

mientrasNoSeHayaSwappeado:
    mov     dword[swapped], 0

iterar:
    mov     ecx, dword[lenVector]
    cmp     dword[nroDeIteracion], ecx
    jg      finIterar

    call    imprimirIteracion

    mov     ebx, dword[nroDeIteracion]

    mov     dword[posNum1], ebx
    call    obtenerPosicionDeNumero1
    mov     r10, [eax]

    inc     ebx

    mov     ecx, dword[lenVector]
    cmp     ebx, ecx
    jg      finIterar

    mov     dword[posNum2], ebx
    call    obtenerPosicionDeNumero2
    mov     r11, [eax]

    mov     [num1], r10
    mov     [num2], r11

    call    swapDadoQueSeCumpleCondicion

    inc     dword[nroDeIteracion]
    jmp     iterar

finIterar:
    cmp     dword[swapped], 0
    je     mientrasNoSeHayaSwappeado
finDeMientras:
ret

imprimirEncabezadoDeBubbleSort:
    mov     rcx, mensajeEncabezadoBubbleSort
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret

imprimirModoDeOrdenamiento:
    mov ah, byte[modoDeOrdenamiento]
	cmp ah, byte[ASCENDENTE]
    je  imprimirTituloAscendente
    jne imprimirTituloDescendente
ret

imprimirTituloAscendente:
    mov     rcx, tituloAscendente
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret

imprimirTituloDescendente:
    mov     rcx, tituloDescendente
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret

imprimirPosicion:
    call    obtenerValorDePosicion

    mov     rcx,mensajeNumeroGuardado
    mov     rdx,[posVector] ;posicion
    mov     r8,[eax] ;valor guardado
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret

obtenerValorDePosicion:
    mov     eax, dword[posVector]
    dec     eax
    imul    dword[longitudDelRegistro]
    lea     eax, [vector+eax]   ;deja el valor en eax
ret

obtenerPosicionDeNumero1:
    mov     ecx,[posNum1]
    mov     dword[posVector], ecx
    call    obtenerValorDePosicion
ret

obtenerPosicionDeNumero2:
    mov     ecx,[posNum2]
    mov     dword[posVector], ecx
    call    obtenerValorDePosicion
ret

imprimirMensajeIntercambio1:
    mov     rcx, mensajeIntercambio1
    mov     rdx,[posNum1]
    mov     r8d,[num1]
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret

imprimirMensajeIntercambio2:
    mov     rcx, mensajeIntercambio2
    mov     rdx,[posNum2]
    mov     r8d,[num2]
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret


imprimirElNumero1EsMayor:
    mov     rcx, mensajeNum1EsMayor
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret

swap:
    call    obtenerPosicionDeNumero1
    mov 	edx, dword[num2]
    mov     dword[eax], edx

    call    obtenerPosicionDeNumero2
    mov     edx, dword[num1]
    mov     dword[eax], edx

    mov     dword[swapped], 1
ret

swapDadoQueSeCumpleCondicion:
    mov ah, byte[modoDeOrdenamiento]
	cmp ah, byte[ASCENDENTE]
    je      swapAscendente
    jne     swapDescendente
ret

swapAscendente:
    cmp     r10, r11
    jng     finSwapAscendente

    call    imprimirMensajeIntercambio1
    call    imprimirMensajeIntercambio2
    call    swap
finSwapAscendente:
ret

swapDescendente:
    cmp     r10, r11
    jg     finSwapDescendente

    call    imprimirMensajeIntercambio1
    call    imprimirMensajeIntercambio2
    call    swap
finSwapDescendente:
ret

imprimirIteracion:
    mov     rcx, mensajeDebugCicloFor
    mov     rdx,[nroDeIteracion]
    sub     rsp, 32
    call    printf
    add     rsp, 32
ret