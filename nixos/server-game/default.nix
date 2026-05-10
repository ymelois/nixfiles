{
  modulesPath,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  environment.systemPackages = with pkgs; [
    tmux
    neovim
    gitMinimal
    jdk21_headless
    minecraft-server-manager
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "server-game";

  users.users."root" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPO/hKBeNBJVbq8yPL13KRBLCn+gpXyNtAs1UyvyP9Z"
    ];
  };

  users.users."minecraft" = {
    isSystemUser = true;
    group = "minecraft";
    home = "/srv/minecraft";
    createHome = true;
  };

  users.groups."minecraft" = { };

  services.minecraft = {
    enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedTCPPortRanges = [
      {
        from = 25000;
        to = 30000;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 25000;
        to = 30000;
      }
    ];
  };

  system.stateVersion = "25.05";
}
