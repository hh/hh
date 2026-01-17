# Home Manager configuration for Framework 16 "scope"
{
  config,
  lib,
  pkgs,
  ...
}: let
  theme = import ../themes/firewatch.nix;
in {
  imports = [
    ../platforms/linux.nix
  ];

  # ============================================================
  # Home Manager Settings
  # ============================================================

  programs.home-manager.enable = true;
  news.display = "silent";

  # ============================================================
  # User Identity
  # ============================================================

  home.username = "hh";
  home.homeDirectory = "/home/hh";

  # ============================================================
  # Hyprland Settings (Framework 16 specific)
  # ============================================================

  hyprland = {
    inherit theme;
    monitor = "eDP-1"; # Internal laptop display
    # Scale for Framework 16's 2560x1600 display
    size = n: builtins.toString (builtins.floor (n * 1.25));
    swap_escape = false;
  };

  # ============================================================
  # Framework 16 specific packages
  # ============================================================

  home.packages = with pkgs; [
    # For dGPU offloading
    # Usage: dgpu steam, dgpu blender
    (writeShellScriptBin "dgpu" ''
      DRI_PRIME=1 "$@"
    '')
  ];

  # ============================================================
  # Allow unfree packages
  # ============================================================

  nixpkgs.config.allowUnfree = true;

  # ============================================================
  # State Version
  # ============================================================

  home.stateVersion = "25.05";
}
