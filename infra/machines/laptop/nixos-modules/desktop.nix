# Desktop environment configuration
# Hyprland + Wayland stack for Framework 16
{
  config,
  pkgs,
  ...
}: {
  # ============================================================
  # Package Configuration
  # ============================================================

  nixpkgs.config.allowUnfree = true;

  # Wayland environment hint for Electron apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # ============================================================
  # System Packages
  # ============================================================

  environment.systemPackages = with pkgs; [
    # Desktop Environment & Window Management
    brightnessctl
    btop
    cliphist
    hypridle
    hyprpaper
    pyprland
    rofi
    swww
    waybar
    wlogout

    # System Monitoring
    inxi
    gnome-system-monitor

    # Graphics & Screenshots
    grim
    slurp
    swappy
    imagemagick

    # Audio
    pamixer
    playerctl
    pavucontrol

    # System Integration
    polkit_gnome
    libnotify
    xdg-user-dirs
    xdg-utils

    # Terminals
    ghostty
    kitty
    alacritty

    # Editors
    neovim

    # Browsers
    firefox
    google-chrome

    # Utilities
    killall
    pciutils
    wl-clipboard
    yt-dlp

    # Password Management
    _1password-gui

    # File Management
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.tumbler
    xarchiver

    # Gaming (optional - comment out if not needed)
    # lutris
    # steam
    # protonup-qt
  ];

  # ============================================================
  # AMD Graphics (iGPU 780M + dGPU 7700S)
  # ============================================================

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr # OpenCL support
    ];
  };

  # RADV (Mesa) is now the default and recommended Vulkan driver for AMD

  # ============================================================
  # Framework 16 Specific
  # ============================================================

  services.fwupd.enable = true; # Firmware updates
  services.fprintd.enable = true; # Fingerprint reader
  hardware.framework.enableKmod = true; # Battery limits, LEDs

  # ============================================================
  # Bluetooth
  # ============================================================

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # ============================================================
  # Fonts
  # ============================================================

  fonts.packages = with pkgs; [
    fira-code
    font-awesome
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-cjk-sans
  ];

  # ============================================================
  # Hyprland Window Manager
  # ============================================================

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.waybar.enable = true;

  # ============================================================
  # Login Manager
  # ============================================================

  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "hh";
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
    };
  };

  # ============================================================
  # XDG Portals
  # ============================================================

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-hyprland
    ];
  };

  # ============================================================
  # Audio (PipeWire)
  # ============================================================

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ============================================================
  # Services
  # ============================================================

  services.dbus.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.printing.enable = true;
  services.libinput.enable = true;

  # ============================================================
  # Programs
  # ============================================================

  programs.dconf.enable = true;
  programs.ssh.startAgent = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["hh"];
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.mosh.enable = true;
}
