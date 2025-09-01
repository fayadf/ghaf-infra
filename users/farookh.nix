# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  users.users = {
    farookh = {
      description = "Farookh Rangrej";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINYE20IjBKCAgWu4OfDT+HyPIH/YRvvXODvJr9HZa/Wu farookh.rangrej@tii.ae"
      ];
      extraGroups = [
        "wheel"
        "tsusers"
      ];
    };
  };
}
