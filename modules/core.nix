{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
    builders-use-substitutes = true;
    keep-derivations = true;
    keep-outputs = true;
    allowed-users = ["@wheel"];
    trusted-users = ["root" "@wheel"];
    substituters = [
      "https://hyprland.cachix.org"
      "https://cache.nixos.org"
      "https://nixpkgs-unfree.cachix.org"
      "https://nyx.chaotic.cx"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
      "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    ];
  };

  # Include the results of the hardware scan.
  imports = [
    ./virtualisation.nix
    ./shell.nix
    ./users.nix
    ./game.nix
    ./yubikey.nix
    ../services/mullvad.nix
    ../services/fwupd.nix
    ../services/swapfile.nix
  ];

  #ntfs support
  boot.supportedFilesystems = ["btrfs" "ntfs"];
  # Fonts
  fonts.fonts = with pkgs; [
    font-awesome
    (nerdfonts.override {fonts = ["FiraCode" "JetBrainsMono" "Iosevka"];})
  ];

  boot.kernelModules = [
    "v4l2loopback" # Virtual camera
    "uinput"
    "fuse"
    "overlay"
  ];
  boot.extraModprobeConfig = ''
    options fuse allow_other
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Boot entries limit
  boot.loader.systemd-boot.configurationLimit = 10;

  # Enable networking
  networking.networkmanager.enable = true;
  # Bluethooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  services.envfs.enable = true;

  #Services
  # Enable ssd trim
  services.fstrim.enable = true;
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Flatpak
  services.flatpak.enable = true;
  # locate
  services.locate.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.tapping = true; #tap
  # Do nothing if AC on
  services.logind.lidSwitchExternalPower = "ignore";
  #tlp
  #services.tlp.enable = true;
  #upower dbus
  services.upower.enable = true;
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  #Display
  # Enable Gnome login
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = false;
  services.xserver.displayManager.defaultSession = "hyprland";
  services.dbus.packages = [pkgs.dconf];
  services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

  #SystemPackages
  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    nwg-drawer
    pinentry-gnome
    qgnomeplatform
    polkit_gnome
    polkit
    nerdfonts
    gnomeExtensions.systemd-manager
    gnomeExtensions.battery-threshold
    xfce.thunar #filemanager
    xfce.xfconf
    xfce.thunar-volman
    gnome-text-editor
    gnome.file-roller
    gnome.adwaita-icon-theme
    gnome.evince
    gnome.gnome-font-viewer
    gnome.gnome-calculator
    vim
    zig
    fuse
    wget
    killall
    git
    neofetch
    gh
    _1password
    bat
    binutils
    curl
    dig
    dua
    duf
    exa
    fd
    file
    gotop
    nix-index
    nwg-dock-hyprland
    helix
    htop
    jq
    pciutils
    ripgrep
    rsync
    traceroute
    tree
    unzip
    usbutils
    vulkan-tools
    glxinfo
    cmatrix
    wdisplays
    nvtop
    ntfs3g
    btop
    yq-go
    onlyoffice-bin # Microsoft Office alternative for Linux
    xorg.xhost # Use x.org server with distrobox
    qbittorrent
    xdg-utils
    cryptomator
  ];

  # Make applications find files in <prefix>/share
  environment.pathsToLink = ["/share"];

  # Move ~/.Xauthority out of $HOME (setting XAUTHORITY early isn't enough)
  environment.extraInit = ''
    export XAUTHORITY=/tmp/Xauthority
    [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
  '';

  # Disable coredumps
  systemd.coredump.enable = false;

  hardware.uinput.enable = true; # Enable uinput support

  programs.bash.interactiveShellInit = ''
    source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
  '';

  #Firewall
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  #For Chromecast from chrome
  #networking.firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
