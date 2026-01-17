# Declarative disk partitioning for Framework 16 "scope"
# LUKS encryption + Btrfs with subvolumes
#
# Usage:
#   echo "your-password" > /tmp/disk-password
#   sudo nix run github:nix-community/disko -- --mode disko ./disko-scope.nix
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Framework 16 NVMe drive
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

            # LUKS encrypted root
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptroot";
                # Set password before running disko:
                # echo "password" > /tmp/disk-password
                passwordFile = "/tmp/disk-password";
                settings = {
                  allowDiscards = true; # TRIM support for SSD performance
                };
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"]; # Force overwrite
                  subvolumes = {
                    # Root subvolume
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ["compress=zstd" "noatime"];
                    };

                    # Home - separate for easy backup/restore
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = ["compress=zstd" "noatime"];
                    };

                    # Nix store - separate to exclude from snapshots
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["compress=zstd" "noatime"];
                    };

                    # Var - logs, state, etc.
                    "@var" = {
                      mountpoint = "/var";
                      mountOptions = ["compress=zstd" "noatime"];
                    };

                    # Swap file for hibernate support
                    # Size should match RAM (32G recommended for 32GB RAM)
                    "@swap" = {
                      mountpoint = "/swap";
                      swap.swapfile = {
                        size = "32G";
                      };
                    };

                    # Snapshots subvolume (for btrfs snapshots)
                    "@snapshots" = {
                      mountpoint = "/.snapshots";
                      mountOptions = ["compress=zstd" "noatime"];
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
