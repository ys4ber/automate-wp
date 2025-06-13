# Makefile for c
APP_NAME=c

.PHONY: start stop restart logs shell wp-shell db-shell backup setup status

start: ## Start this WordPress app
	docker compose up -d

stop: ## Stop this WordPress app
	docker compose down

restart: ## Restart this WordPress app
	docker compose restart

logs: ## Show logs
	docker compose logs -f

shell: ## Access WordPress container shell
	docker compose exec wordpress bash

wp-shell: ## Access WP-CLI
	docker compose run --rm wpcli bash

db-shell: ## Access database shell
	docker compose exec database mysql -u root -p0fi0V6MWxDZ4cQA0

backup: ## Create backup
	mkdir -p backups
	docker compose exec -T database mysqldump -u root -p0fi0V6MWxDZ4cQA0 c_db > backups/c_$(shell date +%Y%m%d_%H%M%S).sql

setup: ## Setup WordPress
	docker compose up -d
	sleep 15
	docker compose run --rm wpcli core download || true
	docker compose run --rm wpcli config create --dbname=c_db --dbuser=c_user --dbpass=rNme28LSCYWtepYm --dbhost=database:3306 --force || true
	docker compose run --rm wpcli core install --url=http://192.99.35.79:4021 --title="c WordPress Site" --admin_user=admin --admin_password=RTpl0tM88f5HBydj --admin_email=admin@c.local || true

status: ## Show container status
	docker compose ps

help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
