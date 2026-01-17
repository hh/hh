# Depot deploy machine - automatically rebuild NixOS from depot
{
  config,
  pkgs,
  lib,
  ...
}: let
  deploy = pkgs.callPackage ../../../../tools/deploy {};
in {
  systemd.services.depot-deploy-machine = {
    description = "Deploy NixOS configuration from depot";
    after = ["network-online.target"];
    wants = ["network-online.target"];

    unitConfig = {
      ConditionACPower = true;
    };

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      TimeoutStartSec = "30min";
      ExecStart = "${deploy}/bin/deploy machine";
      Environment = [
        "PATH=${lib.makeBinPath [pkgs.hostname pkgs.git pkgs.nix pkgs.nixos-rebuild pkgs.systemd]}"
      ];
    };
  };

  systemd.timers.depot-deploy-machine = {
    description = "Run depot machine deploy every hour";
    wantedBy = ["timers.target"];

    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "5m";
    };
  };
}
