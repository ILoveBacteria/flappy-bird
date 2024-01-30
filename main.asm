.MODEL SMALL
.STACK 64

.DATA
BIRD_HALF_SIZE      EQU 10
LIGHT_BLUE          EQU 11
DARK_BLUE           EQU 1

ROW                 DB 120
COLUMN              DB 100

ROW_BIRD            DB 100
COLUMN_BIRD         DB 100

ROW_START           DB 10
COLUMN_START        DB 5
ROW_END             DB 200
COLUMN_END          DB 150

.CODE
MAIN            PROC FAR
                MOV AX,@DATA
                MOV DS,AX

                MOV AH,0 ; set graphic mode
                MOV AL,12H
                INT 10H

                CALL DRAW_SQUARE_OUTLINE

                MOV AH,4CH ; exit program
                INT 21H

MAIN            ENDP

; This routine gets 2 arguments. (ROW, COLUMN)
DRAW_DOT	    PROC NEAR
                MOV AH,0CH ; write dot to the screen
                MOV CX,0
                MOV DX,0
                MOV CL,COLUMN
                MOV DL,ROW
                INT 10H
                RET
DRAW_DOT	    ENDP


; This routine gets 4 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END)
DRAW_SQUARE_FILL    PROC NEAR
                    MOV DH,ROW_START                
LOOP1:
                    MOV ROW,DH

                    PUSH DX
                    CALL DRAW_HORIZONT_LINE
                    POP DX

                    INC DH
                    CMP DH,ROW_END
                    JNE LOOP1

                    RET
DRAW_SQUARE_FILL    ENDP


; This routine gets 4 arguments. (ROW_START, ROW_END, COLUMN)
DRAW_VERTICAL_LINE      PROC NEAR
                        MOV DH,ROW_START                
LOOP1:
                        MOV ROW,DH

                        PUSH DX
                        CALL DRAW_DOT
                        POP DX

                        INC DH
                        CMP DH,ROW_END
                        JNE LOOP1
                        RET
DRAW_VERTICAL_LINE      ENDP


; This routine gets 4 arguments. (COLUMN_START, COLUMN_END, ROW)
DRAW_HORIZONT_LINE      PROC NEAR
                        MOV DH,COLUMN_START                
LOOP1:
                        MOV COLUMN,DH

                        PUSH DX
                        CALL DRAW_DOT
                        POP DX

                        INC DH
                        CMP DH,COLUMN_END
                        JNE LOOP1
                        RET
DRAW_HORIZONT_LINE      ENDP


; This routine gets 4 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END)
DRAW_SQUARE_OUTLINE         PROC NEAR
;Draw upper line
                            MOV DH,ROW_START                
                            MOV ROW,DH
                            CALL DRAW_HORIZONT_LINE

;Draw down line
                            MOV DH,ROW_END                
                            MOV ROW,DH
                            CALL DRAW_HORIZONT_LINE

;Draw right line
                            MOV DH,COLUMN_END                
                            MOV COLUMN,DH
                            CALL DRAW_VERTICAL_LINE

;Draw left line
                            MOV DH,COLUMN_START                
                            MOV COLUMN,DH
                            CALL DRAW_VERTICAL_LINE
                            RET
DRAW_SQUARE_OUTLINE         ENDP


; This routine gets 2 arguments. (ROW_BIRD, COLUMN_BIRD)
; Fills 3x3
DRAW_BIRD       PROC NEAR
                MOV DL,ROW_BIRD
                MOV DH,COLUMN_BIRD
                SUB DL,BIRD_HALF_SIZE
                SUB DH,BIRD_HALF_SIZE
                MOV ROW_START,DL
                MOV COLUMN_START,DH

                MOV DL,ROW_BIRD
                MOV DH,COLUMN_BIRD
                ADD DL,BIRD_HALF_SIZE
                ADD DH,BIRD_HALF_SIZE
                MOV ROW_END,DL
                MOV COLUMN_END,DH

                MOV AL,DARK_BLUE
                CALL DRAW_SQUARE_FILL
                RET
DRAW_BIRD	    ENDP

DRAW_WALL_UP    PROC NEAR

                RET
DRAW_WALL_UP    ENDP

END MAIN