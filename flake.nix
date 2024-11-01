{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    systems = {
      url = "github:nix-systems/default";
      flake = false;
    };

    ez-configs = { url = "github:ehllie/ez-configs"; };
  };

  outputs = inputs@{ self, nixpkgs, systems, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import systems;

      imports = with inputs; [
        ez-configs.flakeModule
        flake-parts.flakeModules.easyOverlay
      ];

      ezConfigs = {
        root = ./.;
        globalArgs = { inherit inputs; };
      };

      perSystem = { system, pkgs, lib, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfree = true;
        };

        formatter = pkgs.nixfmt-classic;

        packages = lib.filesystem.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ./packages;
        };

        overlayAttrs = self.packages;
      };
    };
}
