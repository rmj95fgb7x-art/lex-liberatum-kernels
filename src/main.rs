#![no_std]
#![no_main]

#[no_mangle]
pub extern "C" fn _start() -> ! {
    const VGA: *mut u16 = 0xB8000 as *mut u16;
    const COLOR: u16 = 0x1F; // blue bg, white fg
    let msg = b"lex-kernel v0.1.0 booted!";
    unsafe {
        for (i, &ch) in msg.iter().enumerate() {
            *VGA.add(i) = COLOR << 8 | u16::from(ch);
        }
    }
    loop { unsafe { core::arch::asm!("hlt") } }
}



