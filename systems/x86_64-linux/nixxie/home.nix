{
  pkgs,
  config,
  ...
}: {
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  programs = {
    git = {
      enable = true;
      userName = "bibijeebi";
      userEmail = "bennyforeman1@gmail.com";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fish = {
      enable = true;
      interactiveShellInit = "set fish_greeting";
      shellInitLast = "zoxide init fish | source";
    };

    chromium = {
      enable = true;
      package = pkgs.google-chrome;
      extensions = {
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" = {
          id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
          updateUrl = "https://clients2.google.com/service/update2/crx";
        };
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" = {
          id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
          updateUrl = "https://clients2.google.com/service/update2/crx";
        };
      };
      commandLineArgs = [
        "--disable-features=DownloadBubble,BookmarkBar"
        "--disable-session-crashed-bubble"
      ];
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      plugins = with pkgs.vimPlugins; [
        nvim-lspconfig # Language server protocol
        nvim-treesitter.withAllGrammars # Syntax highlighting
        plenary-nvim # Lua functions library
        gruvbox-material # Color scheme
        mini-nvim # Collection of minimal plugins
      ];
    };

    # Terminal Emulator
    kitty = {
      enable = true;
      theme = "Catppuccin-Mocha";
      font = {
        package = pkgs.nerdfonts;
        name = "CaskaydiaCove Nerd Font";
        size = 11;
      };
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        mouse_hide_wait = "-1.0";
      };
    };

    # File Navigation and Search
    fd.enable = true; # Alternative to find
    fzf.enable = true; # Fuzzy finder
    ripgrep.enable = true; # Fast grep
    zoxide.enable = true; # Smarter cd
    yazi.enable = true; # Terminal file manager

    # File Viewing and Processing
    bat.enable = true; # Better cat
    eza.enable = true; # Better ls
    jq.enable = true; # JSON processor
    pandoc.enable = true; # Document converter

    # System Monitoring
    htop.enable = true; # Process viewer

    # Development Tools
    gh.enable = true; # GitHub CLI
    gpg.enable = true; # Encryption
    tmux.enable = true; # Terminal multiplexer

    # Media Tools
    gallery-dl.enable = true; # Image downloader
    mpv.enable = true; # Media player
    yt-dlp.enable = true; # Video downloader

    # Productivity
    firefox.enable = true; # Web browser
    taskwarrior.enable = true; # Task management
  };

  # Window Manager
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

  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = ["google-chrome.desktop"];
        "image/jpeg" = ["qimgv.desktop"];
        "image/png" = ["qimgv.desktop"];
        "inode/directory" = ["thunar.desktop"];
        "text/html" = "google-chrome.desktop";
        "text/plain" = ["neovim.desktop"];
        "video/mkv" = ["mpv.desktop"];
        "video/mp4" = ["mpv.desktop"];
        "video/webm" = ["mpv.desktop"];
        "x-scheme-handler/about" = ["google-chrome.desktop"];
        "x-scheme-handler/http" = ["google-chrome.desktop"];
        "x-scheme-handler/https" = ["google-chrome.desktop"];
        "x-scheme-handler/unknown" = ["google-chrome.desktop"];
      };
    };
  };

  # System Services
  services.cliphist.enable = true; # Clipboard manager
}
