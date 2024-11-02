# modules/home/shells/bash/default.nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.bash;
in {
  options.modules.bash = { enable = mkEnableOption "Bash shell"; };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      historyControl = [ "ignoredups" "ignorespace" ];
      historyFile = "$HOME/.bash_history";
      historyFileSize = 50000;
      historySize = 10000;

      initExtra = ''
        # Better history handling
        shopt -s histappend
        shopt -s cmdhist

        # Check window size after each command
        shopt -s checkwinsize

        # Extended pattern matching
        shopt -s extglob
        shopt -s globstar

        # Readline settings
        bind "set completion-ignore-case on"
        bind "set show-all-if-ambiguous on"
        bind "set mark-symlinked-directories on"
      '';

      shellAliases = {
        ai = "aichat";
        clp = "wl-copy";
        cls = "clear";
        pst = "wl-paste";
        t = "task";
        ya = "yazi";
      };

      # Bash completion settings
      enableCompletion = true;
      bashrcExtra = ''
        # Add custom completion scripts here if needed
      '';
    };
  };
}
