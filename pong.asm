; Un joc in 512 octeti
; Acesta este doar un schelet care simuleaza miscarea unei bile pe ecran
; si, de asemenea, permite deplasarea unei palete cu tastele 'q' si 'w'.

.model tiny
_text segment use16

org 7C00h

start:
    jmp main

; variabile de stare
ball_x db 0             ; pozitia mingii
ball_y db 0
ball_dx db 1            ; directia de miscare a mingii
ball_dy db 1

paddle_x db 25          ; pozitia paletei
paddle_y db 24
paddle_dx db 0          ; directia paletei

paddle2_x db 25          ; pozitia paletei 2
paddle2_y db 0
paddle2_dx db 0          ; directia paletei 2

score_x db 2            ; pozitia scor
score_y db 22

score2_x db 2           ; pozitia scor2
score2_y db 2


main:
    ; initializare cs, ds
    mov ax, cs
    mov ds, ax

    ; ascunde cursorul
    mov ch, 32
    mov ah, 1
    int 10h         ;  INT 10h / AH = 01h - set text-mode cursor shape.

    ; sterge ecranul (afiseaza 25 newline-uri)
    mov cx, 25
cls:
    mov ah, 0Eh
    mov al, 10
    int 10h         ;  INT 10h / AH = 0Eh - teletype output.
    loop cls
    
    ; bucla principala
game:

    ; deseneaza
    call ball_draw
    call paddle_draw
	call paddle2_draw
	call score_draw
	call score2_draw
    
    ; pauza intre doua cadre ale animatiei
    call delay
    
    ; sterge ce am desenat mai devreme
    call ball_erase
    call paddle_erase
	call paddle2_erase

    ; calcul miscare
    call ball_move
    call paddle_move
    
    ; continua animatia
    jmp game

; aceasta rutina determina numarul de cadre pe secunda
delay proc
    mov ah, 086h
    mov cx, 0
    mov dx, 25000
    int 15h         ;  INT 15h / AH = 86h - BIOS wait function. 
    ret
delay endp

; pozitioneaza cursorul la scor
score_setpos proc
    mov dl, score_x
    mov dh, score_y
    mov bh, 0
    mov ah, 2
    int 10h         ;  INT 10h / AH = 2 - set cursor position.
    ret
score_setpos endp

; pozitioneaza cursorul la scor2
score2_setpos proc
    mov dl, score2_x
    mov dh, score2_y
    mov bh, 0
    mov ah, 2
    int 10h         ;  INT 10h / AH = 2 - set cursor position.
    ret
score2_setpos endp

; deseneaza scor
score_draw proc
    call score_setpos
    mov ah, 0Ah
    mov al, '0'
    mov cx, 1
    int 10h         ;  INT 10h / AH = 0Ah - write character only at cursor position.
    ret
score_draw endp

; deseneaza scor2
score2_draw proc
    call score2_setpos
    mov ah, 0Ah
    mov al, '0'
    mov cx, 1
    int 10h         ;  INT 10h / AH = 0Ah - write character only at cursor position.
    ret
score2_draw endp


; pozitioneaza cursorul pentru desenarea mingii
ball_setpos proc
    mov dl, ball_x
    mov dh, ball_y
    mov bh, 0
    mov ah, 2
    int 10h         ;  INT 10h / AH = 2 - set cursor position.
    ret
ball_setpos endp

; deseneaza mingea
ball_draw proc
    call ball_setpos
    mov ah, 0Ah
    mov al, 'o'
    mov cx, 1
    int 10h         ;  INT 10h / AH = 0Ah - write character only at cursor position.
    ret
ball_draw endp

; sterge mingea (deseneaza spatiu in locul ei)
ball_erase proc
    call ball_setpos
    mov ah, 0Ah
    mov al, ' '
    mov cx, 1
    int 10h         ;  INT 10h / AH = 0Ah - write character only at cursor position.
    ret
