# all numbers in hex format
# we always start by reset signal
# this is a commented line
.ORG 0  #this means the the following line would be  at address  0 , and this is the reset address
FF
#you should ignore empty lines

.ORG 1  #this hw interrupt handler
100

.ORG 2  #this is int 0
200

.ORG 3  #this is int 1
250

.ORG FF
IADD R1, R0, 7
IADD R2, R0, 3
IADD R3, R0, 10
IADD R4, R0, 15
SWAP R1, R2
SWAP R2, R1
SWAP R3, R4
SWAP R4, R3