.section .multiboot2_header, "a"
.align 8
multiboot2_header:
    .long 0xE85250D6                /* magic */
    .long 0                         /* architecture: i386 */
    .long multiboot2_end - multiboot2_header /* header length */
    .long 0x100000000 - (0xE85250D6 + 0 + (multiboot2_end - multiboot2_header)) /* checksum */
    /* end tag */
    .word 0
    .word 0
    .long 8
multiboot2_end:
