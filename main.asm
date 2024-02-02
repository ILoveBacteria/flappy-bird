.MODEL SMALL
.STACK 64

.DATA
SCREEN_WIDTH        EQU 320 - 1
SCREEN_HEIGHT       EQU 200 - 1

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

TOP_MARGIN          EQU 10
BOTTOM_MARGIN       EQU SCREEN_HEIGHT

ROW                 DW 120
COLUMN              DW 100
DOT_COLOR           DW 0

BIRD_SIZE           EQU 10
ROW_BIRD_START      DW 20
ROW_BIRD_END        DW 20 + BIRD_SIZE
COLUMN_BIRD_START   DW 100
COLUMN_BIRD_END     DW 100 + BIRD_SIZE
VELOCITY_BIRD       DW 0
ACCELERATION_BIRD   DW 1
FLY_VELOCITY_BIRD   DW 0FFF9H

ROW_START           DW 10
COLUMN_START        DW 5
ROW_END             DW 20
COLUMN_END          DW 80

IS_BIRD_FLY         DB 0
IS_GAMEOVER         DB 0
IS_POINT_IN_WALL    DB 0

WALL_ROW_START      DW 130
WALL_COLUMN_START   DW 300
WALL_ROW_END        DW BOTTOM_MARGIN - 1
WALL_COLUMN_END     DW 300+20

SCORE               DW 0
SCORE_LENGTH        DW 0
NUMBER_STRING       DB 4 DUP ('$')

.CODE
MAIN            PROC FAR
                MOV AX,@DATA
                MOV DS,AX

                MOV AX,0A000H
                MOV ES,AX
                CALL CLEAR_SCREEN
                CALL DRAW_MARGIN
                MOV AX,SCORE
                CALL PRINT_SCORE
                CALL TEST_CODE

                MOV AH,4CH ; exit program
                INT 21H

MAIN            ENDP


; The main logic of the game
; This routine gets no arguments and returns if the game is over
TEST_CODE       PROC NEAR
DR:
                ; Wait here
                CALL DELAY
                ; Moving wall
                CALL MOVE_WALL
                ;Moving bird
                MOV DOT_COLOR,BLACK
                CALL DRAW_BIRD
                CALL MOVE_BIRD
                MOV DOT_COLOR,WHITE
                CALL DRAW_BIRD
                ; Check IS_GAMEOVER
                CALL MARGIN_COLLISION
                CALL WALL_COLLISION
                CMP IS_GAMEOVER,0
                JZ CONTINUE_GAME
                RET  
CONTINUE_GAME:
                ; Handle changing the score
                CALL CLEAR_SCORE
                INC SCORE
                CALL PRINT_SCORE
                ; For simulation, change the IS_BIRD_FLY bit
                CALL CHECK_KEY_PRESS
                JZ KEY_NOT_PRESSED
                MOV DX,FLY_VELOCITY_BIRD
                MOV VELOCITY_BIRD,DX
KEY_NOT_PRESSED:
                JMP DR
                RET
TEST_CODE       ENDP


; This routine makes a delay by busy waiting
DELAY           PROC NEAR
                MOV CX,60000
BUSY_WAIT:
                LOOP BUSY_WAIT                
                RET
DELAY           ENDP


; This routine generates the offset of pixel in memory segment
; This routine gets 2 arguments. (ROW, COLUMN)
; Return BX as OFFSET
GET_OFFSET      PROC NEAR
                MOV AX,320
                MUL ROW
                ADD AX,COLUMN
                MOV BX,AX
                RET
GET_OFFSET      ENDP


; This routine sets the video mode to 320x200
CLEAR_SCREEN    PROC NEAR
                MOV AH,0 ; set graphic mode
                MOV AL,13H ; 320x200
                INT 10H
                RET
CLEAR_SCREEN    ENDP


; This routine gets 3 arguments. (ROW, COLUMN, DOT_COLOR)
DRAW_DOT	    PROC NEAR
                CALL GET_OFFSET
                MOV DX,DOT_COLOR
                MOV ES:[BX],DX
                RET
DRAW_DOT	    ENDP


; This routine gets 5 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END, DOT_COLOR)
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


