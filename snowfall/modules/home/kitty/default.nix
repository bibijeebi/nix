# modules/home/kitty/default.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.kitty;
in {
  options.modules.kitty = { enable = mkEnableOption "Waybar configuration"; };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";
      font = {
        package = pkgs.nerdfonts;
        name = "CaskaydiaCove Nerd Font";
        size = 11;
      };
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
      };
    };
  };
}
