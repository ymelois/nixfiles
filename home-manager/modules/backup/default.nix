{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.backup;

  moduleNames = builtins.attrNames (builtins.readDir ./.);
  modules = builtins.map (name: ./. + ("/" + name)) moduleNames;
  filterOut = module: modules: builtins.filter (module': module' != module) modules;
in
{
  imports = filterOut ./default.nix modules;

  options.modules.backup = {
    enable = lib.mkEnableOption "backup";
    folders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "Backups"
        "Desktop"
        "Pictures"
        "Videos"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      syncthing = {
        enable = true;
        folders = cfg.folders;
      };
    };
  };
}
