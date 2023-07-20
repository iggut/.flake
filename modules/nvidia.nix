{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}: {
  #Nvidia
  #Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Tell Xorg to use the nvidia driver
  services.xserver.videoDrivers = ["nvidia"];

  environment.variables = {
    EDITOR = "code";
    BROWSER = "brave";
    TERMINAL = "kitty";
    LAUNCHER = "nwg-drawer";
    GBM_BACKEND = "nvidia-drm";
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    WLR_DRM_NO_ATOMIC = "1";
    XDG_SESSION_TYPE = "wayland";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland";
    WLR_NO_HARDWARE_CURSORS = "1";
    MOZ_ENABLE_WAYLAND = "1";
    WLR_BACKEND = "vulkan";
    WLR_RENDERER = "vulkan";
    XCURSOR_SIZE = "24";
    NIXOS_OZONE_WL = "1";
  };

  programs.xwayland.enable = true;

  virtualisation.docker.enableNvidia = true;
  virtualisation.podman.enableNvidia = true;

  hardware = {
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
      ];
    };
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };
}
