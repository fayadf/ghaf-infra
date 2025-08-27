# SPDX-FileCopyrightText: 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  self,
  pkgs,
  inputs,
  modulesPath,
  lib,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/profiles/qemu-guest.nix")
    inputs.sops-nix.nixosModules.sops
  ]
  ++ (with self.nixosModules; [
    common
    service-openssh
    user-bmg
    user-fayad
    team-profilence
  ]);

  users.groups.tsusers = { };
  sops = {
    defaultSopsFile = ./secrets.yaml;
  };

  # this server has been installed with 24.11
  system.stateVersion = lib.mkForce "25.05";

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.enableRedistributableFirmware = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "uae-lab-node1";
    useDHCP = true;
  };

  boot = {
    # use predictable network interface names (eth0)
    kernelParams = [ "net.ifnames=0" ];
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    screen
    tmux
    dmidecode
    pciutils
    dnsutils
    inetutils
    wget
    openssl
    nix-info
    nebula
    kubectl
    helm
    argocd
    k9s
  ];

  # RDP server configurations
  #  services.xserver.enable = true;
  #  services.displayManager.sddm.enable = true;
  #  services.desktopManager.plasma6.enable = true;

  # services.xrdp.enable = true;
  # services.xrdp.defaultWindowManager = "startplasma-x11";
  # services.xrdp.openFirewall = true;
  networking.firewall.allowedTCPPorts = [
    3389
    8080
    4822
  ];

  services.guacamole-server = {
    enable = true;
    host = "127.0.0.1";
    userMappingXml = ./user-mapping.xml;
    package = (import inputs.nixpkgs-unstable { inherit (pkgs) system; }).guacamole-server;
  };

  services.guacamole-client = {
    enable = true;
    enableWebserver = true;
    settings = {
      guacd-port = 4822;
      guacd-hostname = "127.0.0.1";
      auth-provider = "net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider";
      basic-user-mapping = "/etc/guacamole/user-mapping.xml";
      enable-rdp = true;
    };
  };

  system.activationScripts.copy-jar = ''
       source ${config.system.build.setEnvironment}
       if [ ! -d "/etc/guacamole/extensions" ];
       then 
    	mkdir -p /etc/guacamole/extensions && cd /etc/guacamole
            wget -O ./guacamole-auth-sso-1.6.0.tar.gz https://apache.org/dyn/closer.lua/guacamole/1.6.0/binary/guacamole-auth-sso-1.6.0.tar.gz?action=download
            tar -xvzf ./guacamole-auth-sso-1.6.0.tar.gz
       	mv ./guacamole-auth-sso-1.6.0/openid/guacamole-auth-sso-openid-1.6.0.jar ./extensions/ 
       	rm -rf /etc/guacamole/guacamole-auth-sso-1.6.0
       fi
  '';

  # services.oauth2-proxy = {
  #    enable = true;
  #    clientID = "uae-lab-node1";
  #    clientSecret = null;
  #    cookie.secret = null;
  #    provider = "oidc";
  #    oidcIssuerUrl = "https://auth.vedenemo.dev";
  #    setXauthrequest = true;
  #    cookie.secure = false;
  #    extraConfig = {
  #      email-domain = "*";
  #      auth-logging = true;
  #      request-logging = true;
  #      standard-logging = true;
  #      reverse-proxy = true;
  #      scope = "openid profile email groups";
  #      provider-display-name = "Vedenemo Auth";
  #      custom-sign-in-logo = "-";
  #      client-secret-file = config.sops.secrets.oauth2_proxy_client_secret.path;
  #      whitelist-domain = "10.161.5.196";
  #    };
  #    keyFile = config.sops.templates.oauth2_proxy_env.path;
  #  };

  #  services.nebula.networks.mesh = {
  #    enable = true;
  #    isLighthouse = false;
  #    lighthouses = [ "91.99.96.123" ];
  #    settings = {
  #        cipher= "aes";
  #        };
  #    cert = "/etc/nebula/host.crt";
  #    key = "/etc/nebula/host.key";
  #    ca = "/etc/nebula/ca.crt";
  #    staticHostMap = {
  #        "10.161.5.196" = [
  #                "91.99.96.123:4242"
  #                ];
  #        };
  #    firewall.outbound = [
  #    {
  #    host = "any";
  #    port = "any";
  #    proto = "any";
  #    }
  #   ];
  #    firewall.inbound = [
  #    {
  #    host = "any";
  #    port = "any";
  #    proto = "any";
  #    }
  #  ];
  # };
}
