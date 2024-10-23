{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  programs = {
    home-manager.enable = true;

    # Enable multiple programs with a single declaration
    bat.enable = true;
    eza.enable = true;
    fd.enable = true;
    firefox.enable = true;
    fzf.enable = true;
    gh.enable = true;
    gpg.enable = true;
    htop.enable = true;
    imv.enable = true;
    jq.enable = true;
    mpv.enable = true;
    pandoc.enable = true;
    ripgrep.enable = true;
    taskwarrior.enable = true;
    tmux.enable = true;
    waybar.enable = true;
    wofi.enable = true;
    yazi.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;
    gallery-dl.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    vscode = {
      enable = false;
      extensions = with pkgs.vscode-extensions; [
        albymor.increment-selection
        bbenoist.nix
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        genieai.chatgpt-vscode
        kamadorueda.alejandra
        ms-python.python
        ms-vscode.powershell
        timonwong.shellcheck
      ];
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      mutableExtensionsDir = true;
      userSettings = {
        "editor.fontSize" = 11;
        "editor.mouseWheelZoom" = true;
        "extensions.autoCheckUpdates" = false;
        "explorer.confirmDelete" = false;
        "files.autoSave" = "afterDelay";
        "files.saveConflictResolution" = "overwriteFileOnDisk";
        "files.simpleDialog.enable" = true;
        "files.trimFinalNewlines" = true;
        "files.trimTrailingWhitespace" = true;
        "genieai" = {
          "enableConversationHistory" = true;
          "openai" = {
            "maxTokens" = 8196;
            "temperature" = 0.3;
            "apiBaseUrl" = "https://openrouter.ai/api";
            "model" = "anthropic/claude-3.5-sonnet:beta";
          };
        };
        "git.confirmSync" = false;
        "security.workspace.trust.enabled" = false;
        "shellcheck.exclude" = ["SC1008"];
        "update.mode" = "none";
        "window" = {
          "dialogStyle" = "custom";
          "titleBarStyle" = "custom";
        };
        "workbench" = {
          "colorTheme" = "Catppuccin Mocha";
          "commandPalette.preserveInput" = true;
          "startupEditor" = "none";
        };
      };
    };

    kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
      };
      theme = "Catppuccin-Mocha";
      font = {
        package = pkgs.nerdfonts;
        name = "CaskaydiaCove Nerd Font";
        size = 11;
      };
    };

    git = {
      enable = true;
      userName = "bibijeebi";
      userEmail = "bennyforeman1@gmail.com";
    };

    fish = {
      enable = true;
      interactiveShellInit = "set fish_greeting";
      shellInitLast = "zoxide init fish | source";
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig
        nvim-treesitter.withAllGrammars
        plenary-nvim
        gruvbox-material
        mini-nvim
      ];
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
      startup = [
        {command = "firefox";}
      ];
    };
  };

  services.cliphist.enable = true;

  home.stateVersion = "24.05";
}
