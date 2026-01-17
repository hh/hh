# NixOS configurations for hh's machines
# Inspired by ghuntley's depot pattern
{
  description = "NixOS machine and home configurations";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VSCode remote server support
    nixos-vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Code formatting
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    disko,
    home-manager,
    sops-nix,
    nixos-vscode-server,
    treefmt-nix,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    # Helper to create NixOS systems
    mkSystem = {
      hostname,
      modules,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit self;};
        modules =
          modules
          ++ [
            # Common modules for all machines
            sops-nix.nixosModules.sops
            nixos-vscode-server.nixosModules.default
            disko.nixosModules.disko
          ];
      };

    # Helper to create home-manager configurations
    mkHome = {
      username,
      modules,
    }:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {inherit self;};
        modules =
          modules
          ++ [
            {
              _module.args.keys = import ./users/${username}/keys {};
            }
          ];
      };
  in {
    # ============================================================
    # NixOS Machine Configurations
    # ============================================================

    nixosConfigurations = {
      # Framework 16 laptop
      "infra:laptop:scope" = mkSystem {
        hostname = "scope";
        modules = [
          # Framework 16 AMD 7040 hardware support
          nixos-hardware.nixosModules.framework-16-7040-amd

          # Machine-specific config
          ./infra/machines/laptop/scope.nix
        ];
      };
    };

    # ============================================================
    # Home Manager Configurations
    # ============================================================

    homeConfigurations = {
      # hh's home config for scope (Framework 16)
      "users:hh:home:scope" = mkHome {
        username = "hh";
        modules = [
          ./users/hh/home/machines/scope.nix
        ];
      };
    };

    # ============================================================
    # Development Shell
    # ============================================================

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        # Nix tools
        nil # Nix LSP
        nixpkgs-fmt
        nix-tree
        nvd # Nix version diff

        # Secrets
        sops
        age
        ssh-to-age

        # Git
        git

        # Utils
        jq
        yq
      ];
    };

    # ============================================================
    # Formatter
    # ============================================================

    formatter.${system} = pkgs.alejandra;

    # ============================================================
    # Packages (deploy tool, etc.)
    # ============================================================

    packages.${system} = {
      deploy = pkgs.callPackage ./tools/deploy {};
    };

    # ============================================================
    # Custom ISO for installation
    # ============================================================

    nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        disko.nixosModules.disko

        ({
          pkgs,
          lib,
          ...
        }: let
          # Embed the entire repo into the ISO
          repoSource = pkgs.stdenv.mkDerivation {
            name = "hh-repo";
            src = self;
            installPhase = ''
              mkdir -p $out
              cp -r . $out/
            '';
          };

          # Install script
          install-scope = pkgs.writeShellScriptBin "install-scope" ''
            set -euo pipefail

            echo "========================================"
            echo "  NixOS Installer for Framework 16"
            echo "  Hostname: scope"
            echo "========================================"
            echo ""

            # Check if running as root
            if [[ $EUID -ne 0 ]]; then
              echo "This script must be run as root (use sudo)"
              exit 1
            fi

            # Show available drives
            echo "Available drives:"
            lsblk -d -o NAME,SIZE,MODEL | grep -E "^nvme|^sd"
            echo ""

            # Default to nvme0n1, but allow override
            TARGET_DRIVE="''${1:-nvme0n1}"
            echo "Target drive: /dev/$TARGET_DRIVE"
            echo ""

            # Confirm
            read -p "This will ERASE /dev/$TARGET_DRIVE. Continue? [y/N] " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
              echo "Aborted."
              exit 1
            fi

            # Copy repo to /tmp for disko (it needs write access for flake.lock)
            echo "Preparing configuration..."
            cp -r ${repoSource} /tmp/hh
            chmod -R u+w /tmp/hh
            cd /tmp/hh

            # Update disko config if different drive
            if [[ "$TARGET_DRIVE" != "nvme0n1" ]]; then
              echo "Updating disko config for /dev/$TARGET_DRIVE..."
              sed -i "s|/dev/nvme0n1|/dev/$TARGET_DRIVE|g" infra/machines/laptop/disko-scope.nix
            fi

            # Run disko to partition and mount
            echo ""
            echo "Partitioning /dev/$TARGET_DRIVE with disko..."
            ${pkgs.disko}/bin/disko --mode disko ./infra/machines/laptop/disko-scope.nix

            # Verify mounts
            echo ""
            echo "Verifying mounts..."
            mount | grep "$TARGET_DRIVE" || {
              echo "ERROR: Drive not mounted properly"
              exit 1
            }

            # Copy repo to target for future use
            echo ""
            echo "Copying configuration to target..."
            mkdir -p /mnt/home/hh/w/hh
            cp -r /tmp/hh /mnt/home/hh/w/hh/hh
            chown -R 1000:100 /mnt/home/hh

            # Install NixOS
            echo ""
            echo "Installing NixOS (this may take a while)..."
            nixos-install --root /mnt --flake /tmp/hh#infra:laptop:scope --no-root-passwd

            echo ""
            echo "========================================"
            echo "  Installation complete!"
            echo "========================================"
            echo ""
            echo "Next steps:"
            echo "  1. Set root password: nixos-enter --root /mnt -c 'passwd'"
            echo "  2. Set user password: nixos-enter --root /mnt -c 'passwd hh'"
            echo "  3. Reboot: reboot"
            echo ""
            echo "After reboot, your config will be at: /home/hh/w/hh/hh"
          '';

          # Quick network setup script
          wifi-connect = pkgs.writeShellScriptBin "wifi-connect" ''
            if [[ $# -lt 2 ]]; then
              echo "Usage: wifi-connect <SSID> <password>"
              echo ""
              echo "Available networks:"
              nmcli device wifi list
              exit 1
            fi
            nmcli device wifi connect "$1" password "$2"
          '';
        in {
          environment.systemPackages = with pkgs; [
            # Installation tools
            install-scope
            wifi-connect
            disko
            parted
            gptfdisk

            # Editors & tools
            neovim
            tmux
            htop
            git

            # Hardware inspection
            pciutils
            usbutils
            nvme-cli
            smartmontools

            # Network
            networkmanager
            wget
            curl
          ];

          # Include the repo source for reference
          environment.etc."hh-repo".source = repoSource;

          nix.settings.experimental-features = ["nix-command" "flakes"];
          networking.networkmanager.enable = true;
          networking.wireless.enable = false;

          # Latest kernel for Framework 16
          boot.kernelPackages = pkgs.linuxPackages_latest;

          # Helpful message on login
          services.getty.helpLine = lib.mkForce ''

            Welcome to the NixOS Installer for Framework 16!

            Quick start:
              1. Connect to WiFi:  wifi-connect "YourSSID" "YourPassword"
              2. Install NixOS:    sudo install-scope

            The install script will:
              - Partition /dev/nvme0n1 (or specify another: sudo install-scope nvme1n1)
              - Install NixOS with the "scope" configuration
              - Copy the config repo to /home/hh/w/hh/hh

            Manual commands:
              - List drives:       lsblk
              - List WiFi:         nmcli device wifi list
              - Check hardware:    lspci, lsusb

          '';

          # Auto-login for convenience
          services.getty.autologinUser = "nixos";

          # ISO label
          isoImage.isoName = "nixos-scope-installer.iso";
          isoImage.volumeID = "NIXOS_SCOPE";
        })
      ];
    };
  };
}
