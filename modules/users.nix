{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iggut = {
    isNormalUser = true;
    initialPassword = "nixos";
    uid = 1000;
    description = "iggut";
    shell = pkgs.nushell;
    extraGroups = [
      "wheel"
      "libvirtd"
      "kvm"
      "audio"
      "networkmanager"
      "disk"
      "video"
      "docker"
      "media"
      "input"
      "qemu-libvirtd"
    ];
    packages = with pkgs; [
      p7zip
      neovim
      obs-studio
      mpv
      gimp
      brave
      discord
      webcord-vencord
      swaylock-effects
      swayidle
      wlogout
      swaybg #Login etc..
      waybar #topbar
      wayland-protocols
      libsForQt5.qt5.qtwayland
      kanshi #laptop dncies
      rofi
      mako
      rofimoji #Drawer + notifications
      jellyfin-ffmpeg #multimedia libs
      viewnior #image viewr
      pavucontrol #Volume control
      pinentry-gnome
      qgnomeplatform
      polkit_gnome
      xfce.thunar #filemanager
      xfce.xfconf
      xfce.thunar-volman
      gnome-text-editor
      gnome.file-roller
      gnome.adwaita-icon-theme
      gnome.evince
      gnome.gnome-font-viewer
      gnome.gnome-calculator
      vlc #Video player
      amberol #Music player
      cava #Sound Visualized
      wl-clipboard
      wf-recorder #Video recorder
      sway-contrib.grimshot #Screenshot
      ffmpegthumbnailer #thumbnailer
      playerctl #play,pause..
      pamixer #mixer
      brightnessctl #Brightness control
      ####GTK Customization####
      nordic
      papirus-icon-theme
      gtk3
      glib
      xcur2png
      rubyPackages.glib2
      libcanberra-gtk3 #notification sound
      nix-index
      #########System#########
      kitty
      gnome.gnome-system-monitor
      libnotify
      poweralertd
      dbus
      #gsettings-desktop-schemas
      #wrapGAppsHook
      #xdg-desktop-portal-hyprland
      ####photoshop dencies####
      gnome.zenity
      wine64Packages.waylandFull
      curl
      #########################
      grim
      swappy
      wayland
      wayland-utils
      wayshot
      wev
      wf-recorder
      wl-clipboard
      wlr-randr
      wtype
      sov
    ];
  };

  #swaylock pass verify
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  # Automatically tune nice levels
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  # Get notifications about earlyoom actions
  services.systembus-notify.enable = true;

  # 90% ZRAM as swap
  zramSwap = {
    algorithm = "zstd";
    enable = true;
    memoryPercent = 90;
  };

  # Earlyoom to prevent OOM situations
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;
  };

  services.openssh.enable = true;

  #thunar dencies
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;

  #gnome outside gnome
  programs.dconf.enable = true;

  programs = {
    #nm-applet.enable = true; # Network manager tray icon
    kdeconnect.enable = true; # Connect phone to PC
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = ["iggut"];
    };
  };

  programs.adb.enable = true;

  programs.seahorse.enable = true;

  programs.nix-index.enable = true;

  programs.command-not-found.enable = false;

  # Configure system services
  environment.etc = {
    "polkit-gnome".source = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    "kdeconnectd".source = "${pkgs.libsForQt5.kdeconnect-kde}/libexec/kdeconnectd";
    "xdg/user-dirs.defaults".text = ''
      DESKTOP=$HOME/Desktop
      DOWNLOAD=$HOME/Downloads
      TEMPLATES=$HOME/Templates
      PUBLICSHARE=$HOME/Public
      DOCUMENTS=$HOME/Documents
      MUSIC=$HOME/Music
      PICTURES=$HOME/Photos
      VIDEOS=$HOME/Video
    '';
  };

  #Overlays
  #Waybar wlr/Workspaces
  nixpkgs.overlays = [
    (self: super: {
      waybar = super.waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
      });
    })
  ];
}
