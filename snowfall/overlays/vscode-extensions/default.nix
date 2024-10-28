{inputs}: final: prev: {
  vscode-extensions =
    prev.vscode-extensions
    // {
      vscode-org-mode.org-mode = prev.internal.vscode-org-mode;
    };
}
