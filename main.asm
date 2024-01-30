.MODEL SMALL
.STACK 64

.DATA
BIRD_HALF_SIZE      EQU 10
LIGHT_BLUE          EQU 11
DARK_BLUE           EQU 1

ROW                 DB ?
COLUMN              DB ?

ROW_BIRD            DB 100
COLUMN_BIRD         DB 100

ROW_START           DB ?
COLUMN_START        DB ?
ROW_END             DB ?
COLUMN_END          DB ?

.CODE
MAIN            PROC FAR
                MOV AX,@DATA
                MOV DS,AX

                MOV AH,0 ; set graphic mode
                MOV AL,12H
                INT 10H

                CALL FILL_BACKGROUND
                CALL DRAW_BIRD

                MOV AH,4CH ; exit program
                INT 21H

MAIN            ENDP

; This routine gets 2 arguments. (ROW, COLUMN)
DRAW_DOT	    PROC NEAR
                MOV AH,0CH ; write dot to the screen
                MOV CX,0
                MOV DX,0
                MOV CL,ROW
                MOV DL,COLUMN
                INT 10H
                RET
DRAW_DOT	    ENDP


; This routine gets 4 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END)
DRAW_SQUARE         PROC NEAR
                MOV DH,ROW_START                
LOOP1:
                MOV DL,COLUMN_START
LOOP2:
                MOV ROW,DH
                MOV COLUMN,DL

                PUSH AX
                PUSH DX
                CALL DRAW_DOT
                POP DX
                POP AX

                INC DL
                CMP DL,COLUMN_END
                JNE LOOP2

                INC DH
                CMP DH,ROW_END
                JNE LOOP1
                    RET
DRAW_SQUARE         ENDP


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
                            MOV DH,ROW_START                
                            MOV DL,COLUMN_START
;Draw upper line
LOOP1:
                            MOV ROW,DH
                            MOV COLUMN,DL

                            PUSH AX
                            PUSH DX
                            CALL DRAW_DOT
                            POP DX
                            POP AX

                            INC DL
                            CMP DL,COLUMN_END
                            JNE LOOP1
;Draw right line
LOOP2:
                            MOV ROW,DH
                            MOV COLUMN,DL

                            PUSH AX
                            PUSH DX
                            CALL DRAW_DOT
                            POP DX
                            POP AX

                            INC DH
                            CMP DH,ROW_END
                            JNE LOOP2
;Draw down line
LOOP2:
                            MOV ROW,DH
                            MOV COLUMN,DL

                            PUSH AX
                            PUSH DX
                            CALL DRAW_DOT
                            POP DX
                            POP AX

                            INC DH
                            CMP DH,ROW_END
                            JNE LOOP2
                            
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
                CALL DRAW_SQUARE
                RET
DRAW_BIRD	    ENDP

DRAW_WALL_UP    PROC NEAR

                RET
DRAW_WALL_UP    ENDP

FILL_BACKGROUND PROC NEAR
                MOV ROW_START,40
                MOV COLUMN_START,0
                MOV ROW_END,250
                MOV COLUMN_END,250
                MOV AL,LIGHT_BLUE
                CALL DRAW_SQUARE
                RET
FILL_BACKGROUND ENDP


END MAIN