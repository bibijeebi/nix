{ ezModules, ... }: {
  imports = builtins.attrValues { inherit (ezModules) alf qimgv aichat; };

  nixpkgs.config = import ../nixpkgs-config.nix;
  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;

  programs.home-manager.enable = true;
}
