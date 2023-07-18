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
    ../../modules/nvidia.nix
  ];

  # Define your hostname
  networking.hostName = "gs66";
}
