;;; $DOOMDIR/config.el --- My personal configuration -*- lexical-binding: t; -*-
;;; Commentary:

;;; Code:
;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Ahmet Cemal Özgezer"
      user-mail-address "ozgezer@gmail.com"

      ;; There are two ways to load a theme. Both assume the theme is installed and
      ;; available. You can either set `doom-theme' or manually load a theme with the
      ;; `load-theme' function. This is the default:
      doom-theme (if (display-graphic-p) 'ef-eagle 'ef-dark)
      ;; modus-operandi modus-vivendi doom-one doom-gruvbox doom-tomorrow-night

      ;; This determines the style of line numbers in effect. If set to `nil', line
      ;; numbers are disabled. For relative line numbers, set this to `relative'.
      ;;
      ;; Line numbers are pretty slow all around. The performance boost of
      ;; disabling them outweighs the utility of always keeping them on.
      display-line-numbers-type 'relative

      ;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
      ;; are the three important ones:
      ;;
      ;; + `doom-font'
      ;; + `doom-variable-pitch-font'
      ;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
      ;;   presentations or streaming.
      ;;
      ;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
      ;; font string. You generally only need these two:
      doom-font (font-spec :family "Iosevka Comfy" :size (cond ((featurep :system 'macos) 13.0)
                                                               ((string= (system-name) "EVT03660NB") 11.7)
                                                               (t 12.0)))
      doom-big-font (font-spec :family "Iosevka Comfy" :size (if (featurep :system 'macos) 26.0 20.0))
      doom-variable-pitch-font (font-spec :family "Overpass Nerd Font" :size (cond ((featurep :system 'macos) 13.0)
                                                                                   ((string= (system-name) "EVT03660NB") 10.8)
                                                                                   (t 12.0)))
      doom-serif-font (font-spec :family "BlexMono Nerd Font" :size (if (featurep :system 'macos) 13.0 12.0) :weight 'light)
      
      fancy-splash-image (funcall
                          (lambda (choices) (elt
                                        choices (random (length choices))))
                          (directory-files (concat (expand-file-name
                                                    doom-user-dir) "splash")
                                           t "^\\([^.]\\|\\.[^.]\\|\\.\\..\\)" t))

      auth-source-cache-expiry nil ; default is 7200 (2h)

      delete-by-moving-to-trash t  ; Delete files to trash
      window-combination-resize t  ; take new window space from all other windows (not just current)
      x-stretch-cursor t           ; Stretch cursor to the glyph width
      undo-limit 80000000          ; Raise undo-limit to 80Mb
      auto-save-default t          ; Nobody likes to loose work, I certainly don't
      truncate-string-ellipsis "…" ; Unicode ellispis are nicer than "...", and also save /precious/ space
      window-resize-pixelwise t
      frame-resize-pixelwise t
      xref-history-storage 'xref-window-local-history)

;; (if (equal "Battery status not available"
;;            (battery))
;;     (display-battery-mode 1)                        ; On laptops it's nice to know how much power you have
;;   (setq password-cache-expiry nil))               ; I can trust my desktops ... can't I? (no battery = desktop)

(global-subword-mode 1)                           ; Iterate through CamelCase words

(setq-default custom-file (expand-file-name "custom.el" doom-local-dir))
(when (file-exists-p custom-file)
  (load custom-file))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(custom-set-faces!
  '(aw-leading-char-face
    :foreground "white" :background "red"
    :weight bold :height 2.5 :box (:line-width 10 :color "red")))

;; to hide autosave file from recent files
(after! recentf
  (add-to-list 'recentf-exclude doom-local-dir))

(when (daemonp)
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (with-selected-frame frame
                (if (not (display-graphic-p))
                    (load-theme 'catppuccin t)
                  (load-theme 'ef-eagle t)
                  (set-frame-parameter (selected-frame) 'fullscreen 'maximized))))))

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

;; Directional window-selection routines
(use-package! windmove
  :config
  (windmove-default-keybindings '(shift))
  (windmove-swap-states-default-keybindings '(shift ctrl))
  :custom
  (windmove-wrap-around t))

;; (add-hook 'org-shiftup-final-hook 'windmove-up)
;; (add-hook 'org-shiftleft-final-hook 'windmove-left)
;; (add-hook 'org-shiftdown-final-hook 'windmove-down)
;; (add-hook 'org-shiftright-final-hook 'windmove-right)

;; SPC n to switch to winum-numbered window n
(map!
 (:leader
  :desc "Switch to window 0" :n "0" #'treemacs-select-window
  :desc "Switch to window 1" :n "1" #'winum-select-window-1
  :desc "Switch to window 2" :n "2" #'winum-select-window-2
  :desc "Switch to window 3" :n "3" #'winum-select-window-3
  :desc "Switch to window 4" :n "4" #'winum-select-window-4
  :desc "Switch to window 5" :n "5" #'winum-select-window-5
  :desc "Switch to window 6" :n "6" #'winum-select-window-6
  :desc "Switch to window 7" :n "7" #'winum-select-window-7
  :desc "Switch to window 8" :n "8" #'winum-select-window-8
  :desc "Switch to window 9" :n "9" #'winum-select-window-9))

(map! "M-c" #'capitalize-dwim
      "M-l" #'downcase-dwim
      "M-u" #'upcase-dwim)

(set-popup-rules! '(("^\\*info\\*" :size 82 :side right :select t :quit t)
                    ("^\\*\\(?:Wo\\)?Man " :size 82 :side right :select t :quit t)))

(after! avy
  (setq avy-all-windows 'all-frames
        avy-all-windows-alt nil
        avy-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o ?w ?f ?p ?l ?u ?y)))

(use-package! beginend
  :hook (after-init . beginend-global-mode))

;; WSL specific setting
(when (and (featurep :system 'linux)
           (getenv "WSL_DISTRO_NAME"))
  ;; teach Emacs how to open links with your default browser
  (let ((cmd-exe "/mnt/c/Windows/System32/cmd.exe")
        (cmd-args '("/c" "start")))
    (when (file-exists-p cmd-exe)
      (setq browse-url-generic-program  cmd-exe
            browse-url-generic-args     cmd-args
            browse-url-browser-function 'browse-url-generic
            search-web-default-browser 'browse-url-generic))))

(after! calendar
  (setq calendar-location-name "Istanbul, Turkey"
        calendar-latitude 41.168602
        calendar-longitude 29.047024))

(add-hook! 'c-mode-common-hook
  (google-set-c-style)
  (c-set-offset 'access-label -2)
  (google-make-newline-indent))

(after! ccls
  (setq ccls-initialization-options `(:index (:comments 2)
                                      :completion (:detailedLabel t)
                                      :cache (:directory ,(file-truename "~/.cache/ccls")))))

(after! compile
  (setq compilation-scroll-output t))

(use-package! daemons
  :commands (daemons daemons-disable daemons-enable daemons-reload daemons-restart daemons-start daemons-status daemons-stop)
  :config
  (require 'evil-collection-daemons)
  (evil-collection-define-key '(normal visual) 'daemons-mode-map
    "e" 'daemons-enable-at-point
    "d" 'daemons-disable-at-point
    "u" 'daemons-systemd-toggle-user)
  (evil-collection-define-key '(normal visual) 'daemons-output-mode-map
    "e" 'daemons-enable-at-point
    "d" 'daemons-disable-at-point
    "u" 'daemons-systemd-toggle-user))

(use-package! dired
  :config
  (setq dired-listing-switches (concat dired-listing-switches " --time-style=long-iso")))

(use-package! dired-auto-readme
  :config
  (setq dired-auto-readme-separator "\n"))

(use-package! page-break-lines)
(add-hook! 'dired-auto-readme-mode-hook #'page-break-lines-mode)

(defadvice! acml/dired-auto-readme--enable (fn &rest args)
  :around #'dired-auto-readme--enable
  (let ((visible (dirvish-side--session-visible-p)))
    (unless (eq visible (selected-window))
      (advice-add 'dired-revert :override #'ignore)
      (apply fn args)
      (advice-remove 'dired-revert #'ignore))))

(defadvice! acml/dirvish-subtree-toggle (fn &rest args)
  :around #'dirvish-subtree-toggle (save-excursion (apply fn args)))

(after! dirvish
  (setq dirvish-attributes (append
                            ;; The order of these attributes is insignificant, they are always
                            ;; displayed in the same position.
                            '(vc-state subtree-state nerd-icons collapse)
                            ;; Other attributes are displayed in the order they appear in this list.
                            ;; '(git-msg file-modes file-time file-size)
                            '(file-size))
        dirvish-side-attributes '(vc-state nerd-icons collapse ;; file-size
                                  )
        dirvish-header-line-format '(:left (path) :right (free-space))
        dirvish-hide-details '(dired dirvish dirvish-side)
        dirvish-hide-cursor '(dired dirvish dirvish-side)
        dirvish-path-separators (list (format "  %s " (nerd-icons-codicon "nf-cod-home"))
                                      (format "  %s " (nerd-icons-codicon "nf-cod-root_folder"))
                                      (format " %s " (nerd-icons-faicon "nf-fa-angle_right")))
        dirvish-quick-access-entries '(("h" "~/"                          "Home")
                                       ("d" "~/Downloads/"                "Downloads")
                                       ("m" "/mnt/"                       "Drives")
                                       ("n" "~/.nix-config/"              "Nix")
                                       ("p" "~/Projects/"                 "Projects")
                                       ("t" "~/.local/share/Trash/files/" "TrashCan"))
        dirvish-subtree-prefix "  "
        dirvish-subtree-state-style 'nerd)
  ;; (dirvish-peek-mode)
  (dirvish-side-follow-mode)
  (add-hook! 'dirvish-setup-hook #'dired-auto-readme-mode))

(after! dirvish-side
  (setq dirvish-side-display-alist
        '((side . right) (slot . -1))))

(use-package! dwim-shell-command
  :bind (([remap shell-command] . dwim-shell-command)
         :map dired-mode-map
         ([remap dired-do-async-shell-command] . dwim-shell-command)
         ([remap dired-do-shell-command] . dwim-shell-command)
         ([remap dired-smart-shell-command] . dwim-shell-command))
  :config
  ;; Also make available all the utility functions provided by Xenodium
  (require 'dwim-shell-commands))

(after! eglot
  (set-eglot-client! '(c-mode c-ts-mode c++-mode c++-ts-mode objc-mode) `("ccls" ,(concat "--init={\"cache\": {\"directory\": \"" (file-truename "~/.cache/ccls") "\"}}")))
  (set-eglot-client! '(nix-mode) '("nil" :initializationOptions (:nil (:nix (:flake (:autoArchive t)))))))

;; Easier to match with a bspwm rule:
;;   bspc rule -a 'Emacs:emacs-everywhere' state=floating sticky=on
(setq emacs-everywhere-frame-name-format "emacs-everywhere")

;; The modeline is not useful to me in the popup window. It looks much nicer
;; to hide it.
(add-hook 'emacs-everywhere-init-hooks #'hide-mode-line-mode)

;; Semi-center it over the target window, rather than at the cursor position
;; (which could be anywhere).
(defadvice! my-emacs-everywhere-set-frame-position (&rest _)
  :override #'emacs-everywhere-set-frame-position
  (cl-destructuring-bind (width . height)
      (alist-get 'outer-size (frame-geometry))
    (set-frame-position (selected-frame)
                        (+ emacs-everywhere-window-x
                           (/ emacs-everywhere-window-width 2)
                           (- (/ width 2)))
                        (+ emacs-everywhere-window-y
                           (/ emacs-everywhere-window-height 2)))))

(setq prefix-help-command #'embark-prefix-help-command)
(after! vertico-multiform
  (add-to-list 'vertico-multiform-categories '(embark-keybinding grid)))

(use-package! exercism :commands (exercism)
              :config
              (map! (:leader :desc "Exercism" :n "oe" #'exercism))
              (setq exercism-directory "~/Projects/exercism"))

(after! evil
  (setq
   ;; x-select-enable-clipboard nil   ; yanking to the system clipboard crashes emacs (emacsPgtkNativeComp)
   evil-want-fine-undo t       ; By default while in insert all changes are one big blob. Be more granular
   evil-vsplit-window-right t  ; Switch to the new window after splitting
   evil-split-window-below t))

(use-package! evil-colemak-basics :disabled
              :after evil evil-snipe
              ;; :hook (ediff-keymap-setup-hook . evil-colemak-basics-mode)
              :init
              (setq evil-colemak-basics-rotate-t-f-j nil
                    evil-colemak-basics-char-jump-commands 'evil-snipe)
              :config
              (global-evil-colemak-basics-mode))

;; :ui window-select settings, ignoring +numbers flag for now
(after! ace-window
  (setq aw-keys '(?a ?r ?s ?t ?d ?h ?n ?e ?i ?o ?w ?f ?p ?l ?u ?y)))

;; (defun acml/ediff-before-setup ()
;;   (select-frame (make-frame)))
;; (add-hook 'ediff-before-setup-hook 'acml/ediff-before-setup)

(use-package! ef-themes
  :bind ("<f5>" . ef-themes-toggle)
  :custom
  (ef-themes-to-toggle '(ef-eagle ef-dark))
  (ef-themes-variable-pitch-ui t)
  (ef-themes-mixed-fonts t)
  ;; (ef-themes-headings '((0 1.4) (1 1.3) (2 1.2) (3 1.1)))
  :init
  (load-theme (if (display-graphic-p) 'ef-eagle 'ef-dark) t))

(after! expand-region
  (define-key evil-visual-state-map (kbd "v") 'er/expand-region))

(use-package! highlight-parentheses
  :init
  (setq highlight-parentheses-delay 0.2)
  :config
  (set-face-attribute 'hl-paren-face nil :weight 'ultra-bold)
  :hook
  (prog-mode . highlight-parentheses-mode))

(after! indent-bars
  (setq
   indent-bars-color '(highlight :face-bg t :blend 0.15)
   indent-bars-color-by-depth '(:regexp "outline-\\([0-9]+\\)" :blend 1) ; blend=1: blend with BG only
   indent-bars-highlight-current-depth '(:blend 0.5) ; pump up the BG blend on current
   ;; indent-bars-pattern "."
   indent-bars-starting-column nil
   indent-bars-width-frac 0.1))

(use-package! journalctl-mode :commands (journalctl))

(use-package! ll-debug
  :commands (ll-debug-comment-region-or-line ll-debug-copy-and-comment-region-or-line ll-debug-insert ll-debug-mode
                                             ll-debug-revert ll-debug-toggle-comment-region-or-line
                                             ll-debug-uncomment-region-or-line)
  :config
  (setcdr (assq 'c++-mode ll-debug-statement-alist)
          (cdr (assq 'c-mode ll-debug-statement-alist))))

(after! lsp-go
  (lsp-register-custom-settings
   '(("gopls.staticcheck" t t))))

(after! lsp-mode
  (setq lsp-enable-file-watchers t
        lsp-file-watch-threshold 15000
        lsp-lens-enable nil
        lsp-semantic-tokens-enable t
        lsp-signature-render-documentation t
        lsp-headerline-breadcrumb-enable t))

(after! lsp-ui
  (setq lsp-ui-doc-enable nil ; fixes the LSP lag
        lsp-ui-doc-include-signature t
        lsp-ui-doc-max-height 50
        lsp-ui-doc-max-width 150
        lsp-ui-doc-position 'bottom
        lsp-ui-doc-use-childframe t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-symbol t))

;; https://stackoverflow.com/questions/730751/hiding-m-in-emacs
(defun acml/hide-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

;; https://newbedev.com/how-do-i-display-ansi-color-codes-in-emacs-for-any-mode
(defun acml/ansi-color ()
  "Color the ANSI escape sequences in the active region or whole buffer.
Sequences start with an escape \033 (typically shown as \"^[\")
and end with \"m\", e.g. this is two sequences
  ^[[46;1mTEXT^[[0m
where the first sequence says to display TEXT as bold with
a cyan background and the second sequence turns it off.

This strips the ANSI escape sequences and if the buffer is saved,
the sequences will be lost."
  (interactive)
  (let (beg end
            (ansi-color-context-region nil))
    (if (use-region-p)
        (setq beg (region-beginning) end (region-end))
      (setq beg (point-min) end (point-max))))
  (if buffer-read-only
      ;; read-only buffers may be pointing a read-only file system, so don't mark the buffer as
      ;; modified. If the buffer where to become modified, a warning will be generated when emacs
      ;; tries to autosave.
      (let ((inhibit-read-only t)
            (modified (buffer-modified-p)))
        (ansi-color-apply-on-region beg end t)
        (set-buffer-modified-p modified))
    (ansi-color-apply-on-region (point-min) (point-max) t)))
(add-hook 'find-file-hook #'acml/render-log)
(defun acml/render-log ()
  (when (and (stringp buffer-file-name)
             (string-match "\\.log\\'" buffer-file-name))
    (acml/hide-dos-eol)
    (acml/ansi-color)))

(setq-default left-fringe-width 8
              right-fringe-width 8)

;;; :tools magit
(add-hook! 'magit-mode-hook
  (setq-local
   left-fringe-width 16
   magit-section-visibility-indicator (if (display-graphic-p)
                                          '(magit-fringe-bitmap> . magit-fringe-bitmapv)
                                        (cons (if (char-displayable-p ?) "" "...") t))))

(after! magit
  (magit-add-section-hook 'magit-status-sections-hook
                          'magit-insert-ignored-files
                          'magit-insert-untracked-files
                          nil)

  (setq magit-repolist-columns
        '(("Name" 24 magit-repolist-column-ident nil)
          ("Version" 58 magit-repolist-column-version
           ((:sort magit-repolist-version<)))
          ("Status" 6 magit-repolist-column-flag
           ((:right-align t)))
          ("B<U" 4 magit-repolist-column-unpulled-from-upstream
           ((:right-align t)
            (:sort <)
            (:help-echo "Upstream changes not in branch")))
          ("B>U" 4 magit-repolist-column-unpushed-to-upstream
           ((:right-align t)
            (:pad-right 2)
            (:sort <)
            (:help-echo "Local changes not in upstream")))
          ("Path" 0 magit-repolist-column-path nil))))

(setopt magit-format-file-function #'magit-format-file-nerd-icons)

(setq magit-repository-directories '(("~/.nix-config" . 0)
                                     ("~/.nixpkgs" . 0)
                                     ;; ("~/git_pa" . 4)
                                     ("~/Projects" . 3))
      magit-save-repository-buffers nil
      ;; Don't restore the wconf after quitting magit, it's jarring
      magit-inhibit-save-previous-winconf t
      transient-values '((magit-rebase "--autostash" "--autosquash")
                         (magit-pull "--autostash" "--rebase")))

(use-package! magit-todos
  :after magit
  :config (magit-todos-mode 1))

(map! :leader
      (:prefix ("p" . "project")
       :desc "List project todos" "t" #'magit-todos-list))

(defvar elken/mixed-pitch-modes '(org-mode LaTeX-mode markdown-mode gfm-mode Info-mode)
  "Only use `mixed-pitch-mode' for given modes.")

(defun init-mixed-pitch-h ()
  "Hook `mixed-pitch-mode' into each mode of `elken/mixed-pitch-modes'"
  (when (memq major-mode elken/mixed-pitch-modes)
    (mixed-pitch-mode 1))
  (dolist (hook elken/mixed-pitch-modes)
    (add-hook (intern (concat (symbol-name hook) "-hook")) #'mixed-pitch-mode)))

(add-hook 'doom-init-ui-hook #'init-mixed-pitch-h)

(add-hook! markdown-mode
  (add-hook! before-save :local #'markdown-toc-refresh-toc))

(use-package! modus-themes
  :disabled
  :init
  (setq modus-themes-italic-constructs t
        modus-themes-bold-constructs nil
        modus-themes-mixed-fonts t
        modus-themes-variable-pitch-ui t
        modus-themes-custom-auto-reload t)
  :bind ("<f5>" . modus-themes-toggle))

(use-package! nov
  :mode ("\\.epub\\'" . nov-mode)
  :hook ((nov-mode . visual-line-mode)
         (nov-mode . visual-fill-column-mode))
  :config
  (setq nov-text-width most-positive-fixnum)
  (setq visual-fill-column-center-text t))

(map! (:leader :desc "No comments, it is obvious" :n "to" #'obvious-mode))

(use-package! deft
  :after org
  :custom
  (deft-recursive t)
  (deft-use-filter-string-for-filename t)
  (deft-default-extension "org")
  (deft-directory org-roam-directory))

(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autosubmarkers t
        org-appear-autolinks nil)
  ;; for proper first-time setup, `org-appear--set-elements'
  ;; needs to be run after other hooks have acted.
  (run-at-time nil nil #'org-appear--set-elements))

(use-package! org-block-capf :after org)
(add-hook! 'org-mode-hook #'org-block-capf-add-to-completion-at-point-functions)

(use-package! org-noter
  :after org
  :config
  (setq org-noter-notes-search-path '("~/Documents/org/notes/")))

(setq
 ;; If you use `org' and don't want your org files in the default location below,
 ;; change `org-directory'. It must be set before org loads!
 org-directory (expand-file-name "~/Documents/org/")
 org-startup-with-inline-images t)

(use-package! org
  :config
  (setq
   org-hide-emphasis-markers t
   org-agenda-files (list org-directory  (expand-file-name "~/Documents/worg/"))
   org-ellipsis (if (and (display-graphic-p) (char-displayable-p ?)) " " nil)
   org-startup-folded 'show2levels)
  (add-to-list 'org-modules 'org-habit))

(use-package! ox-latex
  :after org
  :config
  (setq org-latex-pdf-process
        '("tectonic -X compile --outdir=%o -Z shell-escape -Z continue-on-errors %f")))

;; (use-package! pdf-occur :commands (pdf-occur pdf-occur-global-minor-mode))
;; (use-package! pdf-history :commands (pdf-history-minor-mode))
;; (use-package! pdf-links :commands (pdf-links-isearch-link pdf-links-action-perform pdf-links-minor-mode))
;; (use-package! pdf-outline :commands (pdf-outline pdf-outline-minor-mode))
;; (use-package! pdf-annot :commands (pdf-annot-minor-mode))
;; (use-package! pdf-sync :commands (pdf-sync-minor-mode))

(defun lkn-tab-bar--workspaces ()
  "Return a list of the current workspaces."
  (tab-bar-mode t)
  (nreverse
   (let ((show-help-function nil)
         (persps (+workspace-list-names))
         (persp (+workspace-current-name)))
     (when (<= 1 (length persps))
       (seq-reduce
        (lambda (acc elm)
          (let* ((face (if (equal persp elm)
                           'tab-bar-tab
                         'tab-bar-tab-inactive))
                 (pos (1+ (cl-position elm persps)))
                 (edge-x (get-text-property 0 'edge-x (car acc)))
                 (tab-id (format " %d" pos))
                 (tab-name (format " %s " elm)))
            (push
             (concat
              (propertize tab-id
                          'id pos
                          'name elm
                          'edge-x (+ edge-x (string-pixel-width tab-name) (string-pixel-width tab-id))
                          'face
                          `(:inherit ,face
                            :weight bold))
              (propertize tab-name 'face `,face)
              " ")
             acc)
            acc))
        persps
        `(,(propertize (+workspace-current-name) 'edge-x 0 'invisible t)))))))

;; (customize-set-variable 'global-mode-string '((:eval (lkn-tab-bar--workspaces)) " "))
(customize-set-variable 'global-mode-string '((:eval (if (and (fboundp 'persp-names) (< 1 (length (+workspace-list-names)))) (lkn-tab-bar--workspaces) (tab-bar-mode -1))) " "))
(add-hook! 'dirvish-setup-hook #'(lambda () (if (< 1 (length (+workspace-list-names))) (tab-bar-mode +1) (tab-bar-mode -1))))
(customize-set-variable 'tab-bar-format '(tab-bar-format-global))
(customize-set-variable 'tab-bar-mode t)

;; These two things combined prevents the tab list to be printed either as a
;; tooltip or in the echo area
(defun tooltip-help-tips (_event)
  "Hook function to display a help tooltip.
This is installed on the hook `tooltip-functions', which
is run when the timer with id `tooltip-timeout-id' fires.
Value is non-nil if this function handled the tip."
  (let ((xf (lambda (str) (string-trim (substring-no-properties str)))))
    (when (and
           (stringp tooltip-help-message)
           (not (string= (funcall xf tooltip-help-message) (funcall xf (format-mode-line (lkn-tab-bar--workspaces))))))
      (tooltip-show tooltip-help-message (not tooltip-mode))
      t)))

(tooltip-mode)

(defun lkn-tab-bar--event-to-item (event)
  "Given a click EVENT, translate to a tab.

We handle this by using `string-pixel-width' to calculate how
long the tab would be in pixels and use that in the reduction in
`lkn-tab-bar--workspaces' to determine which tab has been
clicked."
  (let* ((posn (event-start event))
         (workspaces (lkn-tab-bar--workspaces))
         (x (car (posn-x-y posn))))
    (car (cl-remove-if (lambda (workspace)
                         (>= x (get-text-property 0 'edge-x workspace)))
                       workspaces))))

(defun lkn-tab-bar-mouse-1 (ws)
  "Switch to tabs by left clicking."
  (when-let ((name (get-text-property 0 'name ws)))
    (+workspace-switch name)))

(defun lkn-tab-bar-mouse-2 (ws)
  "Close tabs by clicking the mouse wheel."
  (when-let ((name (get-text-property 0 'name ws)))
    (+workspace/kill name)))

(defun lkn-tab-bar-click-handler (evt)
  "Function to handle clicks on the custom tab."
  (interactive "e")
  (when-let ((ws (lkn-tab-bar--event-to-item evt)))
    (pcase (car evt)
      ('mouse-1 (lkn-tab-bar-mouse-1 ws))
      ('mouse-2 (lkn-tab-bar-mouse-2 ws)))))

(keymap-set tab-bar-map "<mouse-1>" #'lkn-tab-bar-click-handler)
(keymap-set tab-bar-map "<mouse-2>" #'lkn-tab-bar-click-handler)
(keymap-set tab-bar-map "<wheel-up>" #'+workspace:switch-previous)
(keymap-set tab-bar-map "<wheel-down>" #'+workspace:switch-next)

(setq +workspaces-switch-project-function #'dired)

(map! :when (modulep! :ui workspaces)
      :map doom-leader-workspace-map
      :desc "Swap Left"  "<" #'+workspace/swap-left
      :desc "Swap Right" ">" #'+workspace/swap-right)

;; ("%b – Doom Emacs")
;; (setq frame-title-format
;;     '((:eval
;;        (let ((project-name (projectile-project-name)))
;;          (unless (string= "-" project-name)
;;            (format "[%s]: " project-name))))
;;       "%b"))

;; https://github.com/blaenk/dots/blob/main/dot_emacs.d/inits/conf/mode-line.el
;; Construct the buffer identifier for a buffer backed by a file. This is done
;; by combining: dirname/ + filename, each propertized separately.
(defun my--mode-line-file-identifier (path &optional max-width)
  (let* ((path (if (file-remote-p buffer-file-name)
                   (tramp-file-name-localname (tramp-dissect-file-name buffer-file-name))
                 path))
         ;; FIXME
         ;; This calls f-short on tramp
         (dirname (file-name-as-directory (abbreviate-file-name (or (file-name-directory path) "./"))))
         (filename (f-filename path))
         (propertized-filename
          (propertize filename 'face 'mode-line-buffer-id)))
    (if (> (+ (length dirname) (length filename) 2) max-width)
        propertized-filename
      (concat
       (unless (string= dirname "./")
         (propertize dirname 'face 'mode-line-stem-face))
       propertized-filename))))

;; Construct the buffer identifier for a regular, simple buffer that is not
;; backed by a file nor remote.
(defun my--mode-line-buffer-identifier (&optional max-width)
  (if buffer-file-name
      (my--mode-line-file-identifier buffer-file-name max-width)
    (propertize "%b" 'face 'mode-line-buffer-id)))

(defun my--frame-title-format ()
  (cond
   ((and buffer-file-name (file-remote-p buffer-file-name))
    (let ((tramp-vec (tramp-dissect-file-name buffer-file-name)))
      (concat
       (tramp-file-name-host tramp-vec)
       " — "
       (abbreviate-file-name (tramp-file-name-localname tramp-vec)))))

   ((and (featurep 'projectile) (projectile-project-p))
    (concat
     (projectile-project-name)
     " — "
     (if buffer-file-name
         (f-relative buffer-file-name (projectile-project-root))
       (buffer-name))))

   (t (my--mode-line-buffer-identifier))))

(setq frame-title-format '((:eval (my--frame-title-format))))

(use-package! proced :commands (proced)
              :init
              (setq proced-auto-update-flag t
                    proced-auto-update-interval 1
                    proced-descend t))

(after! projectile
  (setq ;; projectile-switch-project-action 'projectile-dired
   projectile-project-root-functions '(projectile-root-local
                                       projectile-root-marked
                                       projectile-root-top-down
                                       projectile-root-bottom-up
                                       projectile-root-top-down-recurring)
   projectile-enable-caching t
   projectile-enable-cmake-presets t
   projectile-project-search-path '(("~/git_pa" . 2) ("~/Projects" . 3)))
  (projectile-register-project-type 'acml/exercism-lua '(".exercism" ".busted" "HELP.md" "README.md")
                                    :project-file '("?*.lua")
                                    :test "busted -v"
                                    :test-suffix "_spec"))

(use-package! rainbow-mode
  :hook
  ((prog-mode . rainbow-mode)
   (org-mode . rainbow-mode)))

(use-package! scopeline
  :commands (scopeline-mode)
  ;; :config
  ;; (add-to-list 'scopeline-targets '(makefile-mode "conditional"))
  :init
  (add-hook! 'prog-mode-hook #'scopeline-mode))

(setq +treemacs-git-mode 'deferred
      ;; treemacs-collapse-dirs 5
      ;; treemacs-eldoc-display t
      ;; treemacs-is-never-other-window nil
      treemacs-position 'right
      treemacs-recenter-after-file-follow 'on-distance
      treemacs-recenter-after-project-expand 'on-distance
      ;; treemacs-show-hidden-files t
      ;; treemacs-silent-filewatch t
      ;; treemacs-silent-refresh t
      ;; treemacs-sorting 'alphabetic-asc
      ;; treemacs-user-mode-line-format nil
      treemacs-width 40
      treemacs-follow-after-init t)

(after! treemacs
  (treemacs-define-RET-action 'file-node-open   #'treemacs-visit-node-in-most-recently-used-window)
  (treemacs-define-RET-action 'file-node-closed #'treemacs-visit-node-in-most-recently-used-window)
  ;; Quite often there are superfluous files I'm not that interested in. There's no
  ;; good reason for them to take up space. Let's add a mechanism to ignore them.
  (defvar treemacs-file-ignore-extensions '()
    "File extension which `treemacs-ignore-filter' will ensure are ignored")
  (defvar treemacs-file-ignore-globs '()
    "Globs which will are transformed to
`treemacs-file-ignore-regexps' which `treemacs-ignore-filter'
will ensure are ignored")
  (defvar treemacs-file-ignore-regexps '()
    "RegExps to be tested to ignore files, generated from
`treeemacs-file-ignore-globs'")
  (defun treemacs-file-ignore-generate-regexps ()
    "Generate `treemacs-file-ignore-regexps' from `treemacs-file-ignore-globs'"
    (setq treemacs-file-ignore-regexps (mapcar 'dired-glob-regexp treemacs-file-ignore-globs)))
  (if (equal treemacs-file-ignore-globs '()) nil (treemacs-file-ignore-generate-regexps))
  (defun treemacs-ignore-filter (file full-path)
    "Ignore files specified by `treemacs-file-ignore-extensions', and
`treemacs-file-ignore-regexps'"
    (or (member (file-name-extension file) treemacs-file-ignore-extensions)
        (let ((ignore-file nil))
          (dolist (regexp treemacs-file-ignore-regexps ignore-file)
            (setq ignore-file (or ignore-file (if (string-match-p regexp full-path) t nil)))))))
  (add-to-list 'treemacs-ignored-file-predicates #'treemacs-ignore-filter)

  ;; Now, we just identify the files in question.
  (setq treemacs-file-ignore-extensions
        '(;; build outputs
          "o"
          "psd"
          ;; LaTeX
          "aux"
          "ptc"
          "fdb_latexmk"
          "fls"
          "synctex.gz"
          "toc"
          ;; LaTeX - glossary
          "glg"
          "glo"
          "gls"
          "glsdefs"
          "ist"
          "acn"
          "acr"
          "alg"
          ;; LaTeX - pgfplots
          "mw"
          ;; LaTeX - pdfx
          "pdfa.xmpi"
          ))
  (setq treemacs-file-ignore-globs
        '(;; LaTeX
          "*/_minted-*"
          ;; AucTeX
          "*/.auctex-auto"
          "*/_region_.log"
          "*/_region_.tex"))

  (treemacs-follow-mode)
  (treemacs-filewatch-mode))

(use-package! turkish :commands (turkish-mode))

(when (modulep! :completion vertico)
  (after! consult
    (consult-customize
     +default/search-project +default/search-other-project
     +default/search-project-for-symbol-at-point
     +default/search-cwd +default/search-other-cwd
     +default/search-notes-for-symbol-at-point
     +default/search-emacsd
     consult-bookmark
     :preview-key (list "C-SPC" :debounce 0.2 'any))))

(after! vterm
  (setq vterm-max-scrollback 100000))

;; Map [kp-delete] to send <C-d>. Otherwise, the delete key does not work in
;; terminal.
(map! :after vterm
      :map vterm-mode-map
      "<deletechar>" #'vterm-send-delete)

(add-hook! 'vterm-mode-hook
  (set (make-local-variable 'buffer-face-mode-face) '(:family "IosevkaTerm Nerd Font"))
  (buffer-face-mode t))

(setq which-key-allow-multiple-replacements t)
(after! which-key
  (pushnew!
   which-key-replacement-alist
   '(("" . "\\`+?evil[-:/]?\\(?:a-\\)?\\(.*\\)") . (nil . " \\1"))
   '(("\\`g s" . "\\`evilem--?motion-\\(.*\\)") . (nil . " \\1"))))

;; text mode directory tree
(after! ztree
  (setq ztree-draw-unicode-lines t
        ztree-show-number-of-children t))

;;
;;; Scratch frame

(defvar +hlissner--scratch-frame nil)

(defun cleanup-scratch-frame (frame)
  (when (eq frame +hlissner--scratch-frame)
    (with-selected-frame frame
      (setq doom-fallback-buffer-name (frame-parameter frame 'old-fallback-buffer))
      (remove-hook 'delete-frame-functions #'cleanup-scratch-frame))))

;;;###autoload
(defun open-scratch-frame (&optional fn)
  "Opens the org-capture window in a floating frame that cleans itself up once
you're done. This can be called from an external shell script."
  (interactive)
  (let* ((frame-title-format "")
         (preframe (cl-loop for frame in (frame-list)
                            if (equal (frame-parameter frame 'name) "scratch")
                            return frame))
         (frame (unless preframe
                  (make-frame `((name . "scratch")
                                (width . 120)
                                (height . 24)
                                (transient . t)
                                (internal-border-width . 10)
                                (left-fringe . 0)
                                (right-fringe . 0)
                                (undecorated . t)
                                ,(if (featurep :system 'linux) '(display . ":0")))))))
    (setq +hlissner--scratch-frame (or frame posframe))
    (select-frame-set-input-focus +hlissner--scratch-frame)
    (when frame
      (with-selected-frame frame
        (if fn
            (call-interactively fn)
          (with-current-buffer (switch-to-buffer "*scratch*")
            ;; (text-scale-set 2)
            (when (eq major-mode 'fundamental-mode)
              (emacs-lisp-mode)))
          (redisplay)
          (set-frame-parameter frame 'old-fallback-buffer doom-fallback-buffer-name)
          (setq doom-fallback-buffer-name "*scratch*")
          (add-hook 'delete-frame-functions #'cleanup-scratch-frame))))))

(use-package! reader
  :commands (reader-mode)
  :config
  (require 'reader-autoloads))

(when (and (featurep :system 'linux)
           (display-graphic-p)
           (getenv "WSL_DISTRO_NAME"))
  (defun acml-set-keyboard ()
    (interactive)
    (start-process "" nil "setxkbmap" "us" "-variant" "colemak"))

  (map! "<f6>" #'acml-set-keyboard)
  (add-hook! 'emacs-startup-hook #'acml-set-keyboard))

(map! :map reader-mode-map
      :nvm "j" 'reader-scroll-down-or-next-page
      :nvm "k" 'reader-scroll-up-or-prev-page
      :nvm "h" 'reader-scroll-left
      :nvm "l" 'reader-scroll-right
      :nvm "d" 'reader-next-page
      :nvm "u" 'reader-previous-page
      :nvm "g" 'reader-goto-page
      :nvm "H" 'reader-fit-to-height
      :nvm "W" 'reader-fit-to-width
      :nvm "q" 'quit-window)

;; Load a file with the same name as the computer’s name. Just keep on going if
;; the requisite file isn't there.
(load (concat doom-user-dir (car (split-string (system-name) "\\."))) t)

;; Load a file with the name of the OS type ("gnu/linux" → "linux")
(load (concat doom-user-dir (car (reverse (split-string (symbol-name system-type) "/")))) t)
