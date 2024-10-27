{pkgs, ...}: let
  locale = "en_US.UTF-8";
in {
  imports = [./hardware.nix];

  # Core System Configuration
  system.stateVersion = "24.11";
  time.timeZone = "America/New_York";

  # Nix Configuration
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System Boot & Hardware
  boot = {
    supportedFilesystems = ["fuse"];
    kernelModules = ["fuse"];
    kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    pulseaudio.enable = false;
    graphics = {
      enable = true;
    };
  };

  # Network Configuration
  networking = {
    hostName = "nixxie";
    networkmanager.enable = true;
  };

  # Internationalization
  i18n = {
    defaultLocale = locale;
    extraLocaleSettings = builtins.listToAttrs (map (key: {
        name = key;
        value = locale;
      }) [
        "LC_ADDRESS"
        "LC_IDENTIFICATION"
        "LC_MEASUREMENT"
        "LC_MONETARY"
        "LC_NAME"
        "LC_NUMERIC"
        "LC_PAPER"
        "LC_TELEPHONE"
        "LC_TIME"
      ]);
  };

  # Desktop Environment & Display
  programs = {
    # Window Managers
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      xwayland.enable = true;
    };
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    # Core Programs
    firefox.enable = true;
    dconf.enable = true;
    fish.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    # Development Tools
    wireshark.enable = true;
    nix-index.enable = true;
    command-not-found.enable = false;

    # System Utilities
    mtr.enable = true;
    xfconf.enable = true;
  };

  # System Services
  services = {
    # Desktop Services
    udisks2.enable = true;
    flatpak.enable = true;
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
    desktopManager.plasma6.enable = true;
    gnome.gnome-keyring.enable = true;
    tumbler.enable = true;
    gvfs.enable = true;

    # Audio
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    # Network Services
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
    };
    openssh.enable = true;
    jellyseerr = {
      enable = true;
      openFirewall = true;
    };
  };

  # Security Configuration
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
    pam.services.login.enableGnomeKeyring = true;
    wrappers = {
      fusermount = {
        source = "${pkgs.fuse}/bin/fusermount";
        owner = "root";
        group = "root";
        setuid = true;
      };
      bindfs = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+ep";
        source = "${pkgs.bindfs}/bin/bindfs";
      };
    };
  };

  # Font Configuration
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "CascadiaCode"
        "DaddyTimeMono"
        "Meslo"
        "SourceCodePro"
        "Ubuntu"
      ];
    })
  ];

  # Virtualization
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = [pkgs.virtiofsd];
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            })
            .fd
          ];
        };
      };
    };
    docker.enable = true;
  };

  # User Management
  users.users.bibi = {
    isNormalUser = true;
    description = "bibi";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "libvirtd"
      "docker"
      "fuse"
    ];
    shell = pkgs.fish;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.bibi = import ./home.nix;
  home-manager.backupFileExtension = "backup";

  # Media Server
  nixarr = {
    enable = true;
    vpn.enable = false;
    jellyfin = {
      enable = true;
      vpn.enable = false;
      expose.vpn.enable = false;
    };
    transmission = {
      enable = true;
      vpn.enable = false;
    };
    sonarr.enable = true;
    radarr.enable = true;
    prowlarr.enable = true;
    readarr.enable = true;
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    (hiPrio parallel)
    aichat
    alacritty
    alejandra
    android-tools
    anki
    apktool
    bc
    bindfs
    black
    bottles
    btop
    burpsuite
    cabal-install
    cabextract
    cargo
    code-cursor
    coreutils
    curl
    deadnix
    emacs
    exploitdb
    fclones
    ffmpeg
    foot
    fuse
    gcc
    gh
    ghc
    git
    glow
    gnumake
    grim
    hashcat
    haskell-language-server
    hyprshot
    imagemagick
    isort
    jadx
    john
    jsbeautifier
    kmod
    libvirt
    literate
    lsb-release
    mako
    manix
    metasploit
    mokutil
    moreutils
    mpv
    neovim
    nix-init
    nix-output-monitor
    nmap
    nodejs
    obsidian
    openvpn
    ormolu
    pavucontrol
    pciutils
    pipenv
    polkit
    poppler_utils
    pre-commit
    pup
    python3
    qemu
    qimgv
    quickemu
    realesrgan-ncnn-vulkan
    rust-analyzer
    rustc
    shellcheck
    slurp
    snowfallorg.flake
    socat
    spacenavd
    sqlmap
    stack
    stegseek
    sway-contrib.grimshot
    swtpm
    texliveTeTeX
    tmux
    unionfs-fuse
    unixtools.xxd
    unzip
    uv
    vdhcoapp
    veracrypt
    viu
    vscode
    wget
    wine
    winetricks
    wineWowPackages.waylandFull
    wl-clipboard
    wordlists
    xdg-utils
    xfce.thunar
    zip
    zoxide
  ];
}
