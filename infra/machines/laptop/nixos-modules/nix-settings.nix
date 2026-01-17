# Nix daemon and store configuration
{
  config,
  pkgs,
  ...
}: {
  # ============================================================
  # Nix Settings
  # ============================================================

  nix.settings = {
    # Auto-optimize store to save disk space
    auto-optimise-store = true;

    # Users allowed to manage nix
    trusted-users = ["root" "hh"];

    # Enable flakes and new nix command
    experimental-features = ["nix-command" "flakes"];

    # Require signatures on binary caches
    require-sigs = true;

    # Binary caches (faster builds)
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
      "https://devenv.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  # ============================================================
  # Garbage Collection
  # ============================================================

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
