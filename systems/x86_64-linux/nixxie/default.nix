{
  config,
  pkgs,
  ...
}: let
  locale = "en_US.UTF-8";
in {
  imports = [./hardware.nix];

  boot.supportedFilesystems = ["fuse"];
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "nixxie";
    networkmanager.enable = true;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["FiraCode" "CascadiaCode" "DaddyTimeMono" "Meslo" "SourceCodePro" "Ubuntu"];})
  ];

  time.timeZone = "America/New_York";
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

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services = {
    displayManager.sddm.wayland.enable = true;
    displayManager.sddm.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "bibi";
    desktopManager.plasma6.enable = true;

    printing.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
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

  services.gnome.gnome-keyring.enable = true;

  hardware.pulseaudio.enable = false;

  environment = {
    systemPackages = with pkgs; [
      (hiPrio parallel)
      # blender
      # chromium
      # super-slicer
      # vscode
      aichat
      alejandra
      android-tools
      anki
      apktool
      bat
      black
      burpsuite
      cabal-install
      code-cursor
      curl
      expect
      exploitdb
      fd
      ffmpeg
      file
      firefox
      fish
      gcc
      gh
      ghc
      ghidra-bin
      git
      glow
      gobuster
      google-chrome
      grim
      grim # screenshot functionality
      hashcat
      haskell-language-server
      htop
      imagemagick
      imv
      internal.assemblyai-cli
      isort
      jadx
      john
      jsbeautifier
      kitty
      kmod
      libvirt
      mako # notification system developed by swaywm maintainer
      metasploit
      moreutils
      mpv
      neovim
      netcat
      nmap
      obsidian
      openvpn
      pandoc
      pavucontrol
      pciutils
      poppler_utils
      powershell
      qemu
      qimgv
      quickemu
      realesrgan-ncnn-vulkan
      ripgrep
      slurp
      slurp # screenshot functionality
      snowfallorg.flake
      socat
      sqlmap
      stack
      stegseek
      swtpm
      texliveTeTeX
      tmux
      unixtools.xxd
      unzip
      uv
      vdhcoapp
      veracrypt
      wget
      wl-clipboard
      wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
      wordlists
      xclip
      yazi
      yt-dlp
      zip
      zoxide
      (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
        qemu-system-x86_64 \
          -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
          "$@"
      '')
    ];
  };

  users.users.bibi = {
    isNormalUser = true;
    description = "bibi";
    extraGroups = ["networkmanager" "wheel" "libvirtd" "docker" "fuse"];
    shell = pkgs.fish;
  };

  security = {
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
  };

  programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-gnome3;

  programs = {
    firefox.enable = true;
    dconf.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nix-index.enable = true;
    command-not-found.enable = false;
    wireshark.enable = true;
    fish.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };

  virtualisation.libvirtd = {
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

  virtualisation.docker.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.bibi = import ./home.nix;
    backupFileExtension = "hm-backup";
  };

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

  system.stateVersion = "24.05";
}
