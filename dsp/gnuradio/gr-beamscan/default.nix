{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  # Specify the packages you want in your shell environment
  buildInputs =
    [ pkgs.gnuradio pkgs.cmake pkgs.boost pkgs.spdlog pkgs.gmp pkgs.volk ];

  PROJECT_ROOT = builtins.toString ./.;

  # Set the environment variables using shellHook
  shellHook = ''
    export PYTHONPATH=$PROJECT_ROOT/build/python:$PYTHONPATH
    export LD_LIBRARY_PATH=$PROJECT_ROOT/build/lib:$LD_LIBRARY_PATH
    export GRC_BLOCKS_PATH=$PROJECT_ROOT/grc:$GRC_BLOCKS_PATH
  '';
}
