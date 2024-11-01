{ ezModules, ... }: {
  imports = builtins.attrValues { inherit (ezModules) alf qimgv aichat; };

  nixpkgs.config.allowUnfree = true;

  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;

  programs.home-manager.enable = true;
}
