# Power management for Framework 16 AMD
# CRITICAL: Use power-profiles-daemon, NOT TLP for AMD Framework
{
  config,
  pkgs,
  ...
}: {
  # ============================================================
  # Power Profiles Daemon (Required for AMD Framework)
  # ============================================================

  # power-profiles-daemon provides better AMD CPU/GPU power management
  services.power-profiles-daemon.enable = true;

  # TLP conflicts with power-profiles-daemon - explicitly disable
  services.tlp.enable = false;

  # Thermald is Intel-specific, not needed for AMD
  services.thermald.enable = false;

  # ============================================================
  # General Power Management
  # ============================================================

  powerManagement.enable = true;

  # ============================================================
  # Backlight Control
  # ============================================================

  programs.light.enable = true;

  # ============================================================
  # Lid Switch Behavior
  # ============================================================

  services.logind.settings.Login = {
    # Suspend when lid closed on battery
    HandleLidSwitch = "suspend";

    # Don't suspend when lid closed if external power
    HandleLidSwitchExternalPower = "ignore";

    # Don't suspend when docked
    HandleLidSwitchDocked = "ignore";

    # Power button behavior
    HandlePowerKey = "poweroff";
    HandlePowerKeyLongPress = "poweroff";
  };

  # ============================================================
  # Idle Management (hypridle handles this too, but system-level backup)
  # ============================================================

  services.hypridle.enable = true;

  # ============================================================
  # UPower for battery monitoring
  # ============================================================

  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };
}
