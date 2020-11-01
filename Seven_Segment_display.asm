;
; Seven_Segment_display.asm
;
; Created: 10/22/2020 8:40:09 PM
; Author : Chaise Ballotti
; Purpse : Using I/O arrays and pointers to display digits 0-9 
;          on a seven segment display. This will use a push button
;          to cycle through the digits.

.def nxt_dgt = r19

main:
          ; initialize the stack pointer
          ldi       r16,HIGH(RAMEND)
          out       SPH,r16
          ldi       r16,LOW(RAMEND)
          out       SPL,r16             ; end of stack pointer initialization

          ; force 1mhz clock for an easier delay
          ldi       r16,0b10000000
          sts       CLKPR,r16           ; enables clock div change
          ldi       r16,0b00000011
          sts       CLKPR,r16           ; set DIV8 (base clock is 8mhz/8 = 1mhz)

          ; set array pointer
          ldi       ZH,HIGH(digits << 1)
          ldi       ZL,LOW(digits << 1) ; left sifting by one to multiply by 2

          ; initialize port registers
          ldi       r16,0xff            ; Bit mask for output
          out       DDRD,r16            ; for every pin
          
          cbi       DDRB,DDB4           ; setting portb pin 4 to input
          sbi       PORTB,PB4           ; set portb pin 4 to pull-up
          
          ldi       nxt_dgt,0           ; next digit to display
          call      disp_digit          ; initialize dispaly to 0
main_proc:
          sbis      PINB,PINB4          ; skip call to disp_digit if pinb 4 cleared
          call      disp_digit

          call      delay_250           ; delay .25 seconds before checking

end_main: rjmp     main_proc

; code to cycle through and display the digits
disp_digit:
          lpm       r0,Z+               ; get current digit and inc pointer
          out       PORTD,r0            ; display digit

          inc       nxt_dgt

          cpi       nxt_dgt,10
          brne      disp_ret            ; if flase skip
                                        ; if true do the following
          sbiw      ZH:ZL,10            ; reset z pointer
          ldi       nxt_dgt,0
disp_ret:
          ret                           ; end disp_digit

; creating a delay for button push to cycle through digits 250ms
delay_250:
          ldi       r25,HIGH(50000)     ; initialize value for delay
          ldi       r24,LOW(50000)
delay_lp:
          nop
          sbiw      R25:R24,1
          brne      delay_lp
          ret                           ;end delay_50

      ;        0    1    2    3    4    5    6    7    8    9
digits: .db 0x7b,0x60,0x37,0x76,0x6c,0x5e,0x5f,0x70,0x7f,0x7c