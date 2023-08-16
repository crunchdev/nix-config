{ config, lib, pkgs, ... }:

{
  options.crunchdev.baremetal = lib.mkEnableOption "baremetal";

  config = {
    environment.systemPackages = with pkgs; [
      freeipmi
      lshw
      pciutils
      smartmontools
    ];
    nix.settings.system-features = [
      "kvm" "big-parallel" "nixos-test" "benchmark"
    ];

    powerManagement.cpuFreqGovernor = "schedutil";

    services = {
      fstrim.enable = true;
      smartd.enable = true;
    };
  };
}