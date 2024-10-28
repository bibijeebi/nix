{
  config,
  pkgs,
  ...
}: {
  home.stateVersion = "24.11";

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
      themeFile = "Catppuccin-Mocha";
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

    waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          modules-left = ["hyprland/workspaces" "hyprland/mode"];
          modules-center = ["hyprland/window"];
          modules-right = ["pulseaudio" "network" "cpu" "memory" "battery" "clock" "tray"];
        };
      };
    };

    vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        vscode-org-mode.org-mode
      ];
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
  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.adwaita-icon-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    settings = {
      # Monitor configuration
      monitor = [
        "HDMI-A-1,1920x1080@60,0x0,1"
        ",preferred,auto,1"
      ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      # Input configuration
      input = {
        follow_mouse = 0;
        sensitivity = 0;
      };

      # Window decoration
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          new_optimizations = true;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      # Window rules
      windowrule = [
        "float,^(pavucontrol)$"
        "float,^(blueman-manager)$"
        "float,^(nm-connection-editor)$"
        "float,title:^(btop)$"
        "float,title:^(update-sys)$"
      ];

      # Variables
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";
      "$volume" = "pamixer";
      "$brightness" = "brightnessctl";

      # Key bindings
      bind = [
        # Basic bindings
        "$mod, Return, exec, $terminal"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, nautilus"
        "$mod, V, togglefloating,"
        "$mod, R, exec, $menu"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        # Move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Move windows
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Switch workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move windows to workspaces
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Screenshot bindings
        ", Print, exec, grim"
        "SHIFT, Print, exec, grim -g \"$(slurp)\""
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      # Media and function keys
      bindle = [
        # Volume
        ", XF86AudioRaiseVolume, exec, $volume -i 5"
        ", XF86AudioLowerVolume, exec, $volume -d 5"
        ", XF86AudioMute, exec, $volume -t"

        # Brightness
        ", XF86MonBrightnessUp, exec, $brightness set +5%"
        ", XF86MonBrightnessDown, exec, $brightness set 5%-"

        # Media
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Startup applications
      exec-once = [
        "dunst"
        "swww init"
        "nm-applet --indicator"
        "blueman-applet"
        "swayidle -w timeout 300 'swaylock -f' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f'"
      ];
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
