// SPDX-License-Identifier: MIT OR Apache-2.0

#![no_std]

use ::core::panic::PanicInfo;

// Panic handler setup for no_std
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
	loop {}
}

#[unsafe(no_mangle)]
pub fn rust_eh_personality() {
	// Empty stub
}

type zlong = i64;
type zulong = u64;

pub const ZLONG_MAX: zlong = i64::MAX;
pub const ZRANGE_MAX: zlong = ZLONG_MAX;
