#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#
      
	db 1024 dup(0)
	
;init ds, es, ss, sp
st1:cli
	mov ax,0200h
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0f00H
	
; init 8259
	mov al, 13h ;icw1
    out 10h, al
	mov al, 80h ;icw2
	out 12h, al
	mov al, 01h ;icw4
	out 12h, al
	mov al, 00h ;ocw1
	out 12h, al
	sti
	
;init 8255
	mov al, 81h
	out 06h, al
	mov al, 00h
	out 04h, al
	mov al, 00h
	out 02, al

;init 8253 
;C0 - 50 ms, 1khz input, count = 50, mode 3     
	mov al, 00110111b
	out 0eh, al
	mov al, 50
	out 08h, al
	mov al, 00
	out 08h, al
;C1 - Random time generator, 1khz input, count = 4k, mode 3
    mov al, 01110111b
    out 0eh, al 
    mov al, 00
	out 0ah, al
	mov al, 40
	out 0ah, al
         
;check game start
gst:in al, 04h
    and al, 01h
    cmp al, 01h
    jne gst                              

;init all displays and 50ms clock
mov al, 00h
out 00h, al
out 02h, al
out 04h, al

;generate random number
    ;
    in al, 04h
    and al, 02h
    cmp al, 02h
    je stp
    
    in al, 04h
    and al, 08h
    mov ah, al
    cmp al, 08h
    je hi
    
lo: ;
    in al, 04h
    and al, 02h
    cmp al, 02h
    je stp
    
    in al, 04h    
    and al, 08h
    cmp al, ah
    je lo
    
lo2:;
    in al, 04h
    and al, 02h
    cmp al, 02h
    je stp
    
    in al, 04h
    and al, 08h
    cmp al, ah
    jne lo2
    jmp pc0
    
hi: ;
    in al, 04h
    and al, 02h
    cmp al, 02h
    je stp
    
    in al, 04h    
    and al, 08h
    cmp al, ah
    je hi

hi2:;
    in al, 04h
    and al, 02h
    cmp al, 02h
    je stp
    
    in al, 04h
    and al, 08h
    cmp al, ah
    jne hi2
               
; start the first led and C0 (50ms)
pc0:mov al, 30h
    out 04h, al

;store score in bl          
    mov bl, 10
;store if the user wins in bh    
    mov dx, 0
    
ml: in al, 04h
    and al, 04h
    mov ah, al
    
    w51:;
        in al, 04h
        and al, 02h
        cmp al, 02h
        je go
    
        in al, 04h
        and al, 04h
        cmp ah, al
        je w51
    
    stc
    rcl dl, 1
    mov al, dl
    out 00, al
    
    ;debug score
    cmp dl, 11111111b
    je go
    dec bl
    jmp ml
    
;in case of cheating with stop button
stp:mov cx, 30h
lpt:in al, 04h
    and al, 04h
    mov ah, al
    cmp ah,00h
    jne glw
    
    mov al,00
    out 00h,al
    mov al, 20h
    out 04, al
    jmp w52
    
glw:mov al,0ffh
    out 00h,al
    mov al, 30h
    out 04, al
    
w52:in al, 04h
    and al, 04h
    cmp ah, al
    je w52
    
    dec cx
    jnz lpt
    
    ;init all displays and 50ms clock
    mov al, 00h
    out 00h, al
    out 02h, al
    out 04h, al
    
    jmp gst

;otherwise you display and restart    
go: mov al, bl
    ror al, 1
    out 02h, al
    jmp gst