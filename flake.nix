{
  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Framework
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "unstable";
    };

    # System Management
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications
    nixarr.url = "github:rasmus-kirk/nixarr";
    erosanix.url = "github:emmanuelrosa/erosanix";
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      # Basic configuration
      snowfall = {
        root = ./snowfall;
        namespace = "bibijeebi";
      };
      channels-config.allowUnfree = true;

      # System modules and overlays
      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        nixarr.nixosModules.default
      ];
      overlays = with inputs; [
        snowfall-flake.overlays."package/flake"
      ];
    };
}
