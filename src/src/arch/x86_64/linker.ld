ENTRY(_start)

SECTIONS {
    . = 1M;    /* Multiboot2 header must live in first 32 KiB */
    .multiboot2_header : ALIGN(8) {
        KEEP(*(.multiboot2_header))
    }


    .text : ALIGN(4K) {
        *(.text .text.*)
    }

    .rodata : ALIGN(4K) {
        *(.rodata .rodata.*)
    }

    .data : ALIGN(4K) {
        *(.data .data.*)
    }

    .bss : ALIGN(4K) {
        *(.bss .bss.*)
        *(COMMON)
    }
}
