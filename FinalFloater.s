#Made By M J Baig, Hufsa Rizwan
#########NOTES###########
#$s0 contains first num decimal part
#$s6 contains n digits used by decimal floater
#$s0 contains the whole part of the number
#$s7 contains n digits used by binary whole
#########################

.data
firstdecfl: .asciiz "        "		        	#string containing the floating point of number in decimal notation address in $s1
firstbinwh: .asciiz "        "				#string containing the whole number in binary notation. address in $s2
firstbinfl: .asciiz "                                         "	#string containing the floating point of number in binary notation. Address in $s3

fexponent: .asciiz  "        "				#first exponent. 8 bytes, one for each character. Address in $s2, which it shares with firstbinwh
fmantissa: .asciiz  "                       "		#first mantissa. Occupies 23 bytes, one for each character. Address in $s4

nDigitsbin: .byte 40					#constant telling us the maximum number of binary decimal places to go 


fwholedec:  .space 2					#first whole number in decimal notation
expdec:     .space 2 					#decimal number that holds the value of exponent. #prev size 4 
nDigitsfWh: .space 2					#number of digits occupied by first binary whole
nDigitssWh: .space 2
					
nDigitsfdec1: .space 2					#number of digits occupied by floating point 1 in decimal
nDigitsfdec2: .space 2					#number of digits occupied by floating point 2 in decimal

swholedec:  .space 2				#second whole number in decimal notation
sexpdec:    .space 2					#second decimal exponent #prev size 4

secdecfl:    .asciiz "        "			        #string containing floating point of second number in decimal notation
secbinwh:    .asciiz "        "			        #string containing whole number second in binary notation
secbinfl:    .asciiz "                                         "  #string containing second floating number in binary.

sexponent:   .asciiz "        "				#second exponent in binary
smantissa:   .asciiz "                       "		#second mantissa


rwholedec: .space 2					#sum whole number in decimal notation
rexpdec:   .space 4					#sum exponent in decimal
nDigitsrWh: .space 2					#number of digits occupied by sum binary whole

resdecfl:   .asciiz   "        "			#string containing floating point of sum in decimal
resbinwh:  .asciiz    "        "			#string with sum whole number in binary
resbinfl:  .asciiz    "                                        "  #string with sum floating point in binary


rmantissa:   .asciiz "                       "		#mantissa of sum
rexponent:   .asciiz "        "				#exponent of sum
newmantissa: .asciiz "                       "		#new mantissa of smaller number, used for sum
newexp: .asciiz      "        "				#new exponent of smaller number


firstnum: .asciiz "Enter First number\n"
bin1: .asciiz "Binary: \n"
fp1: .asciiz "IEEE Format of first number: \n"
secondnum: .asciiz "Enter Second Number\n"
bin2: .asciiz "Binary: \n"
fp2: .asciiz "IEEE Format of second number: \n"
summation: .asciiz "SUM: \n"
newm: .asciiz "New Mantissa after making exponents same : \n"
inst: .asciiz "Instructions: Enter whole number part of first number and press enter. Then enter decimal part. Repeat for second number. \n "
comments: .asciiz "WORKING: The first number is taken, completely converted to binary and then normalized. The bias is calculated and number is converted to IEEE format. The same is repeated with the second number. Then the exponents are checked. If they are same, the numbers are added as it is. If the exponents differ, the mantissa of the number with the smaller exponent is changed so as to make exponents same. Then bit by bit addition is done. Addition is most accurate for numbers with DIFFERENT EXPONENTS\n" 


.text

.globl main
main:

#input first number ka whole part, store in $s0
#***************************************************************************************#
	
	
	addi $v0, $0, 4
	la $a0, inst
	syscall
	
	addi $a0, $zero, 10
	addi $v0, $zero, 11
	syscall			#newline
	addi $a0, $zero, 10
	addi $v0, $zero, 11
	syscall			#newline
	syscall			#newline
	

	addi $v0, $0, 4
	la $a0, firstnum
	syscall
	

	addi $v0, $zero, 5
	syscall			#input goes in $v0

	add $s0, $zero, $v0	#place input in $s0
	la $t0, fwholedec
	sh $s0, 0($t0)		#halfword to keep range of values greater. a byte can have max 255, hw can have 65500

	

