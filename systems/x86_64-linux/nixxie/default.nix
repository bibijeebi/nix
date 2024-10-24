{
  lib,
  config,
  pkgs,
  ...
}: let
  locale = "en_US.UTF-8";
in {
  imports = [./hardware.nix];

  # System Configuration
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  time.timeZone = "America/New_York";

  # Boot Configuration
  boot = {
    supportedFilesystems = ["fuse"];
    kernelModules = ["fuse"];
    kernel.sysctl."kernel.unprivileged_userns_clone" = 1;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
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

  # Desktop Environment
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Display and Desktop Services
  services = {
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

    # Audio
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };

    # Other Services
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

  # Audio Configuration
  hardware = {
    pulseaudio.enable = false;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
  };

  # Security
  security = {
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
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

  # Fonts
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

  # Programs
  programs = {
    firefox.enable = true;
    dconf.enable = true;
    mtr.enable = true;
    fish.enable = true;
    wireshark.enable = true;
    nix-index.enable = true;
    command-not-found.enable = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryPackage = lib.mkForce pkgs.pinentry-gnome3;
    };
  };

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

  # User Configuration
  users.users.bibi = {
    isNormalUser = true;
    description = "bibi";
    extraGroups = ["networkmanager" "wheel" "libvirtd" "docker" "fuse"];
    shell = pkgs.fish;
  };

  # Home Manager Configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.bibi = import ./home.nix;
    backupFileExtension = "hm-backup";
  };

  # Media Server Configuration
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
    # Development Tools
    aichat
    code-cursor
    gcc
    gh
    git
    (hiPrio parallel)

    # Programming Languages & Tools
    black
    cabal-install
    ghc
    haskell-language-server
    isort
    stack

    # System Tools
    bat
    curl
    fd
    fish
    htop
    kmod
    pciutils
    ripgrep
    tmux
    wget
    zoxide

    # Security Tools
    burpsuite
    exploitdb
    ghidra-bin
    hashcat
    john
    metasploit
    nmap
    sqlmap

    # Media Tools
    ffmpeg
    grim
    imagemagick
    mpv
    qimgv
    realesrgan-ncnn-vulkan
    slurp
    yt-dlp

    # Virtualization
    libvirt
    qemu
    quickemu
    swtpm
    (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
      qemu-system-x86_64 \
        -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
        "$@"
    '')

    # Applications
    alejandra
    android-tools
    anki
    apktool
    firefox
    google-chrome
    jadx
    kitty
    neovim
    obsidian
    powershell
    veracrypt
    yazi

    # Other Utilities
    file
    glow
    internal.assemblyai-cli
    jsbeautifier
    mako
    moreutils
    openvpn
    pandoc
    pavucontrol
    poppler_utils
    snowfallorg.flake
    socat
    stegseek
    texliveTeTeX
    unixtools.xxd
    unzip
    uv
    vdhcoapp
    wl-clipboard
    wordlists
    zip

    fuse
    unionfs-fuse
    bindfs
    wine64
    wine
    winetricks
  ];
}
