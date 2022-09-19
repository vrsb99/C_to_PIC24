NUM_LOOPS = 100                 ; Number of loop iterations to run.
                                ; For debug, choose a small number (1 to 10)
                                ; then increase it when your code works.

.bss                            ; Unitialized data section.
; *****************************************************************************
; TO DO: Declare other variables above; only u8_e is declared here. See the
; next TO DO comment for what variables to declare.
;
; You MUST place .space declarations for 32-bit variables first, followed by
; 16-bit variables, followed by 8-bit variables, to preserve proper alignment.
; For example,
; u32_b: .space 4
; u16_c: .space 2
; u8_a:  .space 1
; is the correct order.
; *****************************************************************************
u16_a:	 .space 2
u16_b:	 .space 2
u16_c:	 .space 2
u8_d:	 .space 1
u8_e:    .space 1

;..............................................................................
;Code Section in Program Memory
;..............................................................................

.text                           ; Start of Code section.

.global _main                   ; Therefore, it must be visible outside this file.
_main:                          ; _main is called after C startup code runs.

    ; *************************************************************************
    ; TO DO: Translate the assignments below to PIC24 assembly. Declare these
    ; variables after the previous TO DO comment.
    ; *************************************************************************

    ; Register assignment. Fill in the values in the comment on the next line.
    ; Do this for ALL register assignments in this program!
    ;           W0       W0
    ; uint16_t u16_a = 0xE494;
    ; Input
    mov #0xE494, W0
    ; Output
    mov W0, u16_a
    
    ;           W0       W0
    ; uint16_t u16_b = 0x29A5;
    ; Input
    mov #0x29A5, W0
    ; Output
    mov W0, u16_b

    ;           W0       W0
    ; uint16_t u16_c = 0x4A55;
    ; Input
    mov #0x4A55, W0
    ; Output
    mov W0, u16_c

    ;          W0      W0
    ; uint8_t u8_d = 0x8F;
    ; Input
    mov.b #0x8F, W0
    ; Output
    mov.b WREG, u8_d

    ; u8_e = 0;
    clr.b u8_e

    ; do {
    do_top:
        mov.b u8_e, WREG
        mov.b W0, W4
        ; *********************************************************************
        ; TO DO: To print out the variables in your code, set:
        ; W0 = u16_a
        ; W1 = u16_b
        ; W2 = u16_c
        ; W3 = u8_d
        ; W4 = u8_e
        ; Note: since only u8_e is used in this sample,
        ; this sample code just sets it. You'll have to do all of them. Make
        ; sure your code comes AFTER this comment but BEFORE the call 
        ; instruction.
        ; *********************************************************************
        ; Your code goes here.
	mov.b u8_e, WREG
        mov.b W0, W4        ;W4 = u8_e
        mov.b u8_d, WREG
        mov   W0, W3        ;W3 = u8_d
	mov   u16_c, W2	    ;W2 = u16_c
        mov   u16_b, W1     ;W1 = u16_b
        mov   u16_a, W0     ;W0 = u16_a
        call _check

        ; *********************************************************************
        ; TO DO: Implement the code fragment below.
        ; *********************************************************************
       ; *********************************************************************
        ; TO DO: Implement the code fragment below:
        ; 1. Fill in all register assignments.
        ; 2. Write the code for each line. DO NOT rely on previous register
        ;    values from other lines of code. Instead, simply load in all inputs
        ;    for the line of C code you're implementing.
        ; *********************************************************************

        ;      W0       W1
        ; if (u16_c & 0x0800) {
        ; Input
	mov u16_c, W0
	mov #0x0800, W1
        ; Process
	and W0, W1, W2
        ; Output
	bra NZ, if_1
	bra Z, else_1
	
	    if_1:
            ;	    W3	    W4
            ; if (u16_b < u16_a) {
            ; Input
	    mov u16_b, W3
	    mov u16_a, W4
            ; Process
	    cp W3, W4
	    bra LTU, if_2
	    bra else_2
            ; Output
		if_2:
                ;  W3	    W3	    W4
                ; u16_b = u16_b + u16_a;
                ; Input
                ; Process
		add W3, W4, W3
                ; Output
		mov W3, u16_b
           ; Code may go here...
	   bra end_body
           ; } else {
		else_2:
           ; ...and may also go here.

                ; W1	    W2	    W1			      W0
                ; u16_a = u16_b + (u16_a >> 2) + ((uint16_t) u8_d);
		
                ; Input
                mov.b u8_d, WREG
		mov u16_a, W1
		mov u16_b, W2
		; Process
		ze W0, W0
		lsr W1, #2, W1
		add W0, W1, W1
		add W1, W2, W1
	       ; Output
		mov W1, u16_a
           ; Code may go here...
	   bra end_body
           ; }
           ; ...and may also go here.

      ; Code may go here...
      ; } else {
      else_1:
      ; ...and may also go here.

          ; W2	    W1	    W2
          ; u16_b = u16_a - u16_b;
          ; Input
	  mov u16_b, W2
	  mov u16_a, W1
          ; Process
	  sub W1, W2, W2
          ; Output
	  mov W2, u16_b

          ;   W1	W1	W2		    W0
          ;  u16_a = u16_a + 0x8080 - (((uint16_t) u8_d) >> 2);
          ; Input
	   mov.b u8_d, WREG
	   mov #0x8080, W2
           ; Process
	   ze W0, W0
	   lsr W0, #2, W0
	   sub W2, W0, W2
	   add W1, W2, W1
           ; Output
           mov W1, u16_a
          ;   W0	 W0     W1	W2
          ;  u8_d = ~( (u8_d ^ 0xA5) + 128) ; // 128 is in decimal!
          ; Input
	  mov.b u8_d, WREG
	  mov #0x00A5, W1
	  mov #128, W2
          ; Process
	  xor W0, W1, W1
	  add W1, W2, W0
	  com W0, W0
          ; Output
	  mov.b WREG, u8_d
	  bra end_body



        ; Code may go here...
        ; }
        ; ...and may also go here.
	end_body:
        ;  W3		W3	    W2
        ; u16_c = ~( (u16_c << 1) + u16_b);
        ; Input
	mov u16_b, W2
	mov u16_c, W3
        ; Process
	sl W3, #1, W3
	add W2, W3, W3
	com W3, W3
        ; Output
	mov W3, u16_c
        ; The two lines of C code below have already been implemented.
        ; Do not modify them.

        ; u8_e++
        inc.b u8_e
        ; } while (u8_e < NUM_LOOPS);
        ;        WREG       W1
        mov.b u8_e, WREG
        mov.b #NUM_LOOPS, W1
        cp.b W0, W1
        bra LTU, do_top
        bra GEU, do_end
    do_end:

done:
    goto    done

.end       ;End of program code in this file

/** \endcond */
