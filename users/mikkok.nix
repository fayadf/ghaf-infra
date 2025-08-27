# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  users.users = {
    mikko = {
      description = "Mikko Keskitalo";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB2PyJbVHI6ytoxUWDAaSvII/MnjaJDVifYjQR5KihSW mikko@LaptopMikko"
      ];
      extraGroups = [ "wheel" ];
    };
  };
}
