final: prev: {
  inherit (import ./extensions) vscode-extensions;

  vscode-insiders = (prev.vscode.override { isInsiders = true; }).overrideAttrs
    (oldAttrs: {
      src = builtins.fetchTarball {
        url =
          "https://code.visualstudio.com/sha/download?build=insider&os=linux-x64";
        sha256 = "sha256:1sx7aqzhcnb3w2irm0sa0z6bji8w0mmj7zwbyagkgni7gc208zab";
      };
      version = "1.95.0-insider";
      buildInputs = oldAttrs.buildInputs ++ [ prev.krb5 ];
    });
}
