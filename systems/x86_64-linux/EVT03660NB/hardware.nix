{ modulesPath, inputs, ... }:
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    inputs.nixos-wsl.nixosModules.wsl
  ];

  wsl = {
    enable = true;
    defaultUser = "ahmet";
    startMenuLaunchers = true;
    useWindowsDriver = true;

    wslConf = {
      network.hostname = "EVT03660NB";
    };

    # Enable native Docker support
    # docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;
  };

  hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = false; # https://github.com/nix-community/NixOS-WSL/issues/578
    suppressNvidiaDriverAssertion = true;
  };
}
