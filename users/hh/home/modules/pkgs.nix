# Common packages for all platforms
{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # Core utilities
    curl
    wget
    unzip
    ripgrep
    fd
    jq
    yq
    htop
    btop

    # Development
    git
    delta
    lazygit
    gh
    mosh

    # Node.js (for many dev tools)
    nodejs_22

    # Nix tools
    nil # LSP
    nixpkgs-fmt
    nix-tree
  ];

  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  programs.jq.enable = true;
  programs.lazygit.enable = true;
  programs.command-not-found.enable = true;
}
