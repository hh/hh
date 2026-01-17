# SSH server configuration
{
  config,
  pkgs,
  ...
}: {
  # ============================================================
  # SSH Server
  # ============================================================

  services.openssh = {
    enable = true;

    settings = {
      # Security settings
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;

      # Allow forwarding
      X11Forwarding = false;
      AllowTcpForwarding = true;
      GatewayPorts = "no";
    };

    # Only listen on Tailscale interface by default
    # Uncomment to also listen on all interfaces
    # listenAddresses = [
    #   { addr = "0.0.0.0"; port = 22; }
    # ];
  };

  # ============================================================
  # VSCode Remote Server Support
  # ============================================================

  services.vscode-server.enable = true;

  # ============================================================
  # Firewall
  # ============================================================

  networking.firewall = {
    enable = true;
    allowedTCPPorts = []; # SSH only via Tailscale
  };
}
