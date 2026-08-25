# SPDX-FileCopyrightText: 2022-2025 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  self,
  inputs,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    ./disk-config.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.disko.nixosModules.disko
  ]
  ++ (with self.nixosModules; [
    common
    openssh
    user-bmg
    user-fayad
    team-devenv
  ]);

  sops.defaultSopsFile = ./secrets.yaml;

  users.groups.tsusers = { };

  boot = {
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "ahci"
      "nvme"
      "uas"
      "usbhid"
      "sd_mod"
    ];
  };

  networking.hostName = "uae-lab-builder1";

  # this server has been installed with 26.05
  system.stateVersion = lib.mkForce "26.05";

}