#input first number ka decimal part, save as a character array(firstdecfl), addr in $s1
#***************************************************************************************#

	la $s1, firstdecfl

	addi $v0, $zero, 8
	add $a0, $zero, $s1
	addi $a1, $zero, 6
	syscall			#input decimal part, take no more than 5 digits, store in firstdec

	addi $a3, $0, 2		#this will make sure the compiler doesnt skip to second number parts

#convert whole number part to binary, store in charactar array(firstbinwh), addr in $s2
#****************************************************************************************#	
	la $s2,  firstbinwh	#s2 points to string that will hold binary whole number
	addi $s7, $zero, 0	#this register will keep track of the number of digits in firstbinwh

	addi $t0, $zero, 2
	add $t1, $zero, $s0    #copy $s0, to t1 for integrity
	
	la $t7, nDigitsfWh     #address of number of digits occupied by first whole number

#converts and pushes on stack
wholenconversion:
	div $t1, $t0		#$s0/2, remainder in HI, quotient in LO
	mflo $t1		#quotient goes back to t1
	mfhi $t2		#remainder goes in t2
	
	addi $sp, $sp, -1	
	sb $t2, 0($sp)		#push remainder from t2 onto stack
	addi $s7, $s7, 1	#increment ndigits counter	

	bgtz $t1, wholenconversion

#stores converted values from stack into memory
	sb $s7, 0($t7)		#safely store number of digits in a memory location
	
	addi $t0, $zero, 0	#this will be compared with s7 for number of digits
	
storebinarywhole:
#
	lb $t3, 0($sp)
	addi $sp, $sp, 1	#pop from stack, bring into $t3
	addi $t3, $t3, 48	#turn it into a character 

	sb, $t3, 0($s2)
	addi $s2, $s2, 1	#store in firstbinwh, move to next byte
	
	addi $t0, $t0, 1
	#NOTE: If this doesnt work, try store bytes

	ble $t0, $s7, storebinarywhole
	

#print number
#***********
	addi $a0, $zero, 10
	addi $v0, $zero, 11
	syscall			#newline
	
	addi $v0, $0, 4
	la $a0, bin1
	syscall


	beq $a3, $0, printsec 	#IF a0 is 0, we are working with the second number. So go down.

	

	la $s2, firstbinwh      #make s2 point to firstbinwh again
	
	addi $t0, $zero, 0	#compared with s7
printing:
	lb $a0, 0($s2)
	#lw $a0, 0($s2)
	addi $v0, $zero, 11
	syscall

	addi $t0, $t0, 1
	add $s2, $s2, 1
	
	blt $t0, $s7, printing
	
	beq $a3, $0, secdec	#reference to second number


#convert decimal part to binary, store in another character with array addr in $s3
#*********************************************************************************
	la $t6, nDigitsbin
	lb $t6, 0($t6)		#max num of dec places

#first we need to merge the character array into a number

	la $s3, firstbinfl	#$s3 points to character array that will hold binary notation floating point 
	la $s1, firstdecfl	#s1 points to char array that holds decimal notation floating point

	la $t5, nDigitsfdec1	#will hold address for number of digits
deciconv:
	lb $t0, 0($s1)		#bring the nextfloat character into register
	addi $t0, $t0, -48	#convert it to number
    addi $t3, $zero, 10	#to compare if decimal values have exceeded two places, and also used to check for newline(=10) character, as well as multiply while merging
	addi $s1, $s1, 1	#move to next char
	addi $t4, $zero, 10	#will be 10^n where n is number of decimal places, or digits in firstdecl. Will be used to divide the dec floating point
	add $t2, $zero, $zero

	addi $s6, $0, 0		#will hold the number of digits


concat:	
		
	lb $t2, 0($s1)

	beq $t2, $t3	firstflconv
	beq $t2, $zero, firstflconv

	mult $t3, $t4
	mflo $t4
	
	addi $t2, $t2, -48	#else repeat for the one after that	

	mult $t0, $t3 	#multiply the first digit by 10
	mflo $t1
	add $t1, $t1, $t2	#and add the second digit to it, so '2', '5' will become 2*10+5 = 25, store in t0
	
	addi $s1, $s1, 1
	add $t0, $zero, $t1
	
	addi $s6, $s6, 1
	j concat


	
