{
  config,
  lib,

  pkgs,
  ...
}:
let

  cfg = config.khanelinix.programs.terminal.editors.emacs;

  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  inherit (config.home) homeDirectory;
  inherit (config.programs.emacs) finalPackage;

  DOOMDIR = "${config.xdg.configHome}/doom";
  DOOMLOCALDIR = "${config.xdg.dataHome}/doom";
  EMACSDIR = "${config.xdg.configHome}/emacs";
  ALTERNATE_EDITOR = "emacs";

  withPlugins =
    with pkgs;
    grammarFn:
    let
      grammars = grammarFn tree-sitter.builtGrammars;
    in
    linkFarm "grammars" (
      map (
        drv:
        let
          name = lib.strings.getName drv;
        in
        {
          name = "lib" + (lib.strings.removeSuffix "-grammar" name) + ".so";
          path = "${drv}/parser";
        }
      ) grammars
    );

  grammarsLibPath = withPlugins (_: pkgs.tree-sitter.allGrammars);

  myEmacs = lib.mkMerge [
    (lib.mkIf isLinux pkgs.emacs30)
    (lib.mkIf isDarwin (
      pkgs.emacs30-pgtk.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          # Fix OS window role (needed for window managers like yabai)
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
            sha256 = "sha256-+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
          })
          # Enable rounded window with no decoration
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/round-undecorated-frame.patch";
            sha256 = "sha256-uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
          })
          # Make Emacs aware of OS-level light/dark mode
          (pkgs.fetchpatch {
            url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-30/system-appearance.patch";
            sha256 = "sha256-3QLq91AQ6E921/W9nfDjdOUWR8YVsqBAT/W9c1woqAw=";
          })
        ];
      })
    ))
  ];

