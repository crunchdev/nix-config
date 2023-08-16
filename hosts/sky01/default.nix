_:

{
  imports = [
    ./hardware-configuration.nix
  ];

  crunchdev = {
    baremetal = true;
  };

  boot = {
    loader.systemd-boot.enable = true;
  };

  networking = {
    hostName = "sky01";
    hostId = "deadbeef";
  };

  simd.arch = "ivybridge"; # E5-2695 v2

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets."machine-id" = {
      mode = "444";
      path = "/etc/machine-id";
    };
  };

  skyflake.nomad.client.meta."crunchdev.cpuSpeed" = "5";

  disko.devices = {
    disk = {
      nodev = {
        "/" = {
          fsType = "tmpfs";
          mountOptions = [
            "defaults"
            "mode=755"
            "size=15G"
          ];
        };
      };
      main = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4CMNG0M101487V";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            nix = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };

  system.stateVersion = "23.05";
}