{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.radarr;
in {
  options.services.radarr = {
    # Inherit existing options from the original module
    # Add your new custom options here
    customConfigFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Custom configuration file to use for Radarr";
    };

    mediaPermissions = mkOption {
      type = types.str;
      default = "766";
      description = "Permissions for media files downloaded by Radarr";
    };

    customDataDir = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Custom data directory for Radarr";
    };

    # Add more custom options as needed
    additionalArgs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional command-line arguments to pass to Radarr";
    };
  };

  config = mkMerge [
    # Include the original configuration
    (mkIf cfg.enable {
      systemd.services.radarr = {
        serviceConfig = mkMerge [
          # Extend the existing service configuration
          (mkIf (cfg.customConfigFile != null) {
            ExecStart = mkForce "${pkgs.radarr}/bin/Radarr -c ${cfg.customConfigFile} ${toString cfg.additionalArgs}";
          })
          (mkIf (cfg.customDataDir != null) {
            StateDirectory = mkForce cfg.customDataDir;
          })
        ];

        # Add custom environment variables if needed
        environment = {
          RADARR_MEDIA_PERMISSIONS = cfg.mediaPermissions;
        };
      };
    })
  ];
}
