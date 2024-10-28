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
}:
(vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.0.0";
    publisher = "vscode-org-mode";
    hash = "sha256-o9CIjMlYQQVRdtTlOp9BAVjqrfFIhhdvzlyhlcOv5rY=";
  };
})
.overrideAttrs (oldAttrs: {
  postInstall = ''
    patch -p1 --directory=$out/$installPrefix < ${./add-nix-language-to-syntaxes.patch}
  '';
})
