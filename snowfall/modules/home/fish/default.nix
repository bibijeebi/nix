# modules/home/shells/fish/default.nix
{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.fish;
in {
  options.modules.fish = {
    enable = mkEnableOption "fish shell configuration";
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = "set fish_greeting";
      shellInitLast = "zoxide init fish | source";

      shellAliases = {
        ai = "aichat";
        clp = "wl-copy";
        cls = "clear";
        pst = "wl-paste";
        t = "task";
        ya = "yazi";
      };

      plugins = let
        mkFishPlugin = pkg: {
          name = pkg.pname;
          src = pkg.src;
        };
      in with pkgs.fishPlugins; [
        (mkFishPlugin z)
        (mkFishPlugin bass)
        (mkFishPlugin fzf-fish)
        (mkFishPlugin autopair)
        (mkFishPlugin sponge)
        (mkFishPlugin git-abbr)
        (mkFishPlugin fish-you-should-use)
        (mkFishPlugin done)
        (mkFishPlugin tide)
      ];
    };
  };
}
