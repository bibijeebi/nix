# modules/home/shells/tools/default.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.tools;
in {
  options.modules.tools = {
    enable = mkEnableOption "common shell tools and utilities";
  };

  config = mkIf cfg.enable {
    programs = {
      # File navigation and search
      bat.enable = true;
      eza.enable = true;
      fd.enable = true;
      fzf = {
        enable = true;
        enableZshIntegration = config.programs.zsh.enable;
        enableFishIntegration = config.programs.fish.enable;
        enableBashIntegration = config.programs.bash.enable;
      };
      zoxide = {
        enable = true;
        enableZshIntegration = config.programs.zsh.enable;
        enableFishIntegration = config.programs.fish.enable;
        enableBashIntegration = config.programs.bash.enable;
      };
      yazi.enable = true;

      # Development tools
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };

      # System monitoring
      btop.enable = true;
      htop.enable = true;

      # Text processing
      ripgrep.enable = true;
      jq.enable = true;

      # Terminal multiplexer
      tmux = {
        enable = true;
        clock24 = true;
        keyMode = "vi";
        terminal = "screen-256color";
        plugins = with pkgs.tmuxPlugins; [
          cpu
          resurrect
          continuum
          better-mouse-mode
        ];
      };
    };

    home = {
      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        PAGER = "less";
        LESS = "-R";
        FZF_DEFAULT_COMMAND = "fd --type f";
      };

      packages = with pkgs; [
        curl
        wget
        tree
        unzip
        zip
        lsof
        ncdu
        parallel
        pv
        xh
        bottom
      ];
    };
  };
}