; This routine gets 5 arguments. (ROW_START, COLUMN_START, ROW_END, COLUMN_END, DOT_COLOR)
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


; This routine gets 5 arguments. (ROW_BIRD_START, COLUMN_BIRD_START, ROW_BIRD_END, COLUMN_BIRD_END, DOT_COLOR)
DRAW_BIRD       PROC NEAR
                MOV DX,ROW_BIRD_START
                MOV AX,COLUMN_BIRD_START
                MOV ROW_START,DX
                MOV COLUMN_START,AX

                MOV DX,ROW_BIRD_END
                MOV AX,COLUMN_BIRD_END
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


; A top level routine that is called in each game loop cycle
; This routine deletes wall and shift it to the left and draw a new wall
; If the wall is out of the screen, it will be removed and a new wall will be drawn
MOVE_WALL       PROC NEAR
                MOV DX,WALL_COLUMN_START
                CMP DX,1
                JA SHIFT_AND_DRAW
                ; Delete whole wall
                MOV DOT_COLOR,BLACK
                CALL DRAW_WALL
                ; Change the wall position
                MOV BX,40
                CALL RANDOM_NUMBER ; Get a random number between 0 and 40 in DX
                MOV AX,SCREEN_WIDTH
                SUB AX,DX
                MOV WALL_COLUMN_START,AX
                MOV WALL_COLUMN_END,SCREEN_WIDTH
                RET
SHIFT_AND_DRAW:
                CALL DELETE_WALL
                DEC WALL_COLUMN_END
                DEC WALL_COLUMN_START
                MOV DOT_COLOR,GREEN
                CALL DRAW_WALL
                RET
MOVE_WALL       ENDP


; Check the keyboard buffer for a key press. If a key is pressed, ZeroFlag will set 0.
CHECK_KEY_PRESS     PROC NEAR
                    MOV AH,01H ; check keyboard buffer is empty or not
                    INT 16H
                    JZ NO_KEY_PRESSED
                    MOV AH,0 ; read key from keyboard buffer (clear buffer)
                    INT 16H
NO_KEY_PRESSED:
                    RET
CHECK_KEY_PRESS     ENDP


; This routine prints the score on the screen
PRINT_SCORE     PROC NEAR
                MOV AX,SCORE
                CALL NUMBER_TO_STRING
                LEA SI,NUMBER_STRING
                MOV CX,SCORE_LENGTH
                ; Print the characters
LOOP1:
                MOV AL,[SI]
                MOV AH,0EH
                INT 10H
                INC SI
                LOOP LOOP1
                RET
PRINT_SCORE     ENDP


; This routine converts AX number to string
; (AX as number)
NUMBER_TO_STRING    PROC NEAR
                    MOV CX,0
                    MOV BX,10
                    LEA SI,NUMBER_STRING
DIVIDE:
                    ; word/word division - DX: remainder, AX: quotient
                    MOV DX,0
                    DIV BX
                    INC CX

                    PUSH DX ; Push the remainder to stack
                    CMP AX,0
                    JNZ DIVIDE
                    MOV SCORE_LENGTH,CX
CONVERT:
                    POP DX
                    ; Print the digit
                    ADD DL,30H
                    MOV [SI],DL
                    INC SI
                    LOOP CONVERT
                    RET
NUMBER_TO_STRING    ENDP


; Clears the score characters by writing back-space character
; (SCORE_LENGTH)
CLEAR_SCORE     PROC NEAR
                MOV CX,SCORE_LENGTH
LOOP1:
                MOV AH,0EH
                MOV AL,08H
                INT 10H
                LOOP LOOP1
                RET
CLEAR_SCORE     ENDP


; (TOP_MARGIN, SCREEN_WIDTH, BOTTOM_MARGIN)
DRAW_MARGIN     PROC NEAR
                MOV DOT_COLOR,ORANGE
                MOV ROW,TOP_MARGIN
                MOV COLUMN_START,0
                MOV COLUMN_END,SCREEN_WIDTH
                CALL DRAW_HORIZONT_LINE
                MOV ROW,BOTTOM_MARGIN
                CALL DRAW_HORIZONT_LINE
                RET
DRAW_MARGIN     ENDP


