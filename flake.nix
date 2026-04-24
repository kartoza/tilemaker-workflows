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

      in
      {
        checks = {
          inherit pre-commit-check;
        };

        formatter = pkgs.nixfmt;

        devShells.default = pkgs.mkShell {
          buildInputs =
            coreDeps
            ++ (with pkgs; [
              mapnik
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
            echo "  ║    nix run .#serve           Start mbtileserver on :8000               ║"
            echo "  ║    nix run .#stopServe       Stop all running tile servers              ║"
            echo "  ║    nix run .#viewer          Serve web viewer on :8001                 ║"
            echo "  ║    nix run .#maputnik        Launch Maputnik style editor              ║"
            echo "  ║                                                                      ║"
            echo "  ║  View Tiles:                                                         ║"
            echo "  ║    Web viewer    http://localhost:8001/viewer.html                    ║"
            echo "  ║    TileJSON      http://localhost:8000/services/                      ║"
            echo "  ║    QGIS Vector Tiles URL:                                            ║"
            echo "  ║      http://localhost:8000/services/planet/tiles/{z}/{x}/{y}.pbf      ║"
            echo "  ║    QGIS Style URL (any of):                                          ║"
            echo "  ║      http://localhost:8001/styles/classic.json                        ║"
            echo "  ║      http://localhost:8001/styles/neon.json                           ║"
            echo "  ║      http://localhost:8001/styles/muted.json                          ║"
            echo "  ║      http://localhost:8001/styles/african.json                        ║"
            echo "  ║      http://localhost:8001/styles/psychedelic.json                    ║"
            echo "  ║      http://localhost:8001/styles/sketch.json                         ║"
            echo "  ║      http://localhost:8001/styles/kartoza.json                        ║"
            echo "  ║      http://localhost:8001/styles/blueprint.json                      ║"
            echo "  ║      http://localhost:8001/styles/grayscale.json                      ║"
            echo "  ║                                                                      ║"
            echo "  ║  Development:                                                        ║"
            echo "  ║    nix run .#lint            Run shellcheck + luacheck                 ║"
            echo "  ║    nix fmt                   Format nix files                         ║"
            echo "  ║    pre-commit run -a         Run all pre-commit hooks                  ║"
            echo "  ║    Neovim: <leader>p         Project command menu                     ║"
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

          serve = mkApp "serve" [ pkgs.mbtileserver ] (builtins.readFile ./run_server.sh);

          stopServe = mkApp "stop-serve" [ pkgs.procps ] (builtins.readFile ./stop_server.sh);

          viewer = mkApp "viewer" [ pkgs.python3 ] ''
            echo "Opening viewer at http://localhost:8001/viewer.html"
            echo "Make sure mbtileserver is running (nix run .#serve)"
            python3 -m http.server 8001
          '';

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
            echo "    nix run .#serve           Start mbtileserver on :8000"
            echo "    nix run .#stopServe       Stop all running tile servers"
            echo "    nix run .#viewer          Serve web viewer & styles on :8001"
            echo "    nix run .#maputnik        Launch Maputnik style editor"
            echo "    nix run .#lint            Run linters"
            echo ""
            echo "  View Tiles:"
            echo "    Web viewer:  http://localhost:8001/viewer.html"
            echo "    TileJSON:    http://localhost:8000/services/"
            echo ""
            echo "  QGIS Vector Tiles:"
            echo "    Tile URL:    http://localhost:8000/services/planet/tiles/{z}/{x}/{y}.pbf"
            echo "    Style URLs:  http://localhost:8001/styles/classic.json"
            echo "                 http://localhost:8001/styles/{neon,muted,african,psychedelic,sketch,kartoza,blueprint,grayscale}.json"
            echo ""
            echo "  Embed in web pages:"
            echo "    Use any style URL with MapLibre GL JS: new maplibregl.Map({style: URL})"
            echo ""
            echo "Enter the dev shell with: nix develop"
            echo ""
          '';
        };
      }
    );
}
