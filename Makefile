all:

prune:
	docker container prune --force
	docker volume prune --force

build:
	docker-compose build

debug: build
	docker exec --interactive --tty ai4pa-ALL bash

up:
	docker-compose up

clean:
	rm -f *~