firstflconv:
	#sb $s6, 0($t5) idk why this is here, something to do with exponent
	beq $t6, $zero, printdot
	sll $t0, $t0, 1		#multiply by two
	bge $t0, $t4, storeone 

storezero:
	addi $t6, $t6, -1
	addi $t5, $zero, 48	
	sb $t5, 0($s3)		#store '0'
	addi $s3, $s3, 1	#move pointer to next byte
		
	blt $t0, $t4, firstflconv

storeone:
	addi $t6, $t6, -1
	addi $t5, $zero, 49
	sb $t5, 0($s3)		#store '1'
	addi $s3, $s3, 1

	div $t0, $t4
	mfhi $t0		#restandardize the comparison numbers
	blt $t0, $t4, firstflconv


#Printing the decimal part after printing a dot
#******************************************************************

printdot:

	beq $a3, $0, printsdot	#sending second number to right place
	la $t6, nDigitsbin
	lb $t6, 0($t6)		#max num of dec places

	la $s3, firstbinfl
	addi $a0, $zero, 46
	addi $v0, $zero, 11
	syscall


printdecs:
	addi $v0, $zero, 11
	lb $a0, 0($s3)

	syscall
	addi $s3, $s3, 1
	addi $t6, $t6, -1	#reduce counter
	bne $t6, $zero, printdecs

	
	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline

	beq $a3, $0, mantissasec
#**************************************************************************************************************************************
#				convert to NORMALIZED form and MERGE the whole and decimal part into a MANTISSA
#**************************************************************************************************************************************
#The way to do this is distributed in two cases:
#	case 1: The whole number part is non-zero.
#		In which case, the leading high bit shall always be the first bit in the whole number binary part.
#		Simply ignore that bit and add the remaining bits in the mantissa data field.
#		The exponent shall simply be the BIAS added to the number of digits (bytes) occupied by whole number part 
#**************
#	case 2: The whole number part is zero. in this case, A loop can run disposing of zeros in the decimal part until a 1 comes.
#		It then adds the characters following the one into the mantissa data field
#		A counter increments for each character discarded until the leading high
#		The exponent is 127 - the value of this counter
#**************************************************************************************************************************************


	la $s4, fmantissa
	la $s2, firstbinwh
	beq $0, $s0, whiszer	#if the whole number (stored in $s0) is 0. This skips to CASE 2.
#CASE 1:
#**************
	la $s3, expdec		#just briefly borrowing $s3 to set the expdec to nDigits
	addi $t0, $s7, -1	#t0 now contains number of digits occupied by binary whole except 1 (first one) ie: the exponent)

	sb $t0, 0($s3)		#expdec (expononent) now contains unbiased exponnet
	
	la $s3, firstbinfl	#set $s3 back to its original value

#First, we add the whole number part to the mantissa.
mant1:
	addi $t0, $zero, 0
	lb $t0, 0($s2)		#bring the next byte in t0
	addi $s2, $s2, 1	#move to next byte

	add $t1, $0, $s7	#bring ndigits used by binary whole number into temp
	addi $t5, $0, 0		#this will used to subtract n digits occupied by whole number from total mantissa digits, to keep the mantissa from overflowing later

	addi $t1, $t1, -1	#subtract it by one as first byte will be ignored, since we know its 1

whisnzer:
	beq $t1, $0, mandec
	lb $t0, 0($s2)		#load next byte
	sb $t0, 0($s4)		#store current byte into the mantissa
	addi $s4, $s4, 1	#move to next byte of mantissa
	addi $t1, $t1, -1	#decrease ndigits counter
	addi $s2, $s2, 1	#move to next byte to read of binary whole.
	addi $t5, $t5, -1	#decrease ndigits -ve counter

	j whisnzer		#while loop
	
#Now to add the decimal part to the mantissa
	#la $s3, firstbinfl	
mandec:
	addi $t6, $0, 23
	add $t7, $t6, $t5	#max num of dec places available in mantissa (23 + $t5 where t5 is -(number of digits occupied by whole number))

