.MODEL SMALL
.STACK 64

.DATA
BIRD_HALF_SIZE      EQU 10

DARK_BLUE           EQU 1
GREEN               EQU 2
LIGHT_BLUE          EQU 3
ROW_END             EQU 4
PINK                EQU 5
LIGHT_BROWN         EQU 6
WHITE               EQU 7
LIGHT_BLACK         EQU 8
PURPLE              EQU 9
LIGHT_GREEN         EQU 10
CYAN                EQU 11
ORANGE              EQU 12
YELLOW              EQU 14

ROW                 DW 120
COLUMN              DW 100

ROW_BIRD            DW 100
COLUMN_BIRD         DW 100

ROW_START           DW 10
COLUMN_START        DW 5
ROW_END             DW 200
COLUMN_END          DW 150

.CODE
MAIN            PROC FAR
                MOV AX,@DATA
                MOV DS,AX

                MOV AH,0 ; set graphic mode
                MOV AL,12H
                INT 10H
DR:
                CALL DRAW_SQUARE_OUTLINE
                MOV CX,10000
BUSY_WA:
                LOOP BUSY_WA
                INC COLUMN_START
                INC COLUMN_END
                MOV DX,028AH
                CMP COLUMN_START,DX
                JNE DR

                MOV AH,4CH ; exit program
                INT 21H

MAIN            ENDP

; This routine gets 2 arguments. (ROW, COLUMN)
DRAW_DOT	    PROC NEAR
                MOV AH,0CH ; write dot to the screen
                MOV CX,COLUMN
                MOV DX,ROW
                INT 10H
                RET
DRAW_DOT	    ENDP


; This routine gets 4 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END)
DRAW_SQUARE_FILL    PROC NEAR
                    MOV DX,ROW_START                
LOOP1:
                    MOV ROW,DX

                    PUSH DX
                    CALL DRAW_HORIZONT_LINE
                    POP DX

                    INC DX
                    CMP DX,ROW_END
                    JNE LOOP1

                    RET
DRAW_SQUARE_FILL    ENDP


; This routine gets 4 arguments. (ROW_START, ROW_END, COLUMN)
DRAW_VERTICAL_LINE      PROC NEAR
                        MOV DX,ROW_START                
LOOP1:
                        MOV ROW,DX

                        PUSH DX
                        CALL DRAW_DOT
                        POP DX

                        INC DX
                        CMP DX,ROW_END
                        JNE LOOP1
                        RET
DRAW_VERTICAL_LINE      ENDP


; This routine gets 4 arguments. (COLUMN_START, COLUMN_END, ROW)
DRAW_HORIZONT_LINE      PROC NEAR
                        MOV DX,COLUMN_START                
LOOP1:
                        MOV COLUMN,DX

                        PUSH DX
                        CALL DRAW_DOT
                        POP DX

                        INC DX
                        CMP DX,COLUMN_END
                        JNE LOOP1
                        RET
DRAW_HORIZONT_LINE      ENDP


; This routine gets 4 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END)
DRAW_SQUARE_OUTLINE         PROC NEAR
;Draw upper line
                            MOV DX,ROW_START                
                            MOV ROW,DX
                            CALL DRAW_HORIZONT_LINE

;Draw down line
                            MOV DX,ROW_END                
                            MOV ROW,DX
                            CALL DRAW_HORIZONT_LINE

;Draw right line
                            MOV DX,COLUMN_END                
                            MOV COLUMN,DX
                            CALL DRAW_VERTICAL_LINE

;Draw left line
                            MOV DX,COLUMN_START                
                            MOV COLUMN,DX
                            CALL DRAW_VERTICAL_LINE
                            RET
DRAW_SQUARE_OUTLINE         ENDP


; This routine gets 2 arguments. (ROW_BIRD, COLUMN_BIRD)
; Fills 3x3
DRAW_BIRD       PROC NEAR
                MOV DX,ROW_BIRD
                MOV AX,COLUMN_BIRD
                SUB DX,BIRD_HALF_SIZE
                SUB AX,BIRD_HALF_SIZE
                MOV ROW_START,DX
                MOV COLUMN_START,AX

                MOV DX,ROW_BIRD
                MOV AX,COLUMN_BIRD
                ADD DX,BIRD_HALF_SIZE
                ADD AX,BIRD_HALF_SIZE
                MOV ROW_END,DX
                MOV COLUMN_END,AX

                MOV AL,DARK_BLUE
                CALL DRAW_SQUARE_FILL
                RET
DRAW_BIRD	    ENDP

DRAW_WALL_UP    PROC NEAR

                RET
DRAW_WALL_UP    ENDP

END MAIN