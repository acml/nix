{
  config,
  lib,

  osConfig ? { },
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;
  inherit (lib.khanelinix) enabled disabled;
  cfg = config.khanelinix.user;
in
{
  khanelinix = {
    user = {
      enable = true;
      name = "ahmet";
      email = "ahmet.ozgezer@siemens.com";
      fullName = "Ahmet Cemal Özgezer";
    };

    programs = {
      graphical = {
        editors = {
          vscode = mkForce disabled;
        };
      };

      terminal = {
        emulators = {
          wezterm = mkForce disabled;
        };

        editors = {
          emacs.enable = true;
          neovim = {
            enable = true;
            extraModules = [
              {
                config = {
                  plugins = {
                    # NOTE: Disabling some plugins I won't need on work devices
                    avante.enable = mkForce false;
                    windsurf-nvim.enable = mkForce false;
                    firenvim.enable = mkForce false;
                    fzf-lua.enable = mkForce false;
                    neorg.enable = mkForce false;
                  };
                };
              }
            ];
          };
        };

        tools = {
          git = {
            enable = true;
            wslAgentBridge = false;
          };

          ssh = {
            enable = true;
            authorizedKeys = [ ];
          };
        };
      };
    };

    system = {
      xdg = enabled;
    };

    suites = {
      business = enabled;
      common = enabled;
      development = {
        enable = true;
        dockerEnable = true;
        kubernetesEnable = false;
      };
    };

    theme.catppuccin = enabled;
  };

  home.packages = with pkgs; [
    docker-client
    expect
    khanelinix.git-dt
    libxml2.bin
    xorg.setxkbmap
    (pkgs.buildFHSEnv {
      name = "cppfhs";
      runScript = "bash";
      targetPkgs =
        pkgs: with pkgs; [
          automake
          bash-completion
          bc
          bison
          doas
          gcc12
          gnumake
          cmake
          glibc_multi
          flex
          gettext
          kmod
          less
          libtool
          meson
          ncurses
          openssl
          p7zip
          pkg-config
          squashfsTools
          sudo
          ubootTools
          unzip
          xxd
          xz
          zlib
        ];
    })
  ];

  programs = {
    btop.settings.use_fstab = lib.mkForce false;
    git = {
      extraConfig = {
        dt = {
          defaultentity = "pa";
          verboselevel = 0;
        };
        pa = {
          basedir = "/home/${cfg.name}/Projects";
          projectsconf = "dt-projects.xml";
          baseurl = "ssh://saturn.tfs.siemens.net/tfs/DCP/CONFIG_MGMT/_git";
        };
        safe = {
          directory = [
            "~/.config/khanelinix/"
          ];
        };
      };
      includes = [
        { path = "/home/${cfg.name}/Projects/pa.projects/urlrefs"; }
        { path = "/home/${cfg.name}/Projects/pa.projects/gitconfig"; }
        { path = "/home/${cfg.name}/.gitconfig_extended"; }
      ];
    };
    nh.flake = lib.mkForce "${config.home.homeDirectory}/.config/khanelinix";
    ssh.extraConfig = ''
      Include config.d/*
    '';
  };

  sops.secrets = lib.mkIf (osConfig.khanelinix.security.sops.enable or false) {
    kubernetes = {
      path = "${config.home.homeDirectory}/.kube/config";
    };
  };

  home.stateVersion = "25.05";
}
