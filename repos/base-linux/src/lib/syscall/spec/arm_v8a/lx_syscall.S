/*
 * \brief  Linux syscall() binding
 * \author Michael Grunditz
 * \date   2020-11-03
 *
 * based on glibc//sysdeps/unix/sysv/linux/aarch64/syscall.S
 *
 * error case:
 *   glibc's syscall() function returns -1 and sets errno
 *   lx_syscall() returns -errno
 */

	.text
	.globl lx_syscall
	.type lx_syscall, #function
lx_syscall:
	 uxtw x8, w0
	 mov x0, x1
	 mov x1, x2
	 mov x2, x3
	 mov x3, x4
	 mov x4, x5
	 mov x5, x6
	 mov x6, x7
	 svc	0x0
	 ret

/* tell the linker that this code does not need an executable stack */
.section .note.GNU-stack, "", %progbits
