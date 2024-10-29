{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.radarr;
in {
  options = {
    services.radarr = {
      # Keep existing enable option
      enable = mkEnableOption "Radarr Extended, a UsetNet/BitTorrent movie downloader";
      # Keep existing package option
      package = mkPackageOption pkgs "radarr" {};
      # Keep existing dataDir option
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/radarr/.config/Radarr";
        description = "The directory where Radarr Extended stores its data files.";
      };
      # Keep existing openFirewall option
      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the Radarr Extended web interface.";
      };
      # Keep existing user option
      user = mkOption {
        type = types.str;
        default = "radarr";
        description = "User account under which Radarr Extended runs.";
      };
      # Keep existing group option
      group = mkOption {
        type = types.str;
        default = "radarr";
        description = "Group under which Radarr Extended runs.";
      };
      urlBase = mkOption {
        type = types.str;
        default = "";
        description = "URL base for reverse proxy support.";
      };
      authentication = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
        allowLocalAddresses = mkOption {
          type = types.bool;
          default = false;
        };
      };
      apiKey = mkOption {
        type = types.str;
        default = "";
      };
      certValidation = mkOption {
        type = types.bool;
        default = true;
      };
      rootFolders = mkOption {
        type = types.listOf types.str;
        default = [];
      };
      naming = {
        renameMovies = mkOption {
          type = types.bool;
          default = true;
        };
        replaceIllegalChars = mkOption {
          type = types.bool;
          default = true;
        };
        colonReplacement = mkOption {
          type = types.enum ["delete" "dash" "space"];
          default = "delete";
        };
      };
      unmonitorDeletedMovies = mkOption {
        type = types.bool;
        default = false;
      };
      indexers = {
        minimumAge = mkOption {
          type = types.int;
          default = 0;
        };
        retention = mkOption {
          type = types.int;
          default = 0;
        };
        maxSize = mkOption {
          type = types.int;
          default = 0;
        };
        availabilityDelay = mkOption {
          type = types.int;
          default = 0;
        };
      };
      downloadClient = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
        remotePathMappings = mkOption {
          type = types.listOf types.str;
          default = [];
        };
      };
      logging = {
        level = mkOption {
          type = types.enum ["info" "debug" "trace"];
          default = "info";
        };
        dir = mkOption {
          type = types.str;
          default = "";
        };
      };
      analytics = {
        enable = mkOption {
          type = types.bool;
          default = true;
        };
      };
      ui = {
        theme = mkOption {
          type = types.enum ["auto" "light" "dark"];
          default = "auto";
        };
        colorImpaired = mkOption {
          type = types.bool;
          default = false;
        };
        language = mkOption {
          type = types.str;
          default = "en";
        };
      };
    };
  };
  config = mkIf cfg.enable {
    # Keep existing tmpfiles setup
    systemd.tmpfiles.settings."10-radarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };
    # Add config file generation
    system.activationScripts.radarr-config = let
      configFile = builtins.toJSON {
        # Main settings
        UrlBase = cfg.urlBase;
        APIKey = cfg.apiKey;
        AuthenticationMethod =
          if cfg.authentication.enable
          then "Forms"
          else "None";
        AuthenticationRequired = cfg.authentication.enable;
        IgnoreCertificateErrors = !cfg.certValidation;
        # Root folders configuration
        MediaManagement = {
          MovieFolders = cfg.rootFolders;
          RenameMovies = cfg.naming.renameMovies;
          ReplaceIllegalCharacters = cfg.naming.replaceIllegalChars;
          ColonReplacementFormat = cfg.naming.colonReplacement;
          UnmonitorDeletedMovies = cfg.unmonitorDeletedMovies;
        };
        # Indexer settings
        Indexer = {
          MinimumAge = cfg.indexers.minimumAge;
          Retention = cfg.indexers.retention;
          MaximumSize = cfg.indexers.maxSize;
          AvailabilityDelay = cfg.indexers.availabilityDelay;
        };
        # Download client settings
        DownloadClient = {
          Enable = cfg.downloadClient.enable;
          RemotePathMappings =
            map (mapping: {
              LocalPath = mapping;
              RemotePath = mapping;
            })
            cfg.downloadClient.remotePathMappings;
        };
        # Logging configuration
        LogLevel = cfg.logging.level;
        LogDir =
          if cfg.logging.dir != ""
          then cfg.logging.dir
          else "${cfg.dataDir}/logs";
        # Analytics and UI settings
        AnalyticsEnabled = cfg.analytics.enable;
        Theme = cfg.ui.theme;
        EnableColorImpairedMode = cfg.ui.colorImpaired;
        UILanguage = cfg.ui.language;
      };
    in ''
      mkdir -p ${cfg.dataDir}
      echo '${configFile}' > ${cfg.dataDir}/config.json
      chown ${cfg.user}:${cfg.group} ${cfg.dataDir}/config.json
      chmod 600 ${cfg.dataDir}/config.json
    '';
    # Keep existing systemd service
    systemd.services.radarr = {
      description = "Radarr Extended";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/Radarr -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
        # Add some hardening options
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateTmp = true;
        ReadWritePaths = [cfg.dataDir];
      };
    };
    # Keep existing firewall config
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [7878];
    };
    # Keep existing user/group setup
    users.users = mkIf (cfg.user == "radarr") {
      radarr = {
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.radarr;
        isSystemUser = true;
      };
    };
    users.groups = mkIf (cfg.group == "radarr") {
      radarr = {
        gid = config.ids.gids.radarr;
      };
    };
  };
}
