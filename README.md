# hh's NixOS Configuration

NixOS machine and Home Manager configurations using flakes.

## Machines

| Hostname | Hardware | Description |
|----------|----------|-------------|
| `scope` | Framework 16 (AMD 7840HS + RX 7700S) | Primary laptop |

## Quick Start

### Fresh Install on Framework 16

1. **Boot from NixOS ISO** (F12 at startup)

2. **Connect to WiFi**
   ```bash
   sudo nmcli device wifi connect "SSID" password "PASSWORD"
   ```

3. **Set LUKS password**
   ```bash
   echo "your-secure-password" > /tmp/disk-password
   ```

4. **Partition with disko**
   ```bash
   sudo nix --experimental-features "nix-command flakes" run \
     github:nix-community/disko -- \
     --mode disko \
     /tmp/config/infra/machines/laptop/disko-scope.nix
   ```

5. **Install NixOS**
   ```bash
   sudo nixos-install --flake /tmp/config#infra:laptop:scope
   ```

### Updating an Existing System

```bash
# NixOS system
sudo nixos-rebuild switch --flake .#infra:laptop:scope

# Home Manager
home-manager switch --flake .#users:hh:home:scope
```

## Structure

```
.
├── flake.nix                           # Main entry point
├── infra/machines/laptop/              # NixOS machine configs
│   ├── scope.nix                       # Framework 16 config
│   ├── disko-scope.nix                 # Disk partitioning
│   └── nixos-modules/                  # Modular system configs
└── users/hh/                           # User configurations
    ├── home/                           # Home Manager configs
    │   ├── machines/                   # Per-machine home configs
    │   ├── modules/                    # Shared modules
    │   └── themes/                     # Color themes
    └── keys/                           # SSH public keys
```

## Framework 16 Notes

- **dGPU Usage**: Use `DRI_PRIME=1` to run apps on the RX 7700S
  ```bash
  DRI_PRIME=1 steam
  # Or use the alias:
  dgpu steam
  ```

- **Power Management**: Uses `power-profiles-daemon` (NOT TLP)
  ```bash
  powerprofilesctl list
  powerprofilesctl set balanced
  ```

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix).

```bash
# Generate age key from SSH key
ssh-to-age -i ~/.ssh/id_ed25519.pub

# Edit secrets
sops infra/machines/laptop/secrets/scope.yaml
```
