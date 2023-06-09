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
(setq doom-theme 'doom-vibrant)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type `relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(require 'org-habit)
(setq org-default-properties (cons "RESET_SUBTASKS" org-default-properties))
(defun org-reset-subtask-state-subtree ()
  "Reset all subtasks in an entry subtree."
  (interactive "*")
  (if (org-before-first-heading-p)
      (error "Not inside a tree")
    (save-excursion
      (save-restriction (org-narrow-to-subtree)
                        (org-fold-show-subtree) (goto-char (point-min))
                        (beginning-of-line 2)
                        (narrow-to-region (point) (point-max))
                        (org-map-entries
                         '(when (member (org-get-todo-state) org-done-keywords)
                            (org-todo (car org-todo-keywords))))
                        ))))
(defun org-reset-subtask-state-maybe ()
  "Reset all subtasks in an entry if the `RESET_SUBTASKS' property is set"
  (interactive "*")
  (if (org-entry-get (point) "RESET_SUBTASKS")
      (org-reset-subtask-state-subtree)))
(defun org-subtask-reset ()
  (when (member org-state org-done-keywords) ;; org-state dynamically bound in org.el/org-todo
    (org-reset-subtask-state-maybe)
    (org-update-statistics-cookies t)))
(add-hook 'org-after-todo-state-change-hook 'org-subtask-reset)
(provide 'org-subtask-reset)

;; org-roam
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
;; org-roam templates
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

;; c/c++ language
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

;; email
(setq +mu4e-backend 'offlineimap)
(setq mu4e-root-maildir "~/.mail")
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e")
;; Each path is relative to the path of the maildir you passed to mu
(set-email-account! "Tencent"
                    '((mu4e-sent-folder       . "/Tencent/Sent Messages")
                      (mu4e-drafts-folder     . "/Tencent/Drafts")
                      (mu4e-trash-folder      . "/Tencent/Junk")
                      (mu4e-refile-folder     . "/Tencent/INBOX")
                      (mu4e-compose-signature . "---\nYours truly\nBo Zhou"))
                    t)
(require 'smtpmail)
(remove-hook! 'mu4e-compose-mode-hook #'org-mu4e-compose-org-mode)
(require 'auth-source);; probably not necessary
(setq auth-sources '("~/.authinfo" "~/.authinfo.gpg"))
(setq message-send-mail-function 'smtpmail-send-it)
(setq smtpmail-debug-info t)
(setq smtpmail-debug-verb t)
(setq user-mail-address "bozhou_0728@qq.com")
(setq user-full-name "Zhou Bo")
(setq mu4e-confirm-quit nil
      message-send-mail-function 'smtpmail-send-it
      smtpmail-smtp-user "bozhou_0728@qq.com"
      smtpmail-smtp-server "smtp.qq.com"
      smtpmail-smtp-service 465
      smtpmail-stream-type 'ssl)
(setq mu4e-bookmarks
      '(("flag:unread AND NOT flag:trashed" "Unread messages" ?u)))

;; google translate
(require 'google-translate)
(require 'google-translate-default-ui)
(global-set-key "\C-ct" 'google-translate-at-point)
(global-set-key "\C-cT" 'google-translate-query-translate)
(setq google-translate-default-source-language "en")
(setq google-translate-default-target-language "zh-CN")
