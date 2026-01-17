# Linux-specific home configuration
# Imports all common modules + Linux-specific ones
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../modules/default-imports.nix
    ../modules/hyprland.nix
  ];
}
