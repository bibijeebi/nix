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
    };
}
