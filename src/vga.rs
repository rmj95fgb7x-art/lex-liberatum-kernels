use core::fmt;

const VGA_ADDR: *mut u16 = 0xB8000 as *mut u16;
const COLOR: u8 = 0x1F; // blue bg, white fg

static mut CURSOR: (usize, usize) = (0, 0);

pub fn print_str(s: &str) {
    unsafe {
        for b in s.bytes() {
            match b {
                b'\n' => newline(),
                _ => {
                    let off = CURSOR.1 * 80 + CURSOR.0;
                    *VGA_ADDR.add(off) = (COLOR as u16) << 8 | b as u16;
                    CURSOR.0 += 1;
                    if CURSOR.0 == 80 { newline(); }
                }
            }
        }
    }
}

fn newline() {
    unsafe {
        CURSOR.0 = 0;
        CURSOR.1 += 1;
        if CURSOR.1 == 25 {
            // scroll one line up
            for y in 0..24 {
                for x in 0..80 {
                    let src = (y + 1) * 80 + x;
                    let dst = y * 80 + x;
                    *VGA_ADDR.add(dst) = *VGA_ADDR.add(src);
                }
            }
            // clear bottom line
            for x in 0..80 {
                *VGA_ADDR.add(24 * 80 + x) = (COLOR as u16) << 8 | b' ' as u16;
            }
            CURSOR.1 = 24;
        }
    }
}

pub fn clear() {
    unsafe {
        for off in 0..(80 * 25) {
            *VGA_ADDR.add(off) = (COLOR as u16) << 8 | b' ' as u16;
        }
        CURSOR = (0, 0);
    }
}
