{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.aichat;
in {
  options.programs.aichat = {
    enable = mkEnableOption "aichat CLI tool";

    package = mkOption {
      type = types.package;
      default = pkgs.aichat;
      description = "The aichat package to use";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Configuration options for aichat";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."aichat/config.yaml".text =
      lib.generators.toYAML {} cfg.settings;
  };
}