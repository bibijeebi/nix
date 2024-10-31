{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) types mkOption mkIf mkMerge;
  cfg = config.programs.alf;
in {
  options.programs.alf = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable Alf alias manager.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.alf;
      description = "The Alf package to use.";
    };

    settings = mkOption {
      type = types.attrsOf (types.attrsOf (types.nullOr (types.either types.str (types.listOf types.str))));
      default = {};
      example = lib.literalExpression ''
        {
          # Git aliases
          git = {
            s = "status";
            p = "pull";
            b = "branch";
          };
          # Docker aliases
          docker = {
            ps = "ps -a";
            i = "images";
          };
        }
      '';
      description = "Alf aliases configuration.";
    };

    githubRepo = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "username/alf-conf";
      description = "GitHub repository to sync aliases with (username/repo format).";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [ cfg.package ];

      # Ensure bash 4.0+ is available as it's required by alf
      programs.bash.enable = true;

      # Generate alf.conf file
      xdg.configFile."alf/alf.conf".text = let
        # Convert settings to alf.conf format
        formatAliases = namespace: aliases:
          lib.concatStringsSep "\n" (lib.mapAttrsToList
            (name: cmd:
              if cmd == null then ""
              else if builtins.isList cmd
              then "${namespace} ${name} = ${lib.escapeShellArgs cmd}"
              else "${namespace} ${name} = ${cmd}")
            aliases);

        aliasesText = lib.concatStringsSep "\n\n" (lib.mapAttrsToList
          (namespace: aliases: formatAliases namespace aliases)
          cfg.settings);
      in ''
        # Generated by Home Manager
        ${aliasesText}
      '';

      # Add source ~/.bash_aliases to shell rc files
      programs.bash.initExtra = ''
        if [ -f ~/.bash_aliases ]; then
          source ~/.bash_aliases
        fi
      '';

      programs.zsh.initExtra = ''
        if [ -f ~/.bash_aliases ]; then
          source ~/.bash_aliases
        fi
      '';

      # Add zsh completion setup if using zsh
      programs.zsh.enableCompletion = true;
      programs.zsh.initExtra = ''
        # Load completion functions for alf
        autoload -Uz +X compinit && compinit
        autoload -Uz +X bashcompinit && bashcompinit
      '';
    }

    (mkIf (cfg.githubRepo != null) {
      # Set up GitHub repository connection if specified
      home.activation.alfSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD ${cfg.package}/bin/alf connect ${cfg.githubRepo}
      '';
    })
  ]);
}