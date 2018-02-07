# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)
# System 4

One can run the system 4 using make and the commands specified in the makefile
Namely the most useful are

$ sudo make up
Run system4 locally

$ sudo make run
Run system4 in a Docker network with 1 container per peer

$ sudo make down

(Note: we found sudo necessary in the above commands)
There are further options in the makefile

# Tests
The arguments for the tests are set in the Makefile and are passed as command line arguments to the programs
Namely in the Makefile for system4 you can set
PEERS = 5
MAX_BROADCASTS = 100
TIMEOUT = 3000
LPL_RELIABILITY = 100


Note: If we change the number of peers we need to accordingly change the number of containers in docker-compose.yml if we are intending to use $ make up

We can run the following tests for system4
Explanations and comments for the tests can be found on the report

Example tests:

PEERS = 1
MAX_BROADCASTS = 100
TIMEOUT = 3000
LPL_RELIABILITY = 100

PEERS = 5
MAX_BROADCASTS = 100
TIMEOUT = 0
LPL_RELIABILITY = 100

PEERS = 5
MAX_BROADCASTS = 1000
TIMEOUT = 3000
LPL_RELIABILITY = 50

PEERS = 5
MAX_BROADCASTS = 1000
TIMEOUT = 3000
LPL_RELIABILITY = 100

PEERS = 5
MAX_BROADCASTS = 1000
TIMEOUT = 3000
LPL_RELIABILITY = 0
