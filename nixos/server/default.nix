{
  modulesPath,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  users.users."root" = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPO/hKBeNBJVbq8yPL13KRBLCn+gpXyNtAs1UyvyP9Z"
    ];
  };

  services.openssh.enable = true;

  system.stateVersion = "25.05";
}
