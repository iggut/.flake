{
  config,
  pkgs,
  self,
  user,
  ...
}: {
  imports = [
    ./brave.nix
    ./vscode.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "iggut";
  home.homeDirectory = "/home/iggut";

  #Gtk
  gtk = {
    enable = true;
    font.name = "TeX Gyre Adventor 10";
    theme = {
      name = "Juno";
      package = pkgs.juno-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  #Hyprland
  home.sessionVariables = {
    # make stuff work on wayland
    QT_QPA_PLATFORM = "wayland-egl";
    CLUTTER_BACKEND = "wayland";
    #QT_QPA_PLATFORM = "wayland";
    #SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";

    BROWSER = "brave";
    TERMINAL = "kitty";
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