mantcase1:
	addi $t0, $zero, 0
	lb $t0, 0($s3)		#load next character from binary decimals into temp
	sb $t0, 0($s4)		#store in current byte of mantissa. Remember that it left of from storing wholes

	addi $s3, $s3, 1	#move to next byte of binary decimals
	addi $s4, $s4, 1	#move to next byte of mantissa

	addi $t7, $t7, -1	#dec number of available spaces in mantissa

	bne $t7, $0, mantcase1	#if max num of bits hasnt been exceeded, repeat
	beq $a3, $0, getsexp
	j getexp


#CASE 2:
#**************

#load the next char in firstbinfl
#if its a zero, go back to previous step after decrementing counter
#if its a one, go the next char and move to next step after decrementing counter
#store byte in mantissa
#move to next byte and decrement counter
#repeat  

whiszer:
	addi $t3, $0, 23	#number of bits occupied by mantissa
	la $s3, firstbinfl
	#addi $t1, $0, 0	#$t1 is our counter that is used to find number of digits skipped so that the appropriate amount goes in mantissa
	addi $t4, $0, 0		#counter that will go in the opposite direction to find exponent
	la $s2, expdec		#borrowing $s2 to store counter as the exponent


nextchar:	
	lb $t0, 0($s3)		#bring next dec char into temp
	addi $t0, $t0, -48	#convert to number from char
	#addi $t1, $t1, 1	#inc counter as a digit has been skipped
	addi $s3, $s3, 1
	addi $t4, $t4, -1	#each skipped digit contributes to decreasing the exponent
	beq $t0, $0, nextchar	#if it is zero, repeat until it is nonzero
	
	#la $s2, expdec		#borrowing $s2 to store counter as the exponent
	#addi $t1, $t1, 1	#account for the one last extra incrementation
	#addi $t4, $t4, -1	#same as above comment
	sb $t4, 0($s2)		#stored the current value of $t4 in expdec

	
	#add $t3, $t3, $t1	#t3 now holds the number of available bits in the mantissa

	
mantcase2:
	lb $t0, 0($s3)		#bring next byte to store into temp
	sb $t0, 0($s4)		#store byte in mantissa
	addu $s4, $s4, 1	#move to next mantissa byte
	addi $t3, $t3, -1	#decrement number of available bits
	addi $s3, $s3, 1	#move to next binary decimal byte
	bne $t3, $0, mantcase2

	beq $a3, $0, getsexp

	
#****************************************************************************************************
#	  	Calculate the biased exponent
#****************************************************************************************************

#expdec currently contains an unbiased exponent. We need to get that value in a temp register, add the bias and store it back.

getexp:
	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline	

	la $t1, expdec	
	lb $t2, 0($t1)		#load unbiased exponent in temp

	addi $t2, $t2, 127

	sh $t2, 0($t1)		#place biased exponent back in memory



#convert exponent to binary, store in charactar array(fexponent), addr in $s2
#****************************************************************************************#	
	la $s2,  fexponent	#s2 points to string that will hold binary exp
	addi $s7, $zero, 8	#max number of bits counter

	la $t1, expdec
	lh $t1, 0($t1)		#t1 now contains the exponent, which shall be converted to binary

	addi $t0, $zero, 2


#converts and pushes on stack
expconversion:
	div $t1, $t0		#$s0/2, remainder in HI, quotient in LO
	mflo $t1		#quotient goes back to t1
	mfhi $t2		#remainder goes in t2
	
	addi $sp, $sp, -1	
	sb $t2, 0($sp)		#push remainder from t2 onto stack
	addi $s7, $s7, -1	#decrement remaining exponent digits counter	

	bgtz $s7, expconversion

#stores converted values from stack into memory

	addi $t0, $0, 8
storeexp:
#
	lb $t3, 0($sp)
	addi $sp, $sp, 1	#pop from stack, bring into $t3
	addi $t3, $t3, 48	#turn it into a character 

	sb, $t3, 0($s2)
	addi $s2, $s2, 1	#store in exponent, move to next byte
	
	addi $t0, $t0, -1

	bgt $t0, $0, storeexp

	beq $a3, $0, printsecond

	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline	
	syscall			#again

	addi $v0, $0, 4
	la $a0, fp1
	syscall
	
	addi $v0, $0, 1
	addi $a0, $0, 0
	syscall			#print sign bit

	addi $a0, $0, 32
	addi $v0, $0, 11
	syscall			#space

	la $a0, fexponent
	addi $v0, $0, 4
	syscall 		#print exponent

	addi $a0, $0, 32
	addi $v0, $0, 11
	syscall			#space

	
	addi $v0, $0, 4
	la $a0, fmantissa
	syscall			#print mantissa
	

