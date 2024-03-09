{ config, pkgs, lib, ... }:

let
  user = "rileymathews";
  hostname = "myhostname";
in {
  imports = [
    ./hardware.nix
  ];
  environment.pathsToLink = [ "/libexec" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.xserver = {
    enable = true;
    layout = "us";
    autorun = true;
    exportConfiguration = true;

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+i3";
    windowManager.i3.enable = true;
    windowManager.i3.extraPackages = with pkgs; [
      dmenu
      i3status
    ];
  };


  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = hostname;
  };

  environment.systemPackages = with pkgs; [ vim git neovim gcc i3 firefox ];

  services.openssh.enable = true;

  users = {
    mutableUsers = true;
    users."${user}" = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
