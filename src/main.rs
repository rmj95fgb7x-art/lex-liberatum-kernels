#![no_std]
#![no_main]

use core::panic::PanicInfo;

const VGA_ADDR: *mut u16 = 0xB8000 as *mut u16;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    unsafe {
        // blue background, white foreground, char 'L'
        *VGA_ADDR = 0x1F4C;
    }
    loop {
        unsafe { core::arch::asm!("hlt") }
    }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

