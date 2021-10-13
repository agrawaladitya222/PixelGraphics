# Winter 2021 CSE12 Lab5 Template
######################################################
# Macros for instructor use (you shouldn't need these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
#pseudo:
#x = logical right shift of input 4 hex digits
#y = logical left shift of input 4 hex digits
#y = logical right shift of y 4 hex digits
.macro getCoordinates(%input %x %y)
	# YOUR CODE HERE
	srl %x, %input, 16	#shift input right 4 hex digits
	sll %y, %input, 16
	srl %y, %y, 16		#shift input left 4 and then back to right
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
#pseudo:
#output = logical left shift of x 4 hex digits
#output = output + y
.macro formatCoordinates(%output %x %y)
	# YOUR CODE HERE
	sll %output, %x, 16
	add %output, %output, %y	#shift x to left 4 hex digits then add y
.end_macro 

# Macro that converts pixel coordinate to address
# 	output = origin + 4 * (x + 128 * y)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%origin: register containing address of (0, 0)
#	%output: register to store memory address in
#pseudo:
#output = 128 * y
#output = output + x
#output = output * 4
#output = output + origin
.macro getPixelAddress(%output %x %y %origin)
	# YOUR CODE HERE
	mul %output, %y, 128		# 128 * y
	add %output, %output, %x	# + x
	mul %output, %output, 4		# * 4
	add %output, %output, %origin	# + origin
.end_macro


.data
originAddress: .word 0xFFFF0000

.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
#pseudo:
#loop from 0 to 128 in y:
#	loop from 0 to 128 in x:
#		getPixelAddress(x,y,origin)
#		change pixel
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	add $t0, $zero, $zero			#initialize t0 and t1 to 0
	add $t1, $zero, $zero
	lw $t5, originAddress			#store originaddress in t5
	LoopX:
		getPixelAddress ($t3, $t0, $t1, $t5)	#t3 returns with pixel address, t0 is x, t1 is y
		sw $a0, ($t3)
		addi $t0, $t0, 1		#increment x
		blt $t0, 128, LoopX		#loop until whole row(x) is set
		b LoopY				#branch to increment y when whole row set
	LoopY:
		addi $t1, $t1, 1		#increment y
		li $t0, 0			#set x back to 0
		blt $t1, 128, LoopX 		#branch back to set new row of x
 	jr $ra

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
#pseudo:
#getCoordinates((x,y))
#getPixelAddress(x,y,origin)
#change pixel
draw_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	lw $t5, originAddress				#store originAddress in t5
	getCoordinates ($a0, $t0, $t1)			#sets t0 to x, t1 to y
	getPixelAddress ($t3, $t0, $t1, $t5)	#sets t3 to pixel address
	sw $a1, ($t3)
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
#pseudo:
#getCoordinates((x,y))
#getPixelAddress(x,y,origin)
#store pixel color
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	lw $t5, originAddress				#store originaddress in t5
	getCoordinates ($a0, $t0, $t1)			#sets t0 to x, t1 to y
	getPixelAddress ($t3, $t0, $t1, $t5)	#sets t3 to pixel address
	lw $v0, ($t3)
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
#pseudo:
#loop 0 to 128 in x:
#	getPixelAddress(x,y,origin)
#	change pixel
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	add $t0, $zero, $zero			#initialize t0 to 0
	lw $t5, originAddress			#store originaddress in t5
	Loop:
		getPixelAddress ($t3, $t0, $a0, $t5)
		sw $a1, ($t3)			#set pixel
		addi $t0, $t0, 1		#increment pixel index
		blt $t0, 128, Loop		
 	jr $ra

#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
#pseudo:
#loop 0 to 128 in y:
#	getPixelAddress(x,y,origin)
#	change pixel
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	add $t0, $zero, $zero			#initialize t0 to 0
	lw $t5, originAddress			#store originaddress in t5
	Loopy:
		getPixelAddress ($t3, $a0, $t0, $t5)
		sw $a1, ($t3)			#set pixel
		addi $t0, $t0, 1		#increment pixel index
		blt $t0, 128, Loopy		
 	jr $ra

#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
#pseudo:
#getPixelAddress(x,y,origin)
#store color at pixel (x,y)
#draw horizontal line at y
#draw vertical line at x
#restore color at pixel (x,y)
draw_crosshair: nop
	push($ra)
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	move $s5 $sp

	move $s0 $a0  # store 0x00XX00YY in s0
	move $s1 $a1  # store 0x00RRGGBB in s1
	getCoordinates($a0 $s2 $s3)  # store x and y in s2 and s3 respectively
	
	# get current color of pixel at the intersection, store it in s4
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	lw $s0, originAddress			#store originaddress in s0
	getPixelAddress ($s4, $s2, $s3, $s0)	#sets t3 to pixel address
	lw $s4, ($s4)
	move $s0, $a0				#put 0x00XX00YY back in s0

	# draw horizontal line (by calling your `draw_horizontal_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0, $s3				#move y coordinate to a0
	jal draw_horizontal_line		#draw line
		
	# draw vertical line (by calling your `draw_vertical_line`) function
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0, $s2				#move x coordinate to a0
	jal draw_vertical_line			#draw line

	# restore pixel at the intersection to its previous color
	# YOUR CODE HERE, only use the s0-s4 registers (and a, v where appropriate)
	move $a0, $s0				#put (x,y) coordinate in a0
	move $a1, $s4				#put og color in a1
	jal draw_pixel					

	move $sp $s5
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
	pop($ra)
	jr $ra
