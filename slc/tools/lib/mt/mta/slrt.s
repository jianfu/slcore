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
	ldq $l14, main($l17)  !literal
	ldq $l13, __mt_main($l17) !literal
	
	mov 1, $l1
	allocate $l1, 3, $l1
    
	mov 3, $l2
	allocate $l2, 3, $l2
	
	crei $l1, 0($l13)
	crei $l2, 0($l13)
	
	puts $l14, $l1, 0
	putg $l5, $l1, 0
	putg $l6, $l1, 1
	putg $l7, $l1, 2

	puts $l14, $l2, 0
	putg $l5, $l2, 0
	putg $l6, $l2, 1
	putg $l7, $l2, 2


	sync $l1, $l3
	mov $l3, $l3

	sync $l2, $l4
	mov $l4, $l4
	
	gets $l1, 0, $l3
	mov $l3, $l3

	gets $l2, 0, $l4
	mov $l4, $l4
	
	detach $l1
	detach $l2
	
	mov $l3, $l1
	beq $l1, $bad1
	mov $l4, $l2
	bne $l2, $bad
	
$bad1:
	nop
	end
$bad:
	ldah $l3, $msg($l17) !gprelhigh
	lda $l2, 115($l31)  # char <- 's'
	lda $l3, $msg($l3) !gprellow
	.align 4
$L0:
	print $l2, 194  # print char -> stderr
	lda $l3, 1($l3)
	ldbu $l2, 0($l3)
	sextb $l2, $l2
	bne $l2, $L0

	print $l1, 130 # print int -> stderr
        lda $l1, 10($l31) # NL
	print $l1, 194  # print char -> stderr
$fini:	
	nop
	nop
	pal1d 0
	br $fini
	.end _start


	.align 4
    .globl __mt_main
    .ent __mt_main
    .registers 3 1 19 0 0 19
__mt_main:
    .base $l17
    ldpc $l14
    ldah $l17, 0($l14) !gpdisp!2
    lda $l17, 0($l17) !gpdisp!2
        ldfp $l18                               
        mov $31, $l16                           
        lda $l18,-16($l18)                      
        addl $31,$g0,$l7
        mov $d0,$l14
        mov $g1,$l6
        mov $g2,$l5
        jsr $l15,($l14),0
        ldah $l17,0($l15)               !gpdisp!3
        lda $l17,0($l17)                !gpdisp!3
        mov $l1, $s0                            
        end                                     
        .end __mt_main




	.section .rodata
	.ascii "\0slr_runner:mtalpha-sim:\0"
	.ascii "\0slr_datatag:mta:\0"

$msg:	
	.ascii "slrt: main returned \0"
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

