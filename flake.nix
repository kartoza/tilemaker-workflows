{
  description = "Tilemaker Workflows — OpenMapTiles-compliant vector tile generation from OpenStreetMap";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tailor = {
      url = "github:wimpysworld/tailor";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      git-hooks,
      tailor,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Tailor may not be available on all systems
        tailorPkg =
          if builtins.hasAttr system tailor.packages then [ tailor.packages.${system}.default ] else [ ];

        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Shell scripts
            shellcheck = {
              enable = true;
              excludes = [ "maputnik/" ];
            };
            # Nix formatting
            nixfmt-rfc-style.enable = true;
            # Lua linting
            luacheck.enable = true;
            # General hygiene
            trim-trailing-whitespace = {
              enable = true;
              excludes = [
                "landcover/"
                "img/"
                "maputnik/"
              ];
            };
            end-of-file-fixer = {
              enable = true;
              excludes = [
                "landcover/"
                "img/"
                "maputnik/"
              ];
            };
            check-added-large-files.enable = true;
          };
        };

        # Runtime dependencies shared between devShell and apps
        coreDeps = with pkgs; [
          tilemaker
          mbtileserver
          osmium-tool
          curl
          unzip
          wget
        ];

        # Helper to create nix run apps
        mkApp =
          name: runtimeInputs: text:
          flake-utils.lib.mkApp {
            drv = pkgs.writeShellApplication {
              inherit name runtimeInputs;
              text = text;
            };
          };

        # Static assets bundled into the Docker image (only git-tracked files)
        staticDir = pkgs.runCommand "tilemaker-static" { } ''
          mkdir -p $out/styles
          cp ${./viewer.html} $out/viewer.html
          cp ${./styles}/*.json $out/styles/
        '';

        # Nginx config
        nginxConf = pkgs.runCommand "nginx-conf" { } ''
          mkdir -p $out/etc/nginx
          cp ${./nginx.conf} $out/etc/nginx/nginx.conf
          cp ${pkgs.nginx}/conf/mime.types $out/etc/nginx/mime.types
        '';

        # Entrypoint script for Docker
        entrypoint = pkgs.writeShellApplication {
          name = "tilemaker-entrypoint";
          runtimeInputs = [
            pkgs.mbtileserver
            pkgs.nginx
            pkgs.findutils
          ];
          text = builtins.readFile ./docker-entrypoint.sh;
        };

        # Docker base image built via Nix (styles + viewer bundled, fonts added by buildDocker)
        dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "tilemaker-server-base";
          tag = "latest";
          contents = [
            pkgs.mbtileserver
            pkgs.nginx
            pkgs.bashInteractive
            pkgs.coreutils
            pkgs.findutils
            nginxConf
            entrypoint
          ];
          extraCommands = ''
            mkdir -p static data tmp var/log/nginx etc
            cp -r ${staticDir}/* static/
            echo "root:x:0:0:root:/root:/bin/bash" > etc/passwd
            echo "nobody:x:65534:65534:nobody:/nonexistent:/bin/false" >> etc/passwd
            echo "root:x:0:" > etc/group
            echo "nobody:x:65534:" >> etc/group
            echo "nogroup:x:65533:" >> etc/group
          '';
          config = {
            Cmd = [ "${entrypoint}/bin/tilemaker-entrypoint" ];
            ExposedPorts = {
              "80/tcp" = { };
            };
            Volumes = {
              "/data" = { };
            };
            WorkingDir = "/";
          };
        };

      in
      {
        checks = {
          inherit pre-commit-check;
        };

        formatter = pkgs.nixfmt;

        packages.dockerImage = dockerImage;

        devShells.default = pkgs.mkShell {
          buildInputs =
            coreDeps
            ++ (with pkgs; [
              mapnik
              nginx
              nodejs
              git
              byobu
              gotop
              jq

              # Linting & formatting
              shellcheck
              luajitPackages.luacheck
              nixfmt
            ])
            ++ tailorPkg
            ++ pre-commit-check.enabledPackages;

          shellHook = ''
            ${pre-commit-check.shellHook}
            export DIRENV_LOG_FORMAT=""

            echo ""
            echo "  ╔══════════════════════════════════════════════════════════════════════╗"
            echo "  ║              🗺️  Tilemaker Workflows Development Shell               ║"
            echo "  ╠══════════════════════════════════════════════════════════════════════╣"
            echo "  ║                                                                      ║"
            echo "  ║  Generate & Serve:                                                   ║"
            echo "  ║    nix run .#getData         Download required geodata                ║"
            echo "  ║    nix run .#processMalta    Generate Malta vector tiles               ║"
            echo "  ║    nix run .#processPlanet   Generate planet vector tiles              ║"
            echo "  ║    nix run .#coastline       Generate coastline tiles                  ║"
            echo "  ║    nix run .#serve           Start tile server on :8080                ║"
            echo "  ║    nix run .#stopServe       Stop all running tile servers              ║"
            echo "  ║    nix run .#maputnik        Launch Maputnik style editor              ║"
            echo "  ║                                                                      ║"
            echo "  ║  Docker:                                                               ║"
            echo "  ║    make build-docker         Build Nix-based Docker image                ║"
            echo "  ║    docker compose up         Run tile server container                   ║"
            echo "  ║                                                                      ║"
            echo "  ║  View Tiles (local: :8080, docker: :8080):                           ║"
            echo "  ║    Web viewer    http://localhost:8080/viewer.html                    ║"
            echo "  ║    TileJSON      http://localhost:8080/services/                      ║"
            echo "  ║    QGIS Tiles    http://localhost:8080/services/planet/tiles/...      ║"
            echo "  ║    Styles        http://localhost:8080/styles/classic.json            ║"
            echo "  ║                                                                      ║"
            echo "  ║  Development:                                                        ║"
            echo "  ║    nix run .#lint            Run shellcheck + luacheck                 ║"
            echo "  ║    nix fmt                   Format nix files                         ║"
            echo "  ║    pre-commit run -a         Run all pre-commit hooks                  ║"
            echo "  ║    Neovim: <leader>p         Project command menu                     ║"
            echo "  ║  Help:                                                               ║"
            echo "  ║    make help                   Show all available commands            ║"
            echo "  ║                                                                      ║"
            echo "  ║  Made with 💗 by Kartoza — https://kartoza.com                       ║"
            echo "  ╚══════════════════════════════════════════════════════════════════════╝"
            echo ""
          '';
        };

        apps = {
          getData = mkApp "get-data" (with pkgs; [
            curl
            unzip
            coreutils
            python3
            nodejs
          ]) (builtins.readFile ./get_data.sh);

          processMalta = mkApp "process-malta" (with pkgs; [
            tilemaker
            curl
          ]) (builtins.readFile ./process_malta.sh);

          processSouthAfrica = mkApp "process-south-africa" (with pkgs; [
            tilemaker
            curl
          ]) (builtins.readFile ./process_south_africa.sh);

          processPlanet = mkApp "process-planet" (with pkgs; [
            tilemaker
            osmium-tool
            curl
            coreutils
          ]) (builtins.readFile ./process_planet.sh);

          serve = mkApp "serve" (with pkgs; [
            mbtileserver
            nginx
          ]) (builtins.readFile ./run_server.sh);

          stopServe = mkApp "stop-serve" [ pkgs.procps ] (builtins.readFile ./stop_server.sh);

          maputnik = mkApp "maputnik" (with pkgs; [
            git
            nodejs
          ]) (builtins.readFile ./run_maputnik_editor.sh);

          coastline =
            mkApp "coastline"
              (with pkgs; [
                tilemaker
                curl
                unzip
                coreutils
              ])
              ''
                #!/usr/bin/env bash
                source ./common.sh
                ensure_geodata
                echo "Generating coastline tiles..."
                time tilemaker --output "''${OUTPUT_DIR}/coastline.mbtiles" \
                  --bbox -180,-85,180,85 \
                  --process process-coastline.lua \
                  --config config-coastline.json
                echo "Done! Output: ''${OUTPUT_DIR}/coastline.mbtiles"
              '';

          lint =
            mkApp "lint"
              (with pkgs; [
                shellcheck
                luajitPackages.luacheck
              ])
              ''
                #!/usr/bin/env bash
                echo "🔍 Running shellcheck on shell scripts..."
                shellcheck ./*.sh
                echo "✅ shellcheck passed"

                echo ""
                echo "🔍 Running luacheck on Lua scripts..."
                luacheck ./*.lua --config .luacheckrc
                echo "✅ luacheck passed"

                echo ""
                echo "🎉 All checks passed!"
              '';

          default = mkApp "tilemaker-help" [ ] ''
            #!/usr/bin/env bash
            echo ""
            echo "Tilemaker Workflows — available commands:"
            echo ""
            echo "  Generate & Serve:"
            echo "    nix run .#getData         Download required geodata"
            echo "    nix run .#processMalta    Generate Malta vector tiles"
            echo "    nix run .#processPlanet   Generate planet vector tiles"
            echo "    nix run .#coastline       Generate coastline tiles"
            echo "    nix run .#serve           Start tile server on :8080"
            echo "    nix run .#stopServe       Stop all running tile servers"
            echo "    nix run .#maputnik        Launch Maputnik style editor"
            echo "    nix run .#lint            Run linters"
            echo ""
            echo "  Docker:"
            echo "    make build-docker         Build Nix-based Docker image"
            echo "    docker compose up         Run tile server in Docker"
            echo ""
            echo "  View Tiles (all via single port :8080):"
            echo "    Web viewer:  http://localhost:8080/viewer.html"
            echo "    TileJSON:    http://localhost:8080/services/"
            echo "    Styles:      http://localhost:8080/styles/classic.json"
            echo "    Fonts:       http://localhost:8080/fonts/"
            echo ""
            echo "  QGIS Vector Tiles:"
            echo "    Tile URL:    http://localhost:8080/services/planet/tiles/{z}/{x}/{y}.pbf"
            echo "    Style URL:   http://localhost:8080/styles/classic.json"
            echo ""
            echo "Enter the dev shell with: nix develop"
            echo ""
          '';
        };
      }
    );
}
