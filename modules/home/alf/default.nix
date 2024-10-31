{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.alf;

  # Type for Alf configuration file entries
  alfConfigType = with types;
    attrsOf (oneOf [str (listOf str) (attrsOf (either str (listOf str)))]);
in {
  meta.maintainers = [maintainers.fill-in-your-name];

  options.programs.alf = {
    enable = mkEnableOption "Alf - Your Little Bash Alias Friend";

    package = mkOption {
      type = types.package;
      default = pkgs.alf;
      defaultText = literalExpression "pkgs.alf";
      description = "The Alf package to install.";
    };

    settings = mkOption {
      type = alfConfigType;
      default = {};
      example = literalExpression ''
        {
          git = {
            s = "status";
            l = "log --oneline";
            p = "push";
          };
          docker = {
            ps = "ps -a";
            i = "images";
          };
        }
      '';
      description = ''
        Configuration written to the Alf configuration file.
        Each attribute defines a command namespace, and its value can be either:
        - A string representing a simple alias
        - A list of strings for a complex command
        - An attribute set of aliases for sub-commands
      '';
    };

    githubRepo = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "username/alf-conf";
      description = ''
        Optional GitHub repository to sync aliases with.
        Should be in the format "username/repository".
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.githubRepo
          == null
          || (builtins.match "([^/]+)/([^/]+)" cfg.githubRepo) != null;
        message = ''
          The githubRepo option must be in the format "username/repository".
          Got: ${toString cfg.githubRepo}
        '';
      }
    ];

    home.packages = [cfg.package];

    # Required by Alf
    programs.bash.enable = true;

    xdg.configFile."alf/alf.conf".text = let
      # Convert settings to Alf config format
      formatAliases = namespace: aliases:
        if isString aliases
        then "${namespace} = ${aliases}"
        else if isList aliases
        then "${namespace} = ${concatStringsSep " " aliases}"
        else
          concatStringsSep "\n"
          (mapAttrsToList (name: cmd: formatAliases "${namespace} ${name}" cmd)
            aliases);
    in
      concatStringsSep "\n" (mapAttrsToList formatAliases cfg.settings);

    # Source bash_aliases in shells
    home.file.".bash_aliases".source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.xdg.configHome}/bash_aliases";

    programs.bash.initExtra = ''
      if [ -f ~/.bash_aliases ]; then
        source ~/.bash_aliases
      fi
    '';

    programs.zsh.initExtra = mkIf config.programs.zsh.enable ''
      if [ -f ~/.bash_aliases ]; then
        source ~/.bash_aliases
      fi
    '';

    # Set up GitHub integration if requested
    home.activation.alfSetup =
      mkIf (cfg.githubRepo != null)
      (lib.hm.dag.entryAfter ["writeBoundary"] ''
        if [[ ! -f "$HOME/.alfrc" ]] || ! grep -q "${cfg.githubRepo}" "$HOME/.alfrc"; then
          $DRY_RUN_CMD ${cfg.package}/bin/alf connect ${cfg.githubRepo}
        fi
      '');

    # shellInit, promptInit, loginShellInit, interactiveShellInit
    programs.zsh. = mkIf config.programs.zsh.enable ''
      # Load completion functions for Alf
      autoload -Uz +X compinit && compinit
      autoload -Uz +X bashcompinit && bashcompinit
    '';
  };
}
