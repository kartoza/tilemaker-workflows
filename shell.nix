let
  # 
  # Note that I am using a snapshot from NixOS unstable here
  # so that we can use a more bleeding edge version which includes the test --ui . 
  # If you want use a different version, go to nix packages search, and find the 
  # github hash of the version you want to be using, then replace in the URL below.
  #
  nixpkgs = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/e0da498ad77ac8909a980f07eff060862417ccf7.tar.gz";
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
in
with pkgs;
mkShell {
  buildInputs = [
    tilemaker
    mbtileserver
    osmium-tool
    mapnik
    nodejs
    vim
    unzip
    wget
  ];

  # DIRENV_LOG_FORMAT to reduce direnv verbosity
  # See https://github.com/direnv/direnv/issues/68#issuecomment-162639262
  shellHook = ''
    export DIRENV_LOG_FORMAT=""
    echo "------------------------------------------------------------------"
    echo "You can serve any tilesets in this folder by running this command:"
    echo "💻️ mbtileserver -d ."
    echo "Then you can find the tiles here:"
    echo "🔗 http://localhost:8000/services/"
    echo "📒 Please see the README.md"
    echo "------------------------------------------------------------------"
  '';

}

