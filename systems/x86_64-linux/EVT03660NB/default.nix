{ lib, ... }:
let
  inherit (lib) mkForce;
  inherit (lib.khanelinix) enabled disabled;
in
{
  imports = [ ./hardware.nix ];

  documentation.man.enable = mkForce true;

  khanelinix = {
    archetypes = {
      wsl = enabled;
    };

    nix = enabled;

    services = {
      openssh = disabled;
    };

    security = {
      # FIX: make gpg work on wsl
      gpg = mkForce disabled;
    };

    suites = {
      common = enabled;
      development = {
        enable = true;
        dockerEnable = true;
      };
    };

    theme = {
      gtk = enabled;
      qt = enabled;
    };

    user = {
      name = "ahmet";
      email = "ahmet.ozgezer@siemens.com";
      fullName = "Ahmet Cemal Özgezer";
    };
  };

  environment.sessionVariables = {
    LD_LIBRARY_PATH = [
      # "/usr/lib/wsl/lib"
      "/run/opengl-driver/lib"
    ];
    GALLIUM_DRIVER = "d3d12";
    MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
  };

  nix.settings = {
    netrc-file = "/etc/nix/netrc";
  };

  time.timeZone = lib.mkForce "Europe/Istanbul";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
