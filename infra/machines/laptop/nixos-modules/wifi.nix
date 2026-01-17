# WiFi network profiles
# Only wifi5.0G included in git (password looks like a placeholder)
# Add other networks via: nmcli device wifi connect "SSID" password "pass"
{
  config,
  pkgs,
  lib,
  ...
}: {
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [];
    profiles = {
      # Home/RV network
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
    };
  };
}
