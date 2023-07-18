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
      powerManagement.enable = true;
      # Modesetting is needed for most wayland compositors
      modesetting.enable = true;
      # Use the open source version of the kernel module
      # Only available on driver 515.43.04+
      open = true;
      # Enable the nvidia settings menu
      nvidiaSettings = true;
      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.latest;
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
