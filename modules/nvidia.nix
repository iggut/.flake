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

  services.xserver = {
    videoDrivers = ["nvidia"];
  };

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
