{
  config,
  inputs,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  nixpkgs.config.allowUnfree = true;

  swapDevices = [ ]; # No swap configured

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  environment = {
    binsh = "${pkgs.dash}/bin/dash";
    systemPackages = builtins.attrValues {
      inherit (pkgs)
        bash
        coreutils
        home-manager
        pulseaudio
        usbutils
        ;
    };
  };

  users.users.bibi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "video"
      "audio"
      "input"
    ];
    shell = pkgs.fish;
    hashedPassword = "$6$qUiGCyo2rV6J.F2n$LWRdYGXUC.9trlQHWFjFJPBsd.nAkktcwlJNWZAtsZIyRt02AnO713q32hSJ0QxPWYzban3ekl64r6ny.XgHT/";
  };

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      keep-outputs = true;
      keep-derivations = true;
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 7d";
    };
  };

  fonts.packages = [
    (pkgs.nerdfonts.override {
      fonts = [
        "BigBlueTerminal"
        "CascadiaCode"
        "CascadiaMono"
        "ComicShannsMono"
        "DaddyTimeMono"
        "FantasqueSansMono"
        "FiraCode"
        "FiraMono"
        "Gohu"
        "HeavyData"
        "Hermit"
        "Meslo"
        "OpenDyslexic"
        "ProggyClean"
        "ShareTechMono"
        "SourceCodePro"
        "Terminus"
        "Ubuntu"
        "UbuntuMono"
      ];
    })
  ];

  security = {
    rtkit.enable = true;

    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [
        {
          groups = [ "wheel" ];
          commands =
            builtins.map
              (command: {
                inherit command;
                options = [ "NOPASSWD" ];
              })
              [
                "${pkgs.systemd}/bin/shutdown"
                "${pkgs.systemd}/bin/reboot"
              ];
        }
      ];
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
