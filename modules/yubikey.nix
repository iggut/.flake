{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-manager-qt
    yubico-pam
    yubioath-flutter
    gnome.gnome-tweaks
    gnome.gnome-keyring
  ];

  services = {
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
    dbus = {
      enable = true;
      # Make the gnome keyring work properly
      packages = [pkgs.gnome.gnome-keyring pkgs.gcr];
    };

    gnome.gnome-keyring.enable = true;
  };

  # Enable the smartcard daemon
  hardware.gpgSmartcards.enable = true;

  # Configure as challenge-response for instant login,
  # can't provide the secrets as the challenge gets updated
  security.pam.yubico = {
    debug = true;
    enable = true;
    mode = "challenge-response";
    id = ["23911227"];
  };
  security.polkit.enable = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  # Automatically unlock gnome_keyring (gdm is supposed to do this but doesn't when using hyprland).
  services.xserver.displayManager = {
    sessionCommands = ''
      eval $(/run/wrappers/bin/gnome-keyring-daemon --start --daemonize)
      export SSH_AUTH_SOCK
    '';
  };
  security.pam.services = [
    { name = "gnome_keyring"
      text = ''
        auth     optional    ${gnome.gnome_keyring}/lib/security/pam_gnome_keyring.so
        session  optional    ${gnome.gnome_keyring}/lib/security/pam_gnome_keyring.so auto_start
        password  optional    ${gnome.gnome_keyring}/lib/security/pam_gnome_keyring.so
      '';
    }
  ];
}
