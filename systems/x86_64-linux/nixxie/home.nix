{
  pkgs,
  config,
  ...
}: {
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "cursor";
    BROWSER = "google-chrome";
    TERMINAL = "kitty";
    PAGER = "less";

    LESSHISTFILE = "-"; # Disable less history file
    FZF_DEFAULT_COMMAND = "fd --type f"; # FZF default search command
    MANPAGER = "sh -c 'col -bx | bat -l man -p'"; # Better man pages

    MOZ_USE_XINPUT2 = "1"; # Better Firefox touch/scrolling
  };

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
      shellAliases = {
        clp = "wl-copy";
        pst = "wl-paste";
        t = "task";
        ya = "yazi";
      };
      plugins = [
        # Efficient directory jumping (since you're using zoxide)
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        # Auto-complete matching pairs (parentheses, quotes, etc.)
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
        # Reminds you when you have an alias for a command
        {
          name = "fish-you-should-use";
          src = pkgs.fishPlugins.fish-you-should-use.src;
        }
        # Colored man pages
        {
          name = "colored-man-pages";
          src = pkgs.fishPlugins.colored-man-pages.src;
        }
        # Notifications when long processes finish
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        # Enhanced fzf integration
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        # Git abbreviations
        {
          name = "git-abbr";
          src = pkgs.fishPlugins.git-abbr.src;
        }
        # Clean command history (removes typos, etc.)
        {
          name = "sponge";
          src = pkgs.fishPlugins.sponge.src;
        }
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
      ];
      vendor.completions.enable = true;
    };

    chromium = {
      enable = true;
      package = pkgs.google-chrome;
      commandLineArgs = [
        # UI and Appearance
        "--force-dark-mode"
        "--enable-features=WebUIDarkMode"
        "--start-maximized"
        "--hide-scrollbars"

        # Disable Annoying UI Elements
        "--disable-features=DownloadBubble,DownloadBubbleV2,DesktopPWAsRunOnOsLogin,WebUITabStrip,SessionCrashedBubble"
        "--disable-notifications"
        "--disable-infobars"

        # Performance & Security
        "--disable-features=site-per-process"
        "--disable-background-timer-throttling"

        # Memory optimization
        "--disk-cache-size=104857600" # 100MB cache
      ];
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

  # In your home-manager configuration
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
    iconTheme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.adwaita-icon-theme;
    };
  };

  qt = {
    enable = true;
    qt.platformTheme.name = "gtk2";
  };

  fonts.fontconfig.enable = true;

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
