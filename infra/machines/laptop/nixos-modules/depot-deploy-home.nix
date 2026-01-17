# Depot deploy home - automatically rebuild Home Manager from depot
{
  config,
  pkgs,
  lib,
  ...
}: let
  deploy = pkgs.callPackage ../../../../tools/deploy {};
in {
  systemd.services.depot-deploy-home = {
    description = "Deploy Home Manager configuration from depot";
    after = ["network-online.target"];
    wants = ["network-online.target"];

    unitConfig = {
      ConditionACPower = true;
    };

    serviceConfig = {
      Type = "oneshot";
      User = "hh";
      Group = "users";
      TimeoutStartSec = "30min";
      Environment = [
        "PATH=${lib.makeBinPath [pkgs.hostname pkgs.git pkgs.nix pkgs.home-manager pkgs.systemd]}"
        "HOME=/home/hh"
      ];
    };

    script = ''
      ${deploy}/bin/deploy home
    '';
  };

  systemd.timers.depot-deploy-home = {
    description = "Run depot home deploy every hour (offset from machine)";
    wantedBy = ["timers.target"];

    timerConfig = {
      OnCalendar = "*:30"; # Run at 30 minutes past each hour
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}
