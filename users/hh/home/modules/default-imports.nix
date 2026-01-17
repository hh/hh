# Default set of modules imported for all home configurations
{
  config,
  lib,
  pkgs,
  ...
}: let
  modulesPath = toString ../modules;
  mod = name: modulesPath + "/${name}";
in {
  imports = [
    (mod "git.nix")
    (mod "zsh.nix")
    (mod "tmux.nix")
    (mod "pkgs.nix")
    (mod "neovim.nix")
  ];
}
