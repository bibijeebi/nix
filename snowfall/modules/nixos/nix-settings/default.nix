# modules/nixos/nix-settings/default.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.nix-settings;
in {
  options.modules.nix-settings = { enable = mkEnableOption "Nix settings"; };

  config = mkIf cfg.enable {
    nix = {
      settings = {
        auto-optimise-store = true;
        trusted-users = [ "@wheel" ];
        experimental-features = [ "nix-command" "flakes" ];

        # Cache Configuration
        substituters =
          [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        trusted-substituters =
          [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];

        keep-outputs = true;
        keep-derivations = true;
      };

      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 7d";
      };
    };
  };
}
