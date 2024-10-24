# modules/home-manager/web-extensions/default.nix
{ config, lib, ... }:

with lib;

let
  cfg = config.programs.chromium;
  webExtCfg = cfg.webext;

  extensionOptions = { ... }: {
    options = {
      enable = mkEnableOption "extension";
      package = mkOption {
        type = types.package;
        description = "The extension package";
      };
    };
  };

  enabledExtensions = filterAttrs (_n: e: e.enable) webExtCfg.extensions;

  extensionPolicies = mapAttrs' (_name: ext: 
    nameValuePair ext.package.extensionId {
      installation_mode = "force_installed";
      update_url = "file://${ext.package}/share/chrome-extensions/update.xml";
    }
  ) enabledExtensions;

  chromePolicies = {
    ExtensionSettings = extensionPolicies;
    ExtensionInstallForcelist = map (ext: 
      "${ext.package.extensionId};file://${ext.package}/share/chrome-extensions/update.xml"
    ) (attrValues enabledExtensions);
  };

in {
  options.programs.chromium.webext = {
    enable = mkEnableOption "Chrome extension management";

    extensions = mkOption {
      type = types.attrsOf (types.submodule extensionOptions);
      default = {};
      description = "Set of extensions to install";
    };

    globalPolicy = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Chrome policies to apply";
    };
  };

  config = mkIf (cfg.enable && webExtCfg.enable) {
    # Create Chrome policies in home directory
    xdg.configFile = {
      "chrome-policies/managed/extensions.json".text = 
        builtins.toJSON (chromePolicies // webExtCfg.globalPolicy);
      
      # Also support Chromium policies
      "chromium-policies/managed/extensions.json".text = 
        builtins.toJSON (chromePolicies // webExtCfg.globalPolicy);
    };

    # Add extensions to home packages
    home.packages = map (ext: ext.package) (attrValues enabledExtensions);
  };
}
