{ ezModules, inputs, pkgs, ... }: {
  imports = [
    ./hardware.nix
    ezModules.buildarr
    inputs.musnix.nixosModules.default
  ];

  system.stateVersion = "24.11";

  time.timeZone = "America/New_York";

  musnix.enable = true;

  nixarr = {
    enable = true;
    vpn.enable = false;
    jellyfin.enable = true;
    transmission.enable = true;
    sonarr.enable = true;
    prowlarr.enable = true;
    radarr = {
      enable = true;
      port = 7878;
      authentication = {
        useFormLogin = true;
        disabledForLocalAddresses = true;
      };
    };
  };

  nix = {
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
      experimental-features = [ "nix-command" "flakes" ];
      substituters =
        [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      keep-outputs = true;
      keep-derivations = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  hardware = {
    pulseaudio.enable = false;
    graphics = { enable = true; };
  };

  networking = {
    hostName = "nixxie";
    networkmanager.enable = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings.LC_ALL = "en_US.UTF-8";
  };

  console.useXkbConfig = true;

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    firefox.enable = true;
    fish.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };
    wireshark.enable = true;
    nix-index.enable = true;
    command-not-found.enable = false;
    mtr.enable = true;
    xfconf.enable = true;
  };

  services = {
    xserver.xkb = {
      layout = "us";
      options = "caps:escape,terminate:ctrl_alt_bksp";
    };
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
    jellyseerr = {
      enable = true;
      openFirewall = true;
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
    pam.services.login.enableGnomeKeyring = true;
    pam.loginLimits = [{
      domain = "@users";
      item = "rtprio";
      type = "-";
      value = 1;
    }];
    wrappers = {
      bindfs = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+ep";
        source = "${pkgs.bindfs}/bin/bindfs";
      };
    };
  };

  fonts.packages = with pkgs;
    [
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

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = [ pkgs.virtiofsd ];
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };
    docker.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  users.users.bibi = {
    isNormalUser = true;
    description = "bibi";
    extraGroups = [
      "audio"
      "docker"
      "fuse"
      "input"
      "libvirtd"
      "networkmanager"
      "video"
      "wheel"
    ];
    shell = pkgs.fish;
  };

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
    blueman
    bottles
    brightnessctl
    btop
    burpsuite
    cabal-install
    cabextract
    cargo
    cliphist
    code-cursor
    coreutils
    curl
    deadnix
    direnv
    dunst
    exploitdb
    fdupes
    ffmpeg
    ffmpegthumbnailer
    file
    foot
    fuse
    gcc
    gh
    ghc
    git
    glow
    gnumake
    google-chrome
    hashcat
    haskell-language-server
    haskellPackages.cabal-fmt
    hyprshot
    imagemagick
    isort
    jadx
    john
    jsbeautifier
    kanshi
    kmod
    libnotify
    libvirt
    light
    literate
    lsb-release
    mako
    manix
    metasploit
    mokutil
    moreutils
    mpv
    neovim
    networkmanagerapplet
    nil
    nix-direnv
    nix-init
    nix-output-monitor
    nix-prefetch-github
    nixd
    nixpkgs-fmt
    nmap
    obsidian
    openvpn
    ormolu
    p7zip
    pamixer
    pavucontrol
    pciutils
    pipenv
    pipx
    playerctl
    polkit
    poppler
    poppler_utils
    pre-commit
    pup
    qemu
    qimgv
    quickemu
    realesrgan-ncnn-vulkan
    rofi-wayland
    rust-analyzer
    rustc
    shellcheck
    shfmt
    slurp
    snowfallorg.flake
    socat
    spacenavd
    sqlmap
    stack
    stegseek
    sway-contrib.grimshot
    swtpm
    swww
    texliveTeTeX
    tmux
    unionfs-fuse
    unixtools.xxd
    unzip
    uv
    vdhcoapp
    veracrypt
    viu
    waybar
    wget
    wine
    winetricks
    wineWowPackages.waylandFull
    wl-clipboard
    wlsunset
    wofi
    wordlists
    xdg-utils
    xfce.thunar
    zip
    zoxide
    alejandra
    direnv
    git
    gh
    inotify-tools
    nix-direnv
    nix-output-monitor
    parallel
    mdbook
    pandoc
    shellcheck
    pre-commit
    btop
    shfmt
    manix
    deadnix
  ];
}