#Note for biasing: bias is 127. This means that -127 will be 0, and +127 will be a high byte.

######NOW FOR THE SECOND NUMBER########
#**************************************
#We shall use the above functions for the second number as well 
#We shall load the addresses here and keep jumping back from there to here to load the addresses relevant to the second number
#the condition for jumping here shall be if $a3 is 0. Above, it was always 2
#######################################


	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline	
	syscall			#again
	addi $v0, $0, 4
	la $a0, secondnum
	syscall

#input second number whole part
	addi $v0, $zero, 5
	syscall			#input goes in $v0

	add $s0, $zero, $v0	#place input in $s0
	la $t0, swholedec
	sh $s0, 0($t0)		#store in memory
	

#input second number decimal part

	la $s1, secdecfl

	addi $v0, $zero, 8
	add $a0, $zero, $s1
	addi $a1, $zero, 6
	syscall			#input decimal part, take no more than 5 digits, store in firstdec


	addi $a3, $0, 0	#now it will keep returning here from up to load relevant registeres


	
#convert second whole number to binary
#****************
	la $s2,  secbinwh	#s2 points to string that will hold binary whole number
	addi $s7, $zero, 0	#this register will keep track of the number of digits in firstbinwh

	addi $t0, $zero, 2
	add $t1, $zero, $s0    #copy $s0, to t1 for integrity

	la $t7, nDigitssWh     #address of number of digits occupied by second whole number

	j wholenconversion

#print second whole binary number
#****************
printsec:
	la $s2, secbinwh      #make s2 point to secbinwh again
	addi $t0, $zero, 0	#compared with s7
	j printing		#print second whole number


#converting second floater to binary
#******************
secdec:
	la $t6, nDigitsbin
	lb $t6, 0($t6)		#max num of dec places

#first we need to merge the character array into a number

	la $s3, secbinfl	#$s3 points to character array that will hold binary notation floating point 
	la $s1, secdecfl	#s1 points to char array that holds decimal notation floating point
	la $t5, nDigitsfdec2	#will hold address for number of digits

	j deciconv		#go to convert the decimal part

#print second number decimal
#********
printsdot:
	la $t6, nDigitsbin
	lb $t6, 0($t6)		#max num of dec places

	la $s3, secbinfl	#second binary float address
	addi $a0, $zero, 46
	addi $v0, $zero, 11
	syscall
	
	j printdecs		#print second num decimals


#load values for second mantissa
	
mantissasec:

	la $s4, smantissa
	la $s2, secbinwh

	beq $s0, $0, swhoiszero

#case one loads
	la $s3, sexpdec		#just briefly borrowing $s3 to set the expdec to nDigits
	addi $t0, $s7, -1	#t0 now contains number of digits occupied by binary whole except 1 (first one) ie: the exponent)

	sb $t0, 0($s3)		#expdec (expononent) now contains unbiased exponnet
	
	la $s3, secbinfl	#set $s3 back to its original value

	j mant1			#execute case 1

#case two loads
swhoiszero:
	addi $t3, $0, 23	#number of bits occupied by mantissa
	la $s3, secbinfl
	#addi $t1, $0, 0	#$t1 is our counter that is used to find number of digits skipped so that the appropriate amount goes in mantissa
	addi $t4, $0, 0		#counter that will go in the opposite direction to find exponent
	la $s2, sexpdec		#borrowing $s2 to store counter as the exponent

	j nextchar		#execute case 2	

#Bias the exponent and store as decimal
getsexp:
	la $t1, sexpdec	
	lb $t2, 0($t1)		#load unbiased exponent in temp

	addi $t2, $t2, 127

	sh $t2, 0($t1)		#place biased exponent back in memory. using halfword for greater range

