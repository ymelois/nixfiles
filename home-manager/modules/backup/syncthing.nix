{
  config,
  lib,
  user,
  ...
}:

let
  cfg = config.services.syncthing;
in
{
  options.services.syncthing = {
    folders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "Desktop"
        "Pictures"
        "Videos"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      overrideDevices = false;
      settings = {
        gui.enable = true;
        devices = {
          "server" = {
            id = "TTUFKM7-A5RG55J-R3SN7YO-I2KAPCQ-FZROOD5-736WAXG-ZQXSIYZ-5PXUBAJ";
            introducer = true;
          };
        };
        folders = builtins.listToAttrs (
          builtins.map (folder: {
            name = "${user.homeDirectory}/${folder}";
            value = {
              devices = [ "server" ];
            };
          }) cfg.folders
        );
      };
    };

    xdg.desktopEntries.syncthing-ui = {
      name = "";
      noDisplay = true;
    };
  };
}
