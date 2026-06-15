{ ... }:

{
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/suwayomi 0755 1000 1000 -"
    "d /var/lib/wireguard 0700 root root -"
  ];

  virtualisation.oci-containers = {
    backend = "podman";

    containers.wireguard = {
      image = "lscr.io/linuxserver/wireguard:1.0.20250521";
      autoStart = true;
      ports = [
        "4567:4567"
      ];
      volumes = [
        "/var/lib/wireguard:/config"
      ];
      environment = {
        PUID = "0";
        PGID = "0";
        TZ = "Etc/UTC";
      };
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
        "--sysctl=net.ipv6.conf.all.disable_ipv6=0"
      ];
    };

    containers.flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:v3.4.6";
      autoStart = true;
      environment = {
        TZ = "Etc/UTC";
        LOG_LEVEL = "info";
      };
      dependsOn = [ "wireguard" ];
      extraOptions = [
        "--network=container:wireguard"
      ];
    };

    containers.suwayomi = {
      image = "ghcr.io/suwayomi/suwayomi-server:v2.2.2100";
      autoStart = true;
      volumes = [
        "/var/lib/suwayomi:/home/suwayomi/.local/share/Tachidesk"
      ];
      environment = {
        TZ = "Etc/UTC";
        FLARESOLVERR_ENABLED = "true";
        FLARESOLVERR_URL = "http://localhost:8191";
      };
      dependsOn = [ "wireguard" ];
      extraOptions = [
        "--network=container:wireguard"
      ];
    };
  };

  services.caddy = {
    enable = true;
    email = "youn@melois.dev";
    virtualHosts."manga.youn.dev".extraConfig = ''
      reverse_proxy 127.0.0.1:4567
    '';
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
