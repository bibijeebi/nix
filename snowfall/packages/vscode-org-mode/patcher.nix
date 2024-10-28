{
  lib,
  vscode-utils,
  fetchFromGitHub,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "org-mode";
    publisher = "vscode-org-mode";
    version = "1.0.0";
  };

  #   src = fetchFromGitHub {
  #     owner = "vscode-org-mode";
  #     repo = "vscode-org-mode";
  #     rev = "9ad422cb215c6be6a877617db984543e8ffa6584";
  #     hash = "sha256-0rxKcsULJad5mWHQ7rEZFAO+KlgIWtpeXhIfDEtCoxc=";
  #   };

  patches = [./add-nix-language-to-syntaxes.patch];
}
