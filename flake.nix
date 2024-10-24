{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "unstable";
    };
    nixarr.url = "github:rasmus-kirk/nixarr";
    erosanix.url = "github:emmanuelrosa/erosanix";
    base16.url = "github:SenchoPens/base16.nix";
    stylix.url = "github:danth/stylix";
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      channels-config.allowUnfree = true;
      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        nixarr.nixosModules.default
        stylix.nixosModules.stylix
      ];
      overlays = with inputs; [
        snowfall-flake.overlays."package/flake"
      ];
    };
}
