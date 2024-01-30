.MODEL SMALL
.STACK 64

.DATA
BIRD_HALF_SIZE      EQU 5

BLACK               EQU 0
DARK_BLUE           EQU 1
GREEN               EQU 2
LIGHT_BLUE          EQU 3
RED                 EQU 4
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
DOT_COLOR           DW 0

ROW_BIRD            DW 100
COLUMN_BIRD         DW 100

ROW_START           DW 10
COLUMN_START        DW 5
ROW_END             DW 20
COLUMN_END          DW 80

IS_BIRD_FLY         DB 0

WALL_ROW_START           DW 130
WALL_COLUMN_START        DW 300
WALL_ROW_END             DW 200
WALL_COLUMN_END          DW 320

.CODE
MAIN            PROC FAR
                MOV AX,@DATA
                MOV DS,AX

                MOV AX,0A000H
                MOV ES,AX
                CALL CLEAR_SCREEN
                CALL TEST_CODE

                MOV AH,4CH ; exit program
                INT 21H

MAIN            ENDP

TEST_CODE       PROC NEAR
DR:
                ; Moving wall
                CALL DELETE_WALL

                DEC WALL_COLUMN_END
                DEC WALL_COLUMN_START
                MOV DOT_COLOR,GREEN
                CALL DRAW_WALL
                ;Moving bird
                MOV DOT_COLOR,BLACK
                CALL DRAW_BIRD
                ; If the bird is flying then move it up else move it down
                CMP IS_BIRD_FLY,0
                JZ ELSE1
                DEC ROW_BIRD
                JMP ELSE2
ELSE1:          INC ROW_BIRD
ELSE2:
                MOV DOT_COLOR,WHITE
                CALL DRAW_BIRD
                ; Wait here
                MOV CX,60000
BUSY_WAIT:
                LOOP BUSY_WAIT
                
                ; For simulation, change the IS_BIRD_FLY bit
                CMP ROW_BIRD,70
                JE TOGGLE
                CMP ROW_BIRD,130
                JNE ELSE3
TOGGLE:
                XOR IS_BIRD_FLY,1
ELSE3:
                CMP WALL_COLUMN_START,0
                JG DR
                RET
TEST_CODE       ENDP

GET_OFFSET      PROC NEAR
                MOV AX,320
                MUL ROW
                ADD AX,COLUMN
                MOV BX,AX
                RET
GET_OFFSET      ENDP

; This routine gets 2 arguments. (ROW, COLUMN)
CLEAR_SCREEN    PROC NEAR
                MOV AH,0 ; set graphic mode
                MOV AL,13H ; 320x200
                INT 10H
                RET
CLEAR_SCREEN    ENDP

; This routine gets 2 arguments. (ROW, COLUMN, DOT_COLOR)
DRAW_DOT	    PROC NEAR
                CALL GET_OFFSET
                MOV DX,DOT_COLOR
                MOV ES:[BX],DX
                RET
DRAW_DOT	    ENDP


; This routine gets 4 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END, DOT_COLOR)
DRAW_SQUARE_FILL    PROC NEAR
                    MOV DX,ROW_START                
LOOP1:
                    MOV ROW,DX

                    PUSH DX
                    CALL DRAW_HORIZONT_LINE
                    POP DX

                    INC DX
                    CMP DX,ROW_END
                    JBE LOOP1

                    RET
DRAW_SQUARE_FILL    ENDP


; This routine gets 4 arguments. (ROW_START, ROW_END, COLUMN, DOT_COLOR)
DRAW_VERTICAL_LINE      PROC NEAR
                        MOV DX,ROW_START                
LOOP1:
                        MOV ROW,DX

                        PUSH DX
                        CALL DRAW_DOT
                        POP DX

                        INC DX
                        CMP DX,ROW_END
                        JBE LOOP1
                        RET
DRAW_VERTICAL_LINE      ENDP


; This routine gets 4 arguments. (COLUMN_START, COLUMN_END, ROW, DOT_COLOR)
DRAW_HORIZONT_LINE      PROC NEAR
                        MOV DX,COLUMN_START                
LOOP1:
                        MOV COLUMN,DX

                        PUSH DX
                        CALL DRAW_DOT
                        POP DX

                        INC DX
                        CMP DX,COLUMN_END
                        JBE LOOP1
                        RET
DRAW_HORIZONT_LINE      ENDP


; This routine gets 4 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END, DOT_COLOR)
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


; This routine gets 2 arguments. (ROW_BIRD, COLUMN_BIRD, DOT_COLOR)
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

                CALL DRAW_SQUARE_OUTLINE
                RET
DRAW_BIRD	    ENDP

; (WALL_ROW_START, WALL_ROW_END, WALL_COLUMN_START, WALL_COLUMN_END, DOT_COLOR)
DRAW_WALL       PROC NEAR
                MOV DX, WALL_ROW_START
                MOV ROW_START,DX
                MOV DX, WALL_COLUMN_START
                MOV COLUMN_START,DX
                MOV DX, WALL_ROW_END
                MOV ROW_END,DX
                MOV DX, WALL_COLUMN_END
                MOV COLUMN_END,DX
                CALL DRAW_SQUARE_OUTLINE
                RET
DRAW_WALL       ENDP

; (WALL_ROW_START, WALL_ROW_END, WALL_COLUMN_START, WALL_COLUMN_END)
; This routine does not clear the whole wall. Just deletes the left and right lines of wall to make it ready for moving.
; Has more perfoemance than clearing whole wall and then draw a new shifted wall
DELETE_WALL     PROC NEAR
                ;Remove the left line
                MOV DX, WALL_ROW_START
                MOV ROW_START,DX
                MOV DX, WALL_ROW_END
                MOV ROW_END,DX
                MOV DX,WALL_COLUMN_START
                MOV COLUMN,DX
                MOV DOT_COLOR,BLACK
                CALL DRAW_VERTICAL_LINE

                ;Remove the left line
                MOV DX,WALL_COLUMN_END
                MOV COLUMN,DX
                CALL DRAW_VERTICAL_LINE
                RET
DELETE_WALL     ENDP

END MAIN