in
{
  options.khanelinix.programs.terminal.editors.emacs = {
    enable = lib.mkEnableOption "emacs";
  };

  config = lib.mkIf cfg.enable {

    fonts.fontconfig.enable = true;

    home = {
      activation = {
        installDoom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d "${EMACSDIR}" ]; then
            $DRY_RUN_CMD ${pkgs.git}/bin/git clone https://github.com/doomemacs/doomemacs.git ${EMACSDIR} $VERBOSE_ARG
          fi
        '';
        runDoomSync = lib.mkIf pkgs.stdenv.isLinux (
          lib.hm.dag.entryAfter [ "installDoom" ] ''
            run ${config.systemd.user.systemctlPath} start --user doom-sync.service --no-block || true
          ''
        );
      };

      packages =
        with pkgs;
        [
          # fonts
          emacs-all-the-icons-fonts
          hack-font
          iosevka-comfy.comfy
          (lib.mkIf isLinux quivira)
          symbola
          unifont
          nerd-fonts.blex-mono
          nerd-fonts.iosevka
          nerd-fonts.iosevka-term
          nerd-fonts.symbols-only
          nerd-fonts.overpass

          (lib.mkIf isDarwin coreutils-prefixed)
          (lib.mkIf isDarwin pngpaste)

          exercism

          ## Doom dependencies
          (ripgrep.override { withPCRE2 = true; })
          # ripgrep-all

          ## Optional dependencies
          dtach
          exiftool # for image-dired
          fd # faster projectile indexing
          graphicsmagick # for image-dired
          libjpeg # for image-dired
          unzip
          zstd # for undo-fu-session/undo-tree compression

          ## Module dependencies

          # :checkers spell
          (aspellWithDicts (
            dicts: with dicts; [
              en
              en-computers
              en-science
              tr
            ]
          ))

          # :checkers grammar
          languagetool

          # :tools editorconfig
          editorconfig-core-c # per-project style config

          # :tools lookup & :lang org +roam
          sqlite
          wordnet
          (lib.mkIf isLinux maim) # org-download-clipboard
          gnuplot # org-plot/gnuplot
          graphviz # org-roam-graph
          # :lang latex & :lang org (latex previews)
          tectonic

          # :lang cc
          # ccls
          clang-tools
          glslang

          # CMake LSP
          cmake
          cmake-language-server

          # Nix
          nixfmt-classic
          nil

          # Markdown exporting
          mdl
          pandoc

          # Python LSP setup
          # nodePackages.pyright
          # pipenv
          # (python3.withPackages (ps: with ps; [
          #   black isort pyflakes pytest
          # ]))

          # JavaScript
          # nodePackages.typescript-language-server

          # HTML/CSS/JSON language servers
          # nodePackages.prettier
          vscode-langservers-extracted

          # Yaml
          yaml-language-server

          # Bash
          bash-language-server
          shellcheck
          shfmt

          # :lang lua
          # (lib.mkIf isLinux sumneko-lua-language-server)
          lua-language-server

          # Rust
          # cargo
          # cargo-audit
          # cargo-edit
          # clippy
          # rust-analyzer
          # rustfmt
          # rustc.out

          # :lang go
          # go_1_18
          # delve # vscode
          # go-outline # vscode
          # go-tools # vscode (staticcheck)
          # golint # vscode
          # gomodifytags # vscode
          # gopkgs # vscode
          # gopls # vscode
          # gotests # vscode
          # impl # vscode
          # gocode
          # golangci-lint
          # gore
          # gotools

          # dirvish previewers
          epub-thumbnailer
          ffmpegthumbnailer
          mediainfo
          p7zip
          poppler-utils
          vips

          trash-cli
        ]
        ++ lib.optionals stdenv.hostPlatform.isLinux [
          man-pages
          man-pages-posix

          # :app everywhere
          # wl-clipboard
          xclip
          xdotool
          xsel

          zip
        ];

      sessionPath = [ "${homeDirectory}/.config/emacs/bin" ];
      sessionVariables = {
        inherit
          DOOMDIR
          DOOMLOCALDIR
          ALTERNATE_EDITOR
          ;
      };
    };

    systemd.user.sessionVariables = lib.mkIf isLinux {
      inherit
        DOOMDIR
        DOOMLOCALDIR
        # EDITOR
        ALTERNATE_EDITOR
        ;
    };

    systemd.user.services.doom-sync = {
      Unit = {
        After = [
          "network-online.target"
          "graphical-session.target"
        ];
        PartOf = [ "graphical-session.target" ];
        Description = "Sync doomemacs config";
      };
      Service = with pkgs; {
        Nice = "15";
        Environment = [
          "PATH=${
            lib.makeBinPath [
              bash
              finalPackage
              gcc
              git
            ]
          }"
          "EMACSDIR=${EMACSDIR}"
        ];
        ExecStart = "${EMACSDIR}/bin/doom sync -u --no-color --rebuild --aot --gc";
        # ExecStartPre = "${lib.getExe libnotify} 'Starting sync' 'Doom Emacs config is syncing...'";
        # ExecStartPost = "${lib.getExe libnotify} 'Finished sync' 'Doom Emacs is ready!'";
        Type = "oneshot";
      };
    };

    xdg = {
      configFile."doom" = {
        source = ./doom.d;
      };
      dataFile = {
        "doom/etc/lsp/lua-language-server/main.lua".source =
          "${pkgs.lua-language-server}/share/lua-language-server/bin/main.lua";
        "doom/etc/lsp/lua-language-server/bin/lua-language-server".source =
          "${pkgs.lua-language-server}/bin/lua-language-server";
      };
    };

    programs = {
      emacs = {
        enable = true;
        package = myEmacs;
        extraConfig = ''
          (setq treesit-extra-load-path '("${grammarsLibPath}"))
        '';
        extraPackages =
          epkgs:
          (with epkgs; [
            djvu
            emacsql
            (melpaBuild {
              ename = "reader";
              pname = "emacs-reader";
              version = "20250812";
              src = pkgs.fetchFromGitea {
                domain = "codeberg.org";
                owner = "divyaranjan";
                repo = "emacs-reader";
                rev = "a3ce05efee"; # replace with 'version' for stable
                hash = "sha256-lqiT+4P8eQXCLGNQwI3WFwtucMwijxttq5fQlQyzzpI=";
              };
              files = ''(:defaults "render-core.so")'';
              nativeBuildInputs = with pkgs; [ pkg-config ];
              buildInputs = [
                pkgs.gcc
                pkgs.mupdf-headless
                pkgs.gnumake
                pkgs.pkg-config
              ];
              preBuild = "make clean all";
            })
            pdf-tools
            tree-sitter-langs
            treesit-grammars.with-all-grammars
            vterm
          ]);
      };

      jq.enable = true; # cli to extract data out of json input
      man.enable = true;
      man.generateCaches = true;
    };

    # user systemd service for Linux
    services.emacs = {
      enable = false;
      client = {
        enable = true;
        arguments = [
          "--no-wait"
          "--create-frame"
          # "--alternate-editor=\"\""
        ];
      };
      package = myEmacs;
      socketActivation.enable = true;
    };
  };
}
