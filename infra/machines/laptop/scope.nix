# Framework 16 "scope" - Main machine configuration
# AMD Ryzen 7 7840HS + Radeon 780M (iGPU) + Radeon RX 7700S (dGPU)
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Disk partitioning (disko)
    ./disko-scope.nix

    # Modular NixOS configurations
    ./nixos-modules/desktop.nix
    ./nixos-modules/power.nix
    ./nixos-modules/nix-settings.nix
    ./nixos-modules/user.nix
    ./nixos-modules/ssh.nix
    ./nixos-modules/tailscale.nix

    # GitOps auto-deployment (depot pattern)
    ./nixos-modules/depot-sync.nix
    ./nixos-modules/depot-deploy-machine.nix
    ./nixos-modules/depot-deploy-home.nix
  ];

  # ============================================================
  # Machine Identity
  # ============================================================

  networking.hostName = "scope";
  networking.networkmanager.enable = true;

  # ============================================================
  # Boot Configuration
  # ============================================================

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel for best Framework 16 support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Framework 16 kernel modules
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "amdgpu" # Early KMS for smooth boot
  ];
  boot.kernelModules = ["kvm-amd" "amdgpu"];

  # AMD-specific kernel parameters
  boot.kernelParams = [
    # Display color accuracy (disable Active Backlight Management)
    "amdgpu.abmlevel=0"

    # Better sleep on AMD
    "mem_sleep_default=s2idle"

    # Sleep/wake fixes
    "amdgpu.dcdebugmask=0x10"

    # dGPU power management
    "amdgpu.runpm=1"
    "amdgpu.aspm=1"
  ];

  # ============================================================
  # Filesystem Configuration
  # (Matches disko-scope.nix - btrfs, no encryption)
  # ============================================================

  # Core system
  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@" "compress=zstd" "noatime"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@home" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@nix" "compress=zstd" "noatime"];
  };

  # Variable data
  fileSystems."/var/log" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@var-log" "compress=zstd" "noatime"];
  };

  fileSystems."/var/tmp" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@var-tmp" "noatime"];
  };

  # Container & VM storage
  fileSystems."/var/lib/containers" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@containers" "compress=zstd" "noatime"];
  };

  fileSystems."/var/lib/libvirt" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@libvirt" "compress=zstd:1" "noatime"];
  };

  # Snapshots & Swap
  fileSystems."/.snapshots" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@snapshots" "compress=zstd" "noatime"];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-partlabel/root";
    fsType = "btrfs";
    options = ["subvol=@swap" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/ESP";
    fsType = "vfat";
    options = ["umask=0077"];
  };

  # ============================================================
  # Swap (96GB for hibernate with 96GB RAM)
  # ============================================================

  swapDevices = [
    {device = "/swap/swapfile";}
  ];

  # ============================================================
  # Secrets Management (sops-nix)
  # ============================================================

  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ../secrets/scope.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  # ============================================================
  # Platform
  # ============================================================

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # NixOS release version
  system.stateVersion = "25.05";
}
