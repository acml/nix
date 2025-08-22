{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf;

  cfg = config.khanelinix.programs.graphical.addons.satty;
in
{
  options.khanelinix.programs.graphical.addons.satty = {
    enable = lib.mkEnableOption "satty";
  };

  config = mkIf cfg.enable {
    home.file."Pictures/screenshots/.keep".text = "";

    programs.satty = {
      enable = true;

      settings = {
        general = {
          copy-command = lib.getExe' pkgs.wl-clipboard "wl-copy";
          output-filename = "~/Pictures/screenshots/satty-%Y-%m-%d_%H:%M:%S.png";
          save-after-copy = false;
          default-hide-toolbars = false;
        };

        font = {
          family = lib.mkDefault (osConfig.khanelinix.system.fonts.default or "MonaspaceNeon");
          style = "Bold";
        };
      };
    };
  };
}
