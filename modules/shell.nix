{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  #shellAliases
  programs.bash.shellAliases = {
    switch = "sudo nixos-rebuild switch --flake .#nomad";
    switchu = "sudo nixos-rebuild switch --upgrade --flake .#nomad";
    clean = "sudo nix-collect-garbage -d";
    cleanold = "sudo nix-collect-garbage --delete-old";
    cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";
    gamesteam = "gamescope -e -w 1920 -h 1080 -f -F nis -- steam -tenfoot";
    list-packages = "nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq"; # List installed nix packages
  };
  #starship
  programs.starship.enable = true;
}
