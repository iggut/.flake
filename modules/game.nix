{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    goverlay
    mangohud
    osu-lazer-bin
    protonup-qt
    wine
    lutris
    gamemode
    gamescope
    bottles
    runelite
  ];

  hardware = {
    steam-hardware.enable = true;
    # xpadneo.enable = true;
  };

  #Steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # improvement for games using lots of mmaps (same as steam deck)
  boot.kernel.sysctl = {"vm.max_map_count" = 2147483642;};

  #Enable Gamescope
  programs.gamescope = {
    enable = true;
    package = pkgs.gamescope;
    capSysNice = true;
    args = ["--prefer-vk-device 10de:2206"]; #10de:2206 is my 3080
    #env = {
    #  "__GLX_VENDOR_LIBRARY_NAME" = "amd";
    #  "DRI_PRIME" = "1";
    #  "MESA_VK_DEVICE_SELECT" = "pci:1002:73ff";
    #  "__VK_LAYER_MESA_OVERLAY_CONFIG" = "ld.so.preload";
    #  "DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1" = "1";
    #};
  };

  # Enable gamemode
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 10;
      };
      custom = {
        start = "notify-send -a 'Gamemode' 'Optimizations activated'";
        end = "notify-send -a 'Gamemode' 'Optimizations deactivated'";
      };
    };
  };
}
