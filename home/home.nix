{
  config,
  pkgs,
  self,
  user,
  lib,
  ...
}: {
  imports = [
    ./brave.nix
    ./vscode.nix
    ./swayidle.nix
    ./shell.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "iggut";
  home.homeDirectory = lib.mkDefault "/home/iggut";

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

  systemd.user.services = {
    polkit-gnome = {
      Unit = {
        Description = "polkit-gnome";
        Documentation = ["man:polkit(8)"];
        PartOf = ["hyprland-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        RestartSec = 3;
        Restart = "always";
      };
      Install = {
        WantedBy = ["hyprland-session.target"];
      };
    };
  };

  #Hyprland
  home = {
    sessionVariables = {
      EDITOR = "code";
      BROWSER = "brave";
      TERMINAL = "kitty";
      LAUNCHER = "nwg-drawer";

      XDG_CACHE_HOME = "\${HOME}/.cache";
      XDG_CONFIG_HOME = "\${HOME}/.config";
      XDG_BIN_HOME = "\${HOME}/.local/bin";
      XDG_DATA_HOME = "\${HOME}/.local/share";
    };
    sessionPath = [
      "$HOME/.npm-global/bin"
      "$HOME/.local/bin"
      "$HOME/Codelearning/go/bin"
    ];
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
