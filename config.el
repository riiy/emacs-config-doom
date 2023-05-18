;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Riiy Zhou"
      user-mail-address "riiyzhou@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
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

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type `relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/org-roam/"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

(setq find-file-visit-truename t)
;; for org-roam-buffer-toggle
;; Use side-window like V1
;; This can take advantage of slots available with it
(add-to-list 'display-buffer-alist
    '("\\*org-roam\\*"
        (display-buffer-in-side-window)
        (side . right)
        (slot . 0)
        (window-width . 0.25)
        (preserve-size . (t . nil))
        (window-parameters . ((no-other-window . t)
                              (no-delete-other-windows . t)))))
(use-package! org-roam-protocol
  :after org-protocol)

(setq org-roam-capture-templates
      '(
        ("d" "default" plain "%?"
         :target (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}\n#+roam_alias:\n#+roam_key:\n#+roam_tags:\n\n")
         :unnarrowed t)
        )
      )

(setq org-roam-capture-ref-templates
      '(
        ("a" "Annotation" plain
         "%U ${body}\n"
         :target (file+head "${slug}.org"
                            "#+title: ${title}\n#+roam_key: ${ref}\n#+roam_alias:\n#+roam_tags:\n\n")
         :immediate-finish t
         :unnarrowed t
         )
        ("r" "ref" plain ""
         :target (file+head "${slug}.org"
                            "#+title: ${title}\n#+roam_key: ${ref}\n#+roam_alias:\n#+roam_tags:\n\n")
         :immediate-finish t
         :unnarrowed t)
        )
      )

(set-eglot-client! 'cc-mode '("clangd" "-j=3" "--clang-tidy"))
;; input
(setq default-input-method "pyim")
(setq pyim-default-scheme 'wubi)
(pyim-wbdict-v86-enable)

;; eglot
(use-package eglot
  :defer t
  :commands (eglot-ensure my/rust-expand-macro)
  :config
  (progn
    (setq eldoc-echo-area-use-multiline-p 3
          eldoc-echo-area-display-truncation-message nil)
    (set-face-attribute 'eglot-highlight-symbol-face nil
                        :background "#c3d7ff")
    ))
