#![no_std]
#![no_main]

mod vga;
mod serial;
use core::panic::PanicInfo;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    serial::init();
    vga::clear();
    let lines = [
        "lex-kernel v0.1.0\n",
        "Multiboot2 entry OK\n",
        "Serial 8250 UART online\n",
        "VGA driver online\n",
        "Now echoing to both VGA + serial …\n",
        "Halted.\n",
    ];
    for &line in &lines {
        vga::print_str(line);
        serial::puts(line);   // also echo to host
    }
    loop { unsafe { core::arch::asm!("hlt") } }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
