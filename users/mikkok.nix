# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  users.users = {
    mikko = {
      description = "Mikko Keskitalo";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQfPasQtRvOtbUO3fKnp5yf/wXwUZo/t2do364v1SAmhIOVDRUfoKd0lrh2dVQ1M8oX/9PW5LnVMGXbVVJREvncMK2DwzdCQ1yKF50FlN7b9YZ5hJfG+LLJiJuaKJiwDvN5OqMxzok/8OMTENTJK89RLlL5aD9hBnj0czRWZ15gC76G2Mbw0eIMA81WQ6BNez4J72koYpSBb6TCibQU2rvawN4jIVXv248j0Ra249UigH301l9o3xHFe2i608vcoiarBeUInwa7cXqAsPwEPxNHDVEQS6J0hYlQbqTKh+48rr+rXd1YYsmBFU6i3MHUYXzZMqJurV3LY5Ac2NXfClW8o7/HAyt0BoOJLEAd9JsuXi/8XiRU0TmKngRWbk1EaSrbpFXXbmrkFSiUPIiCcIbULVQDaBs3kfodRxDLmAaTOmyMyoZFSvVvXvjlTQqcsWhtK1MGrrQMwFh7k15sbqfpaZvc7VdrPJ7bB9buV2KXztc1RiX8Mn+U93ue8KQsF0= mikko@DESKTOP-PMTE2L8"
      ];
      extraGroups = [ "wheel" ];
    };
  };
}
