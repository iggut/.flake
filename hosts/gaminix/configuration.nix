{
  config,
  pkgs,
  lib,
  inputs,
  modulesPath,
  ...
}: {
  # Include the results of the hardware scan.
  imports = [
    ./hardware-configuration.nix
    ../../modules/core.nix
    ../../modules/nvidia.nix
    #../../modules/nvidia-laptop.nix
  ];

  # Define your hostname
  networking.hostName = "gaminix";
}
