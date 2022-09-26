; Number of loop iterations to run. For debug, choose a small number (1 to 10)
; then increase it when your code works.
NUM_LOOPS = 100


; Unitialized data section.
.bss
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
i32_a:	 .space 4
i32_b:	 .space 4
i32_c:	 .space 4
i16_d:	 .space 2
u8_e:    .space 1

;..............................................................................
;Code Section in Program Memory
;..............................................................................

.text                           ; Start of Code section.

.global _main                   ; Therefore, it must be visible outside this file.
_main:                          ; _main is called after C startup code runs.

    ; *************************************************************************
    ; TO DO: Translate the assignments below to PIC24 assembly. Declare these
    ; variables after the previous TO DO comment..
    ; *************************************************************************
    ;; int32_t i32_a = 0xB3E83894;
    mov #0x3894, W1
    mov W1, i32_a
    mov #0xB3E8, W2
    mov W2, i32_a + 2
    ;; int32_t i32_b = 0x348AC297;
    mov #0xC297, W1
    mov W1, i32_b
    mov #0x348A, W2
    mov W2, i32_b + 2
    ;; int32_t i32_c = 0xA55A93CD;
    mov #0x93CD, W1
    mov W1, i32_c
    mov #0xA55A, W2
    mov W2, i32_c + 2
    ;; int16_t i16_d = 0xA4F5;
    mov #0xA4F5, W1
    mov W1, i16_d

    ; u8_e = 0;
    clr.b u8_e

    ; do {
    do_top:

        
        ; *********************************************************************
        ; TO DO: To print out the variables in your code, set:
	mov.b u8_e, WREG
        mov.b W0, W7
        ; W1:W0 = i32_a
	mov i32_a, W0
	mov i32_a + 2, W1
        ; W3:W2 = i32_b
	mov i32_b, W2
	mov i32_b + 2, W3
        ; W5:W4 = i32_c
	mov i32_c, W4
	mov i32_c +2, W5
        ; W6 = i16_d
	mov i16_d, W6
        ; W7 = u8_e
        ; Note: since only u8_e is used in this sample,
        ; this sample code just sets it. You'll have to do all of them. Make
        ; sure your code comes AFTER this comment but BEFORE the call
        ; instruction.
        ; *********************************************************************
        ; Your code goes here.
        call _check

        ; *********************************************************************
        ; The code fragment to implement:
        ; *********************************************************************
        ;; if (i32_c & 0x08000000) {
        ;;     if (i32_b < i32_a) {
        ;;         i32_b = i32_b + i32_a;
        ;;     } else {
        ;;         i32_a = i32_b + (i32_a >> 2) + ((int32_t) i16_d);
        ;;     }
        ;; } else {	
        ;;     i32_b = i32_a - i32_b;
        ;;     i32_a = i32_a + 0xA2588080 ;
        ;;     i16_d = ~( (i16_d ^ 0x00A5) + 128) ; //128 is in decimal!
        ;; }
        ;; i32_c = ~( (i32_c << 1) + i32_b);

        ; *********************************************************************
        ; TO DO: Implement the templates below:
        ; 1. Fill in all register assignments.
        ; 2. Write the code for each line. DO NOT rely on previous register
        ;    values from other lines of code. Instead, simply load in all inputs
        ;    for the line of C code you're implementing.
        ; *********************************************************************

        ;      W5:W4       W9
        ; if (i32_c & 0x08000000) {
        ; Input
	mov #0x0800, W9
        ; Process
	mov i32_c +2, W5
	and W9, W5, W5
	cp W5, #0
	bra NZ, if1
	bra Z, else1
        ; Output
            ;	  W3:W2	  W1:W0
            ; if (i32_b < i32_a) {
            ; Input
	    if1:
		mov i32_a, W0
		mov i32_a + 2, W1
		mov i32_b, W2
		mov i32_b + 2, W3
            ; Process
	    cp W2, W0
	    cpb W3, W1
	    bra LT, if2
	    bra GE, else2
            ; Output
	    if2:
                ;  W3:W2   W3:W2    W1:W0
                ; i32_b = i32_b + i32_a;
                ; Input
		mov i32_a, W0
		mov i32_a + 2, W1
		mov i32_b, W2
		mov i32_b + 2, W3
                ; Process
		add W0, W2, W2
		addc W1, W3, W3
                ; Output
		mov W2, i32_b
		mov W3, i32_b +2
		bra end1

           ; Code may go here...
           ; } else {
           ; ...and may also go here.
	   else2:
                ; Replace this line with your register assigments.
                ; i32_a = i32_b + (i32_a >> 2) + ((int32_t) i16_d);
                ; Input
		mov i32_a, W0
		mov i32_a + 2, W1
		mov i32_b, W2
		mov i32_b + 2, W3
		mov i16_d, W6
		
		cp W6, #0
		bra LT, is_neg
		mov #0, W7
		bra se_done
		is_neg:
		mov #0xFFFF, W7
		se_done:
                ; Process
		asr W1,W1
		rrc W0, W0
		asr W1,W1
		rrc W0, W0
		add W0, W2, W2
		addc W1, W3, W3
		add W2, W6, W6
		addc W3, W7, W7 
                ; Output
		mov W6, i32_a
		mov W7, i32_a +2
		bra end1
           ; Code may go here...
           ; }
	   end1:
	   bra end2
           ; ...and may also go here.

      ; Code may go here...
      ; } else {
      ; ...and may also go here.
      else1:
          ; W3:W2   W1:W0   W3:W2
          ; i32_b = i32_a - i32_b;
          ; Input
	  mov i32_a, W0
	  mov i32_a + 2, W1
	  mov i32_b, W2
	  mov i32_b + 2, W3
          ; Process
	  sub W0, W2, W2
	  subb W1, W3, W3
          ; Output
	  mov W2, i32_b
	  mov W3, i32_b + 2

          ;    W1:W0   W1:W0   W9:W8
          ;   i32_a = i32_a + 0xA2588080 ;
          ; Input
	  mov i32_a, W0
	  mov i32_a + 2, W1
	  mov #0x8080, W8
	  mov #0xA258, W9
          ; Process
	  add W0, W8, W0
	  addc W1, W9, W1
          ; Output
	  mov W0, i32_a
	  mov W1, i32_a +2

          ; Replace this line with your register assigments.
          ;  i16_d = ~( (i16_d ^ 0x00A5) + 128) ; ; //128 is in decimal!
          ; Input
	  mov #0x00A5, W8
	  mov #128, W9
	  mov i16_d, W6
          ; Process
	  xor W6, W8, W6
          add W6, W9, W6
	  com W6, W6
          ; Output
	  mov W6, i16_d
	  bra end2
        ; Code may go here...
        ; }
        ; ...and may also go here.
	end2:
        ; W5:W4		W5:W4	    W3:W2
        ; i32_c = ~( (i32_c << 1) + i32_b);
        ; Input
	mov i32_b, W2
	mov i32_b + 2, W3
	mov i32_c, W4
	mov i32_c + 2, W5
        ; Process
	sl W4, W4
	rlc W5, W5
	add W2, W4, W4
	addc W3, W5, W5
	com W4, W4
	com W5, W5
        ; Output
	mov W4, i32_c
	mov W5, i32_c + 2


        ; The two lines of C code below have already been implemented.
        ; Do not modify them.

        ; u8_e++
        inc.b u8_e
        ;        WREG       W1
        ; } while (u8_e < NUM_LOOPS);
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
