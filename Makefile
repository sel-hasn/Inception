all: up

up:
	sudo mkdir -p /home/${USER}/data/mariadb
	sudo mkdir -p /home/${USER}/data/wordpress
	cd srcs && docker compose up -d

build:
	cd srcs && docker compose up --build -d

down:
	cd srcs && docker compose down

clean:
	cd srcs && docker compose down
	docker system prune -af

fclean: clean
	cd srcs && docker compose down --volumes --remove-orphans
	docker system prune --volumes -af
	sudo rm -fr /home/${USER}/data

re: fclean all

.PHONY: up down clean fclean re build