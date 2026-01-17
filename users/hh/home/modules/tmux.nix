# Tmux configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    prefix = "C-a";
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 50000;
    escapeTime = 0;

    extraConfig = ''
      # Enable mouse
      set -g mouse on

      # Start windows and panes at 1
      set -g base-index 1
      setw -g pane-base-index 1

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Better splits
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Vim-like pane switching
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Reload config
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # Status bar
      set -g status-style bg=default
      set -g status-left "#[fg=green]#S "
      set -g status-right "#[fg=yellow]%H:%M"
      set -g window-status-current-style fg=cyan,bold
    '';
  };
}
