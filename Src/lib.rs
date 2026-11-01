// SPDX-License-Identifier: MIT OR Apache-2.0

#![no_std]

use ::core::panic::PanicInfo;

// Panic handler setup for no_std
#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
	loop {}
}

#[unsafe(no_mangle)]
pub extern "C" fn rust_eh_personality() {
	// Empty stub
}
