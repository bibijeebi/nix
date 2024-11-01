{ config, inputs, modulesPath, pkgs, ... }:
{
  imports = [ 
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # System Configuration
  system = {
    stateVersion = "24.11";
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      channel = "https://nixos.org/channels/nixos-unstable";
    };
  };

  # Boot Configuration
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
    timeout = 1;
  };

  # Hardware Configuration
  hardware.cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;
  swapDevices = [ ];

  # Network Configuration
  networking.useDHCP = true;

  # Nix Configuration
  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    registry.nixpkgs.flake = inputs.nixpkgs;

    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
      
      # Cache Configuration
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

  # Package Configuration
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "x86_64-linux";
  };

  # Environment Configuration
  environment = {
    binsh = "${pkgs.dash}/bin/dash";
    systemPackages = with pkgs; [
      # Development Tools
      alejandra deadnix direnv git gh home-manager nix-direnv
      nix-output-monitor nixfmt-classic

      # System Tools
      coreutils htop parallel tmux tree usbutils

      # Shell Tools
      bash fish zsh bc curl eza fd jq ripgrep zoxide

      # File Management
      fdupes file p7zip unzip zip

      # Media Tools
      ffmpeg ffmpegthumbnailer imagemagick imv mpv
      
      # Document Tools
      glow pandoc poppler_utils
      
      # Network Tools
      nmap openvpn wget
      
      # Other Utilities
      inotify-tools kitty manix pamixer pavucontrol pup
      sqlite taskwarrior vim wl-clipboard yq
    ];
  };

  # Font Configuration
  fonts.packages = [
    (pkgs.nerdfonts.override {
      fonts = [
        "BigBlueTerminal" "CascadiaCode" "CascadiaMono"
        "ComicShannsMono" "DaddyTimeMono" "FantasqueSansMono"
        "FiraCode" "FiraMono" "Gohu" "HeavyData" "Hermit"
        "Meslo" "OpenDyslexic" "ProggyClean" "ShareTechMono"
        "SourceCodePro" "Terminus" "Ubuntu" "UbuntuMono"
      ];
    })
  ];

  # Security Configuration
  security = {
    rtkit.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraRules = [{
        groups = [ "wheel" ];
        commands = builtins.map
          (command: {
            inherit command;
            options = [ "NOPASSWD" ];
          })
          [
            "${pkgs.systemd}/bin/shutdown"
            "${pkgs.systemd}/bin/reboot"
          ];
      }];
    };
  };

  # User Configuration
  users.users.bibi = {
    isNormalUser = true;
    extraGroups = [
      "wheel" "networkmanager" "video"
      "audio" "input" "docker" "libvirtd"
    ];
    shell = pkgs.fish;
    hashedPassword = "$6$qUiGCyo2rV6J.F2n$LWRdYGXUC.9trlQHWFjFJPBsd.nAkktcwlJNWZAtsZIyRt02AnO713q32hSJ0QxPWYzban3ekl64r6ny.XgHT/";
  };
}