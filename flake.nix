{
  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Framework
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # System Management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications
    nixarr.url = "github:rasmus-kirk/nixarr";
    erosanix.url = "github:emmanuelrosa/erosanix";

    musnix.url = "github:musnix/musnix";
  };

  outputs = inputs: let
  in
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
