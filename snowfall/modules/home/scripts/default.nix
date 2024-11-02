# modules/home/scripts/default.nix
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.scripts;

  # Helper function to create a script package
  mkScript = name: text: deps:
    pkgs.writeScriptBin name ''
      #!${pkgs.bash}/bin/bash
      export PATH="${lib.makeBinPath deps}:$PATH"
      ${text}
    '';

  # Helper to convert a Fish function to a shell script
  mkFishScript = name: text: deps:
    pkgs.writeScriptBin name ''
      #!${pkgs.fish}/bin/fish
      set -x PATH ${lib.makeBinPath deps} $PATH
      ${text}
    '';
in {
  options.modules.scripts = {
    enable = mkEnableOption "user scripts";

    # General options
    path = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/bin";
      description = "Directory to install scripts";
    };

    # Git hooks configuration
    gitHooks = {
      enable = mkEnableOption "git hooks installation";

      hooksPath = mkOption {
        type = types.str;
        default = ".git/hooks";
        description = "Path to install git hooks";
      };
    };

    # Optional script-specific enables
    enableWebExtAnalyzer = mkEnableOption "web extension analyzer script";
    enableImgTools = mkEnableOption "image manipulation tools";
    enableGitTools = mkEnableOption "git helper tools";
    enableMusicTools = mkEnableOption "music review tools";
  };

  config = mkIf cfg.enable {
    home.packages =
      # Always included scripts
      [
        (mkFishScript "rmdupes" ''
          function rmdupes --description "Remove duplicate files using fclones"
              argparse h/help -- $argv
              or return

              if set -q _flag_help
                  echo "Usage: rmdupes [DIRECTORIES...]"
                  echo "Remove duplicate files using fclones"
                  return 0
              end

              set -l dirs $argv
              test (count $dirs) -eq 0
              and set dirs .

              fclones group $dirs | fclones remove
          end
        '' [ pkgs.fclones ])

        (mkScript "upscale" ''
          #!/usr/bin/env bash
          set -euo pipefail

          # Validate input
          if [ $# -ne 1 ]; then
            ${pkgs.libnotify}/bin/notify-send "Error" "Usage: $0 <image_path>"
            exit 1
          fi

          # Initialize variables
          image_path="$1"
          filename=$(basename "$image_path")
          extension="''${filename##*.}"
          name="''${filename%.*}"
          timestamp=$(date +%Y%m%d_%H%M%S)
          backup_path="/tmp/upscale_backup"

          # Create backup
          mkdir -p "$backup_path"
          cp "$image_path" "$backup_path/''${name}_''${timestamp}.''${extension}"

          # Upscale image
          realesrgan-ncnn-vulkan \
            -i "$image_path" \
            -o "$image_path" \
            -n realesrgan-x4plus

          notify-send "Success" "Image upscaled and backup created"
        '' [ pkgs.realesrgan-ncnn-vulkan pkgs.libnotify ])
      ]

      # Web extension analysis tool
      ++ lib.optionals cfg.enableWebExtAnalyzer [
        (mkScript "analyze_webext" (builtins.readFile ./analyze_webext.sh) [
          pkgs.jsbeautifier
          pkgs.jq
          pkgs.curl
          pkgs.anthropic-claude
        ])
      ]

      # Image tools
      ++ lib.optionals cfg.enableImgTools [
        (mkScript "imcrop" (builtins.readFile ./imcrop.py)
          [ (pkgs.python3.withPackages (ps: with ps; [ mediapipe opencv4 ])) ])
      ]

      # Git tools
      ++ lib.optionals cfg.enableGitTools [
        (mkFishScript "autogit" (builtins.readFile ./autogit.fish) [
          pkgs.git
          pkgs.anthropic-claude
        ])
      ]

      # Music tools
      ++ lib.optionals cfg.enableMusicTools [
        (mkScript "music_review" (builtins.readFile ./music_review.sh) [
          pkgs.yt-dlp
          pkgs.curl
          pkgs.jq
          pkgs.anthropic-claude
        ])
      ];

    # Install git hooks if enabled
    home.activation.installGitHooks = mkIf cfg.gitHooks.enable (let
      hookScript = pkgs.writeScript "install-hooks" ''
        #!${pkgs.bash}/bin/bash

        # Common utilities for all hooks
        HOOKS_DIR="$1"

        # Colors for output
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        NC='\033[0m' # No Color

        log_error() {
          echo -e "''${RED}ERROR:''${NC} $1"
        }

        log_success() {
          echo -e "''${GREEN}SUCCESS:''${NC} $1"
        }

        log_warning() {
          echo -e "''${YELLOW}WARNING:''${NC} $1"
        }

        # Install hooks
        ${builtins.readFile ./git-hooks.sh}

        # Make all hooks executable
        chmod +x "$HOOKS_DIR/pre-commit"
        chmod +x "$HOOKS_DIR/pre-push"
        chmod +x "$HOOKS_DIR/post-merge"

        log_success "Git hooks installed successfully!"
      '';
    in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${hookScript} ${cfg.gitHooks.hooksPath}
    '');

    # Ensure script directory exists
    home.activation.createScriptDir =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p "${cfg.path}"
      '';
  };
}
