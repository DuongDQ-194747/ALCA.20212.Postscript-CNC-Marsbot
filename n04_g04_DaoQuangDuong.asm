.eqv 	IN_ADRESS_HEXA_KEYBOARD 	0xFFFF0012
.eqv 	OUT_ADRESS_HEXA_KEYBOARD 	0xFFFF0014
# receive row and column of the key pressed, 0 if not key pressed 
# equal 0x11, means that key button 0 pressed.
# equal 0x14, means that key button 4 pressed.
# equal 0x18, means that key button 8 pressed.

.eqv  HEADING    0xffff8010    	# Integer: An angle between 0 and 359
								# 0 : North (up)
								# 90: East (right)
								# 180: South (down)
								# 270: West  (left)
.eqv  MOVING     0xffff8050  	# Boolean: whether or not to move
.eqv  LEAVETRACK 0xffff8020    	# Boolean (0 or non-0):
								#    whether or not to leave a track
.eqv  WHEREX     0xffff8030    	# Integer: Current x-location of MarsBot
.eqv  WHEREY     0xffff8040    	# Integer: Current y-location of MarsBot


.data
	#postscript [{goc, tg, cat/k cat}, {},...]
	postscript0:	.word	135,4000,0, 225,1414,1, 90,3000,1, 315,1414,1, 270,800,1, 0,2000,0
	postscript4:	.word	90,4000,0, 180,4000,0, 120,4000,1, 150,4000,1, 180,4000,1, 210,4000,1, 240,4000,1, 0,13500,1
	postscript8:	.word	120,4000,0, 180,4000,0, 120,4000,1, 150,4000,1, 180,4000,1, 210,4000,1, 240,4000,1, 0,13500,1
	size0: 6
	size4: 8
	size8: 8
	
.text  
main:
	li $t6, 0xFFFF0010
	li $t7, IN_ADRESS_HEXA_KEYBOARD
 	li $t8, OUT_ADRESS_HEXA_KEYBOARD						 
polling: 
	move 	$t1, $zero
	li 		$t0, 0x01 								# check row 1 with key 0, 1, 2, 3
	sb 		$t0, 0($t7) 							# must reassign expected row
 	lb 		$t0, 0($t8) 							# read scan code of key button
 	or 		$t1, $t1, $t0
 	
 	li 		$t0, 0x02 								# check row 2 with key 4, 5, 6, 7
	sb 		$t0, 0($t7) 							# must reassign expected row
 	lb 		$t0, 0($t8) 							# read scan code of key button
 	or 		$t1, $t1, $t0
 	
 	li 		$t0, 0x04 								# check row 3 with key 8, 9, A, B
	sb 		$t0, 0($t7) 							# must reassign expected row
 	lb 		$t0, 0($t8) 							# read scan code of key button
	or 		$t1, $t1, $t0
 	
	li 		$t0, 0x08 								# check row 4 with key C, D, E, F
	sb 		$t0, 0($t7) 							# must reassign expected row
 	lb 		$t0, 0($t8) 							# read scan code of key button
 	or 		$t1, $t1, $t0
 	
 	beqz 	$t1, back_to_polling
 	
 	
	process: 
		sb 		$t1, 0($t8)
		li 		$v0, 34 							# print integer (hexa)
		move    $a0 $t1
 		syscall
	sleep: 
		li 		$a0, 100 							# sleep 100ms
 		li 		$v0, 32
		syscall 
back_to_polling: 
	j 	polling 								# continue polling



	la 		$t0, postscript8
	lw 		$t1, size8
	li 		$t2, 0		#i=0
loop:	
	beq		$t2, $t1, end
	lw		$s0, ($t0)		# $s0: goc chuyen dong
	addi	$t0, $t0, 4
	lw		$s1, ($t0)		# $s1: thoi gian
	addi	$t0, $t0 4
	lw		$s2, ($t0)		# $s2: cat/khong cat
	addi	$t0, $t0, 4
	
	li $v0, 1
    move $a0, $s0
    syscall
    li $v0, 1
    move $a0, $s1
    syscall
    li $v0, 1
    move $a0, $s2
    syscall
    
	move	$a0, $s0
	jal		ROTATE
	
	bnez	$s2, is_track
	jal		UNTRACK
	j		not_track
	is_track: 	jal		TRACK
	not_track:
	jal		GO
	nop
	
	move    $a0, $s1
	jal		SLEEP
	
	nop
	jal     UNTRACK         	# keep old track
	nop
	jal     TRACK           	# and draw new track line
	
	
	addi 	$t2, $t2, 1		# i++
	j loop
            
end_main:
	
	
#-----------------------------------------------------------
# STEP procedure, to start running
# param[in]    	$s0 : goc chuyen dong
#				$s1 : thoi gian
#				$s2 : cat/khong cat
#-----------------------------------------------------------
STEP: 


	
	
#-----------------------------------------------------------
# SLEEP procedure, to start running
# param[in]    $a0 : time (mili-second)
#-----------------------------------------------------------
SLEEP: 
	addi	$v0, $zero, 32        
	syscall	
	nop       
	jr    	$ra
	nop
	
#-----------------------------------------------------------
# GO procedure, to start running
# param[in]    none
#-----------------------------------------------------------
GO:     
	li    	$at, MOVING     	# change MOVING port
	addi  	$k0, $zero, 1    	# to  logic 1,
	sb    	$k0, 0($at)     	# to start running
	nop       
	jr    	$ra
	nop
	
#-----------------------------------------------------------
# STOP procedure, to stop running
# param[in]    none
#-----------------------------------------------------------
STOP:     
	li    	$at, MOVING     	# change MOVING port TO 0
	sb    	$zero, 0($at)     	# to stop running
	nop       
	jr    	$ra
	nop
	
#-----------------------------------------------------------
# TRACK procedure, to start drawing line 
# param[in]    none
#-----------------------------------------------------------
TRACK:  
	li    	$at, LEAVETRACK 	# change LEAVETRACK port
	addi  	$k0, $zero, 1    	# to  logic 1,
	sb    	$k0, 0($at)     	# to start tracking
	nop
	jr    	$ra
	nop
	
#-----------------------------------------------------------
# UNTRACK procedure, to stop drawing line 
# param[in]    none
#-----------------------------------------------------------
UNTRACK:  
	li    	$at, LEAVETRACK 	# change LEAVETRACK port to 0
	sb    	$zero, 0($at)     	# to start tracking
	nop
	jr    	$ra
	nop  

#-----------------------------------------------------------
# ROTATE procedure, to rotate the robot
# param[in]    $a0, An angle between 0 and 359
#            		0 : North (up)
#                   90: East  (right)
#                  180: South (down)
#                  270: West  (left)
#-----------------------------------------------------------
ROTATE: 
	li    	$at, HEADING    # change HEADING port
	sw    	$a0, 0($at)     # to rotate robot
	nop
	jr    	$ra
	nop
end: 
	jal STOP
	nop
