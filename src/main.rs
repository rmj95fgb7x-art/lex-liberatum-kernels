#![no_std]
#![no_main]

mod vga;
use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    vga::clear();
    vga::print_str("lex-kernel v0.1.0\n");
    vga::print_str("Multiboot2 entry OK\n");
    vga::print_str("VGA driver online\n");
    vga::print_str("Lines 1-3 printed; now scrolling…\n");
    // force a scroll
    for i in 0..22 {
        vga::print_str("Line ");
        let digit: [u8; 1] = [b'0' + i as u8];
        vga::print_str(core::str::from_utf8(&digit).unwrap());
        vga::print_str("\n");
    }
    vga::print_str("Halted.\n");
    loop { unsafe { core::arch::asm!("hlt") } }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}








