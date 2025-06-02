# Rentcast Proxy Makefile

# Docker configuration
DOCKER_IMAGE := rentcast-proxy
DOCKER_TAG := latest
DOCKER_REGISTRY := $(shell if [ -n "$(DOCKER_USERNAME)" ]; then echo "$(DOCKER_USERNAME)/"; fi)

.PHONY: help install build test lint clean docker-build docker-test docker-lint docker-all format

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install Crystal dependencies
	shards install

build: ## Build the application locally
	crystal build src/rentcast-proxy.cr --release

test: ## Run Crystal tests locally
	crystal spec

lint: ## Run ameba linting locally
	./bin/ameba src/

format: ## Format Crystal code
	crystal tool format src/ spec/

clean: ## Clean build artifacts and databases
	rm -f rentcast-proxy *.db *.sqlite *.sqlite3

# Docker commands
docker-build: ## Build Docker image
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .

docker-test: ## Run tests in Docker
	docker build --target builder -t $(DOCKER_IMAGE):test .

docker-lint: ## Run linting in Docker
	docker build --target builder -t $(DOCKER_IMAGE):lint .

docker-integration: ## Run integration tests with Docker
	docker build -t $(DOCKER_IMAGE):integration .
	docker run -d --name rentcast-test -p 3000:3000 -e RENTCAST_API_KEY=test_key $(DOCKER_IMAGE):integration
	sleep 5
	curl -f http://localhost:3000/health || (docker stop rentcast-test && docker rm rentcast-test && exit 1)
	docker stop rentcast-test
	docker rm rentcast-test
	@echo "Integration tests passed!"

docker-all: docker-build docker-test docker-lint ## Build, test, and lint with Docker

docker-push: ## Push Docker image to registry
	@if [ -z "$(DOCKER_USERNAME)" ]; then echo "DOCKER_USERNAME not set"; exit 1; fi
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_REGISTRY)$(DOCKER_IMAGE):$(DOCKER_TAG)
	docker push $(DOCKER_REGISTRY)$(DOCKER_IMAGE):$(DOCKER_TAG)

docker-run: ## Run Docker container locally
	@if [ -z "$(RENTCAST_API_KEY)" ]; then echo "RENTCAST_API_KEY not set"; exit 1; fi
	docker run -p 3000:3000 -e RENTCAST_API_KEY=$(RENTCAST_API_KEY) $(DOCKER_IMAGE):$(DOCKER_TAG)

# Development
dev: ## Run application in development mode
	@if [ -z "$(RENTCAST_API_KEY)" ]; then echo "RENTCAST_API_KEY not set"; exit 1; fi
	crystal run src/rentcast-proxy.cr

watch: ## Watch for changes and rebuild (requires entr)
	find src/ -name "*.cr" | entr -r make dev