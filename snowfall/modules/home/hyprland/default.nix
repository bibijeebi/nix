# modules/home/hyprland/default.nix
{ config, lib, pkgs, inputs, ... }:

with lib;

let cfg = config.modules.hyprland;
in {
  options.modules.hyprland = {
    enable = mkEnableOption "Hyprland configuration";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
      xwayland.enable = true;

      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

      settings = {
        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$menu" = "wofi --show drun";
        "$browser" = "google-chrome-stable";
        "$editor" = "cursor";
        "$fileManager" = "thunar";
        "$volume" = "pavucontrol";

        monitor = [ "HDMI-A-1,1920x1080@60,0x0,1" ];

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

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          resize_on_border = true;
        };

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

        animations = {
          enabled = true;
          bezier =
            [ "myBezier, 0.05, 0.9, 0.1, 1.05" "linear, 0.0, 0.0, 1.0, 1.0" ];

          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
            "specialWorkspace, 1, 6, myBezier, slidevert"
          ];
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          no_gaps_when_only = false;
          force_split = 0;
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
          workspace_swipe_distance = 300;
          workspace_swipe_invert = true;
          workspace_swipe_min_speed_to_force = 30;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
          vrr = 1;
        };

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

        bind = [
          "$mod, Return, exec, $terminal"
          "$mod, C, killactive,"
          "$mod, M, exit,"
          "$mod, E, exec, $fileManager"
          "$mod, V, togglefloating,"
          "$mod, R, exec, $menu"
          "$mod, P, pseudo,"
          "$mod, J, togglesplit,"
          "$mod, F, fullscreen, 0"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

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

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
          "$mod ALT, mouse:272, resizewindow"
        ];

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

    # Install required packages for the Hyprland setup
    home.packages = with pkgs; [
      dunst # Notification daemon
      swww # Wallpaper daemon
      waybar # Status bar
      wofi # Application launcher
      hyprshot # Screenshot utility
      wl-clipboard # Clipboard utilities
      cliphist # Clipboard manager
      networkmanagerapplet
      blueman
    ];
  };
}
