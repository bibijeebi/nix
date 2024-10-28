{...}: final: prev: {
  vscode-extensions =
    prev.vscode-extensions
    // {
      vscode-org-mode.org-mode = prev.internal.vscode-org-mode;

      qcz.text-power-tools = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "text-power-tools";
          publisher = "qcz";
          version = "1.49.0";
          sha256 = "sha256-pIg/eLaJU0KggrLBeY2a9uCWV1O9JTOGGMyESpkaBzc=";
        };
      };

      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "mvllow"; name = "rose-pine"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "mikoz"; name = "black-py"; version = ""; sha256 = lib.fakeSha256; };
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "timonwong"; name = "shellcheck"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "ms-vscode"; name = "powershell"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "berberman"; name = "vscode-cabal-fmt"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "tamasfe"; name = "even-better-toml"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "yib"; name = "rust-bundle"; version = ""; sha256 = lib.fakeSha256; };
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "serayuzgur"; name = "crates"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "dustypomerleau"; name = "rust-syntax"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "artdiniz"; name = "quitcontrol-vscode"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "dracula-theme"; name = "theme-dracula"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "redhat"; name = "vscode-yaml"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "mkhl"; name = "direnv"; version = ""; sha256 = lib.fakeSha256; };
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "kenhowardpdx"; name = "vscode-gist"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "lacroixdavid1"; name = "vscode-format-context-menu"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "mattn"; name = "lisp"; version = ""; sha256 = lib.fakeSha256; };
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "natqe"; name = "reload"; version = ""; sha256 = lib.fakeSha256; };
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "ms-vscode"; name = "vscode-typescript-next"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "jnoortheen"; name = "nix-ide"; version = ""; sha256 = lib.fakeSha256; }; }
      pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = { publisher = "rust-lang"; name = "rust-analyzer"; version = ""; sha256 = lib.fakeSha256; }; }
    };
}
