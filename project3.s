# this program uses the third approach to re-implement project 2 i.e processing the user input in a subprogram and using registers only for parameters and return values.
.data
user_input: .space 11000
input_value_empty: .asciiz "Input is empty."
input_value_invalid: .asciiz "Invalid base-27 number."
input_too_long: .asciiz "Input is too long."

.text
main:
li $v0, 8                                   #  syscall code to get user input
la $a0, user_input                          #  loading byte space into address
li $a1, 11000                               #  allocating byte space for input string
syscall
move $t8, $a0                               #  keeping the copy of string in other register
move $t0, $a0                               #  move string to t0

if_input_empty:
lb $a0, 0($t0)
beq $a0, 10, input_is_empty
j loop                                      #  if it is not empty, go through the loop

input_is_empty:
li $v0, 4                                   #  system call code to print string
la $a0, input_value_empty                   # load address of string to be printed into $a0
syscall
j exit                                      #  exit if it is an empty string

li $s2, -1                                  # checks the validity of the program
li $s3, 0                                   # keeps track of length of valid characters
li $t1, 0                                   #  initializing $t1 to zero to later find the length of chars in string
li $t3, 0                                   #  to count spaces.
li $t4, -20                                 #  initializing $t4 to -20, when a character is found, $t4 is set to 1

loop:
lb $a0, 0($t0)
beq $a0, 10, calculate_value                # last char of the string is line feed. If keyword 'enter' is pressed, it starts conversion.

addi $t0, $t0, 1                            #  shifing the pointer by one byte

slti $t2, $a0, 114                          # $t2=1 if $a0 < 114 which is the ascii value of upper limit of valid character q
beq $t2, $zero, char_invalid

beq $a0, 32, space_found                    #  skip the space
slti $t2, $a0, 48                           # $t2 = 1 if the character  $a0 is less than 48
bne $t2, $zero, char_invalid
slti $t2, $a0, 58                           # $t2 = 1 if the character $a0 is less than 58
bne $t2, $zero, char_is_digit
slti $t2, $a0, 65                           #  if $a0 is less than 65 at this point, $t2 = 1. This checks if the values lie between the invalid characters between upper and lower case values
bne $t2, $zero, char_invalid
slti $t2, $a0, 82                           #  if $a0 is less than 82, the character chosen is in uppercase which is handled in label upper case
bne $t2, $zero, char_is_upper
slti $t2, $a0, 97                           #  if $a0 is less than 97, $t2 = 1, which helps to check the validity of character as 97 is the lower limit for valid lower case letters
bne $t2, $zero, char_invalid
slti $t2, $a0, 114                          # sets $t2 = 1 if $a0 is less than 114 which is the range for lower case value for the valid character
bne $t2, $zero, char_is_lower
j loop

increase_space_count:
addi $t3, $t3, 1                             # increase the space count by one after the non-space character is seen
j loop

space_found:
beq $t1, 0, loop                            #  skips the spaces until it finds first non-space character
beq $t4, 1, space_after_valid_char          #  if a valid char is previously seen
beq $t4, 0, increase_space_count
j loop

space_after_valid_char:
li $t4, 0
addi $t3, $t3, 1                            # increase the space counter
j loop

char_invalid:
li $s2, -1
addi $t1, $t1, 1                            #  increase the character count
bne $t1, 1, check_previous_char             #  if more than one valid characters are present, check if previous character is correct
li $t4, 1                                   # if first valid char is seen
j loop

char_is_lower:
addi $s3, $s3, 1                            #  increase valid character counter
addi $t1, $t1, 1                            #  increase character counter
bne $t1, 1, check_previous_char
li $t4, 1
j loop

too_long:
li $v0, 4                                   #  system call code for printing string
la $a0, input_too_long                      # load the message of stored in variable input_too_long
syscall
j exit

char_is_digit:
addi $s3, $s3, 1                            #  increase the valid character count
addi $t1, $t1, 1                            #  increase character count
bne $t1, 1, check_previous_char             #  if valid char occered for multiple occurences check all prev char to be valid
li $t4, 1                                   # only set if first valid char is seen
j loop


char_is_upper:
addi $s3, $s3, 1                            #  increase valid character counter
addi $t1, $t1, 1                            #  increase character counter
bne $t1, 1, check_previous_char
li $t4, 1
j loop

check_previous_char:
beq $t4, 0, there_is_space_in_between       # if there is space between valid characters
j loop

invalid_value:
li $v0, 4                                   #  system call code for printing string
la $a0, input_value_invalid
syscall
j exit

