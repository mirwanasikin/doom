;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!
(defadvice! +lsp-skip-remote-a (fn &rest args)
  "Don't start LSP for TRAMP (remote) buffers."
  :around #'lsp-deferred
  (unless (file-remote-p default-directory)
    (apply fn args)))

;; (setq display-line-numbers-type 'relative)

(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-doc-face     :slant italic)
  '(font-lock-keyword-face :slant italic))
;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq catppuccin-flavor 'mocha) ; latte, frapper, macchiato, mocha
(setq doom-theme 'catppuccin)
;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.
(setq evil-insert-state-cursor '(bar . 2))
(setq evil-emacs-state-cursor  '(bar . 2))
;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type `relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

(setq doom-font (font-spec :family "CaskaydiaMono Nerd Font Mono" :size 16))
(add-to-list 'default-frame-alist '(alpha-background . 90))
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
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
(defface my-module-face
  '((t :inherit font-lock-type-face :slant italic))
  "Face for module names in import statements.")

(defun +my/python-module-italic ()
  (setq-local treesit-font-lock-settings
              (append treesit-font-lock-settings
                      (treesit-font-lock-rules
                       :language 'python
                       :feature 'my-module
                       :override t
                       '((import_statement
                          name: (dotted_name (identifier) @my-module-face))
                         (import_from_statement
                          module_name: (dotted_name (identifier) @my-module-face))))))
  (setq-local treesit-font-lock-feature-list
              (cons (append (car treesit-font-lock-feature-list) '(my-module))
                    (cdr treesit-font-lock-feature-list)))
  (treesit-font-lock-recompute-features))

(add-hook 'python-ts-mode-hook #'+my/python-module-italic)

(add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))

;; ---------------------------------------------------------------------------
;; LSP — disamakan dengan lazyvim.nix
;;   nix -> nil | python -> pyright + ruff | rust -> rust-analyzer
;;   yaml -> yaml-language-server | docker -> docker-langserver
;;   c/c++ -> clangd | terraform -> tofu-ls | markdown -> (tanpa LSP)
;; Binary-nya datang dari Nix (lihat doom-lsp.nix), bukan dari lsp-mode.
;; ---------------------------------------------------------------------------

;; NixOS: jangan tawarkan download/npm install server otomatis.
(setq lsp-enable-suggest-server-download nil)

;; Inlay hints (nama parameter "format:", "n:", dst.) seperti di neovim.
(setq lsp-inlay-hint-enable t)

;; Dockerfile: modul :tools docker belum tentu memasang hook lsp.
(add-hook 'dockerfile-mode-local-vars-hook #'lsp! 'append)
;; LazyVim: dockerfile = {} di conform (tanpa auto-format).
(setq-hook! 'dockerfile-mode-hook +format-with-lsp nil)

(after! lsp-mode
  ;; Nix: nil + nixfmt (sama seperti conform: nix = { "nixfmt" })
  (setq lsp-nix-nil-formatter ["nixfmt"])

  ;; Terraform/OpenTofu: pakai tofu-ls (fork terraform-ls untuk OpenTofu),
  ;; matikan client bawaan lsp-mode yang mencari terraform-ls.
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("tofu-ls" "serve"))
    :activation-fn (lsp-activate-on "terraform")
    :server-id 'tofu-ls))

  ;; Python: ruff (native `ruff server`) berjalan berdampingan dengan pyright.
  ;; :add-on? t => tidak menggantikan pyright.
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection '("ruff" "server"))
    :activation-fn (lsp-activate-on "python")
    :add-on? t
    :server-id 'ruff-native))

  (dolist (client '(tfls tfmls ruff ruff-lsp))
    (add-to-list 'lsp-disabled-clients client)))

;; (defvar +my/dashboard-width 150)

(defun +my/dashboard-banner ()
  (let* ((banner '( ""
                    ""
                    ""
                    ""
                    ""
                    ""
                    " █████╗ ███████╗██╗██╗  ██╗██╗███╗   ██╗███╗   ██╗"
                    "██╔══██╗██╔════╝██║██║ ██╔╝██║████╗  ██║████╗  ██║"
                    "███████║███████╗██║█████╔╝ ██║██╔██╗ ██║██╔██╗ ██║"
                    "██╔══██║╚════██║██║██╔═██╗ ██║██║╚██╗██║██║╚██╗██║"
                    "██║  ██║███████║██║██║  ██╗██║██║ ╚████║██║ ╚████║"
                    "╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝"
                    "                         Emacs                    "
                    ))
         (width (apply #'max (mapcar #'length banner)))
         (pad (make-string (max 0 (/ (- (window-width) width) 2)) ?\s))
         (face (cl-find-if #'facep '(doom-dashboard-banner dashboard-banner
                                     font-lock-comment-face))))
    (insert "\n")
    (dolist (line banner)
      (insert (propertize (concat pad line "\n") 'face face)))))

;; Ganti widget banner bawaan, apa pun nama variabel/fungsinya di versimu.
(let ((var (cl-find-if #'boundp '(+dashboard-functions +doom-dashboard-functions))))
  (when var
    (set var (mapcar (lambda (f)
                       (if (and (symbolp f)
                                (string-match-p "widget-banner" (symbol-name f)))
                           #'+my/dashboard-banner
                         f))
                     (symbol-value var)))))
(setq-default fill-column 88)
(add-hook 'text-mode-hook #'auto-fill-mode)
(add-hook 'prog-mode-hook #'auto-fill-mode) ; hanya berlaku untuk komentar

;; Format Python pakai ruff (seperti conform di LazyVim), bukan lewat LSP
(setq-hook! 'python-ts-mode-hook +format-with-lsp nil)

(after! apheleia
  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff)))

;; Setelah format-on-save, tengahkan lagi tampilan di sekitar kursor
(add-hook! 'apheleia-post-format-hook
  (defun +my/recenter-after-format ()
    (when (eq (current-buffer) (window-buffer (selected-window)))
      (recenter))))

(after! dired
  (evil-define-key 'normal dired-mode-map
    "v" #'dired-view-file))

(map!  :after dired
       :map dired-mode-map
       :localleader
       "n" #'dired-create-empty-file)

;; (map! :after dired
;; :map dired-modee-map
;; :n "a" #'dired-create-empty-file
;; :n "A" #'dired-create-directory)

(setq +dashboard-menu-sections
      (cl-remove "Recently opened files"
                 +dashboard-menu-sections
                 :key #'car :test #'equal))

(after! corfu
  (setq corfu-auto-delay 0.0
        corfu-auto-prefix 1))

(after! lsp-pyright
  (lsp-register-custom-settings
   '(("python.analysis.completeFunctionParens" t t))))

(after! pdf-tools
  (setq-default pdf-view-display-size 'fit-page))

(after! emms
  (require 'emms-player-mpv)

  (setq emms-player-list '(emms-player-mpv)
        emms-info-functions '(emms-info-native)
        emms-player-mpv-parameters
        '("--quiet"
          "--no-video"
          "--no-audio-display"
          "--force-window=no")))

(use-package! yeetube
  :commands (yeetube yeetube-search)
  :init
  (setq yeetube-play-function #'yeetube-mpv-play
        yeetube-display-thumbnails-p nil
        yeetube-mpv-no-video t)

  :config
  (evil-define-key 'normal yeetube-mode-map
    (kbd "RET") #'yeetube-play))

(map! :leader
      :prefix ("o y" . "YouTube / Music")
      :desc "Search YouTube" "s" #'yeetube-search
      :desc "Pause / Resume" "p" #'emms-pause
      :desc "Next track"     "n" #'emms-next
      :desc "Previous track" "b" #'emms-previous
      :desc "Stop playback"  "q" #'emms-stop)

(setq! org-hide-emphasis-markers t)

(setq org-directory "~/org")
(setq org-agenda-files (directory-files-recursively "~/org" "\\.org$"))

(after! dired
  (setq dired-guess-shell-alist-user
        '(("\\.\\(mp4\\|mkv\\|mov\\|avi\\|webm\\)\\'"
           "mpv"))))

(use-package! org-wild-notifier
  :after org
  :config
  (setq org-wild-notifier-alert-time '(30 5))
  (setq alert-default-style 'libnotify)
  (org-wild-notifier-mode 1))
