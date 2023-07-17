{
  description = "Hyprland+waybar";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    hyprland.url = "github:hyprwm/Hyprland";

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    alejandra,
    self,
    nixpkgs,
    hyprland,
    home-manager,
    disko,
    ...
  }: let
    user = "iggut";
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    lib = nixpkgs.lib;
  in {
    nixosConfigurations = {
      iggut = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit user;};
        modules = [
          {
            environment.systemPackages = [alejandra.defaultPackage.${system}];
          }
          disko.nixosModules.disko
          ./disko-config.nix
          {
            _module.args.disks = ["/dev/nvme1n1"];
          }
          ./configuration.nix
          hyprland.nixosModules.default
          {
            programs.hyprland.enable = true;
            programs.hyprland.nvidiaPatches = true;
            programs.hyprland.xwayland.enable = true;
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit user;};
            home-manager.users.iggut = import ./home/home.nix;
          }
        ];
      };
    };

    nixosConfigurations = {
      gs66 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit user;};
        modules = [
          {
            environment.systemPackages = [alejandra.defaultPackage.${system}];
          }
          disko.nixosModules.disko
          ./hosts/gs66/disko-config.nix
          ./hosts/gs66/configuration.nix
          hyprland.nixosModules.default
          {
            programs.hyprland.enable = true;
            programs.hyprland.nvidiaPatches = true;
            programs.hyprland.xwayland.enable = true;
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit user;};
            home-manager.users.iggut = import ./home/home.nix;
          }
        ];
      };
    };
  };
}
#nixos-23.05

