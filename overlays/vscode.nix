final: prev: {
  vscode = prev.vscode.overrideAttrs (oldAttrs: {
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
}
