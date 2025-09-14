.PHONY: all build up down

all:
	cd ./srcs && docker compose up --build -d

build:
	cd ./srcs && docker compose build

up:
	cd ./srcs && docker compose up -d

down:
	cd ./srcs && docker compose down