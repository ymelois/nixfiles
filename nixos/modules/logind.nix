{
  config,
  lib,
  ...
}:

let
  cfg = config.services.logind;
in
{
  options.services.logind = {
    enable = lib.mkEnableOption "logind";
  };

  config = lib.mkIf cfg.enable {
    services.logind = {
      settings = {
        Login = {
          HandleLidSwitch = "suspend";
          HandleLidSwitchDocked = "suspend";
          HandleLidSwitchExternalPower = "suspend";

          HandlePowerKey = "suspend";
          HandlePowerKeyLongPress = "poweroff";
        };
      };
    };
  };
}
