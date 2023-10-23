
.include "../../utils/macro_defs.s"

.equ MAXCHARLINE, 100
.equ MAXMAPCHAR, 10000
.equ playerChar, '@'

//! LOCAL REDUNDANT DEFINITIONS, NOT REUSABLE!
.equ solidRock, 32 
.equ horizontalBoundary, 45
.equ verticalBoundary, 124
.equ cornerBoundary, 43 
.equ passageSpot, 35 
.equ roomSpot, 46 

// typedef struct player player_t
//! Follows offsets chosen by compiler!
.equ p_isActive,        0
.equ p_name,            8
.equ p_playerNumber,    16
.equ p_pos,             20
.equ p_nuggets,         24
.equ p_originalMap,     32
.equ p_currGrid,        40
.equ p_size,            (40 + MAXMAPCHAR)

.text
// player_t *
// player_new(const char *name, int playerNumber, int pos, grid_t *spectatorGrid, grid_t *originalMap)
.globl _player_new
.p2align 2 
_player_new:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    stp x24, x25, [sp, #-16]!
    str x26, [sp, #-16]!

    mov x20, x0                 // x20 = name 
    mov w21, w1                 // w21 = playerNumber 
    mov w22, w2                 // w22 = pos 
    mov x23, x3                 // x23 = spectatorGrid 
    mov x24, x4                 // x24 = originalMap 

    // Parameter validation 
    mov x0, xzr 
    cbz x20, player_new_end
    cbz x23, player_new_end
    cbz x24, player_new_end
    tbnz w21, #31, player_new_end
    mov x0, x23 
    mov w1, w22 
    bl _getX 
    tbnz w0, #31, player_new_end

    mov w0, #p_size 
    MWRP _malloc, mdbg0, mdbg1  // NOT checking for NULL malloc returns 
    mov x25, x0                 // x25 = playerp 
    mov x0, x20 
    bl _strlen 
    add w0, w0, #1
    mov w26, w0                 // w26 = name_length
    MWRP _malloc, mdbg0, mdbg1
    str x0, [x25, #p_name]
    mov x1, x20 
    mov w2, w26 
    bl _strncpy

    mov w1, #1
    str w1, [x25, #p_isActive]
    str w21, [x25, #p_playerNumber]
    str w22, [x25, #p_pos]
    str wzr, [x25, #p_nuggets]

    mov x0, x23 
    mov w1, w22 
    bl _getX 
    mov w21, w0                 // w21 = getX(spectatorGrid, pos)
    mov x0, x23 
    mov w1, w22
    bl _getY 
    mov w3, w0                  // w3 = getY(spectatorGrid, pos)
    mov w2, w21 
    add x1, x25, #p_currGrid    // x1 = &(playerp->currGrid)
    mov x0, x23 
    bl _getVisibleGrid
    str x24, [x25, #p_originalMap]
    mov x0, x25 

player_new_end:
    ldr x26, [sp], #16
    ldp x24, x25, [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _player_updateGrid
.p2align 2
_player_updateGrid: 
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    
    mov x20, x0                     // x20 = spectGrid 
    mov x22, x2                     // x22 = player 
    cbz x20, player_updateGrid_end
    cbz x22, player_updateGrid_end
    ldr w1, [x22, #p_isActive]
    tbz w1, #0, player_updateGrid_end

    // Set up register for comparisons 
    mov x1, #1
    bfi x19, x1, #solidRock, #1
    bfi x19, x1, #horizontalBoundary, #1
    bfi x19, x1, #cornerBoundary, #1
    bfi x19, x1, #roomSpot, #1
    bfi x19, x1, #passageSpot, #1
    // Prepare loop iteration
    mov x0, x20 
    bl _get_TC 
    mov w23, w0                     // w23 = get_TC(spectatorGrid)
    mov w24, wzr                    // w24 = i
    ldr x25, [x22, #p_originalMap]  // x25 = player->originalMap
    ldr w26, [x22, #p_pos]          // w26 = player->pos 
    add x27, x22, #p_currGrid       // x27 = &(player->currGrid)
    sub sp, sp, #16                 // make space for xyxy 
loop1:
    cmp w24, w23 
    bge loop1_end 
    mov x0, x20 
    mov w1, w24 
    bl _get_gridPoint
    mov w21, w0                     // w21 = currSpectatorChar
    mov x0, x25 
    mov w1, w24 
    bl _get_gridPoint
    mov w28, w0                     // w28 = originalChar

    mov w3, #playerChar             // w3 = playerChar
    cmp w24, w26 
    beq if1
    ldrb w4, [x27, w24, sxtw]
    cmp w4, w3 
    beq elseif1
    mov x0, x20 
    mov w1, w26 
    bl _getX 
    str w0, [sp]                // getX(spectatorGrid, player->pos)
    mov x0, x20 
    mov w1, w26 
    bl _getY 
    str w0, [sp, #4]            // getX(spectatorGrid, player->pos)
    mov x0, x20 
    mov w1, w24 
    bl _getX                    // getX(spectatorGrid, i)
    str w0, [sp, #8]
    mov x0, x20 
    mov w1, w24 
    bl _getY
    str w0, [sp, #12]
    mov x0, x20 
    ldr w1, [sp] 
    ldr w2, [sp, #4]
    ldr w3, [sp, #8]
    ldr w4, [sp, #12]
    bl _isVisible
    tbnz w0, #0, elseif1
    mov w1, #124 
    ldrb w4, [x27, w24, sxtw]
    cmp w1, w4 
    beq endif1
    mov x2, #1
    lsl x2, x2, x4 
    and x3, x2, x19 
    cbnz x3, endif1
    strb w28, [x27, w24, sxtw]
    b endif1
if1:
    strb w3, [x27, w24, sxtw]
    b endif1 
elseif1:
    strb w21, [x27, w24, sxtw]
    b endif1 
endif1:
    add w24, w24, #1                // i++ 
    b loop1 
loop1_end:
    add sp, sp, #16                 // pop xyxy
player_updateGrid_end:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret 


