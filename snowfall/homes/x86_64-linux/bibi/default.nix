{pkgs, ...}: {
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
      plugins = with pkgs.fishPlugins; [
        {
          name = "z";
          src = z.src;
        }
        {
          name = "fzf-fish";
          src = fzf-fish.src;
        }
        {
          name = "autopair";
          src = autopair.src;
        }
        {
          name = "sponge";
          src = sponge.src;
        }
        {
          name = "git-abbr";
          src = git-abbr.src;
        }
        {
          name = "fish-you-should-use";
          src = fish-you-should-use.src;
        }
        {
          name = "done";
          src = done.src;
        }
        {
          name = "tide";
          src = tide.src;
        }
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
      extensions = with pkgs.vscode-extensions; [
        # ms-python.black-formatter
        # ms-python.debugpy
        # ms-python.isort
        # ms-python.python
        # ms-vscode.powershell
        # yib.rust-bundle
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
    gh.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    ripgrep.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
    gallery-dl.enable = true;
    mpv.enable = true;
    pandoc.enable = true;
    yt-dlp.enable = true;
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
    systemd.enable = true;
    settings = {
      monitor = [
        "HDMI-A-1,1920x1080@60,0x0,1"
        ",preferred,auto,1"
      ];
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };
      input = {
        follow_mouse = 0;
        sensitivity = 0;
      };
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
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };
      windowrule = [
        "float,^(pavucontrol)$"
        "float,^(blueman-manager)$"
        "float,^(nm-connection-editor)$"
        "float,title:^(btop)$"
        "float,title:^(update-sys)$"
      ];
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";
      "$volume" = "pavucontrol";
      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, E, exec, thunar"
        "$mod, V, togglefloating,"
        "$mod, R, exec, $menu"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, down, movewindow, d"
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
        ", Print, exec, grim"
        "SHIFT, Print, exec, grim -g \"$(slurp)\""
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
      exec-once = [
        "dunst"
        "swww init"
        "nm-applet --indicator"
        "blueman-applet"
        "swayidle -w timeout 300 'swaylock -f' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock -f'"
      ];
    };
  };
  xdg = {
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = ["firefox.desktop"];
        "text/plain" = ["neovim.desktop"];
        "text/html" = "firefox.desktop";
        "image/jpeg" = ["qimgv.desktop"];
        "image/png" = ["qimgv.desktop"];
        "video/mkv" = ["mpv.desktop"];
        "video/mp4" = ["mpv.desktop"];
        "video/webm" = ["mpv.desktop"];
        "inode/directory" = ["thunar.desktop"];
        "x-scheme-handler/about" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
        "x-scheme-handler/unknown" = ["firefox.desktop"];
      };
    };
  };
}
