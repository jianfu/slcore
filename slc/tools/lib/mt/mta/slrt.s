# slrt.s: this file is part of the SL toolchain.
#
# Copyright (C) 2009,2010 The SL project
#
# This program is free software, you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 2
# of the License, or (at your option) any later version.
#
# The complete GNU General Public Licence Notice can be found as the
# `COPYING' file in the root directory.
#

	.text
	.ent _start
	.globl _start
	.registers 0 0 31 0 0 31
_start:
	#MTREG_SET: $l5,$l6,$l7
        ldpc $l27
	ldgp $l17, 0($l27)
	ldfp $l18

	mov $l18, $l16 # set up frame pointer
	clr $l8 # flush callee-save reg
	clr $l9 # flush callee-save reg
	clr $l10 # flush callee-save reg
	clr $l11 # flush callee-save reg
	clr $l12 # flush callee-save reg
	clr $l13 # flush callee-save reg
	fclr $lf11 # flush callee-save reg
	fclr $lf12 # flush callee-save reg
	fclr $lf13 # flush callee-save reg
	fclr $lf14 # flush callee-save reg
	fclr $lf15 # flush callee-save reg
	fclr $lf16 # flush callee-save reg
	fclr $lf17 # flush callee-save reg
	fclr $lf18 # flush callee-save reg
	fclr $lf3 # init FP return reg
        clr $l2 # flush arg reg
	clr $l3 # flush arg reg
        clr $l4 # flush arg reg
	fclr $lf5 # flush arg reg
	fclr $lf6 # flush arg reg
	fclr $lf7 # flush arg reg
	fclr $lf8 # flush arg reg
	fclr $lf9 # flush arg reg
	fclr $lf10 # flush arg reg

	# here $l7(a0), $l6(a1), $l5(a2) are set by the environment
	# all 3 are used by the init function
	ldq $l14,sys_init($l17)  !literal!1
	jsr $l15,($l14),sys_init !lituse_jsr!1
	ldgp $l17,0($l15)

	# initialize argc, argv and environ for main()
	ldah $l7,__argc($l17)     !gprelhigh
        ldq $l7, __argc($l7)      !gprellow
	ldah $l6,__argv_ptr($l17) !gprelhigh
        ldq $l6, __argv_ptr($l6)  !gprellow
	ldah $l5, environ($l17)   !gprelhigh
        ldq $l5, environ($l5)     !gprellow

	# call main()
	ldq $l14,main($l17) !literal!2
	jsr $l15,($l14),main !lituse_jsr!2
	ldgp $l17,0($l15)

        stq $l1, 0x278($31) # exit simulator with main's error code
	end
	.end _start

	.section .rodata
	.ascii "\0slr_runner:mtalpha-sim:\0"
	.ascii "\0slr_datatag:mta:\0"

$progname:
	.ascii "a.out\0"
        
        .section .data

        .globl __main_place_id
        .type __main_place_id, @object
        .size __main_place_id, 8
        .align 3
__main_place_id:
        .long 0

        .globl environ
        .type environ, @object
        .size environ, 8
        .align 3
environ:
        .long 0
        
	.globl __pseudo_argv
        .type __pseudo_argv, @object
        .size __pseudo_argv, 16
	.align 3
__pseudo_argv:
	.long $progname
	.long 0

        .globl __argv_ptr
        .type __argv_ptr, @object
        .size __argv_ptr, 8
	.align 3
__argv_ptr:
	.long __pseudo_argv

        .globl __argc
        .type __argc, @object
        .size __argc, 8
	.align 3
__argc:
	.long 1