#convert biased exponent to binary
	la $s2,  sexponent	#s2 points to string that will hold binary exp
	addi $s7, $zero, 8	#max number of bits counter

	la $t1, sexpdec
	lh $t1, 0($t1)		#t1 now contains the exponent, which shall be converted to binary. using halfword, as byte has maximum of 127 

	addi $t0, $zero, 2
	
	j expconversion		#execute conversion


#print second floating point
printsecond:
	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall
	addi $v0, $0, 4
	la $a0, fp2
	syscall
	
	addi $v0, $0, 1
	addi $a0, $0, 0
	syscall			#print sign bit

	addi $a0, $0, 32
	addi $v0, $0, 11
	syscall			#space

	la $a0, sexponent
	addi $v0, $0, 4
	syscall 		#print exponent

	addi $a0, $0, 32
	addi $v0, $0, 11
	syscall			#space

	
	addi $v0, $0, 4
	la $a0, smantissa
	syscall			#print mantissa



#################################################################################################################################################
#******************************************************ADDITION OF THE NUMBERS******************************************************************#
#################################################################################################################################################
#
#---------------------------------------------------------------------------------------
#To add, find the difference between the exponents. Then shift the smaller mantissa to the right, and first add the implicit 1 as the msb of the mantissa and if #further shifts are needed, append 0's. (Logic: the implicit 1 is the first high bit of the number, and is preceded by 0's
#

	#load both exponents
	la $s0, expdec
	la $s1, sexpdec

	lh $s0, 0($s0)		#first dec exponent here
	lh $s1, 0($s1)		#second dec exponent here
	

	#Below is the greater than-less than thing
	#If fexponent > sexponent, program jumps to firstgreater
	#if fexponent <= sexponent, program continues from here
	#we want that if sexponent is equal to fexponent, it should jump to the adder
	#however that is not so simple. there are addresses that have to be handled in the process, so be careful
	#also, the adder is currently only adding newmantissa with the second mantissa. Make it add newmantissa with the whatever is the other mantissa
	###############################################################################################################################################
	#kthxbye#
	#########

	beq $s0, $s1, adder1
	bgt $s0, $s1, firstgreater 


	sub $s6, $s1, $s0

	la $s3, smantissa	
	la $s2, fmantissa	#loading mantissas
	j equalizer		#skip over second condition onto exp equalizer

#if $s1 is greater than $s0, then we need to: 
#     Arithmatically Add 1 to $s0
#     Subtract expdiff from 23 to get number of bytes to shift
#     Place pointers to smallmantissa and newmantissa at position determined in above step
#     copy bytes from smallmantissa onto newmantissa until nullvalue is reached
#     bring pointer back to position
#     start going backwords, starting with placing a (the implicit) 1, and then 0's until the diff is 0


firstgreater:
	la $s1, sexpdec
	la $s0, expdec		#interchanging the addresses so that the same equalizer function can be used
	lh $s1, 0($s1)
	lh $s0, 0($s0)

	sub $s6, $s0, $s1


	#now the difference b/w both exps is in $s6
	la $s2, smantissa
	la $s3, fmantissa	#since f and s have reversed roles in the two cases, we use the same function but with reversed addressess
	
#equalizer was here

#/equalizer
equalizer:
	la $s7, newmantissa	#address of newmantissa is now in s7
	addi $t0, $0, 23	
	sub $t0, $t0, $s6	#t0 now contains the position in newmantissa to put what follows the implicit one 
	add $t1, $0, $t0	#copy it to t1 as a counter

	#add $s7, $s7, $t0
	add $s7, $s7, $s6	
eqloop:
	lb $t3, 0($s2)
	sb $t3 0($s7)
	addi $s2, $s2, 1
	addi $s7, $s7, 1
	addi $t1, $t1, -1
	bne $t1, $0, eqloop	#placing the part of the mantissa after the implicit 1 into the correct place of newmantissa
	
	la $s7, newmantissa
	add $s7, $s7, $s6

	add $t4, $0, $s6	#difference is copied to $t4
	addi $t7, $0, 49