ball_erase endp

; miscarea mingii (incrementare cu ball_dx,ball_dy si coliziunea cu peretii)
ball_move proc
    mov al, ball_x
    mov bl, ball_dx
    add al, bl
    mov ball_x, al

    .if (al == 79) || (al == 0)
        neg ball_dx
    .endif
    
    mov al, ball_y
    mov bl, ball_dy
    add al, bl
    mov ball_y, al

    .if (al == 23) || (al == 0)
        neg ball_dy
    .endif
    ret
ball_move endp

; pozitioneaza cursorul pentru desenarea paletei
; paddle_x,paddle_y reprezinta capatul din stanga
; dimensiunea paletei este de 5 caractere
paddle_setpos proc
    mov dl, paddle_x
    mov dh, paddle_y
    mov bh, 0
    mov ah, 2
    int 10h
    ret
paddle_setpos endp

; deseneaza paleta
paddle_draw proc
    call paddle_setpos
    mov ah, 0Ah
    mov al, '*'
    mov cx, 5       ;  afiseaza 5 caractere
    int 10h         ;  INT 10h / AH = 0Ah - write character only at cursor position.
    ret
paddle_draw endp

; pozitioneaza cursorul la paleta2
paddle2_setpos proc
    mov dl, paddle2_x
    mov dh, paddle2_y
    mov bh, 0
    mov ah, 2
    int 10h
    ret
paddle2_setpos endp

; deseneaza paleta2
paddle2_draw proc
    call paddle2_setpos
    mov ah, 0Ah
    mov al, '*'
    mov cx, 5       ;  afiseaza 5 caractere
    int 10h         ;  INT 10h / AH = 0Ah - write character only at cursor position.
    ret
paddle2_draw endp

; sterge paleta (deseneaza spatii)
paddle_erase proc
    call paddle_setpos
    mov ah, 0Ah
    mov al, ' '
    mov cx, 5
    int 10h         ;  INT 10h / AH = 0Ah - write character only at cursor position.
    ret
paddle_erase endp

; sterge paleta2
paddle2_erase proc
    call paddle2_setpos
    mov ah, 0Ah
    mov al, ' '
    mov cx, 5
    int 10h         ;  INT 10h / AH = 0Ah - write character only at cursor position.
    ret
paddle2_erase endp

; miscarea paletei, cu tastele 'q' si 'w', si a paletei 2 cu tastele 'a' si 's'
paddle_move proc
    mov ah, 1
    int 16h         ;  INT 16h / AH = 01h - check for keystroke in the keyboard buffer.
    je no_key       ;  ZF = 1 if keystroke is not available.
    
    mov ah, 0       ;  INT 16h / AH = 00h - get keystroke from keyboard (no echo).
    int 16h         ;  (if a keystroke is present, it is removed from the keyboard buffer). 

    .if al == 'q'
        mov paddle_dx, -1
    .endif

    .if al == 'w'
        mov paddle_dx, 1
    .endif
	
	.if al == 'a'
        mov paddle2_dx, -1
    .endif

    .if al == 's'
        mov paddle2_dx, 1
    .endif
    
no_key:             ; daca nu s-a apasat nimic, mentinem directia anterioara
    
    mov al, paddle_x
    mov bl, paddle_dx
    add al, bl
    .if al <= 80-5              ; al este numar fara semn => o singura comparatie este suficienta
        mov paddle_x, al        ; (actualizam pozitia doar daca paddle_x nu iese din ecran)
    .endif
	
	mov al, paddle2_x
    mov bl, paddle2_dx
    add al, bl
    .if al <= 80-5              ; al is unsigned number => one comparison is enough
        mov paddle2_x, al        ; (update the position only if paddle_x doesn't exit of the screen)
    .endif
    ret
paddle_move endp

; semnatura pentru bootloader
db 510-($-start) dup(0)
dw 0AA55h

_text ends
end
