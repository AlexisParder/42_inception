GREEN	= \033[0;32m
BLUE	= \033[0;34m
YELLOW	= \033[0;33m
RED		= \033[0;31m
RESET	= \033[0m

include ./srcs/.env

export HOST_IP := $(shell ip route get 1.1.1.1 | awk '{print $$7; exit}')

BANNER = \
"\n $(RESET)██$(RED)╗$(RESET)███$(RED)╗   $(RESET)██$(RED)╗ $(RESET)██████$(RED)╗$(RESET)███████$(RED)╗$(RESET)██████$(RED)╗ $(RESET)████████$(RED)╗$(RESET)██$(RED)╗ $(RESET)██████$(RED)╗ $(RESET)███$(RED)╗   $(RESET)██$(RED)╗ $(RESET)\n" \
"$(RESET)██$(RED)║$(RESET)████$(RED)╗  $(RESET)██$(RED)║$(RESET)██$(RED)╔════╝$(RESET)██$(RED)╔════╝$(RESET)██$(RED)╔══$(RESET)██$(RED)╗╚══$(RESET)██$(RED)╔══╝$(RESET)██$(RED)║$(RESET)██$(RED)╔═══$(RESET)██$(RED)╗$(RESET)████$(RED)╗  $(RESET)██$(RED)║ $(RESET)\n" \
"$(RESET)██$(RED)║$(RESET)██$(RED)╔$(RESET)██$(RED)╗ $(RESET)██$(RED)║$(RESET)██$(RED)║     $(RESET)█████$(RED)╗  $(RESET)██████$(RED)╔╝   $(RESET)██$(RED)║   $(RESET)██$(RED)║$(RESET)██$(RED)║   $(RESET)██$(RED)║$(RESET)██$(RED)╔$(RESET)██$(RED)╗ $(RESET)██$(RED)║ $(RESET)\n" \
"$(RESET)██$(RED)║$(RESET)██$(RED)║╚$(RESET)██$(RED)╗$(RESET)██$(RED)║$(RESET)██$(RED)║     $(RESET)██$(RED)╔══╝  $(RESET)██$(RED)╔═══╝    $(RESET)██$(RED)║   $(RESET)██$(RED)║$(RESET)██$(RED)║   $(RESET)██$(RED)║$(RESET)██$(RED)║╚$(RESET)██$(RED)╗$(RESET)██$(RED)║ $(RESET)\n" \
"$(RESET)██$(RED)║$(RESET)██$(RED)║ ╚$(RESET)████$(RED)║╚$(RESET)██████$(RED)╗$(RESET)███████$(RED)╗$(RESET)██$(RED)║        $(RESET)██$(RED)║   $(RESET)██$(RED)║╚$(RESET)██████$(RED)╔╝$(RESET)██$(RED)║ ╚$(RESET)████$(RED)║ $(RESET)\n" \
"$(RED)╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝ $(RESET)\n"

all: banner
	@mkdir -p /home/$(LOGIN)/data
	@mkdir -p /home/$(LOGIN)/data/mariadb
	@mkdir -p /home/$(LOGIN)/data/wordpress
	@mkdir -p /home/$(LOGIN)/data/backup_mariadb
	@docker compose -f ./srcs/docker-compose.yml up -d

build:
	@mkdir -p /home/$(LOGIN)/data
	@mkdir -p /home/$(LOGIN)/data/mariadb
	@mkdir -p /home/$(LOGIN)/data/wordpress
	@mkdir -p /home/$(LOGIN)/data/backup_mariadb
	@docker compose -f ./srcs/docker-compose.yml up -d --build

banner:
	@echo $(BANNER)

down:
	@docker compose -f ./srcs/docker-compose.yml down

clean:
	@docker compose -f ./srcs/docker-compose.yml down -v
	@sudo rm -rf /home/$(LOGIN)/data

fclean: clean
	@docker system prune -af

re: fclean all

.PHONY: all clean fclean re down build
