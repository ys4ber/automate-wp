# WordPress Multi-App Manager Makefile

.PHONY: help list-apps create-app start-app stop-app deploy-app backup-app

help: ## Show this help
	@echo "WordPress Multi-Application Manager"
	@echo "=================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

list-apps: ## List all WordPress applications
	@echo "📱 Available WordPress Applications:"
	@if [ -d "apps" ]; then \
		for app in apps/*/; do \
			if [ -d "$$app" ]; then \
				app_name=$$(basename "$$app"); \
				echo "  🔹 $$app_name"; \
			fi; \
		done; \
	else \
		echo "  No applications found. Use 'make create-app' to create one."; \
	fi

create-app: ## Create new WordPress app (usage: make create-app NAME=myapp PORT=4000)
	@if [ -z "$(NAME)" ] || [ -z "$(PORT)" ]; then \
		echo "❌ Usage: make create-app NAME=myapp PORT=4000"; \
		echo "   Example: make create-app NAME=ecommerce PORT=4000"; \
		exit 1; \
	fi
	./scripts/create-app.sh $(NAME) $(PORT)

start-app: ## Start specific app (usage: make start-app NAME=myapp)
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Usage: make start-app NAME=myapp"; \
		exit 1; \
	fi
	./scripts/manage-app.sh start $(NAME)

stop-app: ## Stop specific app (usage: make stop-app NAME=myapp)
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Usage: make stop-app NAME=myapp"; \
		exit 1; \
	fi
	./scripts/manage-app.sh stop $(NAME)

start-all: ## Start all WordPress applications
	@echo "🚀 Starting all WordPress applications..."
	@if [ -d "apps" ]; then \
		for app in apps/*/; do \
			if [ -d "$$app" ]; then \
				app_name=$$(basename "$$app"); \
				echo "  Starting $$app_name..."; \
				cd "$$app" && docker compose up -d && cd ../..; \
				sleep 20; \
			fi; \
		done; \
	else \
		echo "  No applications found."; \
	fi

stop-all: ## Stop all WordPress applications
	@echo "🛑 Stopping all WordPress applications..."
	@if [ -d "apps" ]; then \
		for app in apps/*/; do \
			if [ -d "$$app" ]; then \
				app_name=$$(basename "$$app"); \
				echo "  Stopping $$app_name..."; \
				cd "$$app" && docker compose down && cd ../..; \
			fi; \
		done; \
	else \
		echo "  No applications found."; \
	fi

status-all: ## Show status of all applications
	./scripts/manage-app.sh status

backup-app: ## Backup specific app (usage: make backup-app NAME=myapp)
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Usage: make backup-app NAME=myapp"; \
		exit 1; \
	fi
	./scripts/manage-app.sh backup $(NAME)

deploy-app: ## Deploy specific app (usage: make deploy-app NAME=myapp)
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Usage: make deploy-app NAME=myapp"; \
		exit 1; \
	fi
	./scripts/manage-app.sh deploy $(NAME)

# Quick setup commands
quick-ecommerce: ## Quick setup for e-commerce site
	make create-app NAME=ecommerce PORT=4000
	@echo "✅ E-commerce site created! Run 'cd apps/ecommerce && make start && make setup'"

quick-blog: ## Quick setup for blog site
	make create-app NAME=blog PORT=4010
	@echo "✅ Blog site created! Run 'cd apps/blog && make start && make setup'"

quick-corporate: ## Quick setup for corporate site
	make create-app NAME=corporate PORT=4020
	@echo "✅ Corporate site created! Run 'cd apps/corporate && make start && make setup'"

# System maintenance
system-cleanup: ## Clean up unused Docker resources
	@echo "🧹 Cleaning up Docker system..."
	docker system prune -f
	docker volume prune -f
	docker network prune -f
	@echo "✅ System cleanup completed"

info: ## Show system information
	@echo "ℹ️ WordPress Multi-App Manager Information"
	@echo "========================================"
	@echo ""
	@echo "📱 Applications:"
	@make list-apps
	@echo ""
	@echo "🐳 Docker Status:"
	@docker --version
	@docker compose version


clean:
	@echo "🧹 Cleaning up all applications..."
	@if [ -d "apps" ]; then \
		for app in apps/*/; do \
			if [ -d "$$app" ]; then \
				app_name=$$(basename "$$app"); \
				echo "  Removing $$app_name..."; \
				sudo rm -rf "$$app"; \
			fi; \
		done; \
	else \
		echo "  No applications found."; \
	fi
	@echo "✅ All applications cleaned up"

# Git operations
push:
	@git add . && \
	if [ $$? -eq 0 ]; then \
		git commit -m "auto commit $$(date)" && \
		if [ $$? -eq 0 ]; then \
			git push && \
			if [ $$? -eq 0 ]; then \
				echo "\033[0;32mcommit and push success\033[0m"; \
			else \
				echo "\033[0;31mpush failed\033[0m"; \
			fi \
		else \
			echo "\033[0;31mcommit failed\033[0m"; \
		fi \
	else \
		echo "\033[0;31madd failed\033[0m"; \
	fi