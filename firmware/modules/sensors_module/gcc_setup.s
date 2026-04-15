    .text
    .align 4
    .syntax unified

    .global _gcc_setup
    .thumb_func
_gcc_setup:

    STMDB   sp!, {r3, r4, r5, r6, r7, lr}

    ldr     r3, =__FLASH_segment_start__
    ldr     r4, =__RAM_segment_start__
    mov     r5,r0

    ldr     r0, =__got_load_start__
    sub     r0,r0,r3
    add     r0,r0,r5
    ldr     r1, =__new_got_start__
    sub     r1,r1, r4
    add     r1,r1,r9
    ldr     r2, =__new_got_end__
    sub     r2,r2,r4
    add     r2,r2,r9

new_got_setup:
    cmp     r1, r2
    beq     got_setup_done
    ldr     r6, [r0]
    cmp     r6, #0
    beq     address_built
    cmp     r6, r4
    blt     flash_area
    sub     r6, r6, r4
    add     r6, r6, r9
    b       address_built
flash_area:
    sub     r6, r6, r3
    add     r6, r6, r5
address_built:
    str     r6, [r1]
    add     r0, r0, #4
    add     r1, r1, #4
    b       new_got_setup
got_setup_done:

    ldr     r0, =__data_load_start__
    sub     r0,r0,r3
    add     r0,r0,r5
    ldr     r1, =__data_start__
    sub     r1,r1, r4
    add     r1,r1,r9
    ldr     r2, =__data_end__
    sub     r2,r2,r4
    add     r2,r2,r9
    bl      crt0_memory_copy

    ldr     r0, =__bss_start__
    sub     r0,r0,r4
    add     r0,r0,r9
    ldr     r1, =__bss_end__
    sub     r1,r1,r4
    add     r1,r1,r9
    mov     r2, #0
    bl      crt0_memory_set

    ldr     r0, =__heap_start__
    sub     r0,r0,r4
    add     r0,r0,r9
    ldr     r1, =__heap_end__
    sub     r1,r1,r4
    add     r1,r1,r9
    sub     r1,r1,r0
    mov     r2, #0
    str     r2, [r0]
    add     r0, r0, #4
    str     r1, [r0]

    LDMIA   sp!, {r3, r4, r5, r6, r7, lr}
    bx      lr

    .align 4

    .thumb_func
crt0_memory_copy:
    cmp     r0, r1
    beq     memory_copy_done
    cmp     r2, r1
    beq     memory_copy_done
    sub     r2, r2, r1
memory_copy_loop:
    ldrb    r3, [r0]
    add     r0, r0, #1
    strb    r3, [r1]
    add     r1, r1, #1
    sub     r2, r2, #1
    cmp     r2, #0
    bne     memory_copy_loop
memory_copy_done:
    bx      lr

    .thumb_func
crt0_memory_set:
    cmp     r0, r1
    beq     memory_set_done
    strb    r2, [r0]
    add     r0, r0, #1
    b       crt0_memory_set
memory_set_done:
    bx      lr

    .section .heap, "wa", %nobits