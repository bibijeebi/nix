# modules/home/waybar/default.nix
{ config, lib, ... }:

with lib;

let cfg = config.modules.waybar;
in {
  options.modules.waybar = { enable = mkEnableOption "Waybar configuration"; };

  config = mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          modules-left = [ "hyprland/workspaces" "hyprland/mode" ];
          modules-center = [ "hyprland/window" ];
          modules-right =
            [ "pulseaudio" "network" "cpu" "memory" "battery" "clock" "tray" ];

          "hyprland/workspaces" = {
            format = "{icon}";
            on-click = "activate";
            format-icons = {
              urgent = "";
              active = "";
              default = "";
            };
            sort-by-number = true;
          };

          "clock" = {
            format = "{:%I:%M %p}";
            format-alt = "{:%Y-%m-%d}";
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
          };

          "cpu" = {
            format = " {usage}%";
            tooltip = false;
          };

          "memory" = { format = " {}%"; };

          "network" = {
            format-wifi = " {essid} ({signalStrength}%)";
            format-ethernet = " {ipaddr}";
            tooltip-format = " {ifname} via {gwaddr}";
            format-linked = " {ifname} (No IP)";
            format-disconnected = "⚠ Disconnected";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };

          "pulseaudio" = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}% ";
            format-bluetooth-muted = " {icon} ";
            format-muted = " ";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
          };

          "battery" = {
            states = {
              good = 95;
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{icon} {time}";
            format-icons = [ "" "" "" "" "" ];
          };
        };
      };

      style = ''
        * {
          border: none;
          border-radius: 0;
          font-family: "CaskaydiaCove Nerd Font";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background-color: rgba(26, 27, 38, 0.8);
          color: #ffffff;
        }

        #workspaces button {
          padding: 0 5px;
          color: #ffffff;
        }

        #workspaces button.active {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
        }

        #clock,
        #battery,
        #cpu,
        #memory,
        #network,
        #pulseaudio,
        #custom-spotify,
        #tray,
        #mode {
          padding: 0 10px;
          margin: 0 5px;
        }

        #battery.critical:not(.charging) {
          background-color: #f53c3c;
          color: #ffffff;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: linear;
          animation-iteration-count: infinite;
          animation-direction: alternate;
        }

        @keyframes blink {
          to {
            background-color: #ffffff;
            color: #000000;
          }
        }
      '';
    };
  };
}
