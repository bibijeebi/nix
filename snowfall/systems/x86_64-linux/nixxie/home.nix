{
  pkgs,
  config,
  ...
}: {
  home.stateVersion = "24.05";

  # Environment Variables
  home.sessionVariables = {
    # Core applications
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    PAGER = "more";

    # Application configs
    FZF_DEFAULT_COMMAND = "fd --type f"; # FZF default search command
    MOZ_USE_XINPUT2 = "1"; # Better Firefox touch/scrolling
  };

  programs = {
    # Development Tools
    git = {
      enable = true;
      userName = "bibijeebi";
      userEmail = "bennyforeman1@gmail.com";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Shell Configuration
    fish = {
      enable = true;
      interactiveShellInit = "set fish_greeting";
      shellInitLast = "zoxide init fish | source";
      shellAliases = {
        ai = "aichat";
        clp = "wl-copy";
        cls = "clear";
        pst = "wl-paste";
        t = "task";
        ya = "yazi";
      };
      plugins = [
        # Navigation
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        # Editing
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
        {
          name = "sponge";
          src = pkgs.fishPlugins.sponge.src;
        }
        # Git integration
        {
          name = "git-abbr";
          src = pkgs.fishPlugins.git-abbr.src;
        }
        # Utilities
        {
          name = "fish-you-should-use";
          src = pkgs.fishPlugins.fish-you-should-use.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        # Theme
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
      ];
    };

    # Terminal
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

    # CLI Tools
    bat.enable = true;
    btop.enable = true;
    eza.enable = true;
    fd.enable = true;
    fzf.enable = true;
    gh.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    ripgrep.enable = true;
    taskwarrior.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    zoxide.enable = true;

    # Media Tools
    gallery-dl.enable = true;
    mpv.enable = true;
    pandoc.enable = true;
    yt-dlp.enable = true;
  };

  # Theming
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
    platformTheme.name = "gtk2";
  };

  fonts.fontconfig.enable = true;

  # Window Manager
  wayland.windowManager = {
    # Sway
    sway = {
      enable = true;
      config = rec {
        modifier = "Mod4";
        terminal = "kitty";
        startup = [
          {command = "cursor ~/nix";}
        ];
      };
    };

    # Hyprland
    hyprland = {
      enable = true;
      extraConfig = ''
        exec-once = "cursor ~/nix"
      '';
    };
  };

  # File Associations
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Documents
        "application/pdf" = ["firefox.desktop"];
        "text/plain" = ["neovim.desktop"];
        "text/html" = "firefox.desktop";

        # Images
        "image/jpeg" = ["qimgv.desktop"];
        "image/png" = ["qimgv.desktop"];

        # Video
        "video/mkv" = ["mpv.desktop"];
        "video/mp4" = ["mpv.desktop"];
        "video/webm" = ["mpv.desktop"];

        # System
        "inode/directory" = ["thunar.desktop"];
        "x-scheme-handler/about" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
        "x-scheme-handler/unknown" = ["firefox.desktop"];
      };
    };
  };
}
