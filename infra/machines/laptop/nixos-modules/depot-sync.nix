# Depot sync - automatically pull latest from github.com/hh/hh
{
  config,
  pkgs,
  lib,
  ...
}: let
  deploy = pkgs.callPackage ../../../../tools/deploy {};
in {
  systemd.services.depot-sync = {
    description = "Sync depot repository";
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];

    unitConfig = {
      ConditionACPower = true;
    };

    serviceConfig = {
      Type = "oneshot";
      User = "hh";
      Group = "users";
      Nice = 10;
      TimeoutStartSec = "5min";
      PrivateTmp = true;
      ProtectSystem = "strict";
      ReadWritePaths = ["/var/lib/depot"];
    };

    script = ''
      export GIT_CONFIG_SYSTEM=${pkgs.writeText "gitconfig" ''
        [safe]
          directory = /var/lib/depot
      ''}
      export GIT_PATH=${pkgs.git}/bin/git
      ${deploy}/bin/deploy sync
    '';
  };

  systemd.timers.depot-sync = {
    description = "Run depot sync every 15 minutes";
    wantedBy = ["timers.target"];

    timerConfig = {
      OnUnitInactiveSec = "15m";
      RandomizedDelaySec = "30s";
      AccuracySec = "30s";
    };
  };

  # Ensure /var/lib/depot directory exists with proper permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/depot 0755 hh users -"
  ];
}
