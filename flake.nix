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
            echo "  ╔══════════════════════════════════════════════════════════════════╗"
            echo "  ║            🗺️  Tilemaker Workflows Development Shell             ║"
            echo "  ╠══════════════════════════════════════════════════════════════════╣"
            echo "  ║                                                                  ║"
            echo "  ║  Quick Start:                                                    ║"
            echo "  ║    nix run .#getData         Download required geodata            ║"
            echo "  ║    nix run .#processMalta    Generate Malta vector tiles           ║"
            echo "  ║    nix run .#processPlanet   Generate planet vector tiles          ║"
            echo "  ║    nix run .#coastline       Generate coastline tiles              ║"
            echo "  ║    nix run .#serve           Start mbtileserver on :8000           ║"
            echo "  ║    nix run .#maputnik        Launch Maputnik style editor          ║"
            echo "  ║                                                                  ║"
            echo "  ║  Development:                                                    ║"
            echo "  ║    nix run .#lint            Run shellcheck + luacheck             ║"
            echo "  ║    nix fmt                   Format nix files                     ║"
            echo "  ║    pre-commit run -a         Run all pre-commit hooks              ║"
            echo "  ║                                                                  ║"
            echo "  ║  Neovim: <leader>p           Project command menu                 ║"
            echo "  ║  Docs:   README.md           Full workflow documentation          ║"
            echo "  ║  Tiles:  http://localhost:8000/services/ (when serving)           ║"
            echo "  ║                                                                  ║"
            echo "  ║  Made with 💗 by Kartoza — https://kartoza.com                   ║"
            echo "  ╚══════════════════════════════════════════════════════════════════╝"
            echo ""
          '';
        };

        apps = {
          getData = mkApp "get-data" (with pkgs; [
            curl
            unzip
            coreutils
          ]) (builtins.readFile ./get_data.sh);

          processMalta = mkApp "process-malta" (with pkgs; [
            tilemaker
            curl
          ]) (builtins.readFile ./process_malta.sh);

          processPlanet = mkApp "process-planet" (with pkgs; [
            tilemaker
            osmium-tool
            curl
            coreutils
          ]) (builtins.readFile ./process_planet.sh);

          serve = mkApp "serve" [ pkgs.mbtileserver ] (builtins.readFile ./run_server.sh);

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
                time tilemaker --output "${OUTPUT_DIR}/coastline.mbtiles" \
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
            echo "  nix run .#getData         Download required geodata"
            echo "  nix run .#processMalta    Generate Malta vector tiles"
            echo "  nix run .#processPlanet   Generate planet vector tiles"
            echo "  nix run .#coastline       Generate coastline tiles"
            echo "  nix run .#serve           Start mbtileserver"
            echo "  nix run .#maputnik        Launch Maputnik style editor"
            echo "  nix run .#lint            Run linters"
            echo ""
            echo "Enter the dev shell with: nix develop"
            echo ""
          '';
        };
      }
    );
}
