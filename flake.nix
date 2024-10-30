{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Working on a fork of nixarr, the original user is rasmus-kirk
    nixarr.url = "github:bibijeebi/nixarr";

    erosanix.url = "github:emmanuelrosa/erosanix";

    musnix.url = "github:musnix/musnix";
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      snowfall.root = ./snowfall;
      channels-config.allowUnfree = true;

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        nixarr.nixosModules.default
        musnix.nixosModules.musnix
      ];

      overlays = with inputs; [
        snowfall-flake.overlays."package/flake"
      ];

      outputs-builder = channels: {
        formatter = channels.nixpkgs.alejandra;
        devShells.default = channels.nixpkgs.callPackage ./snowfall/shell.nix {
          inherit channels;
        };
      };
    };
}
