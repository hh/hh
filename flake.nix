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
    # Custom ISO for installation
    # ============================================================

    nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        disko.nixosModules.disko

        ({pkgs, ...}: {
          environment.systemPackages = with pkgs; [
            git
            neovim
            tmux
            htop
            pciutils
            usbutils
          ];

          nix.settings.experimental-features = ["nix-command" "flakes"];
          networking.networkmanager.enable = true;
          networking.wireless.enable = false;

          # Latest kernel for Framework 16
          boot.kernelPackages = pkgs.linuxPackages_latest;
        })
      ];
    };
  };
}
