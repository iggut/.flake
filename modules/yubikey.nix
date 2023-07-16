{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-manager-qt
    yubico-pam
    yubico-piv-tool
    yubioath-flutter
    yubikey-personalization-gui
    gnome.gnome-tweaks
    gnome.gnome-keyring
    pam_u2f
  ];

  services = {
    pcscd.enable = true;
    udev.packages = [pkgs.yubikey-personalization];
    dbus = {
      enable = true;
      # Make the gnome keyring work properly
      packages = [pkgs.gcr];
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
  security.pam.services.login.enableGnomeKeyring = true;
  # Automatically unlock gnome_keyring (gdm is supposed to do this but doesn't when using hyprland).

  security.pam.services.gnome_keyring.text = ''
    account  include    login

    auth     requisite  pam_nologin.so
    auth     required   pam_succeed_if.so uid >= 1000 quiet
    auth     sufficient ${pkgs.yubico-pam}/lib/security/pam_yubico.so mode=challenge-response authfile=/etc/yubikey_mappings
    auth     optional   ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
    auth     include    login

    password optional   ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so use_authok

    session  include    login
  '';
}
