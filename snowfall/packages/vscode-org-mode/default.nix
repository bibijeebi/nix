{
  lib,
  stdenv,
  fetchFromGitHub,
  vscode-utils,
  nodejs,
  node2nix,
  callPackage,
  vsce,
  runCommand,
}: let
  src = fetchFromGitHub {
    owner = "vscode-org-mode";
    repo = "vscode-org-mode";
    rev = "9ad422cb215c6be6a877617db984543e8ffa6584";
    hash = "sha256-0rxKcsULJad5mWHQ7rEZFAO+KlgIWtpeXhIfDEtCoxc=";
  };

  packageJson = builtins.fromJSON (builtins.readFile (src + "/package.json"));

  nodeDependencies = (callPackage ./node2nix/default.nix {}).nodeDependencies;

  vsix = stdenv.mkDerivation {
    pname = packageJson.name;
    version = packageJson.version;
    inherit src;
    buildInputs = [nodejs vsce];
    buildPhase = ''
      ln -s ${nodeDependencies}/lib/node_modules ./node_modules
      export PATH="${nodeDependencies}/bin:$PATH"
      vsce package
    '';
    installPhase = ''
      mkdir -p $out
      cp *.vsix $out/${packageJson.name}-${packageJson.version}.vsix
    '';
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
  };
in
  vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      inherit (packageJson) name version;
      publisher = "vscode-org-mode";
    };
    inherit vsix;
  }
