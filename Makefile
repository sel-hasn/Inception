.PHONY: build up down

DATA_DIRS = srcs/data/wordpress srcs/data/mariadb

# Ensure data directories exist
$(DATA_DIRS):
	mkdir -p $@

build: $(DATA_DIRS)
	cd srcs && docker compose build

up: $(DATA_DIRS)
	cd srcs && docker compose up -d

down:
	cd srcs && docker compose down