# Declarative disk partitioning for Framework 16 "scope"
# 4TB NVMe, 96GB RAM, Btrfs (no encryption)
#
# Usage:
#   sudo nix run github:nix-community/disko -- --mode disko ./disko-scope.nix
#
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Framework 16 primary NVMe (4TB)
        # Second drive (nvme1n1) left untouched for other OS
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };

            # Main filesystem (btrfs, no encryption)
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = ["-f"];
                subvolumes = {
                  # ==========================================
                  # Core System
                  # ==========================================

                  "@" = {
                    mountpoint = "/";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  # ==========================================
                  # Variable Data
                  # ==========================================

                  "@var-log" = {
                    mountpoint = "/var/log";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  "@var-tmp" = {
                    mountpoint = "/var/tmp";
                    mountOptions = ["noatime"];
                  };

                  # ==========================================
                  # Container & VM Storage
                  # ==========================================

                  "@containers" = {
                    mountpoint = "/var/lib/containers";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  "@libvirt" = {
                    mountpoint = "/var/lib/libvirt";
                    mountOptions = ["compress=zstd:1" "noatime"];
                  };

                  # ==========================================
                  # Snapshots & Swap
                  # ==========================================

                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = ["compress=zstd" "noatime"];
                  };

                  # Swap for hibernate (96GB RAM)
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = ["noatime"];
                    swap.swapfile = {
                      size = "96G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
