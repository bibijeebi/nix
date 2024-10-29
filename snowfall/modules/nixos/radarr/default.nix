{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.radarr;

  # Helper function for creating standardized options
  mkOptStr = default: description:
    mkOption {
      type = types.str;
      inherit default description;
    };

  # Common option types
  mkOptBool = default: description:
    mkOption {
      type = types.bool;
      inherit default description;
    };

  mkOptInt = default: description:
    mkOption {
      type = types.int;
      inherit default description;
    };

  # Configuration file type
  configFile = {
    UrlBase = cfg.urlBase;
    APIKey = cfg.apiKey;
    AuthenticationMethod =
      if cfg.authentication.enable
      then "Forms"
      else "None";
    AuthenticationRequired = cfg.authentication.enable;
    IgnoreCertificateErrors = !cfg.certValidation;

    MediaManagement = {
      MovieFolders = cfg.rootFolders;
      RenameMovies = cfg.naming.renameMovies;
      ReplaceIllegalCharacters = cfg.naming.replaceIllegalChars;
      ColonReplacementFormat = cfg.naming.colonReplacement;
      UnmonitorDeletedMovies = cfg.unmonitorDeletedMovies;
    };

    Indexer = {
      MinimumAge = cfg.indexers.minimumAge;
      Retention = cfg.indexers.retention;
      MaximumSize = cfg.indexers.maxSize;
      AvailabilityDelay = cfg.indexers.availabilityDelay;
    };

    DownloadClient = {
      Enable = cfg.downloadClient.enable;
      RemotePathMappings =
        map (mapping: {
          LocalPath = mapping;
          RemotePath = mapping;
        })
        cfg.downloadClient.remotePathMappings;
    };

    LogLevel = cfg.logging.level;
    LogDir =
      if cfg.logging.dir != ""
      then cfg.logging.dir
      else "${cfg.dataDir}/logs";
    AnalyticsEnabled = cfg.analytics.enable;
    Theme = cfg.ui.theme;
    EnableColorImpairedMode = cfg.ui.colorImpaired;
    UILanguage = cfg.ui.language;
  };
in {
  options.services.radarr = {
    enable = mkEnableOption "Radarr Extended, a UsetNet/BitTorrent movie downloader";
    package = mkPackageOption pkgs "radarr" {};

    dataDir =
      mkOptStr "/var/lib/radarr/.config/Radarr"
      "The directory where Radarr Extended stores its data files.";

    openFirewall =
      mkOptBool false
      "Open ports in the firewall for the Radarr Extended web interface.";

    user =
      mkOptStr "radarr"
      "User account under which Radarr Extended runs.";

    group =
      mkOptStr "radarr"
      "Group under which Radarr Extended runs.";

    urlBase =
      mkOptStr ""
      "URL base for reverse proxy support.";

    authentication = {
      enable = mkOptBool false "";
      allowLocalAddresses = mkOptBool false "";
    };

    apiKey = mkOptStr "" "";
    certValidation = mkOptBool true "";
    rootFolders = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    naming = {
      renameMovies = mkOptBool true "";
      replaceIllegalChars = mkOptBool true "";
      colonReplacement = mkOption {
        type = types.enum ["delete" "dash" "space"];
        default = "delete";
      };
    };

    unmonitorDeletedMovies = mkOptBool false "";

    indexers = {
      minimumAge = mkOptInt 0 "";
      retention = mkOptInt 0 "";
      maxSize = mkOptInt 0 "";
      availabilityDelay = mkOptInt 0 "";
    };

    downloadClient = {
      enable = mkOptBool false "";
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
      dir = mkOptStr "" "";
    };

    analytics.enable = mkOptBool true "";

    ui = {
      theme = mkOption {
        type = types.enum ["auto" "light" "dark"];
        default = "auto";
      };
      colorImpaired = mkOptBool false "";
      language = mkOptStr "en" "";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-radarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    system.activationScripts.radarr-config = ''
      mkdir -p ${cfg.dataDir}
      echo '${builtins.toJSON configFile}' > ${cfg.dataDir}/config.json
      chown ${cfg.user}:${cfg.group} ${cfg.dataDir}/config.json
      chmod 600 ${cfg.dataDir}/config.json
    '';

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

        # Security hardening
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        PrivateTmp = true;
        ReadWritePaths = [cfg.dataDir];
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [7878];
    };

    users = mkIf (cfg.user == "radarr") {
      users.radarr = {
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.radarr;
        isSystemUser = true;
      };

      groups.radarr = mkIf (cfg.group == "radarr") {
        gid = config.ids.gids.radarr;
      };
    };
  };
}
