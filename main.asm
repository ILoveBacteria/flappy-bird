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

; ROW_START, COLUMN_START, ROW_END, COLUMN_END
WALL                DW 130,300,BOTTOM_MARGIN-1,300+20,150,420,BOTTOM_MARGIN-1,420+20,170,540,BOTTOM_MARGIN-1,540+20
WALL_INDEX          DB 0

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
                ; Moving and draw wall
                MOV AL,0
LOOP_WALL1:
                PUSH AX
                CALL MOVE_WALL
                POP AX
                INC AL
                CMP AL,3
                JB LOOP_WALL1
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


; This routine initializes the SI register to point to the WALL array element
; Gets argument (AL as WALL_INDEX)
INIT_WALL_INDEX PROC NEAR
                LEA SI,WALL
                ; OFFSET = 4 * 2 * WALL_INDEX
                MOV AH,8
                MUL AH ; AX = 8 * WALL_INDEX
                ADD SI,AX
                RET
INIT_WALL_INDEX ENDP


; (DOT_COLOR, SI as WALL_INDEX)
DRAW_WALL       PROC NEAR
                ; Read array elements
                MOV DX,[SI]
                MOV ROW_START,DX
                MOV DX,[SI]+2
                MOV COLUMN_START,DX
                MOV DX,[SI]+4
                MOV ROW_END,DX
                MOV DX,[SI]+6
                MOV COLUMN_END,DX
                CALL DRAW_SQUARE_OUTLINE
                RET
DRAW_WALL       ENDP


; (WALL, SI as WALL_INDEX)
; This routine does not clear the whole wall. Just deletes the left and right lines of wall to make it ready for moving.
; Has more perfoemance than clearing whole wall and then draw a new shifted wall
DELETE_WALL     PROC NEAR
                ;Remove the left line
                MOV DX,[SI]
                MOV ROW_START,DX
                MOV DX,[SI]+2
                MOV COLUMN,DX
                MOV DX,[SI]+4
                MOV ROW_END,DX
                MOV DOT_COLOR,BLACK
                CALL DRAW_VERTICAL_LINE
                ;Remove the left line
                MOV DX,[SI]+6
                MOV COLUMN,DX
                CALL DRAW_VERTICAL_LINE
                RET
DELETE_WALL     ENDP


; A top level routine that is called in each game loop cycle
; This routine deletes wall and shift it to the left and draw a new wall
; If the wall is out of the screen, it will be removed and a new wall will be generated
; Gets (AL as WALL_INDEX)
MOVE_WALL       PROC NEAR
                CALL INIT_WALL_INDEX
                ; Check the wall reached to the left margin or not
                MOV DX,[SI]+2
                CMP DX,1
                JA SHIFT_AND_DRAW
                ; Delete whole wall
                MOV DOT_COLOR,BLACK
                CALL DRAW_WALL
                ; Change the wall position
                ; Find the last wall column in WALL array
                MOV AL,WALL_INDEX
                ADD AL,2 ; go to the last wall
                INC WALL_INDEX
                ; Get the remainder of AL/3. because we have 3 walls
                MOV AH,0
                MOV BL,3
                DIV BL ; remainder in AH
                MOV DI,SI ; copy the current wall index to DI
                MOV AL,AH ; copy wall index to AL
                CALL INIT_WALL_INDEX ; now SI points to the last wall
                ; Generate a random number for width of wall
                MOV BX,5
                CALL RANDOM_NUMBER ; Get a random number between 0 and 4 in DX
                MOV AL,10
                MUL DL ; result in AX
                ; set new columns value
                MOV DX,[SI]+6 ; get the last wall column_end
                ADD DX,100
                MOV [DI]+2,DX ; set the new column_start
                ADD DX,AX
                MOV [DI]+6,DX ; set the new column_end
                ; Generate a random number for height of wall
                MOV BX,10
                CALL RANDOM_NUMBER ; Get a random number between 0 and 9 in DX
                INC DX ; DX is between 1 and 10
                MOV AL,10
                MUL DL ; result in AX
                MOV SI,AX ; Copy the height to SI
                ; Generate a random number for position of wall (down margin or up margin)
                MOV BX,2
                CALL RANDOM_NUMBER ; Get a random number between 0 and 1 in DX
                CMP DX,0
                JNZ WALL_UP

                MOV DX,BOTTOM_MARGIN-1
                MOV [DI]+4,DX
                SUB DX,SI
                MOV [DI],DX ; set the new row_start
                RET
