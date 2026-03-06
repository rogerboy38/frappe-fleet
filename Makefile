# Makefile for Frappe Fleet Management System
# ============================================

.PHONY: help up down restart logs status logs-backend logs-web logs-db shell-backend shell-db rebuild clean install-fleet

# Default values
export $(shell cat .env | xargs)

help:
	@echo "Frappe Fleet Management System - Make Commands"
	@echo "================================================"
	@echo "  make up          - Start all containers"
	@echo "  make down        - Stop all containers"
	@echo "  make restart     - Restart all containers"
	@echo "  make logs        - View all logs"
	@echo "  make status      - Show container status"
	@echo "  make shell       - Access Frappe backend container"
	@echo "  make shell-db    - Access MariaDB container"
	@echo "  make install-fleet - Run Fleet Management installer"
	@echo "  make rebuild     - Rebuild and start containers"
	@echo "  make clean       - Remove all containers and volumes"

up:
	@echo "Starting Frappe Fleet Management System..."
	docker compose up -d
	@echo "Waiting for services to be ready..."
	sleep 10
	@echo "Services started! Check with: make status"

down:
	@echo "Stopping Frappe Fleet Management System..."
	docker compose down

restart:
	@echo "Restarting Frappe Fleet Management System..."
	docker compose restart

logs:
	docker compose logs -f

status:
	docker compose ps

shell:
	docker exec -it frappe_backend bash

shell-db:
	docker exec -it frappe_mariadb mysql -u root -p

install-fleet:
	@echo "Installing Fleet Management System..."
	bash install-fleet-app.sh

rebuild:
	docker compose down
	docker compose build --no-cache
	docker compose up -d

clean:
	docker compose down -v
	@echo "All data removed! Be careful - this deletes all databases!"
