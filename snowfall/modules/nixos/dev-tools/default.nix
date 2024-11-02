# modules/nixos/dev-tools/default.nix
{ config, pkgs, lib, ... }:

with lib;

let cfg = config.modules.dev-tools;
in {
  options.modules.dev-tools = { enable = mkEnableOption "Development tools"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
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

      # Editors and IDEs
      code-cursor
      vim
      vscode
    ];

    programs = {
      nix-index.enable = true;
      command-not-found.enable = false;
    };

    virtualisation = {
      docker.enable = true;
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
    };
  };
}