WALL_UP:
                MOV DX,TOP_MARGIN+1
                MOV [DI],DX
                ADD DX,SI
                MOV [DI]+4,DX
                RET
SHIFT_AND_DRAW:
                ; Check the wall is in the screen or not
                MOV DX,[SI]+6
                CMP DX,SCREEN_WIDTH
                JAE JUST_MOVE_IT
                CALL DELETE_WALL
                ; Shift the wall to the left
                MOV DX,[SI]+2
                DEC DX
                MOV [SI]+2,DX
                MOV DX,[SI]+6
                DEC DX
                MOV [SI]+6,DX
                MOV DOT_COLOR,GREEN
                CALL DRAW_WALL
                RET
JUST_MOVE_IT:
                MOV DX,[SI]+2
                DEC DX
                MOV [SI]+2,DX
                MOV DX,[SI]+6
                DEC DX
                MOV [SI]+6,DX
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
                    MOV AL,0
WALL_LOOP:
                    ; right down corner
                    MOV DX,ROW_BIRD_END
                    MOV ROW,DX
                    MOV DX,COLUMN_BIRD_END
                    MOV COLUMN,DX
                    PUSH AX
                    CALL POINT_IN_WALL
                    POP AX
                    CMP IS_POINT_IN_WALL,1
                    JE GAMEOVER
                    ; left down corner
                    MOV DX,ROW_BIRD_END
                    MOV ROW,DX
                    MOV DX,COLUMN_BIRD_START
                    MOV COLUMN,DX
                    PUSH AX
                    CALL POINT_IN_WALL
                    POP AX
                    CMP IS_POINT_IN_WALL,1
                    JE GAMEOVER
                    ; left up corner
                    MOV DX,ROW_BIRD_START
                    MOV ROW,DX
                    MOV DX,COLUMN_BIRD_START
                    MOV COLUMN,DX
                    PUSH AX
                    CALL POINT_IN_WALL
                    POP AX
                    CMP IS_POINT_IN_WALL,1
                    JE GAMEOVER
                    ; right up corner
                    MOV DX,ROW_BIRD_START
                    MOV ROW,DX
                    MOV DX,COLUMN_BIRD_END
                    MOV COLUMN,DX
                    PUSH AX
                    CALL POINT_IN_WALL
                    POP AX
                    CMP IS_POINT_IN_WALL,1
                    JE GAMEOVER
                    ; Next wall
                    INC AL
                    CMP AL,3
                    JB WALL_LOOP
                    RET
GAMEOVER:
                    MOV IS_GAMEOVER,1
                    RET
WALL_COLLISION      ENDP


; Gets (AL as WALL_INDEX)
; Checks is (ROW,COLUMN) in a wall or not. This routine will be called 4 times for each corner of the bird.
; The WALL_COLLISION routine will call this routine 4 times.
; Return IS_POINT_IN_WALL
POINT_IN_WALL       PROC NEAR
                    CALL INIT_WALL_INDEX
                    MOV DX,ROW
                    MOV AX,COLUMN
                    CMP DX,[SI]
                    JB NOT_IN_WALL
                    CMP DX,[SI]+4
                    JA NOT_IN_WALL
                    CMP AX,[SI]+2
                    JB NOT_IN_WALL
                    CMP AX,[SI]+6
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