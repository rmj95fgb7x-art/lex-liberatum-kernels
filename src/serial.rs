const COM1: u16 = 0x3F8;

pub fn init() {
    unsafe {
        // divisor latch access bit
        outb(COM1 + 3, 0x80);
        // divisor = 1 → 115 200 baud
        outb(COM1 + 0, 0x01);
        outb(COM1 + 1, 0x00);
        // 8 data bits, 1 stop bit, no parity
        outb(COM1 + 3, 0x03);
        // enable FIFO
        outb(COM1 + 2, 0xC7);
        // IRQs disabled, RTS/DSR set
        outb(COM1 + 4, 0x0B);
    }
}

pub fn putc(c: u8) {
    unsafe {
        // wait for transmit hold register empty
        while (inb(COM1 + 5) & 0x20) == 0 {}
        outb(COM1, c);
    }
}

pub fn puts(s: &str) {
    for b in s.bytes() {
        putc(b);
    }
}

unsafe fn outb(port: u16, val: u8) {
    core::arch::asm!("out dx, al", in("dx") port, in("al") val, options(nostack));
}

unsafe fn inb(port: u16) -> u8 {
    let ret: u8;
    core::arch::asm!("in al, dx", out("al") ret, in("dx") port, options(nostack));
    ret
}
