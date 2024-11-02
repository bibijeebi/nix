# modules/home/shells/starship/default.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.starship;
in {
  options.modules.starship = { enable = mkEnableOption "Starship"; };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
      enableFishIntegration = config.programs.fish.enable;
      enableBashIntegration = config.programs.bash.enable;

      settings = {
        add_newline = false;
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$cmd_duration"
          "$line_break"
          "$python"
          "$character"
        ];

        directory = {
          style = "blue";
          truncate_to_repo = true;
          truncation_length = 3;
        };

        git_branch = {
          symbol = "🌱 ";
          truncation_length = 4;
          truncation_symbol = "";
        };

        git_status = {
          format =
            "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };

        git_state = {
          format = "([$state( $progress_current/$progress_total)]($style)) ";
          style = "bright-black";
        };

        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };

        python = {
          format = "[$virtualenv]($style) ";
          style = "bright-black";
        };

        character = {
          success_symbol = "[❯](purple)";
          error_symbol = "[❯](red)";
          vicmd_symbol = "[❮](green)";
        };
      };
    };
  };
}
