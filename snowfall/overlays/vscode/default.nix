# overlays/vscode.nix
{ lib, channels, ... }:

final: prev: {
  vscode-insiders = prev.vscode.overrideAttrs (oldAttrs: {
    pname = "vscode-insiders";
    version = "1.95.0-insider";
    src = builtins.fetchTarball {
      url =
        "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
      sha256 = "sha256:1sx7aqzhcnb3w2irm0sa0z6bji8w0mmj7zwbyagkgni7gc208zab";
    };
    buildInputs = oldAttrs.buildInputs ++ [ final.krb5 ];
    meta = oldAttrs.meta // {
      description = "Visual Studio Code Insiders";
      mainProgram = "code-insiders";
    };
  });

  vscode-extensions = prev.vscode-extensions // {
    qcz.text-power-tools = prev.vscode-utils.buildVscodeMarketplaceExtension {
      mktplcRef = {
        publisher = "qcz";
        name = "text-power-tools";
        version = "1.49.0";
        sha256 = "0dq73aclm16c323369dxadbrdq7nka6pkhdjhah44lw9nrw3z254";
      };
    };

    kenhowardpdx.vscode-gist =
      prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "kenhowardpdx";
          name = "vscode-gist";
          version = "3.0.3";
          sha256 = "033iry115hbd5jbdr04frbrcgfpfnsc2z551nlfsaczbg4j9dydw";
        };
      };

    ms-python.vscode-pylance =
      prev.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "ms-python";
          name = "vscode-pylance";
          version = "2024.10.102";
          sha256 = "1hlvb8yayrk7bdmb7gcs1rk56x0lq29gbjrz6ydg1z5v8gxz12ka";
        };
      };

    # Add more extensions as needed...
  };
}
