{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.services.radarr-extended;
in {
  options = {
    services.radarr-extended = {
      enable = mkEnableOption "Radarr Extended, a UsetNet/BitTorrent movie downloader";

      package = mkPackageOption pkgs "radarr-extended" {};

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/radarr-extended/.config/Radarr";
        description = "The directory where Radarr Extended stores its data files.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the Radarr Extended web interface.";
      };

      user = mkOption {
        type = types.str;
        default = "radarr-extended";
        description = "User account under which Radarr Extended runs.";
      };

      group = mkOption {
        type = types.str;
        default = "radarr-extended";
        description = "Group under which Radarr Extended runs.";
      };

      #============================================================================
      # Custom Options
      #============================================================================

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
    systemd.tmpfiles.settings."10-radarr-extended".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.radarr-extended = {
      description = "Radarr Extended";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/Radarr -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [7878];
    };

    users.users = mkIf (cfg.user == "radarr-extended") {
      radarr-extended = {
        group = cfg.group;
        home = cfg.dataDir;
        uid = config.ids.uids.radarr-extended;
      };
    };

    users.groups = mkIf (cfg.group == "radarr-extended") {
      radarr-extended.gid = config.ids.gids.radarr-extended;
    };
  };
}
