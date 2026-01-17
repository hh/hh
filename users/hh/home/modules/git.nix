# Git configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;

    userName = "Hippie Hacker";
    userEmail = "chris@mcclimans.net";

    ignores = [
      ".DS_Store"
      ".Trash-*"
      "*.swp"
      ".direnv"
      ".envrc"
      "result"
      "result-*"
    ];

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      merge.conflictstyle = "diff3";
      rerere.enabled = true;
      advice.skippedCherryPicks = false;
      core.excludesFile = "~/.gitignore";
    };

    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "Dracula";
      };
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
