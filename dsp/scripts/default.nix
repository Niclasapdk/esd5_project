{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3Packages.numpy
    python3Packages.matplotlib
    python312Packages.scienceplots
    texliveFull
  ];
}
