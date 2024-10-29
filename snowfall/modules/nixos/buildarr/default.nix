{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.buildarr;

  # Import your buildarr derivation
  buildarrPkg = pkgs.internal.buildarr;

  # Helper function to generate service config
  mkServiceConfig = name: serviceCfg: {
    inherit (serviceCfg) hostname port protocol;
    api_key = serviceCfg.apiKey;
    settings = serviceCfg.settings;
  };

  # Convert Nix config to YAML for buildarr
  mkBuildarrConfig = {
    buildarr = {
      watch_config = cfg.watchConfig;
      update_days = cfg.updateDays;
      update_times = cfg.updateTimes;
    };

    sonarr = optionalAttrs (cfg.sonarr != null) (mkServiceConfig "sonarr" cfg.sonarr);
    radarr = optionalAttrs (cfg.radarr != null) (mkServiceConfig "radarr" cfg.radarr);
    prowlarr = optionalAttrs (cfg.prowlarr != null) (mkServiceConfig "prowlarr" cfg.prowlarr);
    jellyseerr = optionalAttrs (cfg.jellyseerr != null) (mkServiceConfig "jellyseerr" cfg.jellyseerr);
  };
in {
  options.services.buildarr = {
    enable = mkEnableOption "Buildarr service";

    configFile = mkOption {
      type = types.str;
      default = "/etc/buildarr/buildarr.yml";
      description = "Path to Buildarr configuration file";
    };

    watchConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Watch configuration files for changes";
    };

    updateDays = mkOption {
      type = types.listOf types.str;
      default = ["monday" "tuesday" "wednesday" "thursday" "friday" "saturday" "sunday"];
      description = "Days to perform updates";
    };

    updateTimes = mkOption {
      type = types.listOf types.str;
      default = ["03:00"];
      description = "Times to perform updates";
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/buildarr";
      description = "Directory for Buildarr state files";
    };

    user = mkOption {
      type = types.str;
      default = "buildarr";
      description = "User account under which Buildarr runs";
    };

    group = mkOption {
      type = types.str;
      default = "buildarr";
      description = "Group under which Buildarr runs";
    };

    sonarr = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          hostname = mkOption {
            type = types.str;
            default = "localhost";
          };
          port = mkOption {
            type = types.port;
            default = 8989;
          };
          protocol = mkOption {
            type = types.enum ["http" "https"];
            default = "http";
          };
          apiKey = mkOption {
            type = types.str;
          };
          settings = mkOption {
            type = types.attrs;
            default = {};
          };
        };
      });
      default = null;
      description = "Sonarr configuration";
    };

    radarr = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          hostname = mkOption {
            type = types.str;
            default = "localhost";
          };
          port = mkOption {
            type = types.port;
            default = 7878;
          };
          protocol = mkOption {
            type = types.enum ["http" "https"];
            default = "http";
          };
          apiKey = mkOption {
            type = types.str;
          };
          settings = mkOption {
            type = types.attrs;
            default = {};
          };
        };
      });
      default = null;
      description = "Radarr configuration";
    };

    # Similar options for prowlarr and jellyseerr...
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.stateDir;
      createHome = true;
    };

    users.groups.${cfg.group} = {};

    systemd.services.buildarr = {
      description = "Buildarr Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${buildarrPkg}/bin/buildarr --config ${cfg.configFile} daemon";
        Restart = "on-failure";
        RestartSec = "10s";

        # Hardening options
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        MemoryDenyWriteExecute = true;
        LockPersonality = true;

        # Required directories
        ReadWritePaths = [
          cfg.stateDir
          dirOf
          cfg.configFile
        ];
      };

      preStart = ''
        # Ensure config directory exists
        mkdir -p ${dirOf cfg.configFile}

        # Generate buildarr config file
        ${pkgs.yq}/bin/yq -y . > ${cfg.configFile} << EOF
        ${builtins.toJSON mkBuildarrConfig}
        EOF

        # Set correct permissions
        chown ${cfg.user}:${cfg.group} ${cfg.configFile}
        chmod 600 ${cfg.configFile}
      '';
    };
  };
}
