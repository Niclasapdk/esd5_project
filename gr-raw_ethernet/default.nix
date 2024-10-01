{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  # Specify the packages you want in your shell environment
  buildInputs =
    [ pkgs.gnuradio pkgs.cmake pkgs.boost pkgs.spdlog pkgs.gmp pkgs.volk ];

  # Set the environment variables using shellHook
  shellHook = ''
    export PYTHONPATH=/home/markus/uni/esd5_project/gr-raw_ethernet/build/python:$PYTHONPATH
    export LD_LIBRARY_PATH=/home/markus/uni/esd5_project/gr-raw_ethernet/build/lib:$LD_LIBRARY_PATH
    export GRC_BLOCKS_PATH=/home/markus/uni/esd5_project/gr-raw_ethernet/grc:$GRC_BLOCKS_PATH
  '';
}
