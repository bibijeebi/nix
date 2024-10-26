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
        ai = "aichat";
        clp = "wl-copy";
        cls = "clear";
        pst = "wl-paste";
        t = "task";
        ya = "yazi";
      };
      plugins = [
        {
          name = "z";
          src = pkgs.fishPlugins.z.src;
        }
        {
          name = "autopair";
          src = pkgs.fishPlugins.autopair.src;
        }
        {
          name = "fish-you-should-use";
          src = pkgs.fishPlugins.fish-you-should-use.src;
        }
        {
          name = "done";
          src = pkgs.fishPlugins.done.src;
        }
        {
          name = "fzf-fish";
          src = pkgs.fishPlugins.fzf-fish.src;
        }
        {
          name = "git-abbr";
          src = pkgs.fishPlugins.git-abbr.src;
        }
        {
          name = "sponge";
          src = pkgs.fishPlugins.sponge.src;
        }
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
      ];
    };

    chromium = {
      enable = true;
      package = pkgs.google-chrome;
      commandLineArgs = [
        "--hide-scrollbars"
        "--disable-notifications"
        "--disable-features=DownloadBubble"
      ];
    };

    # neovim = {
    #   enable = true;
    #   defaultEditor = true;
    #   viAlias = true;
    #   vimAlias = true;
    #   vimdiffAlias = true;
    #   plugins = with pkgs.vimPlugins; [
    #     nvim-lspconfig
    #     nvim-treesitter.withAllGrammars
    #     plenary-nvim
    #     gruvbox-material
    #     mini-nvim
    #   ];
    # };

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

    bat.enable = true;
    btop.enable = true;
    eza.enable = true;
    fd.enable = true;
    firefox.enable = true;
    fzf.enable = true;
    gallery-dl.enable = true;
    gh.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    mpv.enable = true;
    pandoc.enable = true;
    ripgrep.enable = true;
    taskwarrior.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;
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
    platformTheme.name = "gtk2";
  };

  fonts.fontconfig.enable = true;

  # Window Manager
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
      startup = [
        {command = "cursor ~/nix";}
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
}
