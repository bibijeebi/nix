# modules/home/shells/zsh/default.nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.zsh;
in {
  options.modules.zsh = { enable = mkEnableOption "Zsh shell"; };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        # Custom initialization
        setopt AUTO_CD
        setopt EXTENDED_GLOB
        setopt NOMATCH
        setopt NOTIFY
        setopt PROMPT_SUBST

        # History settings
        setopt EXTENDED_HISTORY
        setopt HIST_EXPIRE_DUPS_FIRST
        setopt HIST_FIND_NO_DUPS
        setopt HIST_IGNORE_DUPS
        setopt HIST_IGNORE_SPACE
        setopt HIST_VERIFY
        setopt SHARE_HISTORY
      '';

      history = {
        size = 50000;
        save = 50000;
        ignoreDups = true;
        expireDuplicatesFirst = true;
        share = true;
      };

      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.8.0";
            sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
          };
        }
        {
          name = "zsh-autopair";
          file = "autopair.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "hlissner";
            repo = "zsh-autopair";
            rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
            sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
          };
        }
      ];

      shellAliases = {
        ai = "aichat";
        clp = "wl-copy";
        cls = "clear";
        pst = "wl-paste";
        t = "task";
        ya = "yazi";
      };
    };
  };
}
