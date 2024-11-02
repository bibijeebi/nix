{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-flake = {
      url = "github:snowfallorg/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix.url = "github:musnix/musnix";
    nixarr.url = "github:rasmus-kirk/nixarr";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall = {
        root = ./snowfall;
        meta = {
          name = "bibijeebi";
          title = "Bibi's NixOS Configuration";
        };
      };

      overlays = with inputs; [ snowfall-flake.overlays."package/flake" ];

      channels-config = {
        allowUnfree = true;
        permittedInsecurePackages = [ ];
      };

      systems.modules.nixos = with inputs; [
        hyprland.nixosModules.default
        musnix.nixosModules.default
        nixarr.nixosModules.default
      ];

      outputs-builder = channels: {
        formatter = channels.nixpkgs.nixfmt-classic;
        devShells.default = channels.nixpkgs.callPackage ./shell.nix { };
      };
    };
}
