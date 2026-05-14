.PHONY: help get-data process-malta process-south-africa process-planet coastline \
       serve stop-serve maputnik lint build-docker docker-up docker-down fmt

help: ## Show this help
	@echo ""
	@echo "  Tilemaker Workflows"
	@echo "  ==================="
	@echo ""
	@echo "  Generate & Serve:"
	@echo "    make get-data              Download required geodata"
	@echo "    make process-malta         Generate Malta vector tiles"
	@echo "    make process-south-africa  Generate South Africa vector tiles"
	@echo "    make process-planet        Generate planet vector tiles"
	@echo "    make coastline             Generate coastline tiles"
	@echo "    make serve                 Start tile server on :8080"
	@echo "    make stop-serve            Stop all running tile servers"
	@echo "    make maputnik              Launch Maputnik style editor"
	@echo ""
	@echo "  Docker:"
	@echo "    make build-docker          Build Nix-based Docker image"
	@echo "    make docker-up             Start tile server container"
	@echo "    make docker-down           Stop tile server container"
	@echo ""
	@echo "  Development:"
	@echo "    make lint                  Run shellcheck + luacheck"
	@echo "    make fmt                   Format nix files"
	@echo ""
	@echo "  View Tiles (all via single port :8080):"
	@echo "    Web viewer:  http://localhost:8080/viewer.html"
	@echo "    TileJSON:    http://localhost:8080/services/"
	@echo "    Styles:      http://localhost:8080/styles/classic.json"
	@echo "    Fonts:       http://localhost:8080/fonts/"
	@echo ""
	@echo "  QGIS Vector Tiles:"
	@echo "    Tile URL:    http://localhost:8080/services/planet/tiles/{z}/{x}/{y}.pbf"
	@echo "    Style URL:   http://localhost:8080/styles/classic.json"
	@echo ""
	@echo "  Made with love by Kartoza -- https://kartoza.com"
	@echo ""

get-data: ## Download required geodata
	nix run .#getData

process-malta: ## Generate Malta vector tiles
	nix run .#processMalta

process-south-africa: ## Generate South Africa vector tiles
	nix run .#processSouthAfrica

process-planet: ## Generate planet vector tiles
	nix run .#processPlanet

coastline: ## Generate coastline tiles
	nix run .#coastline

serve: ## Start tile server on :8080 (nginx + mbtileserver)
	nix run .#serve

stop-serve: ## Stop all running tile servers
	nix run .#stopServe

maputnik: ## Launch Maputnik style editor
	nix run .#maputnik

lint: ## Run shellcheck + luacheck
	nix run .#lint

fmt: ## Format nix files
	nix fmt

build-docker: ## Build Nix-based Docker image
	./build_docker.sh

docker-up: ## Start tile server container
	docker compose up -d
	@PORT=$$(docker compose port tilemaker-server 80 2>/dev/null | cut -d: -f2); \
	echo ""; \
	echo "  Tilemaker Server is running"; \
	echo "  ==========================="; \
	echo ""; \
	echo "  Viewer:    http://localhost:$${PORT}/viewer.html"; \
	echo "  TileJSON:  http://localhost:$${PORT}/services/"; \
	echo "  Styles:    http://localhost:$${PORT}/styles/"; \
	echo "  Fonts:     http://localhost:$${PORT}/fonts/"; \
	echo ""; \
	echo "  Stop with: make docker-down"; \
	echo ""

docker-down: ## Stop tile server container
	docker compose down
