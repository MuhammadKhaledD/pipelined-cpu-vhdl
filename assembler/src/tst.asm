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
IN R1        #add 5 in R1
IN R2        #add 19 in R2
IN R3        #FFFFFFFF
IN R4        #FFFFF320
MOV R3,R5    #R5 = FFFFFFFF , flags no change
ADD R4,R1,R4    #R4= FFFFF325 , C-->0, N-->1, Z-->0
SUB R6,R5,R4    #R6= 00000CDA , C-->0, N-->0,Z-->0 here carry is implemented as borrow, you can implement it as not borrow
AND R4,R7,R4    #R4= 00000000 , C-->no change, N-->0, Z-->1
IADD R2,R2,FFFF #R2= 00010018 (C = 0,N,Z= 0)
SWAP R2, R4
ADD R2,R1,R2    #R2= 5 (C,N,Z= 0)
ADD R6,R4,R2  #R6=0001001D