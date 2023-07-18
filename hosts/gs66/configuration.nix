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
    ../../modules/nvidia-laptop.nix
  ];

  services.tlp.settings = {
    # Set battery thresholds
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
    # Use `tlp setcharge` to restore the charging thresholds
    RESTORE_THRESHOLDS_ON_BAT = 1;
    # Increase performance on AC
    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "balanced";
    # Use schedutil governor
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
  };

  # Define your hostname
  networking.hostName = "gs66";
}
