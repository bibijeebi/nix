{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    ante = {
      url = "github:jfecher/ante";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        parts.follows = "flake-parts";
      };
    };
    devshell.url = "github:numtide/devshell";
    ez-configs.url = "github:ehllie/ez-configs";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    musnix.url = "github:musnix/musnix";
    nixarr.url = "git+file:///home/bibi/nixarr?shallow=1";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yazi = {
      url = "github:sxyazi/yazi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [ ez-configs.flakeModule ];

      systems = [ "x86_64-linux" ];

      ezConfigs = {
        root = ./.;
        globalArgs = { inherit inputs; };
      };

      perSystem = { pkgs, lib, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = with inputs; [ sops-nix.overlays.default ];
        };

        devShells.default = pkgs.mkShell {
          packages = lib.attrValues {
            inherit (pkgs)
              cachix deadnix deploy-rs manix nix-diff nix-direnv nix-index
              nix-info nix-init nix-melt nix-output-monitor nix-prefetch
              nix-prefetch-github nix-search-cli nixd nixfmt-rfc-style
              nixos-generators nixos-shell nixtract optinix statix;
          };
        };
      };
    };
}