imploop:		
	addi $s7, $s7, -1
	sb $t7, 0($s7)
	addi $t7, $0, 48
	addi $t4, $t4, -1
	bne $t4, $0, imploop

	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline
	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall

	addi $v0, $0, 4
	la $a0, newm
	syscall
	addi $v0, $0, 4
	la $a0, newmantissa
	syscall

	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline
	
	


	blt $s0, $s1, adder		#if first was less than second, go to adder:

	 addi $s2, $0, 0			#when second mantissa is changed
	la $s1, fmantissa
	la $s2, newmantissa
	la $s3, rmantissa
	addi $t2, $0, 48		#carry in is zero
	addi $t4, $0, 23
        j adding


adder1: addi $s2, $0, 0 		#when exponents are equal
	la $s1, fmantissa
	la $s2, smantissa
	la $s3, rmantissa
	addi $t2, $0, 48		#carry in is zero
	addi $t4, $0, 23
	j adding

adder:
	addi $s2, $0, 0			#when first mantissa is changed
	la $s1, smantissa
	la $s2, newmantissa
	la $s3, rmantissa
	addi $t2, $0, 48		#carry in is zero
	addi $t4, $0, 23
        j adding

adding:
	beq $t4, $0, chkoverflow
	addi $t4, $t4, -1
	lb $t0, 22($s1)		#load first byte from float1
	lb $t1, 22($s2)		#load first byte from float2

	addi $t2, $t2, -48
	addi $t0, $t0, -48
	addi $t1, $t1, -48	#convert to integers

	
	add $t3, $t0, $t1 #add didgits
	add $t3, $t3, $t2 #add carry

    beq $t3, 2, case1 #if sum is 2 i.e 1+1+0
	beq $t3, 3, case2 #if sum is 3 i.e 1+1+1
	beq $t3, 1, case3 #if sum is 1 i.e 1+0+0
	beq $t3, 0, case4 #if sum is 0	



case1: #sum is 0, carry is 1
	addi $t2, $0, 49		#carry
	addi $t1, $0, 48		#sum
	sb $t1, 22($s3)		#store result in the current byte of mantissa, starting from last

	addi $s3, $s3, -1	#move to previous (next byte of result mantissa
	addi $s1, $s1, -1
	addi $s2, $s2, -1	#move to next bytes of mantissas one and two
	j adding

case2:
	#sum is 1, carry is 1
	addi $t2, $0, 49	#carry
	addi $t1, $0, 49	#sum
	sb $t1, 22($s3)

	addi $s3, $s3, -1
	addi $s1, $s1, -1
	addi $s2, $s2, -1
	j adding


case3: # sum is 1, carry is 0
	addi $t2, $0, 48	#carry
	addi $t1, $0, 49	#sum
	sb $t1, 22($s3)

	addi $s3, $s3, -1
	addi $s1, $s1, -1
	addi $s2, $s2, -1
	j adding
	


case4: # sum is 0, carry is 0
	addi $t2, $0, 48	#carry
	addi $t1, $0, 48	#sum
	sb $t1, 22($s3)

	addi $s3, $s3, -1
	addi $s1, $s1, -1
	addi $s2, $s2, -1
	j adding
	


chkoverflow:

	beq $t2, 48, printsum		#if carry out is 0, ie no overflow, jump to print

	

printsum:

	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline	
	syscall


	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline	


	addi $v0, $0, 4
	la $a0, summation
	syscall

	addi $v0, $0, 1
	addi $a0, $0, 0
	syscall			#print sign bit

	addi $a0, $0, 32
	addi $v0, $0, 11

	syscall			#space


	la $s0, expdec
	lh $s0, 0($s0)
	la $s1, sexpdec
	lh $s1, 0($s1)

	la $a0, fexponent
	blt $s1, $s0, pfless
	la $a0, sexponent
pfless:
	addi $v0, $0, 4
	syscall 		#print exponent

	addi $a0, $0, 32
	addi $v0, $0, 11
	syscall			#space

	addi $v0, $0, 4
	la $a0, rmantissa
	syscall			#print mantissa


	
	
		
	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline	
	syscall


	addi $a0, $0, 10
	addi $v0, $0, 11
	syscall			#print newline	
	
	addi $v0, $0, 4
	la $a0, comments
	syscall			



#exit
#*********
exit:
	addi $v0, $zero, 10
	syscall	

