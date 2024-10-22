{
  config,
  pkgs,
  ...
}: let
  locale = "en_US.UTF-8";
in {
  imports = [./hardware.nix];

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

  hardware.pulseaudio.enable = false;

  environment = {
    systemPackages = with pkgs; [
      (hiPrio parallel)
      aichat
      alejandra
      android-tools
      anki
      apktool
      bat
      black
      blender
      burpsuite
      cabal-install
      code-cursor
      chromium
      curl
      exploitdb
      fd
      ffmpeg
      firefox
      file
      fish
      expect
      gcc
      gh
      ghc
      ghidra-bin
      git
      glow
      gobuster
      google-chrome
      grim
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
      firefox
      powershell
      qemu
      quickemu
      realesrgan-ncnn-vulkan
      ripgrep
      slurp
      snowfallorg.flake
      socat
      sqlmap
      stack
      stegseek
      # super-slicer
      swtpm
      texliveTeTeX
      tmux
      unixtools.xxd
      unzip
      uv
      vdhcoapp
      veracrypt
      vscode
      wget
      wl-clipboard
      wordlists
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
    extraGroups = ["networkmanager" "wheel" "libvirtd" "docker"];
    shell = pkgs.fish;
  };

  security = {
    sudo.wheelNeedsPassword = false;
    rtkit.enable = true;
  };

  # systemd.services = {
  #   "getty@tty1".enable = false;
  #   "autovt@tty1".enable = false;
  # };

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
