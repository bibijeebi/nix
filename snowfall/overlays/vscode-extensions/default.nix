{...}: final: prev: {
  vscode-extensions =
    prev.vscode-extensions
    // {
      vscode-org-mode.org-mode = let
        drv = prev.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "org-mode";
            version = "1.0.0";
            publisher = "vscode-org-mode";
            hash = "sha256-o9CIjMlYQQVRdtTlOp9BAVjqrfFIhhdvzlyhlcOv5rY=";
          };
        };
      in
        drv.overrideAttrs
        (oldAttrs: {
          postInstall = let
            patch = final.fetchurl {
              url = "https://gist.githubusercontent.com/bibijeebi/cb84102cd197e63a7d7a8d28f117e6ca/raw/02929a3574291bc41fc6435654583fe63e2a0abb/vscode-org-mode-add-nix-syntaxes.patch";
              sha256 = "03r05zb4zmg8b63q6nd38ppzi7n2msy2qv9xmpgnby208rx1lhj0";
            };
          in ''
            patch -p1 --directory=$out/$installPrefix < ${patch}
            ${oldAttrs.postInstall}
          '';
        });
      mikoz.black-py = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "mikoz";
          name = "black-py";
          version = "1.0.3";
          sha256 = "1pmf0php40fbjaq99x3yx44lnsfjq33hh50nqjg1jsnj8zv2bhpk";
        };
      };
      berberman.vscode-cabal-fmt = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "berberman";
          name = "vscode-cabal-fmt";
          version = "0.0.3";
          sha256 = "0kfcipzhmf70447vmdikipq5s8192hm055is8hfxp4k3v32mz3ad";
        };
      };
      dustypomerleau.rust-syntax = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "dustypomerleau";
          name = "rust-syntax";
          version = "0.6.1";
          sha256 = "0rccp8njr13jzsbr2jl9hqn74w7ji7b2spfd4ml6r2i43hz9gn53";
        };
      };
      natqe.reload = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "natqe";
          name = "reload";
          version = "0.0.7";
          sha256 = "1bpzv7pg80ly31l2fyi7lbdyi2w71x7w5g3p63017hlsi3ny6h4g";
        };
      };
      qcz.text-power-tools = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "qcz";
          name = "text-power-tools";
          version = "1.49.0";
          sha256 = "0dq73aclm16c323369dxadbrdq7nka6pkhdjhah44lw9nrw3z254";
        };
      };
      ms-python.vscode-pylance = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "ms-python";
          name = "vscode-pylance";
          version = "2024.10.102";
          sha256 = "1hlvb8yayrk7bdmb7gcs1rk56x0lq29gbjrz6ydg1z5v8gxz12ka";
        };
      };
      artdiniz.quitcontrol-vscode = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "artdiniz";
          name = "quitcontrol-vscode";
          version = "4.0.0";
          sha256 = "1932g6aqll0mjm2w2wjj726f99q25912mlkfqr9353c7xsz467r4";
        };
      };
      lacroixdavid1.vscode-format-context-menu = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "lacroixdavid1";
          name = "vscode-format-context-menu";
          version = "1.0.4";
          sha256 = "100bdj9yy3a67pyq0hqlyf3afwb28hhlmdaphgab6a15f653l3iy";
        };
      };
      kenhowardpdx.vscode-gist = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "kenhowardpdx";
          name = "vscode-gist";
          version = "3.0.3";
          sha256 = "033iry115hbd5jbdr04frbrcgfpfnsc2z551nlfsaczbg4j9dydw";
        };
      };
      ms-vscode.vscode-typescript-next = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "ms-vscode";
          name = "vscode-typescript-next";
          version = "5.7.20241027";
          sha256 = "1dx8bkjziz3wainnrx6zgk7c6ljmfwhqrd0anvip0mcjxv0wc6jy";
        };
      };
    };
}