; Checks weather the bird is beyond margins or not
; Return IS_GAMEOVER
MARGIN_COLLISION    PROC NEAR
                    CMP ROW_BIRD_START,TOP_MARGIN
                    JBE GAMEOVER
                    CMP ROW_BIRD_END,BOTTOM_MARGIN
                    JAE GAMEOVER
                    RET
GAMEOVER:
                    MOV IS_GAMEOVER,1
                    RET
MARGIN_COLLISION    ENDP


; Checks if any point of bird is in wall or not
WALL_COLLISION      PROC NEAR
                    ; right down corner
                    MOV DX,ROW_BIRD_END
                    MOV ROW,DX
                    MOV DX,COLUMN_BIRD_END
                    MOV COLUMN,DX
                    CALL POINT_IN_WALL
                    CMP IS_POINT_IN_WALL,1
                    JE GAMEOVER
                    ; left down corner
                    MOV DX,ROW_BIRD_END
                    MOV ROW,DX
                    MOV DX,COLUMN_BIRD_START
                    MOV COLUMN,DX
                    CALL POINT_IN_WALL
                    CMP IS_POINT_IN_WALL,1
                    JE GAMEOVER
                    ; left up corner
                    MOV DX,ROW_BIRD_START
                    MOV ROW,DX
                    MOV DX,COLUMN_BIRD_START
                    MOV COLUMN,DX
                    CALL POINT_IN_WALL
                    CMP IS_POINT_IN_WALL,1
                    JE GAMEOVER
                    ; right up corner
                    MOV DX,ROW_BIRD_START
                    MOV ROW,DX
                    MOV DX,COLUMN_BIRD_END
                    MOV COLUMN,DX
                    CALL POINT_IN_WALL
                    CMP IS_POINT_IN_WALL,1
                    JE GAMEOVER
                    RET
GAMEOVER:
                    MOV IS_GAMEOVER,1
                    RET
WALL_COLLISION      ENDP


; Checks is (ROW,COLUMN) in a wall or not. This routine will be called 4 times for each corner of the bird.
; The WALL_COLLISION routine will call this routine 4 times.
; Return IS_POINT_IN_WALL
POINT_IN_WALL       PROC NEAR
                    MOV DX,ROW
                    MOV AX,COLUMN
                    CMP DX,WALL_ROW_START
                    JB NOT_IN_WALL
                    CMP DX,WALL_ROW_END
                    JA NOT_IN_WALL
                    CMP AX,WALL_COLUMN_START
                    JB NOT_IN_WALL
                    CMP AX,WALL_COLUMN_END
                    JA NOT_IN_WALL
                    MOV IS_POINT_IN_WALL,1
                    RET
NOT_IN_WALL:
                    MOV IS_POINT_IN_WALL,0
                    RET
POINT_IN_WALL       ENDP


; Calculate the new position of the bird with Makan-Zaman equation
; new_position = old_position + (old_velocity * time) + (0.5 * acceleration * time * time)
; new_velocity = old_velocity + (acceleration * time)
; The time value is always 1 because the time unit is 1 cycle of the game loop.
; (ROW_BIRD, COLUMN_BIRD, VELOCITY_BIRD, ACCELERATION_BIRD)
MOVE_BIRD   PROC NEAR
            ; Calculate new ROW_BIRD_START
            MOV AX,ACCELERATION_BIRD
            MOV BX,2
            MOV DX,0
            DIV BX ; Result is in AX
            MOV DX,VELOCITY_BIRD
            ADD ROW_BIRD_START,DX
            ADD ROW_BIRD_START,AX
            ; Calculate new ROW_BIRD_END
            ADD ROW_BIRD_END,DX
            ADD ROW_BIRD_END,AX
            ; Calculate new VELOCITY_BIRD
            ADD DX,ACCELERATION_BIRD
            MOV VELOCITY_BIRD,DX
            RET
MOVE_BIRD   ENDP


; Gets 1 argument (BX as maximum number)
; Return a random number between 0 and BX in DX
RANDOM_NUMBER   PROC NEAR
                MOV AX,0 ; Get clock ticks
                INT 1AH
                ; Byte/Byte division - DX: remainder, AX: quotient
                MOV AX,DX
                MOV DX,0
                DIV BX
                RET
RANDOM_NUMBER   ENDP

END MAIN