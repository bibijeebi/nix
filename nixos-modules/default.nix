{ config, inputs, lib, modulesPath, pkgs, ... }:
let
  systemPackages = builtins.attrValues {
    inherit (pkgs) bash coreutils home-manager pulseaudio usbutils;
  };
in {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ../overlays ];

  nixpkgs.config = import ../nixpkgs-config.nix;

  swapDevices = [ ]; # No swap configured

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  environment = {
    inherit systemPackages;
    binSh = "${pkgs.dash}/bin/dash";
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";

    settings = {
      trusted-users = [ "@wheel" ];
      trusted-substituters = [ "https://nix-community.cachix.org" ];
      extra-substituters = [ "https://nix-community.cachix.org" ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };

    registry.nixpkgs.flake = inputs.nixpkgs;

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  fonts.packages = with pkgs; [
    cascadia-code
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
  ];

  security = {
    rtkit.enable = true;

    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [{
        groups = [ "wheel" ];
        commands = builtins.map (command: {
          inherit command;
          options = [ "NOPASSWD" ];
        }) [ "${pkgs.systemd}/bin/shutdown" "${pkgs.systemd}/bin/reboot" ];
      }];
    };
  };

  system = {
    stateVersion = "24.11";
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      channel = "https://nixos.org/channels/nixos-unstable";
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };

}
