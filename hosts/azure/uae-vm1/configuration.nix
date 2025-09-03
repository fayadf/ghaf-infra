# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  self,
  pkgs,
  inputs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ../../azure-common.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko
  ]
  ++ (with self.nixosModules; [
    common
    service-openssh
    user-fayad
  ]);

  # this server has been installed with 24.05
  system.stateVersion = lib.mkForce "24.05";

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;

  #  sops = {
  #    defaultSopsFile = ./secrets.yaml;
  #    secrets = {
  #      loki_password.owner = "promtail";
  #    };
  #  };

  networking = {
    hostName = "ghaf-infra-vm1";
  };

  boot = {
    # use predictable network interface names (eth0)
    # kernelParams = [ "net.ifnames=0" ];
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    initrd.systemd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    screen
    tmux
  ];

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };
}
