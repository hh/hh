# WiFi network profiles
# These are embedded in the config for convenience
# For sensitive networks, consider using sops-nix secrets
{
  config,
  pkgs,
  lib,
  ...
}: {
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [];
    profiles = {
      # Home/RV network (highest priority)
      "wifi5.0G" = {
        connection = {
          id = "wifi5.0G";
          type = "wifi";
          autoconnect = true;
          autoconnect-priority = 100;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "wifi5.0G";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "password";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      # Harperhouse
      "Harperhouse" = {
        connection = {
          id = "Harperhouse";
          type = "wifi";
          autoconnect = true;
          autoconnect-priority = 90;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "Harperhouse";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "Harper1064";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };

      # Bitter Buffalo
      "Bitter Buffalo" = {
        connection = {
          id = "Bitter Buffalo";
          type = "wifi";
          autoconnect = true;
          autoconnect-priority = 80;
        };
        wifi = {
          mode = "infrastructure";
          ssid = "Bitter Buffalo";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "pr@yf0rm0j0";
        };
        ipv4.method = "auto";
        ipv6.method = "auto";
      };
    };
  };
}