there_is_space_in_between:
li $s2, -1
add $t1, $t1, $t3                           # length here equals the total number of length plus the spaces
li $t3, 0                                   # setting the space counter back to zero
li $t4, 1                                   # assuming the space between valid character is found
j loop

calculate_value:
li $a1, 27                                  #  loading the base
li $a2, 19683                               #  highest possible value for the most significant bit for base-27
li $a3, 4                                   #  maximum possible length of valid string
li $t7, 0                                   #  register to store the conversion sum
move $t0, $t8                               #  move the string again to $t0 for fresh calculation

beq $t1, 0, input_is_empty                  #  string only has spaces
slti $t2, $t1, 5                            #  checking the validity of the string length which can't be more than 4
beq $t2, $zero, too_long                    #  too long to handle

beq $s2, -1, invalid_value                  #  if spaces between valid chars of required length

slti $t2, $s3, 4                            #  check if padding of the input is required. for instance, if user enters "ab" it needs to make sure to make it "00ab" for calculation"
bne $t2, $zero, adding_zero_in_front

loop_for_conversion:
lb $a0, 0($t0)
beq $a0, 10, print_decimal_value            # last char is line feed ($a0 = 10) so exit the loop and start conversion

addi $t0, $t0, 1                            #  shifing the pointer right by one byte

slti $t2, $a0, 114                          # checking the validity of character for range 0 to 113 else elminating the invalid possibilities with values greater than 113
beq $t2, $zero, char_invalid
beq $a0, 32, loop_for_conversion            # ignoring the space character and going back to the loop
slti $t2, $a0, 48                           # setting the value of $t2 to 1 if the character is less than 48 which is invalid character limit
bne $t2, $zero, char_invalid
slti $t2, $a0, 58                           #  setting the value of $t2 to 1 if the value is less than 58 i.e 48 to 57
bne $t2, $zero, conversion_of_digit
slti $t2, $a0, 65                           #  if  $a0 is less than 65, $t2 is set to 1 which includes the invalid range of characters of ASCII value 58 to 67
bne $t2, $zero, char_invalid
slti $t2, $a0, 82                           #  if $a0 is less than 82, $t2 is set to 1 which includes the valid range of 65 to 81
bne $t2, $zero, conversion_of_upper_case
slti $t2, $a0, 97                           #  if $a0 is less than 97, $t2 is set to 1 which includes the invalid range of 82 to 96
bne $t2, $zero, char_invalid
slti $t2, $a0, 114                          #if $a0 is less than 114, $t2 is set to 1 which includes the valid range of 97 to 113
bne $t2, $zero, conversion_of_lower_case

j loop_for_conversion

conversion_of_digit:
addi $a0, $a0, -48                          #  conversion of ascii value to base-27
mult $a0, $a2                               # a2 = 27^n
mflo $t9
add $t7, $t7, $t9                           #  adding the sum for each bit multiplication and storing it to $t7
div $a2, $a1
mflo $a2                                    #  reducing n by 1 to make 27^n to 27^(n-1) by dividing the highest possible value of most significant bit of 27 i.e 19683 by 27
j loop_for_conversion

conversion_of_upper_case:
addi $a0, $a0, -55                          # for instance, we have to convert A's value to 10 but its ascii value is 65 so we subtract 55 to get 10
mult $a0, $a2                               #a2 = 27^n
mflo $t9
add $t7, $t7, $t9                           #  adding the sum for each bit multiplication and storing it to $t7
div $a2, $a1
mflo $a2                                    #  reducing n by 1 to make 27^n to 27^(n-1)
j loop_for_conversion

conversion_of_lower_case:
addi $a0, $a0, -87
mult $a0, $a2                               #a2 = 27^n
mflo $t9
add $t7, $t7, $t9                           #  adding the sum for each bit multiplication and storing it to $t7
div $a2, $a1
mflo $a2                                    #  reducing n by 1 to make 27^n to 27^(n-1)
j loop_for_conversion

adding_zero_in_front:
sub $t5, $a3, $t1                          # difference between the length of string and the valid length required
zero_adding_loop:
beq $t5, 0, loop_for_conversion
addi $t5, $t5, -1
div $a2, $a1
mflo $a2
j zero_adding_loop

too_long:
li $v0, 4                                   #  system call code for printing string
la $a0, input_too_long                      # load the message of stored in variable input_too_long
syscall
j exit

print_decimal_value:
li $v0, 1                                   # syscall code to print integer
addi $a0, $t7, 0                            # print the total sum
syscall

exit:
li $v0, 10                                  # end the program
syscall

