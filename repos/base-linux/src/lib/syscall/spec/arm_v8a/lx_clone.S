/* Copyright (C) 1996-2014 Free Software Foundation, Inc.

   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

/* clone() is even more special than fork() as it mucks with stacks
   and invokes a function in the right context after its all over.  */
/*

Imported to Genode 20201103 by Michael Grunditz - micken@update.uu.se


*/
#define SYS_clone 220
#define SYS_exit 93
#define SYS_getpid 172
#undef RESET_PID

#define CLONE_VM      0x00000100
#define CLONE_THREAD  0x00010000

        .text
        .globl lx_clone
        .type lx_clone, #function
lx_clone:
	/* Sanity check args.  */
	cbz	x0, 1f
	cbz	x1, 1f
	/* Insert the args onto the new stack.  */
	stp	x0, x3, [x1, #-16]!	/* Fn, arg.  */

	/* Do the system call.  */
	mov	x0, x2                  /* flags  */

	/* New sp is already in x1.  */
	mov	x2, x4			/* ptid  */
	mov	x3, x5			/* tls  */
	mov	x4, x6			/* ctid  */

#ifdef RESET_PID
	/* We rely on the kernel preserving the argument regsiters across a
	   each system call so that we can inspect the flags against after
	   the clone call.  */
	mov	x5, x0
#endif

	mov	x8, #SYS_clone
	/* X0:flags, x1:newsp, x2:parenttidptr, x3:newtls, x4:childtid.  */
	svc	0x0
	cmp	x0, #0
	beq	2f
	blt	3f
	RET
1:	mov	x0, #-1
3:
	b	4f

2:
	mov	x29, 0
#ifdef RESET_PID
	tbnz	x5, #CLONE_THREAD, 3f
	mov	x0, #-1
	tbnz	x5, #CLONE_VM, 2f
	mov	x8, #SYS_getpid
	svc	0x0
2:
	mrs	x1, tpidr_el0
	sub	x1, x1, #8
	str	w0, [x1, #PID_OFFSET]
	str	w0, [x1, #TID_OFFSET]

3:
#endif
	/* Pick the function arg and call address from the stack and
	   execute.  */
	ldp	x1, x0, [sp], #16
	blr	x1

4:	mov     x8,#SYS_exit
        svc     0x0

	/* We are done, pass the return value through x0.  */

