# WordPress Multi-App Manager Makefile with Pipeline Generation

.PHONY: help list-apps create-app create-pipeline create-all-pipelines

help: ## Show this help
	@echo "WordPress Multi-Application Manager with Pipeline Generation"
	@echo "==========================================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

list-apps: ## List all WordPress applications
	@echo "📱 Available WordPress Applications:"
	@if [ -d "apps" ]; then \
		for app in apps/*/; do \
			if [ -d "$$app" ]; then \
				app_name=$$(basename "$$app"); \
				pipeline_file="pipelines/$${app_name}-pipeline.yml"; \
				if [ -f "$$pipeline_file" ]; then \
					echo "  🔹 $$app_name (✅ Pipeline ready)"; \
				else \
					echo "  🔹 $$app_name (❌ No pipeline)"; \
				fi; \
			fi; \
		done; \
	else \
		echo "  No applications found. Use 'make create-app' to create one."; \
	fi

create-app: ## Create new WordPress app with pipeline (usage: make create-app NAME=myapp PORT=4000 USER=deployuser)
	@if [ -z "$(NAME)" ] || [ -z "$(PORT)" ]; then \
		echo "❌ Usage: make create-app NAME=myapp PORT=4000 [USER=deployuser]"; \
		echo "   Example: make create-app NAME=ecommerce PORT=4000 USER=deployuser"; \
		exit 1; \
	fi
	./scripts/create-app.sh $(NAME) $(PORT) $(USER)

create-pipeline: ## Create pipeline for existing app (usage: make create-pipeline NAME=myapp USER=deployuser)
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Usage: make create-pipeline NAME=myapp [USER=deployuser]"; \
		echo "   Example: make create-pipeline NAME=ecommerce USER=deployuser"; \
		exit 1; \
	fi
	./scripts/create-pipeline.sh $(NAME) $(USER)

create-all-pipelines: ## Create pipelines for all existing apps
	@echo "🚀 Creating pipelines for all applications..."
	@if [ -d "apps" ]; then \
		for app in apps/*/; do \
			if [ -d "$$app" ]; then \
				app_name=$$(basename "$$app"); \
				pipeline_file="pipelines/$${app_name}-pipeline.yml"; \
				if [ ! -f "$$pipeline_file" ]; then \
					echo "  Creating pipeline for $$app_name..."; \
					./scripts/create-pipeline.sh $$app_name $(USER); \
				else \
					echo "  Pipeline already exists for $$app_name"; \
				fi; \
			fi; \
		done; \
	else \
		echo "  No applications found."; \
	fi

list-pipelines: ## List all generated pipelines
	@echo "🚀 Generated Azure DevOps Pipelines:"
	@if [ -d "pipelines" ]; then \
		for pipeline in pipelines/*-pipeline.yml; do \
			if [ -f "$$pipeline" ]; then \
				pipeline_name=$$(basename "$$pipeline" -pipeline.yml); \
				app_name=$$(echo "$$pipeline_name" | sed 's/-pipeline//'); \
				if [ -d "apps/$$app_name" ]; then \
					echo "  🔹 $$pipeline_name (✅ App exists)"; \
				else \
					echo "  🔹 $$pipeline_name (❌ App missing)"; \
				fi; \
			fi; \
		done; \
	else \
		echo "  No pipelines found. Use 'make create-pipeline' to create one."; \
	fi

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
				sleep 5; \
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

# Quick setup commands with pipelines
quick-ecommerce: ## Quick setup for e-commerce site with pipeline
	make create-app NAME=ecommerce PORT=4000 USER=deployuser
	@echo "✅ E-commerce site with pipeline created!"

quick-blog: ## Quick setup for blog site with pipeline
	make create-app NAME=blog PORT=4010 USER=deployuser
	@echo "✅ Blog site with pipeline created!"

quick-corporate: ## Quick setup for corporate site with pipeline
	make create-app NAME=corporate PORT=4020 USER=deployuser
	@echo "✅ Corporate site with pipeline created!"

# Pipeline management
regenerate-pipeline: ## Regenerate pipeline for existing app (usage: make regenerate-pipeline NAME=myapp)
	@if [ -z "$(NAME)" ]; then \
		echo "❌ Usage: make regenerate-pipeline NAME=myapp [USER=deployuser]"; \
		exit 1; \
	fi
	@if [ -f "pipelines/$(NAME)-pipeline.yml" ]; then \
		echo "🔄 Regenerating pipeline for $(NAME)..."; \
		rm -f "pipelines/$(NAME)-pipeline.yml"; \
		./scripts/create-pipeline.sh $(NAME) $(USER); \
	else \
		echo "❌ Pipeline for $(NAME) not found. Creating new one..."; \
		./scripts/create-pipeline.sh $(NAME) $(USER); \
	fi

validate-pipelines: ## Validate all pipeline files exist for apps
	@echo "🔍 Validating pipeline configuration..."
	@missing_pipelines=0; \
	if [ -d "apps" ]; then \
		for app in apps/*/; do \
			if [ -d "$$app" ]; then \
				app_name=$$(basename "$$app"); \
				pipeline_file="pipelines/$${app_name}-pipeline.yml"; \
				if [ ! -f "$$pipeline_file" ]; then \
					echo "  ❌ Missing pipeline: $$app_name"; \
					missing_pipelines=$$((missing_pipelines + 1)); \
				else \
					echo "  ✅ Pipeline exists: $$app_name"; \
				fi; \
			fi; \
		done; \
		if [ $$missing_pipelines -gt 0 ]; then \
			echo ""; \
			echo "🔧 Fix missing pipelines with: make create-all-pipelines"; \
		else \
			echo ""; \
			echo "✅ All applications have pipelines!"; \
		fi; \
	fi

# System maintenance
clean-pipelines: ## Remove all generated pipeline files
	@echo "🧹 Cleaning up pipeline files..."
	@if [ -d "pipelines" ]; then \
		rm -f pipelines/*-pipeline.yml; \
		rm -f pipelines/*-ssh-setup.md; \
		echo "✅ Pipeline files cleaned up"; \
	else \
		echo "  No pipeline files to clean"; \
	fi

info: ## Show system information including pipelines
	@echo "ℹ️ WordPress Multi-App Manager Information"
	@echo "========================================"
	@echo ""
	@echo "📱 Applications:"
	@make list-apps
	@echo ""
	@echo "🚀 Pipelines:"
	@make list-pipelines
	@echo ""
	@echo "🐳 Docker Status:"
	@docker --version
	@docker compose version