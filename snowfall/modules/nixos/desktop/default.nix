# modules/nixos/desktop/default.nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.desktop;
in {
  options.modules.desktop = {
    enable = mkEnableOption "Enable desktop environment";
  };

  config = mkIf cfg.enable {
    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
      };
      firefox.enable = true;
      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
      };
    };

    services = {
      xserver.xkb = {
        layout = "us";
        options = "caps:escape,terminate:ctrl_alt_bksp";
      };
      displayManager = {
        sddm = {
          enable = true;
          wayland.enable = true;
        };
        autoLogin = {
          enable = true;
          user = "bibi";
        };
      };
      tumbler.enable = true;
      gvfs.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    };

    # Font Configuration
    fonts.packages = [
      (pkgs.nerdfonts.override {
        fonts = [
          "CascadiaCode"
          "FiraCode"
          "JetBrainsMono"
          "Meslo"
          "SourceCodePro"
          "UbuntuMono"
        ];
      })
    ];

    environment.systemPackages = with pkgs; [
      # Desktop utilities
      dunst
      kitty
      pamixer
      pavucontrol
      swww
      waybar
      wofi
      wl-clipboard
    ];
  };
}
