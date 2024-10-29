{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.${system} = rec {
      prowlarr-py = pkgs.callPackage ./prowlarr-py.nix {};
      radarr-py = pkgs.callPackage ./radarr-py.nix {};
      buildarr = pkgs.callPackage ./buildarr.nix {};
      buildarr-radarr = pkgs.callPackage ./buildarr-radarr.nix {};
      buildarr-sonarr = pkgs.callPackage ./buildarr-sonarr.nix {};
      buildarr-prowlarr = pkgs.callPackage ./buildarr-prowlarr.nix {};
      buildarr-jellyseerr = pkgs.callPackage ./buildarr-jellyseerr.nix {};
      default = self.packages.${system}.buildarr;
    };
  };
}
