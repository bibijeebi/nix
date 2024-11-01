{ config, lib, pkgs, ... }:
with lib;
let cfg = config.programs.qimgv;
in {
  options.programs.qimgv = {
    enable = mkEnableOption "qimgv image viewer";

    package = mkOption {
      type = types.package;
      default = pkgs.qimgv;
      description = "The qimgv package to use";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          panelPosition = "bottom";
          backgroundOpacity = 100;
          imageFitMode = "fit_window";
          maxZoom = 2.0;
          showImageName = true;
          sortingMode = "name";
          playbackMode = "single";
          usePreloader = true;
          expandImage = false;
          expandLimit = 2;
          smoothUpscaling = true;
          smoothDownscaling = true;
          warnMouseDrag = false;
          videoPlayCommand = "mpv --";
        }
      '';
      description = "Configuration options for qimgv";
    };

    keybindings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          next_image = "right";
          previous_image = "left";
          zoom_in = "up";
          zoom_out = "down";
          exit_fullscreen = "escape";
          toggle_fullscreen = "f";
          open_file = "o";
          save_file = "s";
          delete_file = "delete";
          copy = "c";
          paste = "v";
          toggle_panel = "tab";
        }
      '';
      description = "Custom keybindings for qimgv";
    };

    defaultApplications =
      mkEnableOption "Register qimgv as default image viewer";
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # qimgv stores its config in ~/.config/qimgv/qimgv.conf
    xdg.configFile."qimgv/qimgv.conf".text = let
      # Convert the settings to an INI-like format that qimgv expects
      formatValue = v:
        if isBool v then (if v then "true" else "false") else toString v;

      formatSection = name: attrs:
        ''
          [${name}]
        '' + concatStrings (mapAttrsToList (k: v: ''
          ${k}=${formatValue v}
        '') attrs);

      configSections = {
        General = cfg.settings;
        Shortcuts = cfg.keybindings;
      };

      configText = concatStrings (mapAttrsToList formatSection
        (filterAttrs (n: v: v != { }) configSections));
    in configText;

    # Optionally set as default image viewer
    xdg.mimeApps = mkIf cfg.defaultApplications {
      defaultApplications = {
        "image/jpeg" = [ "qimgv.desktop" ];
        "image/png" = [ "qimgv.desktop" ];
        "image/gif" = [ "qimgv.desktop" ];
        "image/bmp" = [ "qimgv.desktop" ];
        "image/webp" = [ "qimgv.desktop" ];
      };
    };
  };
}
