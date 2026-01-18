# hh's NixOS Configuration

NixOS machine and Home Manager configurations using flakes.

## Machines

| Hostname | Hardware | Description |
|----------|----------|-------------|
| `scope` | Framework 16 (AMD 7840HS + RX 7700S) | Primary laptop |

## Quick Start

### Fresh Install on Framework 16 (Custom ISO)

1. **Build the custom installer ISO**
   ```bash
   nix build .#nixosConfigurations.installer.config.system.build.isoImage
   ```

2. **Write to USB** and boot (F12 at startup)
   - SSH access: `ssh nixos@2.2.2.4` or `ssh root@2.2.2.4`
   - Thunderbolt ethernet auto-configured at 2.2.2.4
   - WiFi fallback: wifi5.0G (auto-connect)

3. **Run the installer**
   ```bash
   sudo install-scope
   # Or specify a different drive:
   sudo install-scope nvme1n1
   ```

4. **Set passwords after install**
   ```bash
   nixos-enter --root /mnt -c 'passwd root'
   nixos-enter --root /mnt -c 'passwd hh'
   ```

5. **Reboot**
   ```bash
   reboot
   ```

### Fresh Install (Manual Method)

1. **Boot from NixOS ISO** (F12 at startup)

2. **Connect to WiFi**
   ```bash
   sudo nmcli device wifi connect "SSID" password "PASSWORD"
   ```

3. **Partition with disko** (no encryption for now)
   ```bash
   sudo nix --experimental-features "nix-command flakes" run \
     github:nix-community/disko -- \
     --mode disko \
     /tmp/config/infra/machines/laptop/disko-scope.nix
   ```

4. **Install NixOS**
   ```bash
   sudo nixos-install --flake /tmp/config#infra:laptop:scope --no-root-passwd
   ```

5. **Set passwords** and reboot

### Updating an Existing System

```bash
# NixOS system
sudo nixos-rebuild switch --flake .#infra:laptop:scope

# Home Manager
home-manager switch --flake .#hh@scope
```

### Post-Install Setup

After first boot, set the user password (initialPassword only works on first user creation):

```bash
passwd hh
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

## Depot Pattern (Automated GitOps)

This repo follows a "depot" pattern for automated deployments:

### How It Works

1. **Development**: Work in `~/w/hh/hh` (or wherever you cloned the repo)
2. **Push changes** to GitHub
3. **depot-sync** service (runs every 15 minutes):
   - Pulls latest from `github.com/hh/hh` to `/var/lib/depot`
   - Owned by user `hh`, not root
4. **depot-deploy-home** service (runs hourly at :30):
   - Runs `home-manager switch` from `/var/lib/depot`

### Manual Commands

```bash
# Sync depot manually
deploy sync

# Deploy home-manager from depot
deploy home

# Deploy home-manager from local working directory
deploy home --local

# Check service status
systemctl status depot-sync.timer
systemctl status depot-deploy-home.timer
journalctl -u depot-sync -f
journalctl -u depot-deploy-home -f
```

### Bootstrap Flow

First boot after installation:
1. Set password: `passwd hh`
2. Start depot-sync: `sudo systemctl start depot-sync`
3. Deploy home: `nix run home-manager/release-24.11 -- switch --flake /var/lib/depot#hh@scope`

After home-manager is deployed, `home-manager` will be in PATH and services will work automatically.

## Secrets

Secrets are managed with [sops-nix](https://github.com/Mic92/sops-nix).

### Bootstrap Flow for Secrets

The machine's SSH host key is used for decryption:

```bash
# 1. Get machine's SSH public key
sudo cat /etc/ssh/ssh_host_ed25519_key.pub

# 2. Convert to age format
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub

# 3. Add the age key to .sops.yaml in the repo
# 4. Encrypt secrets
sops secrets/scope.yaml
```

### Manual Key Generation

```bash
# Generate age key from user SSH key
ssh-to-age -i ~/.ssh/id_ed25519.pub

# Edit secrets
sops infra/machines/laptop/secrets/scope.yaml
```
