; *******************
; upcase_asmversion.s
; *******************
;
; illustrates string initialization from program memory
; using the PSV window

.include "xc.inc"

; Declare variables
; =================
; Unitialized data section
.bss
sz_1:   .space 16
sz_2:   .space 16
u8_c:	  .space 1
mplab_x_bug: .space 2

; Initialized constant data section.
; The statement below is taken from DS70613C, page 4-21.
.section .const, psv
sz_1_const: .asciz "Upper/LOWER."
sz_2_const: .asciz "mIXeD CaSe.."


; Code
; ====
.text
.global __reset
__reset:
; Initialize the stack pointer and stack limit register.
mov #__SP_init, W15
; __SPLIM_init is set by linker to be after allocated data.
mov #__SPLIM_init, W0
mov W0, SPLIM

; Copy constant data to RAM.
;; char sz_1[] = "Hello";
;; char sz_1[] = "UPPER/lower";
call init_variables       ;initialize strings
; Now that everything is initialized, call main().
rcall main
; If main() exits, restart the processor.
reset

;; void main(void) {
main:

  ;;         W0   W1
  ;; dostr(sz_1, sz_2);
  mov #sz_1, W0
  mov #sz_2, W1
  rcall dostr
  
  ;; while(1);
  done:
  goto    done

;; }
return


;;                    W0
;; void upcase(char *psz_1) {
dostr:

  ;;          W0
  ;; while (*psz_2 != 0) {
  ;;        --W1--
  ; Input
  mov.b [W1], W2
  ; Process
  cp.b W2, #0
  ; Output
  bra Z, dostr_while_end  ; Z means !=
    ;; u8_c = *psz_2;
    mov.b [W1], W2
    mov W2, u8_c
    ;;	    W2	    W3
    ;; if (u8_c > 0x2F) {
    ;; Left input
    mov u8_c, W2
    ; Left process
    cp.b W2, #0x2F
    ; Left output
    bra GTU, if_body
    bra LEU, if_else  ;if_else
    if_body:
      ;; // lowercase a-z, so
      ;; // convert to A-Z
      ;;   W0       W2    W3
      ;; *psz_1 = u8_c | 0x20; 
      ;;          --W1--
      ; Input
      mov u8_c, W2
      mov #0x20, W3
      ; Process, output
      ior.b W2, W3, [W0]
      bra if_end
      
    ;;  } else {
    if_else:
    ;;    W0      W2
    ;; *psz_1 = u8_c;
    mov u8_c, W2
    mov.b W2, [W0]
    
    bra if_end
    if_end:

    ;;   W0
    ;;  psz_1++;  //advance to next char
    ;;   W1
    ;;	psz_2++;
    inc W0, W0
    inc W1, W1

  bra dostr          ;loop back to top
  ;; }
  dostr_while_end:

;; }
return

;; void init_variables() {
init_variables:

  ;;              DSRPAG:W0    W1
  ;; copy_cstring(sz_1_const, sz_1)
  ; Set DSRPAG to the page that contains the sz_1_const array
  movpag #psvpage(sz_1_const), DSRPAG
  ; Set up W0 as a pointer to sz_1_const through the PSV data window
  mov  #psvoffset(sz_1_const), W0
  mov  #sz_1,W1
  rcall copy_cstring

  ;;              DSRPAG:W0    W1
  ;; copy_cstring(sz_2_const, sz_2)
  ; Set DSRPAG to the page that contains the sz_2_const array
  movpag #psvpage(sz_2_const), DSRPAG
  ; Set up W0 as a pointer to sz_2_const through the PSV data window
  mov  #psvoffset(sz_2_const), W0
  mov  #sz_2, W1
  rcall copy_cstring
  return

; Copy constant null-terminated string from program memory to data memory.
;;                             DSRPAG:W0          W1
;; void copy_cstring(const char* psz_src, char* psz_dest)
copy_cstring:

  ;;           W0
  ;; while (*psz_src != 0) {
  ;;        ---W2---
  mov.b [W0], W2
  cp.b W2, #0
  bra NZ, copy_cstring_while_body ; NZ means !=
  bra Z, copy_cstring_while_end   ; Z means ==
  copy_cstring_while_body:

    ;;    W1            W0
    ;; *psz_dest++ = *psz_src++;
    mov.b [W0++], [W1++]

  bra  copy_cstring
  ;; }
  copy_cstring_while_end:

  ;; // Copy null terminator.
  ;;    W1            W0
  ;; *psz_dest++ = *psz_src++;
  mov.b [W0++], [W1++]

;; }
return
