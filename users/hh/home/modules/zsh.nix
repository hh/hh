# Zsh configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    initExtra = ''
      # Add local bin to PATH
      export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

      # Direnv hook
      eval "$(direnv hook zsh)"

      # Better history
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_SPACE
      setopt SHARE_HISTORY
    '';

    shellAliases = {
      # Nix shortcuts
      nrs = "sudo nixos-rebuild switch --flake .";
      nrt = "sudo nixos-rebuild test --flake .";
      hms = "home-manager switch --flake .";

      # Git shortcuts
      g = "git";
      gs = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline -20";

      # General
      ll = "ls -la";
      ".." = "cd ..";
      "..." = "cd ../..";

      # dGPU (Framework 16)
      dgpu = "DRI_PRIME=1";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
