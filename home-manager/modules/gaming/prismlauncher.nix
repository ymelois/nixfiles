{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.prismlauncher;
in
{
  options.programs.prismlauncher = {
    enable = lib.mkEnableOption "prismlauncher";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      let
        prism = pkgs.prismlauncher.override {
          additionalPrograms = with pkgs; [
            ffmpeg
            vlc
            alsa-oss
          ];

          jdks = with pkgs; [
            graalvm25-ce
            graalvm21-ce
            jdk17
            jdk8
          ];
        };
      in
      [
        # Inject GTK gsettings schemas so the file picker does not crash with
        # "Settings schema 'org.gtk.Settings.FileChooser' is not installed".
        # See https://github.com/PrismLauncher/PrismLauncher/issues/4595.
        (pkgs.symlinkJoin {
          name = "prismlauncher-with-schemas-${prism.version}";
          paths = [ prism ];
          nativeBuildInputs = [ pkgs.makeWrapper ];
          postBuild = ''
            wrapProgram $out/bin/prismlauncher \
              --prefix XDG_DATA_DIRS : "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
          '';
          inherit (prism) meta;
        })
      ];
  };
}
