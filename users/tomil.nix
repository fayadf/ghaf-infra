# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  users.users = {
    tomi = {
      description = "Tomi Laine";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkgp5NrCnUXTwQZuzznNjagOL0dlLWtBdqUx6SEtflC tomi@tomi-asus"
      ];
      extraGroups = [ "wheel" ];
    };
  };
}
