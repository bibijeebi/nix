{ fetchurl, vscode-utils }:
let
  drv = vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "org-mode";
      version = "1.0.0";
      publisher = "vscode-org-mode";
      hash = "sha256-o9CIjMlYQQVRdtTlOp9BAVjqrfFIhhdvzlyhlcOv5rY=";
    };
  };
in drv.overrideAttrs (oldAttrs: {
  postInstall = let
    patch = fetchurl {
      url =
        "https://gist.githubusercontent.com/bibijeebi/cb84102cd197e63a7d7a8d28f117e6ca/raw/02929a3574291bc41fc6435654583fe63e2a0abb/vscode-org-mode-add-nix-syntaxes.patch";
      sha256 = "03r05zb4zmg8b63q6nd38ppzi7n2msy2qv9xmpgnby208rx1lhj0";
    };
  in ''
    patch -p1 --directory=$out/$installPrefix < ${patch}
    ${oldAttrs.postInstall or ""}
  '';
})
