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

  programs.dconf.enable = true;

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
    gtk2.extraConfig = "gtk-application-prefer-dark-theme = true";

    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;

    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
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
