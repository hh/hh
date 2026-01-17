# Hyprland window manager configuration
# For Framework 16 with AMD graphics
{
  config,
  lib,
  pkgs,
  ...
}: let
  terminal = "${pkgs.ghostty}/bin/ghostty";
  browser = "${pkgs.firefox}/bin/firefox";
  launcher = "${pkgs.rofi-wayland}/bin/rofi -show drun";
  grim = "${pkgs.grim}/bin/grim";
  slurp = "${pkgs.slurp}/bin/slurp";
  swappy = "${pkgs.swappy}/bin/swappy";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  waybar = "${pkgs.waybar}/bin/waybar";
  hyprpaper = "${pkgs.hyprpaper}/bin/hyprpaper";
  _1password = "${pkgs._1password-gui}/bin/1password";
  pypr = "${pkgs.pyprland}/bin/pypr";
  kitty = "${pkgs.kitty}/bin/kitty";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
in {
  # ============================================================
  # Options
  # ============================================================

  options.hyprland = {
    theme = lib.mkOption {type = lib.types.attrs;};
    monitor = lib.mkOption {type = lib.types.str;};
    size = lib.mkOption {type = lib.types.functionTo lib.types.str;};
    swap_escape = lib.mkOption {type = lib.types.bool;};
  };

  # ============================================================
  # Hyprland Config
  # ============================================================

  config.home.file = {
    ".config/hypr/hyprland.conf".text = ''
      # ========================================
      # Monitor Configuration
      # ========================================
      monitor = ${config.hyprland.monitor}, preferred, auto, 1.25

      # ========================================
      # General Settings
      # ========================================
      general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgb(${config.hyprland.theme.focus})
          col.inactive_border = rgba(595959aa)
          layout = dwindle
      }

      # ========================================
      # Environment (AMD specific - no NVIDIA vars!)
      # ========================================
      env = XCURSOR_SIZE,24
      env = QT_QPA_PLATFORMTHEME,qt5ct
      env = GDK_SCALE,1.25

      # XWayland
      xwayland {
          force_zero_scaling = true
      }

      # ========================================
      # Input
      # ========================================
      input {
          kb_layout = us
          follow_mouse = 1
          touchpad {
              natural_scroll = true
              tap-to-click = true
          }
          sensitivity = 0
          repeat_delay = 200
          repeat_rate = 40
      }

      # ========================================
      # Decoration
      # ========================================
      decoration {
          rounding = 8
          blur {
              enabled = true
              size = 3
              passes = 1
          }
      }

      # ========================================
      # Animations
      # ========================================
      animations {
          enabled = true
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 4, myBezier
          animation = windowsOut, 1, 4, default, popin 80%
          animation = border, 1, 10, default
          animation = fade, 1, 4, default
          animation = workspaces, 1, 4, default
      }

      # ========================================
      # Layout
      # ========================================
      dwindle {
          pseudotile = true
          preserve_split = true
      }

      misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
      }

      # ========================================
      # Startup Applications
      # ========================================
      exec-once = dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY
      exec-once = ${waybar}
      exec-once = ${hyprpaper}
      exec-once = ${pypr}
      exec-once = ${_1password} --silent

      # ========================================
      # Keybindings
      # ========================================
      $mainMod = SUPER

      # Core
      bind = $mainMod, RETURN, exec, ${terminal}
      bind = $mainMod, Q, killactive,
      bind = $mainMod, V, togglefloating,
      bind = $mainMod, P, exec, ${launcher}
      bind = $mainMod, B, exec, ${browser}
      bind = $mainMod, F, fullscreen,
      bind = $mainMod SHIFT, L, exec, loginctl lock-session

      # Screenshots
      bind = $mainMod SHIFT, S, exec, ${grim} -g "$(${slurp})" - | ${swappy} -f -

      # 1Password
      bind = $mainMod SHIFT, P, exec, ${_1password} --quick-access

      # Brightness (Framework 16)
      bind = , XF86MonBrightnessUp, exec, ${brightnessctl} set +5%
      bind = , XF86MonBrightnessDown, exec, ${brightnessctl} set 5%-
      bind = SHIFT, XF86MonBrightnessUp, exec, ${brightnessctl} set 100%
      bind = SHIFT, XF86MonBrightnessDown, exec, ${brightnessctl} set 10%

      # Volume
      bind = , XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
      bind = , XF86AudioLowerVolume, exec, ${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
      bind = , XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle

      # Window focus (vim-style)
      bind = $mainMod, h, movefocus, l
      bind = $mainMod, l, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d

      # Workspaces
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Move to workspace
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scratchpads
      bind = $mainMod, grave, exec, ${pypr} toggle term
      bind = $mainMod, A, exec, ${pypr} toggle audio

      # Mouse bindings
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Scratchpad window rules
      windowrulev2 = float, class:^(scratchpad)$
      windowrulev2 = size 80% 80%, class:^(scratchpad)$
      windowrulev2 = center, class:^(scratchpad)$
      windowrulev2 = workspace special silent, class:^(scratchpad)$

      windowrulev2 = float, class:^(pavucontrol)$
      windowrulev2 = size 60% 40%, class:^(pavucontrol)$
      windowrulev2 = move 20% 5%, class:^(pavucontrol)$
    '';

    # ========================================
    # Hyprpaper (Wallpaper)
    # ========================================
    ".config/hypr/hyprpaper.conf".text = ''
      preload = ${config.hyprland.theme.wallpaper}
      wallpaper = ${config.hyprland.monitor}, ${config.hyprland.theme.wallpaper}
    '';

    # ========================================
    # Hypridle (Idle management)
    # ========================================
    ".config/hypr/hypridle.conf".text = ''
      general {
          lock_cmd = loginctl lock-session
          before_sleep_cmd = loginctl lock-session
          after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
          timeout = 150
          on-timeout = ${brightnessctl} -s set 10
          on-resume = ${brightnessctl} -r
      }

      listener {
          timeout = 300
          on-timeout = loginctl lock-session
      }

      listener {
          timeout = 330
          on-timeout = hyprctl dispatch dpms off
          on-resume = hyprctl dispatch dpms on
      }

      listener {
          timeout = 1800
          on-timeout = systemctl suspend
      }
    '';

    # ========================================
    # Pyprland (Scratchpads)
    # ========================================
    ".config/hypr/pyprland.toml".text = ''
      [pyprland]
      plugins = ["scratchpads"]

      [scratchpads.term]
      command = "${kitty} --class scratchpad"
      margin = 50
      unfocus = "hide"
      animation = "fromTop"
      lazy = true

      [scratchpads.audio]
      command = "${pavucontrol}"
      margin = 50
      unfocus = "hide"
      animation = "fromTop"
      lazy = true
    '';

    # ========================================
    # Waybar
    # ========================================
    ".config/waybar/config".text = builtins.toJSON {
      layer = "top";
      height = 28;
      spacing = 10;
      modules-left = ["hyprland/workspaces" "hyprland/window"];
      modules-center = ["clock"];
      modules-right = ["cpu" "memory" "pulseaudio" "network" "battery" "tray"];

      "hyprland/workspaces" = {
        format = "{name}";
        all-outputs = true;
      };

      clock = {
        format = "{:%H:%M}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      cpu = {
        format = "{usage}% ";
      };

      memory = {
        format = "{}% ";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-icons = [" " " " " " " " " "];
      };

      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr} ";
        format-disconnected = "Disconnected";
      };

      pulseaudio = {
        format = "{volume}% {icon}";
        format-muted = "muted ";
        format-icons = {
          default = ["" "" ""];
        };
        on-click = "${pavucontrol}";
      };

      tray = {
        spacing = 10;
      };
    };

    ".config/waybar/style.css".text = ''
      * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 13px;
      }

      window#waybar {
          background-color: #${config.hyprland.theme.background};
          color: #${config.hyprland.theme.foreground};
      }

      #workspaces button {
          padding: 0 5px;
          color: #${config.hyprland.theme.foreground};
          background: transparent;
      }

      #workspaces button.active {
          background-color: #${config.hyprland.theme.secondary};
      }

      #clock {
          background-color: #${config.hyprland.theme.secondary};
          padding: 0 10px;
      }

      #battery.warning {
          color: #${config.hyprland.theme.alert};
      }

      #battery.critical {
          background-color: #${config.hyprland.theme.alert};
          color: #${config.hyprland.theme.foreground};
      }

      #network {
          background-color: #${config.hyprland.theme.secondary};
          padding: 0 10px;
      }
    '';

    # ========================================
    # Rofi
    # ========================================
    ".config/rofi/config.rasi".text = ''
      configuration {
          display-drun: "Apps:";
          drun-display-format: "{icon} {name}";
          font: "JetBrainsMono Nerd Font 12";
          modi: "drun";
          show-icons: true;
      }

      * {
          background-color: #${config.hyprland.theme.background};
          text-color: #${config.hyprland.theme.foreground};
      }

      window {
          width: 30%;
          border: 2px;
          border-color: #${config.hyprland.theme.primary};
          border-radius: 8px;
      }

      element selected {
          background-color: #${config.hyprland.theme.secondary};
      }

      entry {
          padding: 12px;
      }

      listview {
          padding: 8px;
          lines: 8;
      }
    '';

    # ========================================
    # Swappy (Screenshot editor)
    # ========================================
    ".config/swappy/config".text = ''
      [Default]
      save_dir=$HOME/Pictures/Screenshots
      save_filename_format=screenshot-%Y%m%d-%H%M%S.png
      show_panel=false
      early_exit=true
    '';
  };
}
