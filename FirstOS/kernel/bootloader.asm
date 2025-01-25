[BITS 16]
[ORG 0x7C00]

start:
    xor ax, ax      
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  
    
    jmp kmain        

kmain:
    jmp bmain

bmain:
    mov ah, 0x0E
    lea si, prompt
    
print_loop:
    lodsb
    cmp al, 0
    je get_input
    int 0x10
    jmp print_loop

get_input:
    mov di, buffer      
    
input_loop:
    mov ah, 0          
    int 0x16           
    
    cmp al, 8          
    je handle_backspace
    
    cmp al, 13         
    je process_command
    
    mov [di], al       
    inc di             
    
    mov ah, 0x0E       
    int 0x10
    
    jmp input_loop

handle_backspace:
    cmp di, buffer     
    je input_loop      
    
    dec di             
    mov byte [di], 0   
    
    mov ah, 0x0E       
    mov al, 8
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 8
    int 0x10
    
    jmp input_loop

process_command:
    mov ah, 0x0E       ; New line
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10

    mov si, buffer
    mov di, cmd_help   ; Compare with "help" command
    call strcmp
    je do_help

    mov si, buffer
    mov di, cmd_clear  ; Compare with "clear" command
    call strcmp
    je do_clear

    mov si, buffer
    mov di, cmd_about  ; Compare with "about" command
    call strcmp
    je do_about

    mov si, buffer
    mov di, cmd_vga    ; Compare with "vga" command
    call strcmp
    je do_vga

    mov si, buffer     ; If no command matched, echo input
    jmp echo_loop

do_help:
    mov si, help_msg
    jmp print_msg

do_clear:
    mov ah, 0          ; Set video mode (clear screen)
    mov al, 3          ; Text mode 80x25
    int 0x10
    jmp clear_and_prompt

do_about:
    mov si, about_msg
    jmp print_msg

do_vga:
    mov ah, 0x00    
    mov al, 0x13    
    int 0x10
    
    mov ah, 0x0C    
    mov al, 0x0F    ; Bright white
    mov bx, 0       ; Page number
draw_box:
    mov cx, 50      ; X start
box_line:
    mov dx, 30      ; Y start
box_column:
    int 0x10
    inc dx
    cmp dx, 170     ; Y end
    jne box_column
    inc cx
    cmp cx, 250     ; X end
    jne box_line


print_msg:
    mov ah, 0x0E
print_msg_loop:
    lodsb
    cmp al, 0
    je clear_and_prompt
    int 0x10
    jmp print_msg_loop

echo_loop:
    lodsb
    cmp al, 0
    je clear_and_prompt
    int 0x10
    jmp echo_loop

clear_and_prompt:
    mov di, buffer     
    mov cx, 64         
clear_loop:
    mov byte [di], 0   
    inc di
    loop clear_loop
    
    mov ah, 0x0E       
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    
    jmp bmain           

; String comparison routine
strcmp:
    push si
    push di
strcmp_loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne strcmp_not_equal
    cmp al, 0
    je strcmp_equal
    inc si
    inc di
    jmp strcmp_loop
strcmp_not_equal:
    pop di
    pop si
    clc
    ret
strcmp_equal:
    pop di
    pop si
    stc
    ret

prompt db 'FirstOS> ', 0
cmd_help db 'help', 0
cmd_clear db 'clear', 0
cmd_about db 'about', 0
cmd_vga db 'vga', 0
help_msg db 'Commands: help, clear, about, vga', 0x0D, 0x0A, 0
about_msg db 'About FirstOS: Windows 95 better addition (not)', 0x0D, 0x0A, 0
buffer times 64 db 0

times 510-($-$$) db 0
dw 0xAA55
