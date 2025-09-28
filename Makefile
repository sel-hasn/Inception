.PHONY: build up down

DATA_DIRS = /home/sel-hasn/data/wordpress /home/sel-hasn/data/mariadb

$(DATA_DIRS):
	mkdir -p $@

build: $(DATA_DIRS)
	cd srcs && docker compose build

up: $(DATA_DIRS)
	cd srcs && docker compose up --build -d

down:
	cd srcs && docker compose down