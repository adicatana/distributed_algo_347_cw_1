# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)
# System 1

One can run the system 1 using make and the commands specified in the makefile
Namely the most useful are

$ sudo make up
Run system1 locally

$ sudo make run
Run system1 in a Docker network with 1 container per peer

$ sudo make down

(Note: we found sudo necessary in the above commands)
There are further options in the makefile

# Tests
The arguments for the tests are set in the Makefile and are passed as command line arguments to the programs
Namely in the Makefile for system1 you can set
PEERS = 5
MAX_BROADCASTS = 100
TIMEOUT = 3000

Note: If we change the number of peers we need to accordingly change the number of containers in docker-compose.yml if we are intending to use $ make up

We can run the following tests for system1
Explanations and comments for the tests can be found on the report

Example tests:

PEERS = 1
MAX_BROADCASTS = 100
TIMEOUT = 3000

PEERS = 5
MAX_BROADCASTS = 100
TIMEOUT = 0

PEERS = 5
MAX_BROADCASTS = 1000
TIMEOUT = 3000

PEERS = 5
MAX_BROADCASTS = 10_000_000
TIMEOUT = 6000
