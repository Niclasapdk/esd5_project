{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [ iverilog gtkwave python3Packages.numpy ];
  PROJECT_ROOT = builtins.toString ./.;
  shellHook = "export PATH=$PROJECT_ROOT/.venv/bin:$PATH";
}
