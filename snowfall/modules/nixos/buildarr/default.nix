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
      default = "/var/lib/buildarr/buildarr.yml";
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

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/buildarr";
      description = "Directory for Buildarr data files";
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

    prowlarr = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          hostname = mkOption {
            type = types.str;
            default = "localhost";
          };
          apiKey = mkOption {
            type = types.str;
          };
        };
      });
      default = null;
      description = "Prowlarr configuration";
    };

    jellyseerr = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          hostname = mkOption {
            type = types.str;
            default = "localhost";
          };
          apiKey = mkOption {
            type = types.str;
          };
        };
      });
      default = null;
      description = "Jellyseerr configuration";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-buildarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0750";
    };

    systemd.services.buildarr = {
      description = "Buildarr Service";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      preStart = ''
        # Generate buildarr config file
        ${pkgs.yq}/bin/yq -y . > ${cfg.configFile} << EOF
        ${builtins.toJSON mkBuildarrConfig}
        EOF

        # Set correct permissions
        chown ${cfg.user}:${cfg.group} ${cfg.configFile}
        chmod 600 ${cfg.configFile}
      '';

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${buildarrPkg}/bin/buildarr --config ${cfg.configFile} daemon";
        Restart = "on-failure";
        RestartSec = "10s";

        # Hardening options (retained from your original config)
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
          cfg.dataDir
        ];
      };
    };

    users.users = mkIf (cfg.user == "buildarr") {
      buildarr = {
        isSystemUser = true;
        group = cfg.group;
        home = cfg.dataDir;
      };
    };

    users.groups = mkIf (cfg.group == "buildarr") {
      buildarr = {};
    };

    services.sonarr.enable = mkIf (cfg.sonarr != null) false;
    services.radarr.enable = mkIf (cfg.radarr != null) false;
    services.prowlarr.enable = mkIf (cfg.prowlarr != null) false;
    services.jellyseerr.enable = mkIf (cfg.jellyseerr != null) false;
  };
}
