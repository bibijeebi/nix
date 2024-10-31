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

    nixarr.url = "git+file:///home/bibi/nixarr?shallow=1";

    erosanix.url = "github:emmanuelrosa/erosanix";

    musnix.url = "github:musnix/musnix";
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;
      
      channels-config.allowUnfree = true;

      systems.modules.nixos = with inputs; [
        nixarr.nixosModules.default
        musnix.nixosModules.default
      ];

      overlays = with inputs; [
        snowfall-flake.overlays.default
      ];
    };
}
