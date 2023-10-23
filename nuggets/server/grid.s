
.include "../../utils/macro_defs.s"
.include "../../integer_math/division_algorithms.s"

// .equ GRID_TEST, 1

.data 
solidRock:          .byte   ' '
horizontalBoundary: .byte   '-'
verticalBoundary:   .byte   '|'
cornerBoundary:     .byte   '+'
passageSpot:        .byte   '#'

gvg_err:    .asciz  "(%d, %d) position not allowed; %c\n"
map_str:    .asciz  "../maps/blobby.txt"
r_str:      .asciz  "r"

// maximum characters in map
.equ MAXMAPCHAR, 10000

// typedef struct grid grid_t
.equ g_NR, 0
.equ g_NC, 4
.equ g_TC, 8
.equ g_map, 12
.equ g_size, (12 + MAXMAPCHAR)

.text 
.globl _grid_new 
.p2align 2
_grid_new:  // grid_t * grid_new(FILE * mapFp)
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    stp x22, x23, [sp, #-16]!
    str x24,      [sp, #-16]!

    cbz x0, grid_new_end        // if (mapFp == NULL) return NULL
    mov x20, x0                 // x20 = mapFp
    mov x0, #g_size 
    MWRP _malloc, mdbg0, mdbg1  // grid_t * grid = malloc(sizeof(grid_t));
    cbnz x0, endif1             // if (grid == NULL) return NULL 
    mov x0, xzr 
    b grid_new_end
endif1:
    mov x21, x0                 // x21 = grid 
    mov w22, wzr                // w22 = NR 
    mov w23, wzr                // w23 = NC
    mov w24, wzr                // w24 = TC
loop1: // while ((c = getc(mapFp)) != EOF)
    mov x0, x20 
    bl _getc 
    cmp w0, #-1                 // if (c = getc(mapFp) == -1), goto loop1_end
    beq loop1_end
if2:    // if (c != '\n' && (grid->NC == grid->TC))
    cmp w0, '\n'                // if (c == '\n') goto elseif2
    beq elseif2                 
    cmp w23, w24                // if (NC == TC) NC++
    cinc w23, w23, eq 
    b endif2
elseif2:// if (c == '\n')       
    add w22, w22, #1            // NR++
endif2:
    add x1, x21, #g_map         // x1 = &(grid->map)
    strb w0, [x1, w24, sxtw]    // (grid->map)[TC] = c
    add w24, w24, #1            // TC++
    b loop1
loop1_end:
    add x1, x21, #g_map         // x1 = &(grid->map)
    strb wzr, [x1, w24, sxtw]   // (grid->map)[TC] = '\0'
    str w22, [x21, #g_NR]       // grid->NR = NR
    str w23, [x21, #g_NC]       // grid->NC = NC
    str w24, [x21, #g_TC]       // grid->TC = TC
    mov x0, x21                 // return grid 

grid_new_end:
    ldr x24,      [sp], #16
    ldp x22, x23, [sp], #16
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _isVisible
// Define offsets & macro to store each game charater in single 64-bit register
.equ sr, 0
.equ hb, 8
.equ vb, 16
.equ cb, 24
.equ ps, 32
.macro STORE_GAME_CH reg, sreg, swreg, ch, choff
    LOAD_ADDR \sreg, \ch
    ldrb \swreg, [\sreg]
    bfi \reg, \sreg, #\choff, #8
.endm
.macro STORE_GAME_CHARS reg, sreg, swreg
    STORE_GAME_CH \reg, \sreg, \swreg, solidRock, sr
    STORE_GAME_CH \reg, \sreg, \swreg, horizontalBoundary, hb
    STORE_GAME_CH \reg, \sreg, \swreg, verticalBoundary, vb
    STORE_GAME_CH \reg, \sreg, \swreg, cornerBoundary, cb 
    STORE_GAME_CH \reg, \sreg, \swreg, passageSpot, ps
.endm
// Macro to compute tile character 
.macro TILE_CHAR dreg, arg1, arg2, arg3
    mov x0, \arg1
    mov w1, \arg2              
    mov w2, \arg3 
    bl _getPos
    add x1, \arg1, #g_map         // x1 = &(grid->map)
    ldrb \dreg, [x1, w0, sxtw]    // dreg = tile
.endm 
// Macro to extract game characters in x1, x2, x3, x4, x5 
.macro EXTRACT_GAME_CHARS reg 
    ubfx x1, \reg, #sr, #8   // x1 = solidRock 
    ubfx x2, \reg, #hb, #8   // x2 = horizontalBoundary
    ubfx x3, \reg, #vb, #8   // x3 = verticalBoundary 
    ubfx x4, \reg, #cb, #8   // x4 = cornerBoudnary
    ubfx x5, \reg, #ps, #8   // x5 = passageSpot
.endm
// Macro to compare extracted game characters with tile
.macro COMP_TILE treg, lab
    cmp \treg, x1 
    beq \lab 
    cmp \treg, x2 
    beq \lab 
    cmp \treg, x3 
    beq \lab 
    cmp \treg, x4 
    beq \lab 
    cmp \treg, x5 
    beq \lab 
.endm
.p2align 2
_isVisible:   // bool isVisible(grid_t *grid, int px, int py, int ox, int oy)
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    stp s8, s9,   [sp, #-16]!

    cbz x0, if3 
    tbnz w1, #31, if3
    tbnz w2, #31, if3
    tbnz w3, #31, if3
    tbnz w4, #31, if3
    ldr w5, [x0, #g_NC]     // w5 = grid->NC
    cmp w1, w5 
    bgt if3 
    cmp w3, w5 
    bgt if3 
    ldr w5, [x0, #g_NR]     // w5 = grid->NR 
    cmp w2, w5 
    bge if3 
    cmp w4, w5 
    bge if3 
    b endif3
if3:
    mov w0, wzr             // return false
    b isVisible_end
endif3:
    mov x20, x0             // x20 = grid 
    mov w21, w1             // w21 = px 
    mov w22, w2             // w22 = py 
    
    subs w6, w3, w1         // w6 = ox - px              
    csel w23, w1, w3, ge    // w23 = xmin 
    csel w24, w3, w1, ge    // w24 = xmax 
    subs w5, w4, w2         // w5 = oy - py 
    csel w25, w2, w4, ge    // w25 = ymin 
    csel w26, w4, w2, ge    // w26 = ymax 
    scvtf s5, w5            // s5 = (float)(oy - py)
    scvtf s6, w6            // s6 = (float)(ox - px)
    fdiv s8, s5, s6         // s8 = m 

    // Store game characters in x27, using x7 as scratch 
    STORE_GAME_CHARS x27, x7, w7
    add w23, w23, #1        // w23 = x
loop2:  // for (int x = xmin + 1; x < xmax; x++)
    cmp w23, w24 
    bge loop2_end 
    sub w1, w23, w21        // w1 = x - px 
    scvtf s1, w1            // s1 = (float)(x - px)
    scvtf s2, w22           // s2 = (float)py
    fmadd s9, s8, s1, s2    // s9 = y 

    fcvtms w2, s9                   // w2 = floor(y)
    TILE_CHAR w19, x20, w23, w2     // x19 = prevTile 
    fcvtps w2, s9                   // w2 = ceil(y)
    TILE_CHAR w28, x20, w23, w2     // x28 = nextTile
    EXTRACT_GAME_CHARS x27  // extract game characters from x27 
    COMP_TILE x19, if4_2
    b loop2_pre_end
if4_2:
    COMP_TILE x28, if4 
    b loop2_pre_end
if4:    // return false
    mov w0, wzr             // return false
    b isVisible_end
loop2_pre_end:
    add w23, w23, #1        // x++
    b loop2
loop2_end:

    add w25, w25, #1        // w25 = y  
loop3:  // for (int y = ymin + 1; y < ymax; y++)
    cmp w25, w26 
    bge loop3_end
    sub w1, w25, w22        // w1 = y - py 
    scvtf s1, w1            // s1 = (float)(y - py)
    scvtf s2, w21           // s2 = (float) px
    fdiv s1, s1, s8         // s1 = (float)(y - py) / m
    fadd s9, s1, s2         // s9 = x

    fcvtms w1, s9                // w1 = floor(x)
    TILE_CHAR w19, x20, w1, w25 // x19 = prevTile
    fcvtps w1, s9               // w1 = ceil(x)
    TILE_CHAR w28, x20, w1, w25 // x28 = nextTile
    EXTRACT_GAME_CHARS x27 
    COMP_TILE x19, if5_2 
    b loop3_pre_end
if5_2:
    COMP_TILE x28, if5 
    b loop3_pre_end
if5:
    mov w0, wzr             // return false
    b isVisible_end
loop3_pre_end:
    add w25, w25, #1        // y++
    b loop3
loop3_end:

    mov w0, #1              // return true 
isVisible_end:
    ldp s8, s9,   [sp], #16
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret



.globl _getVisibleGrid
.macro CMP_N_BRANCH ch, lab
    LOAD_ADDR x1, \ch
    ldrb w1, [x1]
    cmp w1, w0 
    beq \lab
.endm
.p2align 2
_getVisibleGrid: // void getVisibleGrid(grid_t *grid, char pmap[], int px, int py)
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!

    cbz x0, getVisibleGrid_end
    tbnz w2, #31, getVisibleGrid_end
    tbnz w3, #31, getVisibleGrid_end
    ldr w4, [x0, #g_NC]
    cmp w2, w4 
    bgt getVisibleGrid_end
    ldr w4, [x0, #g_NR]
    cmp w3, w4 
    bge getVisibleGrid_end

    mov x20, x0                         // x20 = grid 
    mov x21, x1                         // x21 = pmap[]
    mov w22, w2                         // w22 = px 
    mov w23, w3                         // w23 = py
    TILE_CHAR w0, x20, w22, w23 
    CMP_N_BRANCH horizontalBoundary, if6 
    CMP_N_BRANCH verticalBoundary, if6 
    CMP_N_BRANCH cornerBoundary, if6 
    CMP_N_BRANCH solidRock, if6 
    cmp w0, '\n'
    beq if6 
    b endif6
if6:
    stp x22, x23, [sp, #-32]!
    str x0,       [sp, #16]
    LOAD_CONT_GOT x0, ___stderrp
    ldr x0, [x0]
    LOAD_ADDR x1, gvg_err           // fprintf(stderr, "(%d, %d) position not allowed; %c\n", px, py, p);
    bl _fprintf
    add sp, sp, #32 
    b getVisibleGrid_end           
endif6:
    mov w24, wzr                    // w24 = i
    ldr w25, [x20, #g_TC]           // w25 = grid->TC
loop4:  // for (int i = 0; i < grid->TC; i++)
    cmp w24, w25 
    bge loop4_end
    mov x0, x20 
    mov w1, w24 
    bl _getX 
    mov w26, w0     // w26 = x
    mov x0, x20 
    mov w1, w24 
    bl _getY 
    mov w27, w0     // w27 = y 

    cmp w26, w22                // nzcv = (eq ? nzcv(w27 - w23) : 0)
    ccmp w27, w23, #0b0000, eq  
    beq if7 
    add x0, x20, #g_map         // x0 = &(grid->map)
    ldrb w28, [x0, w24, sxtw]   // w28 = (grid->map)[i]
    cmp w28, '\n'
    beq elseif7_1
    mov x0, x20 
    mov w1, w22 
    mov w2, w23 
    mov w3, w26 
    mov w4, w27 
    bl _isVisible
    tbnz w0, #0, elseif7_1
    b else7 
if7:    // if (x == px && y == py)
    mov w0, '@'
    strb w0, [x21, w24, sxtw]   // pmap[i] = '@'
    b endif7 
elseif7_1:  // else if ((grid->map)[i] == '\n' || isVisible(grid, px, py, x, y))
    strb w28, [x21, w24, sxtw]   // pmap[i] = (grid->map)[i]
    b endif7
else7:
    LOAD_ADDR x0, solidRock
    ldrb w0, [x0]
    strb w0, [x21, w24, sxtw]   // pmap[i] = solidRock
endif7:
    add w24, w24, #1                // i++
    b loop4
loop4_end:
    strb wzr, [x21, w25, sxtw]  // pmap[grid->TC] = '\0'

getVisibleGrid_end:
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.globl _getX
.macro GETXY_ARG_CHECK l, r
    mov x2, x0              // x2 = grid 
    mov w0, #\r             // w0 = r
    cbz x2, \l 
    tbnz w1, #31, \l
    ldr w3, [x2, #g_TC]     // w3 = grid->TC 
    cmp w3, w1 
    bls \l
.endm
.p2align 2 
_getX:  // int getX(grid_t *grid, int pos)
    stp x29, x30, [sp, #-16]!
    GETXY_ARG_CHECK getX_end, -1

    sxtw x0, w1             // x0 = pos 
    ldrsw x1, [x2, #g_NC]   // x1 = grid->NC 
    add x1, x1, #1          // x1 = grid->NC  + 1
    bl _mudiv64 
    mov x0, x1              //! We assume the remainder actually fits in a 32-bit register!

getX_end:
    ldp x29, x30, [sp], #16
    ret 

.globl _getY
.p2align 2
_getY: // int getY(grid_t *grid, int pos)
    stp x29, x30, [sp, #-16]!
    GETXY_ARG_CHECK getY_end, -1

    stp x2, x1, [sp, #-16]!     // save grid and pos on stack 
    mov x0, x2 
    bl _getX
    ldp x2, x1, [sp], #16       // reload grid and pos from stack 
    sub w0, w1, w0              // w0 = pos - getX(grid, pos)
    ldr w1, [x2, #g_NC]         // w1 = grid->NC 
    add w1, w1, #1 
    udiv w0, w0, w1 

getY_end:
    ldp x29, x30, [sp], #16
    ret 

.globl _getPos 
.p2align 2 
_getPos:
    mov x4, x0                  // x4 = grid
    mov w0, #-1 
    cbz x4, getPos_end 
    tbnz w1, #31, getPos_end
    tbnz w2, #31, getPos_end 
    ldr w3, [x4, #g_NC]         // w3 = grid->NC 
    cmp w1, w3 
    bhi getPos_end
    ldr w5, [x4, #g_NR]
    cmp w2, w5
    bhs getPos_end 

    add w3, w3, #1 
    madd w0, w2, w3, w1         // w0 = y * (grid->NC + 1) + x
getPos_end:
    ret

.globl _get_gridPoint 
.p2align 2 
_get_gridPoint:
    GETXY_ARG_CHECK get_gridPoint_end, 0
    add x1, x1, #g_map  // since w1 is unsigned, no sign extension needed 
    ldr w0, [x1]
get_gridPoint_end:
    ret 

.globl _grid_delete
.p2align 2
_grid_delete:
    stp x29, x30, [sp, #-16]!
    cbz x0, grid_delete_end
    MWRP _free, fdbg0, fdbg1
grid_delete_end:
    ldp x29, x30, [sp], #16
    ret 

.globl _get_TC 
.p2align 2
_get_TC:
    mov x2, x0 
    mov w0, #-1 
    cbz x2, get_TC_end 
    ldr x0, [x2, #g_TC]
get_TC_end:
    ret

.globl _set_gridPoint
.p2align 2 
_set_gridPoint:
    mov w4, w3 
    GETXY_ARG_CHECK set_gridPoint_end, 0
    add x1, x1, #g_map  // since w1 is unsigned, no sign extension needed 
    str w4, [x1]        // (grid->map)[pos] = c
    mov w1, #1          // return true
set_gridPoint_end:
    ret 

.globl _get_map
.p2align 2
_get_map:
    cbz x0, get_map_end
    ldr x0, [x0, #g_map]
get_map_end:
    ret 


.ifdef GRID_TEST
.globl _main 
.p2align 2 
_main:
    stp x29, x30, [sp, #-16]!
    stp x20, x21, [sp, #-16]!
    LOAD_ADDR x0, map_str
    LOAD_ADDR x1, r_str 
    bl _fopen 
    mov x20, x0                 // x20 = mapFp 
    bl _grid_new
    mov x21, x0                 // x21 = grid 
    mov x6, #((16 * MAXMAPCHAR) / 16)
    sub sp, sp, x6
    mov x1, sp 
    mov w2, #45 
    mov w3, #12
    bl _getVisibleGrid
//! This would load grid->map[0], but we need simply the pointer grid->map!
    ldr x0, [x21, #g_map]
//!
    add x0, x21, #g_map
    bl _puts 
    mov x0, sp 
    bl _puts 
    mov x6, #((16 * MAXMAPCHAR) / 16)
    add sp, sp, x6
    mov x0, x21 
    bl _grid_delete
    mov x0, x20 
    bl _fclose
    mov w0, wzr 
main_end:
    ldp x20, x21, [sp], #16
    ldp x29, x30, [sp], #16
    ret
.endif // GRID_TEST

