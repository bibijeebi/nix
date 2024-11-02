# systems/x86_64-linux/nixxie/default.nix
{ lib, pkgs, modulesPath, ... }: {
  modules = {
    desktop.enable = true;
    dev-tools.enable = true;
    media.enable = true;
    nix-settings.enable = true;
    security.enable = true;
  };

  # Environment Configuration
  environment = {
    binsh = "${pkgs.dash}/bin/dash";
    systemPackages = with pkgs; [
      # Development Tools
      alejandra
      deadnix
      direnv
      git
      gh
      home-manager
      nix-direnv
      nix-output-monitor
      nixfmt-classic

      # System Tools
      coreutils
      htop
      parallel
      tmux
      tree
      usbutils

      # Shell Tools
      bash
      fish
      zsh
      bc
      curl
      eza
      fd
      jq
      ripgrep
      zoxide

      # File Management
      fdupes
      file
      p7zip
      unzip
      zip
    ];
  };

  # Security Configuration
  security = {
    rtkit.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
      extraRules = [{
        groups = [ "wheel" ];
        commands = builtins.map (command: {
          inherit command;
          options = [ "NOPASSWD" ];
        }) [ "${pkgs.systemd}/bin/shutdown" "${pkgs.systemd}/bin/reboot" ];
      }];
    };
  };

  # User Configuration
  users.users.bibi = {
    isNormalUser = true;
    extraGroups =
      [ "wheel" "networkmanager" "video" "audio" "input" "docker" "libvirtd" ];
    shell = pkgs.fish;
    hashedPassword =
      "$6$qUiGCyo2rV6J.F2n$LWRdYGXUC.9trlQHWFjFJPBsd.nAkktcwlJNWZAtsZIyRt02AnO713q32hSJ0QxPWYzban3ekl64r6ny.XgHT/";
  };

  programs.fish.enable = true;

  # Services Configuration
  services = {
    xserver.xkb = {
      layout = "us";
      options = "caps:escape,terminate:ctrl_alt_bksp";
    };
    udisks2.enable = true;
    tumbler.enable = true;
    gvfs.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    openssh.enable = true;
  };

  # System Configuration
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7c780241-0638-42ea-9338-09721aa3852d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/94CD-4B1F";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  system = {
    stateVersion = "24.05";
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

  # Nix Configuration
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
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

  # Swap Devices Configuration
  swapDevices = [ ];

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  # Networking Configuration
  networking = {
    useDHCP = lib.mkDefault true;
    networkmanager.enable = true;
  };
}
