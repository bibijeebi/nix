{ ezModules, inputs, pkgs, ... }: {
  imports = [
    ezModules.buildarr
    inputs.musnix.nixosModules.default
    inputs.nixarr.nixosModules.default
  ];

  boot = {
    # Kernel Modules
    initrd = {
      availableKernelModules = [
        "vmd" # Intel Volume Management Device
        "xhci_pci" # USB 3.0 Controller
        "ahci" # SATA Controller
        "usbhid" # USB HID Devices
        "usb_storage" # USB Storage
        "sd_mod" # SD Card Support
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ]; # Intel KVM Support
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/7c780241-0638-42ea-9338-09721aa3852d";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/94CD-4B1F";
      fsType = "vfat";
      options = [
        "fmask=0077" # File permissions mask
        "dmask=0077" # Directory permissions mask
      ];
    };
  };

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
}
