{
  description = "crunchdev NixOS configurations";

  inputs = {
    nixos.url = "github:nixos/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixos";
    };
    flake-utils.url = "github:numtide/flake-utils";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixos";
      };
    };
    naersk = {
      url = "github:nix-community/naersk";
      inputs = {
        nixpkgs.follows = "nixos";
      };
    };
    nix-cache-cut = {
      url = "github:astro/nix-cache-cut";
      inputs = {
        naersk.follows = "naersk";
        nixpkgs.follows = "nixos";
        utils.follows = "flake-utils";
      };
    };
    skyflake = {
      url = "github:astro/skyflake";
      inputs = {
        microvm.follows = "microvm";
        nixpkgs.follows = "nixos";
        nix-cache-cut.follows = "nix-cache-cut";
      };
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixos";
        nixpkgs-stable.follows = "nixos";
      };
    };
  };
  outputs = inputs@{ self, disko, microvm, naersk, nixos, nixos-hardware, skyflake, sops-nix, ... }:
    let
      inherit (nixos) lib;

      ssh-public-keys = import ./ssh-public-keys.nix;

      nixosSystem' =
        { nixos ? inputs.nixos
        , modules
        , system ? "x86_64-linux"
      }@args:

      { inherit args; } // nixos.lib.nixosSystem {
        inherit system;

        modules = [
          ({ pkgs, ... }: {
            _module.args = {
              inherit nixos ssh-public-keys;
            };
          })
        ] ++ modules;
      };
    in {

      nixosConfigurations = {
        sky01 = nixosSystem' {
          modules = [
            ./hosts/sky01
            self.nixosModules.cluster
            skyflake.nixosModules.default
            { _module.args = { inherit self; }; }
          ];
        };
      };
    };
}