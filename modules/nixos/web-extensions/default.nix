# modules/web-extensions/default.nix
{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.chromium.webext;

  # Import your buildChromeExtension

  # Extension submodule type
  extensionOpts = types.submodule {
    options = {
      enable = mkEnableOption "this extension";
      package = mkOption {
        type = types.package;
        description = "The extension package";
      };
    };
  };
in {
  options = {
    programs.chromium.webext = {
      enable = mkEnableOption "web extension support";

      extensions = mkOption {
        type = types.attrsOf extensionOpts;
        default = {};
        description = "Set of extensions to install";
        example = literalExpression ''
          {
            altdown = {
              enable = true;
              package = pkgs.web-extensions.altdown;
            };
          }
        '';
      };

      allowFileAccess = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to allow extensions to access local files";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      extensions =
        map
        (ext: ext.package.extensionString)
        (filter (ext: ext.enable) (attrValues cfg.extensions));

      extraOpts = {
        # Basic extension requirements
        ExtensionInstallSources = mkIf cfg.allowFileAccess [
          "file://*"
          "https://*"
        ];

        ExtensionManifestV2Availability = 1;

        # Allow external extensions
        BlockExternalExtensions = false;

        # Default extension settings
        ExtensionSettings = {
          "*" = {
            installation_mode = "allowed";
            allowed_types = ["extension" "user_script"];
          };
        };

        # You could add more reasonable defaults here
      };
    };
  };
}
