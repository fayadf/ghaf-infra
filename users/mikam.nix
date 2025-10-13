# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  users.users = {
    mika = {
      description = "Mika Mikkela";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGf+cR9KRbBrRkCgwhNqWZ40aNtL8D/iju+dTSHH00kV meefe@LAPTOP-FAJL89A1"
      ];
      extraGroups = [ "wheel" ];
    };
  };
}
