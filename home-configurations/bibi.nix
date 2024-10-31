{ezModules, inputs, pkgs, ...}: {
  imports = with inputs; builtins.attrValues [
    ezModules.qimgv
    ezModules.alf
    hyprland.homeModules.default
  ];

  home = {
    stateVersion = "24.11";
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox";
      TERMINAL = "kitty";
      PAGER = "more";
      FZF_DEFAULT_COMMAND = "fd --type f";
      MOZ_USE_XINPUT2 = "1";
    };
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
      plugins = let
        mkFishPlugin = pkg: {
          name = pkg.pname;
          src = pkg.src;
        };
      in
        with pkgs.fishPlugins; [
          (mkFishPlugin z)
          (mkFishPlugin bass)
          (mkFishPlugin fzf-fish)
          (mkFishPlugin autopair)
          (mkFishPlugin sponge)
          (mkFishPlugin git-abbr)
          (mkFishPlugin fish-you-should-use)
          (mkFishPlugin done)
          (mkFishPlugin tide)
        ];
    };
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
      package = pkgs.vscode-insiders;
      extensions = with pkgs.vscode-extensions; [
        artdiniz.quitcontrol-vscode
        bbenoist.nix
        berberman.vscode-cabal-fmt
        bmalehorn.vscode-fish
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
        continue.continue
        davidanson.vscode-markdownlint
        dbaeumer.vscode-eslint
        dracula-theme.theme-dracula
        dustypomerleau.rust-syntax
        foxundermoon.shell-format
        haskell.haskell
        jnoortheen.nix-ide
        justusadam.language-haskell
        kamadorueda.alejandra
        kenhowardpdx.vscode-gist
        lacroixdavid1.vscode-format-context-menu
        mattn.lisp
        mikoz.black-py
        mkhl.direnv
        ms-python.vscode-pylance
        ms-vscode.vscode-typescript-next
        mvllow.rose-pine
        natqe.reload
        qcz.text-power-tools
        redhat.vscode-yaml
        rust-lang.rust-analyzer
        tamasfe.even-better-toml
        timonwong.shellcheck
        vscode-org-mode.org-mode
      ];
    };
    bat.enable = true;
    btop.enable = true;
    eza.enable = true;
    fd.enable = true;
    fzf.enable = true;
    gallery-dl.enable = true;
    gh.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    mpv.enable = true;
    pandoc.enable = true;
    ripgrep.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    yt-dlp.enable = true;
    zoxide.enable = true;
  };
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
    systemd.enable = true; # Enable systemd integration
    xwayland.enable = true; # Enable XWayland support

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";
      "$browser" = "google-chrome-stable";
      "$editor" = "cursor";
      "$fileManager" = "thunar";
      "$volume" = "pavucontrol";

      # Monitor configuration
      monitor = [
        "HDMI-A-1,1920x1080@60,0x0,1"
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;

        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
          middle_button_emulation = true;
        };
      };

      # General window and system behavior
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
        resize_on_border = true;
      };

      # Window decorations
      decoration = {
        rounding = 10;
        drop_shadow = true;
        shadow_range = 8;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";

        blur = {
          enabled = true;
          size = 5;
          passes = 2;
          new_optimizations = true;
          ignore_opacity = false;
          xray = false;
        };

        active_opacity = 1.0;
        inactive_opacity = 0.93;
        fullscreen_opacity = 1.0;
      };

      # Animations
      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
          "linear, 0.0, 0.0, 1.0, 1.0"
        ];

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
          "specialWorkspace, 1, 6, myBezier, slidevert"
        ];
      };

      # Layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
        no_gaps_when_only = false;
        force_split = 0;
      };

      # Gesture settings
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
        workspace_swipe_distance = 300;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 30;
      };

      # Misc settings
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        vrr = 1; # Variable refresh rate
      };

      # Window rules
      windowrule = [
        "float,^(pavucontrol)$"
        "float,^(blueman-manager)$"
        "float,^(nm-connection-editor)$"
        "float,title:^(btop)$"
        "float,title:^(update-sys)$"
        "float,^(wofi)$"
        "center,^(pavucontrol)$"
        "size 800 600,^(pavucontrol)$"
        "workspace 2 silent,^(firefox)$"
        "workspace 3 silent,^(code)$"
        "float,^(zoom)$"
        "opacity 0.95,^(Code)$"
        "opacity 0.95,^(code-url-handler)$"
      ];

      # Key bindings
      bind = [
        # Basic window and system controls
        "$mod, Return, exec, $terminal"
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, $fileManager"
        "$mod, V, togglefloating,"
        "$mod, R, exec, $menu"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"
        "$mod, F, fullscreen, 0"

        # Window focus and movement
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"

        # Window resizing
        "$mod ALT, left, resizeactive, -20 0"
        "$mod ALT, right, resizeactive, 20 0"
        "$mod ALT, up, resizeactive, 0 -20"
        "$mod ALT, down, resizeactive, 0 20"

        # Workspace management
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
        ", Print, exec, hyprshot -m monitor"
        "SHIFT, Print, exec, hyprshot -m region"
        "CTRL, Print, exec, hyprshot -m window"
        "CTRL SHIFT, Print, exec, hyprshot -m window -m active"

        # Quick app launches
        "$mod, B, exec, $browser"
        "$mod SHIFT, Return, exec, $editor"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      # Startup applications
      exec-once = [
        "dunst" # Notification daemon
        "swww init" # Wallpaper daemon
        "waybar" # Status bar
        "nm-applet --indicator" # Network manager applet
        "blueman-applet" # Bluetooth applet
        "/usr/lib/polkit-kde-authentication-agent-1" # Authentication agent
        "wl-paste --type text --watch cliphist store" # Clipboard manager
        "wl-paste --type image --watch cliphist store"
      ];
    };
  };
}
