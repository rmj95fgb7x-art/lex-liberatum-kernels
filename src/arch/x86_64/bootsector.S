.code16
.section .bootsect, "ax"
.global _start16
_start16:
    cli
    cld
    xor     %ax, %ax
    mov     %ax, %ds
    mov     %ax, %es
    mov     %ax, %fs
    mov     %ax, %gs

    // enable A20 gate (fast method)
    in      $0x92, %al
    or      $2, %al
    out     %al, $0x92

    // switch to 32-bit protected mode
    lgdt    gdtdesc
    mov     %cr0, %eax
    or      $1, %eax
    mov     %eax, %cr0
    ljmp    $0x08, $protected_mode

.code32
protected_mode:
    mov     $0x10, %ax
    mov     %ax, %ds
    mov     %ax, %es
    mov     %ax, %fs
    mov     %ax, %gs
    mov     %ax, %ss
    mov     $0x120000, %esp   // temp stack above 1 MiB

    // jump to Rust _start at 1 MiB
    mov     $0x100000, %eax
    jmp     %eax

// GDT
gdt:
    .quad 0x0000000000000000   // null
    .quad 0x00CF9A000000FFFF   // code 32-bit
    .quad 0x00CF92000000FFFF   // data 32-bit
gdtdesc:
    .word gdtend - gdt - 1
    .long gdt
gdtend:

// boot signature
.org 510
.word 0xAA55
