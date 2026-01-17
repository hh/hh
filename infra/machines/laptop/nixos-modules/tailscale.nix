# Tailscale VPN configuration
{
  config,
  pkgs,
  ...
}: {
  # ============================================================
  # Tailscale Service
  # ============================================================

  environment.systemPackages = [pkgs.tailscale];

  services.tailscale.enable = true;

  # ============================================================
  # Firewall Configuration
  # ============================================================

  networking.firewall = {
    # Trust Tailscale interface
    trustedInterfaces = ["tailscale0"];

    # Allow Tailscale UDP port
    allowedUDPPorts = [config.services.tailscale.port];

    # Required for Tailscale exit node / subnet routing
    checkReversePath = "loose";
  };

  # ============================================================
  # IPv6 Forwarding (for exit node capability)
  # ============================================================

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = "1";
    "net.ipv4.ip_forward" = "1";
  };

  # ============================================================
  # Services available over Tailscale
  # ============================================================

  networking.firewall.interfaces."tailscale0" = {
    # SSH
    allowedTCPPorts = [22];

    # Mosh
    allowedUDPPortRanges = [
      {
        from = 60000;
        to = 60010;
      }
    ];
  };
}
