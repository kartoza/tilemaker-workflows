let
  # 
  # Note that I am using a snapshot from NixOS unstable here
  # so that we can use a more bleeding edge version which includes the test --ui . 
  # If you want use a different version, go to nix packages search, and find the 
  # github hash of the version you want to be using, then replace in the URL below.
  #
  nixpkgs = builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/4059c4f71b3a7339261c0183e365fd8016f24bdb.tar.gz";
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
in
with pkgs;
mkShell {
  buildInputs = [
    mbtileserver
    osmium-tool
    mapnik
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
    echo "------------------------------------------------------------------"
  '';

}

