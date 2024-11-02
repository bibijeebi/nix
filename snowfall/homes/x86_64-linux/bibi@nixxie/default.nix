# homes/x86_64-linux/bibi/default.nix
{ pkgs, ... }: {

  modules = {
    aichat.enable = true;
    alf.enable = true;
    bash.enable = true;
    fish.enable = true;
    hyprland.enable = true;
    kitty.enable = true;
    qimgv.enable = true;
    scripts.enable = false;
    starship.enable = true;
    tools.enable = true;
    waybar.enable = true;
    zsh.enable = true;
  };

  home = {
    stateVersion = "24.05";
    sessionVariables = {
      BROWSER = "firefox";
      MOZ_USE_XINPUT2 = "1";
    };
  };
  # Basic environment setup
  gtk = {
    enable = true;
    theme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
