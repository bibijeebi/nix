# modules/nixos/security/default.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.security;
in {
  options.modules.security = {
    enable = mkEnableOption "security configurations";

    ssh = {
      enable = mkEnableOption "SSH security configuration";
      permitRootLogin = mkOption {
        type = types.enum [ "yes" "no" "prohibit-password" ];
        default = "no";
        description = "Whether to permit root login through SSH";
      };
      passwordAuthentication = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to allow password authentication";
      };
    };

    sudo = {
      enable = mkEnableOption "sudo configuration";
      wheelNoPasword = mkOption {
        type = types.bool;
        default = false;
        description =
          "Whether to allow wheel group to use sudo without password";
      };
      extraRules = mkOption {
        type = types.listOf types.attrs;
        default = [ ];
        description = "Extra sudo rules to apply";
      };
    };

    firewall = {
      enable = mkEnableOption "firewall configuration";
      allowedTCPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of allowed TCP ports";
      };
      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [ ];
        description = "List of allowed UDP ports";
      };
    };

    wireguard = {
      enable = mkEnableOption "wireguard configuration";
      interfaces = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            privateKeyFile = mkOption {
              type = types.str;
              description = "Path to the private key file";
            };
            peers = mkOption {
              type = types.listOf (types.submodule {
                options = {
                  publicKey = mkOption {
                    type = types.str;
                    description = "Peer's public key";
                  };
                  allowedIPs = mkOption {
                    type = types.listOf types.str;
                    description = "Allowed IP addresses for this peer";
                  };
                  endpoint = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Endpoint address and port";
                  };
                };
              });
              default = [ ];
              description = "List of peers";
            };
          };
        });
        default = { };
        description = "Wireguard interface configurations";
      };
    };

    faillock = {
      enable = mkEnableOption "faillock configuration";
      denyAfter = mkOption {
        type = types.int;
        default = 3;
        description = "Number of failed attempts before denying access";
      };
      unlockTime = mkOption {
        type = types.int;
        default = 600;
        description = "Time in seconds before unlocking after deny";
      };
    };
  };

  config = mkIf cfg.enable {
    # Basic security settings
    security = {
      rtkit.enable = true;
      sudo = mkIf cfg.sudo.enable {
        enable = true;
        wheelNeedsPassword = !cfg.sudo.wheelNoPasword;
        extraRules = cfg.sudo.extraRules;
      };

      # PAM configuration
      pam = {
        services = mkIf cfg.faillock.enable {
          login.faillock = {
            enable = true;
            inherit (cfg.faillock) denyAfter unlockTime;
          };
        };
      };
    };

    # SSH configuration
    services.openssh = mkIf cfg.ssh.enable {
      enable = true;
      settings = {
        PermitRootLogin = cfg.ssh.permitRootLogin;
        PasswordAuthentication = cfg.ssh.passwordAuthentication;
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
      };
    };

    # Firewall configuration
    networking.firewall = mkIf cfg.firewall.enable {
      enable = true;
      allowedTCPPorts = cfg.firewall.allowedTCPPorts;
      allowedUDPPorts = cfg.firewall.allowedUDPPorts;
    };

    # Wireguard configuration
    networking.wireguard.interfaces =
      mkIf cfg.wireguard.enable cfg.wireguard.interfaces;

    # Security-related packages
    environment.systemPackages = with pkgs;
      [
        gnupg
        openssl
        age
        tomb
        gocryptfs
        yubikey-manager
        yubikey-personalization
        yubico-pam
        veracrypt
        pass
        pass-secret-service
        wireshark
      ] ++ optionals cfg.wireguard.enable [ wireguard-tools ];

    # Additional hardening
    boot.kernel.sysctl = {
      # Disable magic SysRq key
      "kernel.sysrq" = 0;
      # Disable core dumps
      "fs.suid_dumpable" = 0;
      # Protect against SUID process ptrace access
      "kernel.yama.ptrace_scope" = 2;
      # Protect against hostile ICMP
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Protect against IP spoofing
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      # Protect against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
    };
  };
}
