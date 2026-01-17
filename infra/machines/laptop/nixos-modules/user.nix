# User accounts
{
  config,
  pkgs,
  ...
}: {
  # ============================================================
  # Primary User
  # ============================================================

  users.users.hh = {
    isNormalUser = true;
    description = "Hippie Hacker";
    extraGroups = [
      "wheel" # sudo access
      "networkmanager" # Network management
      "video" # Backlight control
      "audio" # Audio devices
      "input" # Input devices
      "docker" # Docker (if enabled)
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # ed25519 keys (preferred)
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwsHmQtv++obVtbu8Nc9COPOLEG5N12jYk75dTCaRsT hh@nextral.sharing.io"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIItrB/8JpOZIyhp00TSKPxLOs3ZsqGBciIkCJi+SyjzJ hh@m1.medusa.local"
      # RSA key (legacy compatibility)
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDUhS7BghZwYoLKSsQx7HBxeV9JaA8jIA/kQCrKR58wWbFW7o2qHSC5lD9eJuDH439ifzsG05OxOgsm3Q+Jrb+VTOY1MdGAIW7SV2/xqDjLWmS259qH5kSYaP8TBq2EZZ9mFmIdZPDA7Q5ezjNcyH/LqW0FxU7XqIzFsrZlhDTZ57KZgivRZZsyauwOOP8+nXNj4YGSeQfzpiZXIaTZpSqWOrgud2kIehkeraJTlkXIbLge2zqM0dGLHVEyVW3W8qFPbmZBTdVhH2Tkgz9NNeukgXPzBdhSzSCdA/pLZ28MYUGScaDkc6BhpXHJzBo5zTpyhDyeHoHPUUYyTmFPUc2d hh@p70"
    ];
  };

  # ============================================================
  # Shell
  # ============================================================

  programs.zsh.enable = true;

  # ============================================================
  # Sudo Configuration
  # ============================================================

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    extraConfig = ''
      # Allow hh to run certain commands without password
      hh ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild
      hh ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/systemctl
    '';
  };
}
