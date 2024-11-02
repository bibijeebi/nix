# modules/nixos/media/default.nix
{ config, pkgs, lib, ... }:

with lib;

let cfg = config.modules.media;
in {
  options.modules.media = { enable = mkEnableOption "Media"; };

  config = mkIf cfg.enable {
    hardware = {
      pulseaudio.enable = false;
      graphics.enable = true;
    };

    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      # Media Tools
      ffmpeg
      ffmpegthumbnailer
      imagemagick
      imv
      mpv

      # Audio Tools
      pavucontrol
      pamixer
    ];

    # Requests manager for Jellyfin
    services.jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    # Media server configuration
    nixarr = {
      enable = true;
      vpn.enable = false;
      jellyfin.enable = true;
      transmission.enable = true;
      sonarr.enable = true;
      prowlarr.enable = true;
      radarr.enable = true;
    };

    musnix.enable = true;
  };
}
