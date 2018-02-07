# Panayiotis Panayiotou (pp3414) and Adrian Catana (ac7815)

PEERS = 5
MAX_BROADCASTS = 100
TIMEOUT = 6000
LPL_RELIABILITY = 100

MAIN    = System6.main
MAIN_NET = System6.main_net

PROJECT = da347
NETWORK = $(PROJECT)_network

COMPOSE = docker-compose -p $(PROJECT)

LOCAL	 = mix run --no-halt -e $(MAIN) $(PEERS) $(MAX_BROADCASTS) $(TIMEOUT) $(LPL_RELIABILITY)
COMPOSE  = MAIN=$(MAIN_NET) PEERS=$(PEERS) MAX_BROADCASTS=$(MAX_BROADCASTS) TIMEOUT=$(TIMEOUT) LPL_RELIABILITY=$(LPL_RELIABILITY) docker-compose -p $(PROJECT)

compile:
	mix compile

run:
	$(LOCAL)

clean:
	mix clean

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up

down:
	$(COMPOSE) down
	make show

show:
	@echo ----------------------
	@make ps
	@echo ----------------------
	@make network

show2:
	@echo ----------------------
	@make ps2
	@echo ----------------------
	@make network

ps:
	docker ps -a --format 'table {{.Names}}\t{{.Image}}'

network net:
	docker network ls

inspect:
	docker network inspect $(NETWORK)

netrm:
	docker network rm $(NETWORK)
conrm:
	docker rm $(ID)

done:  # place within an 'if' in ~/.bash_logout
	docker rm -f `docker ps -a -q`
	docker network rm $(NETWORK)
