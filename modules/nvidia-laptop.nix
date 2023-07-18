{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}: let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in {
  environment.systemPackages = with pkgs; [
    nvidia-offload
  ];

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
  };

  virtualisation.docker.enableNvidia = true;
  virtualisation.podman.enableNvidia = true;
  #Nvidia
  #Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # NVIDIA drivers are unfree.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
    ];

  # Tell Xorg to use the nvidia driver
  services.xserver.videoDrivers = ["nvidia"];

  hardware = {
    nvidia = {
      nvidiaPersistenced = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      # Modesetting is needed for most wayland compositors
      modesetting.enable = true;
      # Use the open source version of the kernel module
      # Only available on driver 515.43.04+
      open = true;
      # Enable the nvidia settings menu < nvidia-settings doesn't work with clang lto
      nvidiaSettings = false;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        reverseSync.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
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
