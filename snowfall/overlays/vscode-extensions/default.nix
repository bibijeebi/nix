{...}: final: prev: {
  vscode-extensions =
    prev.vscode-extensions
    // {
      vscode-org-mode.org-mode = prev.internal.vscode-org-mode;
      mikoz.black-py = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "mikoz";
          name = "black-py";
          version = "1.0.3";
          sha256 = "1pmf0php40fbjaq99x3yx44lnsfjq33hh50nqjg1jsnj8zv2bhpk";
        };
      };
      bbenoist.nix = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "bbenoist";
          name = "nix";
          version = "1.0.1";
          sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
        };
      };
      kamadorueda.alejandra = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "kamadorueda";
          name = "alejandra";
          version = "1.0.0";
          sha256 = "1ncjzhrc27c3cwl2cblfjvfg23hdajasx8zkbnwx5wk6m2649s88";
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
      haskell.haskell = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "haskell";
          name = "haskell";
          version = "2.5.3";
          sha256 = "13s39fvb6kwxklcfsa5xh4z7y8y3y0h6jv39ljrgl24qkwgx8xnw";
        };
      };
      mvllow.rose-pine = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "mvllow";
          name = "rose-pine";
          version = "2.12.1";
          sha256 = "14y3r06fgvgv251kly8d13nw1h84482ynhnmrlr3m91f5yrvw4fy";
        };
      };
      justusadam.language-haskell = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "justusadam";
          name = "language-haskell";
          version = "3.6.0";
          sha256 = "115y86w6n2bi33g1xh6ipz92jz5797d3d00mr4k8dv5fz76d35dd";
        };
      };
      foxundermoon.shell-format = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "foxundermoon";
          name = "shell-format";
          version = "7.2.5";
          sha256 = "0a874423xw7z6zjj7gzzl39jahrrqcf2r16zbcvncw23483m3yli";
        };
      };
      davidanson.vscode-markdownlint = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "davidanson";
          name = "vscode-markdownlint";
          version = "0.56.0";
          sha256 = "17cz1nnb94qngnq9mwzc5i78sj27ab945lap4837gn9pxlysjd11";
        };
      };
      timonwong.shellcheck = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "timonwong";
          name = "shellcheck";
          version = "0.37.1";
          sha256 = "0pdnp2zddygjk0m2azi46nwvznyqxpc3qd24k9qjxy7siqcv8915";
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
      mattn.lisp = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "mattn";
          name = "lisp";
          version = "0.1.12";
          sha256 = "0k10d77ffl6ybmk7mrpmlsawzwppp87aix2a2i24jq7lqnnqb9n7";
        };
      };
      serayuzgur.crates = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "serayuzgur";
          name = "crates";
          version = "0.6.7";
          sha256 = "16l0y3khjqvg17kxi9i41s0ijb07xyryrmsb1y5j590hklqp2mhm";
        };
      };
      dracula-theme.theme-dracula = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "dracula-theme";
          name = "theme-dracula";
          version = "2.25.1";
          sha256 = "1h3xxwgzgzpwb9fkfl3psm2clvp1jwfhp6asc6chj3cv59v9ncca";
        };
      };
      mkhl.direnv = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "mkhl";
          name = "direnv";
          version = "0.17.0";
          sha256 = "1n2qdd1rspy6ar03yw7g7zy3yjg9j1xb5xa4v2q12b0y6dymrhgn";
        };
      };
      ms-python.isort = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "ms-python";
          name = "isort";
          version = "2023.13.12321012";
          sha256 = "00i27f61yqq79yhvd52ffwdq0dz1lw2zwgkz7da58h0wvps0ib1h";
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
      ms-python.debugpy = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "ms-python";
          name = "debugpy";
          version = "2024.13.2024101501";
          sha256 = "1b90ng5v8m46kcb6qmwc2xjbjp2w9vfpk8bg9xmc4lhf5pjf70y0";
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
      tamasfe.even-better-toml = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "tamasfe";
          name = "even-better-toml";
          version = "0.19.2";
          sha256 = "0q9z98i446cc8bw1h1mvrddn3dnpnm2gwmzwv2s3fxdni2ggma14";
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
      ms-python.python = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "ms-python";
          name = "python";
          version = "2024.17.2024102201";
          sha256 = "0bdwwllnlnw5napzwgk267jpdpsvysz5jq8rh80qqhfqpnzk9x28";
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
      jnoortheen.nix-ide = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "jnoortheen";
          name = "nix-ide";
          version = "0.3.5";
          sha256 = "12sg67mn3c8mjayh9d6y8qaky00vrlnwwx58v1f1m4qrbdjqab46";
        };
      };
      redhat.vscode-yaml = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "redhat";
          name = "vscode-yaml";
          version = "1.15.0";
          sha256 = "0hqbfqwszfwxia2flh92z70zd57azpl5i3zapy8s5j3bh8sln69n";
        };
      };
      bmalehorn.vscode-fish = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "bmalehorn";
          name = "vscode-fish";
          version = "1.0.38";
          sha256 = "0njljmszyq51z1kmmiggdn2jpi4n6mm97gkywkzcaq3k744ryj20";
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
      ms-vscode.powershell = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "ms-vscode";
          name = "powershell";
          version = "2024.3.2";
          sha256 = "0dx0j5hlxvifi1faag0b147bzx0hg0d70skigfn63ca3892g9fxc";
        };
      };
      rust-lang.rust-analyzer = prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "rust-lang";
          name = "rust-analyzer";
          version = "0.4.2161";
          sha256 = "1qf47p86zhgn6haab7zadfg3nq9zz5np7jm6fmlsw9zd82z00d2m";
        };
      };
    };
}
