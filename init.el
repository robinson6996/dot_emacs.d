;;; init.el --- Starting point for Alex Murray's Emacs Configuration

;;; Commentary:

;;; Code:

;; Risky !!!
(setq enable-local-variables :safe)

;; gpg preferences
(setq epa-armor t)
(setq epg-gpg-program "gpg2")
;; prefer newer non-byte compiled sources to older byte compiled ones
(setq load-prefer-newer t)

;; uncomment to debug package loading times
;; (setq use-package-verbose t)

;; customisations
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
;; load custom but ignore error if doesn't exist
(load custom-file t)

;;; Package management
(require 'package)
;; we use use-package to do this for us
(setq package-enable-at-startup nil)
;; use https for both melpa and gelpa if available
(if (gnutls-available-p)
    (setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                             ("melpa" . "https://melpa.org/packages/")))
  (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                           ("melpa" . "http://melpa.org/packages/"))))

(package-initialize)

;; Bootstrap `use-package' from melpa
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(use-package alert
  :ensure t
  :init (when (eq system-type 'gnu/linux)
          (setq alert-default-style 'notifications)))

;; some useful functions for the rest of this init file
(defun apm-camelize (s &optional delim)
  "Convert under_score string S to CamelCase string with optional DELIM."
  (interactive "s")
  (mapconcat 'identity (mapcar
                        #'(lambda (word) (capitalize (downcase word)))
                        (split-string s (if delim delim "_"))) ""))

(when (version< emacs-version "24.4")
  (alert "Emacs version too old - please run 24 or newer"
         :severity 'high))

;;; General settings etc

;; automatically garbage collect when switch away from emacs
(add-hook 'focus-out-hook 'garbage-collect)

;; enable narrow-to-region
(put 'narrow-to-region 'disabled nil)

;; set a reasonable fill and comment column
(setq-default fill-column 80)
(setq-default comment-column 78)

;; just use y or n not yes or no
(defalias 'yes-or-no-p 'y-or-n-p)

;; inhibit startup message and splash screen
(setq inhibit-startup-message t)
;; remove message from initial scratch buffer
(setq initial-scratch-message nil)

;; Make Tab complete if the line is indented
(setq tab-always-indent 'complete)

;; disable menu, tool and scroll-bars, show time
(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode 0))
(display-time-mode 1)
;; Show line column numbers in mode line
(line-number-mode 1)
(column-number-mode 1)
;; Parent highlight
(show-paren-mode 1)

;; Prefer space over tab
(setq indent-tabs-mode nil)

;; Moves backup files in a different folder
(defvar emacs-backup-directory
  (concat user-emacs-directory "backups/")
  "This variable dictates where to put backups.")

(setq backup-directory-alist
      `((".*" . ,emacs-backup-directory)))

;;; --- Global Shortcuts -------------------------------------------------------
(global-set-key "\C-c\;" 'comment-region)
(global-set-key "\M-g" 'goto-line)
(global-set-key [f8]   'grep-find)
(global-set-key [f7]   'next-match)
(global-set-key [f12]  'next-error)
(global-set-key [f11]  'recompile)

;; prompt when trying to switch out of a dedicated window
(setq switch-to-buffer-in-dedicated-window 'prompt)

;; ensure scrolling forwards / backwards preserves original location such that
;; they undo each other
(setq scroll-preserve-screen-position 'always)

(defun apm-emoji-fontset-init ()
  "Set fontset to display emoji correctly."
  (if (eq system-type 'darwin)
      ;; For NS/Cocoa
      (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji") nil 'prepend)
    ;; For Linux
    (if (font-info "Symbola")
        (set-fontset-font t 'symbol (font-spec :family "Symbola") nil 'prepend)
      (alert "Symbola is not installed (ttf-ancient-fonts)"))))

(defvar apm-preferred-font-family "Inconsolata"
  "Preferred font family to use.")

(defvar apm-preferred-font-family-package "fonts-inconsolata"
  "Package to install to get `apm-preferred-font-family'.")

(defvar apm-preferred-font-height 100
  "Preferred font height to use.")

(defun apm-graphic-frame-init ()
  "Initialise properties specific to graphical display."
  (interactive)
  (when (display-graphic-p)
    (apm-emoji-fontset-init)
    (setq frame-title-format '(buffer-file-name "%f" ("%b")))
    ;; don't use gtk style tooltips so instead can use pos-tip etc
    (custom-set-variables
     '(x-gtk-use-system-tooltips nil))
    (tooltip-mode -1)
    (blink-cursor-mode -1)
    (if (font-info apm-preferred-font-family)
        (set-face-attribute 'default nil
                            :family apm-preferred-font-family
                            :height apm-preferred-font-height)
      (alert (format "%s font not installed (%s)"
                     apm-preferred-font-family
                     apm-preferred-font-family-package)))
    (if (font-info "FontAwesome")
        ;; make sure to use FontAwesome for it's range in the unicode
        ;; private use area since on Windows this doesn't happen
        ;; automagically
        (set-fontset-font "fontset-default" '(#xf000 . #xf23a) "FontAwesome")
      (alert "FontAwesome is not installed (fonts-font-awesome)."))))

;; make sure graphical properties get set on client frames
(add-hook 'server-visit-hook #'apm-graphic-frame-init)
(apm-graphic-frame-init)

;; Use regex searches and replace by default.
(bind-key "C-s" 'isearch-forward-regexp)
(bind-key "C-r" 'isearch-backward-regexp)
(bind-key "M-%" 'query-replace-regexp)
(bind-key "C-M-s" 'isearch-forward)
(bind-key "C-M-r" 'isearch-backward)
(bind-key "C-M-%" 'query-replace)

;; from http://endlessparentheses.com/fill-and-unfill-paragraphs-with-a-single-key.html
(defun endless/fill-or-unfill ()
  "Like `fill-paragraph', but unfill if used twice."
  (interactive)
  (let ((fill-column
         (if (eq last-command 'endless/fill-or-unfill)
             (progn (setq this-command nil)
                    (point-max))
           fill-column)))
    (call-interactively #'fill-paragraph)))

(bind-key [remap fill-paragraph] #'endless/fill-or-unfill)

;; general modes in text-mode or derived from
(defun apm-text-mode-setup ()
  "Setup `text-mode' buffers."
  ;; use visual line mode to do soft word wrapping
  (visual-line-mode 1)
  ;; and use adaptive-wrap to 'indent' paragraphs appropriately with visual-line-mode
  (adaptive-wrap-prefix-mode 1)
  ;; Enable flyspell
  (flyspell-mode 1)
  ;; give warning if words misspelled when typing
  (ispell-minor-mode 1))

(add-hook 'text-mode-hook #'apm-text-mode-setup)

;;; Packages
(use-package abbrev
  :diminish abbrev-mode
  :config (progn
            (setq save-abbrevs t)
            (setq-default abbrev-mode t)))

(use-package adaptive-wrap
  :ensure t)

(use-package aggressive-indent
  :ensure t
  :defer t
  :diminish aggressive-indent-mode)

(use-package akantu-input
  :load-path "lisp/"
  :mode "\\.dat\\'"
  )

(use-package anaconda-mode
  :ensure t
  :diminish (anaconda-mode . " 🐍 ")
  ;; enable with apm-python-mode-setup below
  :defer t)

(use-package ansi-color
  ;; show colours correctly in shell
  :config (ansi-color-for-comint-mode-on))

(use-package anzu
  :ensure t
  :diminish anzu-mode
  :init (global-anzu-mode)
  :bind (("M-%" . anzu-query-replace-regexp)
         ("C-M-%" . anzu-query-replace)))

(use-package apm-c
  :load-path "lisp/"
  :commands (apm-c-mode-setup)
  :init (dolist (hook '(c-mode-hook c++-mode-hook))
          (add-hook hook 'apm-c-mode-setup)))

(use-package apropos
  :bind ("C-h a" . apropos))

(use-package autorevert
  :diminish auto-revert-mode
  :init (global-auto-revert-mode 1))

(defun apm-latex-mode-setup ()
  "Tweaks and customisations for LaTeX mode."
  ;; smartparens latex support
  (use-package smartparens-latex)
  ;; Enable source-correlate for Control-click forward/reverse search.
  (TeX-source-correlate-mode 1)
  ;; enable math mode in latex
  (LaTeX-math-mode 1)
  ;; Enable reftex
  (turn-on-reftex)
  ;; integrate with company
  (company-auctex-init))

(use-package auctex
  :ensure t
  :defer t
  :mode ("\\.tex\\'" . LaTeX-mode)
  :init (progn
          (setq-default TeX-auto-save t)
          (setq-default TeX-parse-self t)
          (setq-default TeX-PDF-mode t)
          (setq-default TeX-master nil)
          (setq-default reftex-plug-into-AUCTeX t)
          (setq-default TeX-source-correlate-start-server t)

          (add-hook 'LaTeX-mode-hook #'apm-latex-mode-setup)))

;; show #if 0 / #endif etc regions in comment face - taken from
;; http://stackoverflow.com/questions/4549015/in-c-c-mode-in-emacs-change-face-of-code-in-if-0-endif-block-to-comment-fa
(defun c-mode-font-lock-if0 (limit)
  "Fontify #if 0 / #endif as comments for c modes etc.
Bound search to LIMIT as a buffer position to find appropriate
code sections."
  (save-restriction
    (widen)
    (save-excursion
      (goto-char (point-min))
      (let ((depth 0) str start start-depth)
        (while (re-search-forward "^\\s-*#\\s-*\\(if\\|else\\|endif\\)" limit 'move)
          (setq str (match-string 1))
          (if (string= str "if")
              (progn
                (setq depth (1+ depth))
                (when (and (null start) (looking-at "\\s-+0"))
                  (setq start (match-end 0)
                        start-depth depth)))
            (when (and start (= depth start-depth))
              (c-put-font-lock-face start (match-beginning 0) 'font-lock-comment-face)
              (setq start nil))
            (when (string= str "endif")
              (setq depth (1- depth)))))
        (when (and start (> depth 0))
          (c-put-font-lock-face start (point) 'font-lock-comment-face)))))
  nil)

;; c-mode and other derived modes (c++, java etc) etc
(defun apm-c-mode-common-setup ()
  "Tweaks and customisations for all modes derived from c-common-mode."
  (auto-fill-mode 1)
  ;; diminish auto-fill in the modeline
  (with-eval-after-load 'diminish
    (diminish 'auto-fill-function))
  ;; turn on auto-newline and hungry-delete
  (c-toggle-auto-hungry-state t)
  ;; ensure fill-paragraph takes doxygen @ markers as start of new
  ;; paragraphs properly
  (setq paragraph-start "^[ ]*\\(//+\\|\\**\\)[ ]*\\([ ]*$\\|@param\\)\\|^\f")

  ;; show #if 0 / #endif etc regions in comment face
  (font-lock-add-keywords
   nil
   '((c-mode-font-lock-if0 (0 font-lock-comment-face prepend))) 'add-to-end))

(use-package cc-mode
  :defer t
  :init (add-hook 'c-mode-common-hook #'apm-c-mode-common-setup))

(use-package clang-format
  :ensure t
  :bind (:map c++-mode-map
              ([f5] . clang-format-buffer))
  :config
  (setq clang-format-executable "clang-format-3.9")
  )

(use-package cmake-mode
  :ensure t)

(use-package cmake-font-lock
  :ensure t)

(use-package company
  :ensure t
  :commands global-company-mode
  ;; Use Company for completion
  :bind (:map company-mode-map ([remap completion-at-point] . company-complete))
  :init (progn
          ;; set default lighter as nothing so in general it is not displayed
          ;; but will still be shown when completion popup is active to show the
          ;; backend which is in use
          (setq company-lighter-base "")
          (global-company-mode 1))
  :config (progn
            ;; some better default values
            (setq company-idle-delay 0.5)
            (setq company-tooltip-limit 10)
            (setq company-minimum-prefix-length 2)

            ;; align annotations in tooltip
            (setq company-tooltip-align-annotations t)

            ;; nicer keybindings
            (define-key company-active-map (kbd "C-n") 'company-select-next)
            (define-key company-active-map (kbd "C-p") 'company-select-previous)
            (define-key company-active-map (kbd "C-d") 'company-show-doc-buffer)

            (define-key company-active-map [tab] 'company-complete-common-or-cycle)
            (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)

            ;; put most often used completions at stop of list
            (setq company-transformers '(company-sort-by-occurrence))))

(use-package company-anaconda
  :ensure t
  :commands (company-anaconda)
  :after company
  :init (add-to-list 'company-backends #'company-anaconda))

(use-package company-auctex
  :ensure t
  ;; loaded in apm-latex-mode-setup
  :defer t)

(use-package company-dabbrev
  :after company
  ;; keep original case
  :config (setq company-dabbrev-downcase nil))

(use-package company-flx
  :ensure t
  :after company
  :init (company-flx-mode 1))

(use-package company-irony
  :ensure t
  :after company
  :init (add-to-list 'company-backends 'company-irony))

(use-package company-irony-c-headers
  :ensure t
  :after company
  :init (progn
          (setq company-irony-c-headers--compiler-executable
                (or (executable-find "clang++-3.9")
                    (executable-find "clang++")))
          ;; group with company-irony but beforehand so we get first pick
          (add-to-list 'company-backends '(company-irony-c-headers company-irony))))

(use-package company-jedi
  :ensure t
  :after company
  :init (add-to-list 'company-backends 'company-jedi))

(use-package company-emoji
  :ensure t
  :after company
  :init (add-to-list 'company-backends 'company-emoji))

(use-package company-math
  :ensure t
  :defer t
  :after company
  ;; Add backend for math characters
  :init (progn
          (add-to-list 'company-backends 'company-math-symbols-unicode)
          (add-to-list 'company-backends 'company-math-symbols-latex)))

(use-package company-quickhelp
  :ensure t
  :defer t
  :init (add-hook 'company-mode-hook #'company-quickhelp-mode)
  :config (setq company-quickhelp-delay 0.1))

(use-package company-shell
  :ensure t
  :defer t
  :after company
  :init (add-to-list 'company-backends 'company-shell))

(use-package company-statistics
  :ensure t
  :after company
  :config (company-statistics-mode 1))

(use-package company-try-hard
  :ensure t
  :after company
  :config (progn
            (global-set-key (kbd "C-<tab>") #'company-try-hard)
            (define-key company-active-map (kbd "C-<tab>") #'company-try-hard)))

(use-package company-web
  :ensure t
  :defer t
  :after company
  :init (add-to-list 'company-backends 'company-web-html))

(use-package compile
  :bind ([f9] . compile)
  ;; automatically scroll to first error on output
  :config (setq compilation-scroll-output 'first-error))

(use-package counsel
  :ensure t
  :bind (("M-y" . counsel-yank-pop)
         ("M-x" . counsel-M-x)
         ("C-x C-i" . counsel-imenu)
         ("C-x C-f" . counsel-find-file)
         ("C-h f" . counsel-describe-function)
         ("C-h v" . counsel-describe-variable))
  :init (progn
          (define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
          (setq counsel-find-file-at-point t))
  )

(use-package counsel-projectile
  :ensure t
  :init (counsel-projectile-on))

(defun apm-coverlay-setup()
  (coverlay-mode 1))

(use-package coverlay
  :ensure t
  :defer t
  :diminish coverlay-mode
  :config (add-hook 'c-mode-common-hook #'apm-coverlay-setup))

(use-package crux
  :ensure t
  :bind (([remap move-beginning-of-line] . crux-move-beginning-of-line)
         ("C-c o" . crux-open-with)))

;; show suspicious c constructs automatically
(use-package cwarn
  :diminish cwarn-mode
  :init (global-cwarn-mode 1))

(use-package delsel
  ;; enable delete-selection mode to allow replacing selected region
  ;; with new text automatically
  :init (delete-selection-mode 1))

(defun apm-devhelp-setup ()
  "Setup devhelp integration."
  (require 'devhelp)
  (local-set-key (kbd "<f2>") #'devhelp-toggle-automatic-assistant)
  (local-set-key (kbd  "<f1>") #'devhelp-assistant-word-at-point))

(use-package devhelp
  :load-path "vendor/"
  :defer t
  :init (add-hook 'c-mode-hook #'apm-devhelp-setup))

(use-package diff
  ;; default to unified diff
  :config (setq diff-switches "-u"))

(use-package diff-hl
  :ensure t
  :init (progn
          (global-diff-hl-mode 1)
          ;; highlight in unsaved buffers as well
          (diff-hl-flydiff-mode 1)
          ;; Integrate with Magit
          (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
          ;; Highlight changed files in the fringe of dired
          (add-hook 'dired-mode-hook #'diff-hl-dired-mode)))

(use-package diminish
  :ensure t)

(defun apm-doxymacs-setup()
  (doxymacs-mode)
  (doxymacs-font-lock)
  (setq doxymacs-doxygen-style "JavaDoc")
  (setq doxymacs-file-comment-template
        ("/**" > n
         " * " (doxymacs-doxygen-command-char) "file   " (if (buffer-file-name) (file-name-nondirectory (buffer-file-name)) "") > n
         " *" > n
         " * " (doxymacs-doxygen-command-char) "author " (user-full-name) (doxymacs-user-mail-address) > n
         " *" > n
         " * " (doxymacs-doxygen-command-char) "date   " (current-time-string) > n
         " *" > n
         " * " (doxymacs-doxygen-command-char) "brief  " (p "Brief description of this file: ") > n
         " *" > n
         " * " (doxymacs-doxygen-command-char) "section LICENSE" > n
         " *" > n
         " * Copyright (©) 2010-2011 EPFL (Ecole Polytechnique Fédérale de Lausanne)" > n
         " * Laboratory (LSMS - Laboratoire de Simulation en Mécanique des Solides)" > n " *" > n
         " * Akantu is free  software: you can redistribute it and/or  modify it under the" > n
         " * terms  of the  GNU Lesser  General Public  License as  published by  the Free" > n
         " * Software Foundation, either version 3 of the License, or (at your option) any" > n
         " * later version." > n
         " *" > n
         " * Akantu is  distributed in the  hope that it  will be useful, but  WITHOUT ANY" > n
         " * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR" > n
         " * A  PARTICULAR PURPOSE. See  the GNU  Lesser General  Public License  for more" > n
         " * details." > n
         " *" > n
         " * You should  have received  a copy  of the GNU  Lesser General  Public License" > n
         " * along with Akantu. If not, see <http://www.gnu.org/licenses/>." > n
         " *" > n
         " */" > n > n
         "/* -------------------------------------------------------------------------- */" > n))
  )

(use-package doxymacs
  :defer t
  :load-path "vendor/doxymacs"
  :commands (doxymacs-mode doxymacs-font-lock)
  :diminish doxymacs-mode
  :config (add-hook 'cc-mode-common-hook #'apm-doxymacs-setup)
  )

(use-package dracula-theme
  :ensure t
  :config (load-theme 'dracula t))

(use-package dts-mode
  :ensure t)

;; taken from http://kaushalmodi.github.io/2015/03/09/do-ediff-as-i-mean/
(defun apm-ediff-dwim ()
  "Do ediff as I mean.

If a region is active when command is called, call `ediff-regions-wordwise'.

Else if the current frame has 2 windows,
- Do `ediff-files' if the buffers are associated to files and the buffers
  have not been modified.
- Do `ediff-buffers' otherwise.

Otherwise call `ediff-buffers' interactively."
  (interactive)
  (if (region-active-p)
      (call-interactively 'ediff-regions-wordwise)
    (if (= 2 (safe-length (window-list)))
        (let (bufa bufb filea fileb)
          (setq bufa  (get-buffer (buffer-name)))
          (setq filea (buffer-file-name bufa))
          (save-excursion
            (other-window 1)
            (setq bufb (get-buffer (buffer-name))))
          (setq fileb (buffer-file-name bufb))
          (if (or
               ;; if either of the buffers is not associated to a file
               (null filea) (null fileb)
               ;; if either of the buffers is modified
               (buffer-modified-p bufa) (buffer-modified-p bufb))
              (progn
                (message "Running (ediff-buffers \"%s\" \"%s\") .." bufa bufb)
                (ediff-buffers bufa bufb))
            (progn
              (message "Running (ediff-files \"%s\" \"%s\") .." filea fileb)
              (ediff-files filea fileb))))
      (call-interactively 'ediff-buffers))))

(use-package ediff
  :defer t
  :config (setq ediff-window-setup-function 'ediff-setup-windows-plain
                ediff-split-window-function 'split-window-horizontally))

(use-package ein
  :ensure t
  )

(use-package eldoc
  :diminish eldoc-mode
  :config (global-eldoc-mode 1))

(use-package elpy
  :ensure t
  :config (elpy-enable))

(defun apm-erc-alert (&optional match-type nick message)
  "Show an alert when nick mentioned with MATCH-TYPE NICK and MESSAGE."
  (if (or (null match-type) (not (eq match-type 'fool)))
      (let (alert-log-messages)
        (alert (or message (buffer-string)) :severity 'high
               :title (concat "ERC: " (or nick (buffer-name)))
               :data message))))

(use-package erc
  :defer t
  :config (progn
            (setq erc-nick "networms")
            ;; notify via alert when mentioned
            (add-hook 'erc-text-matched-hook 'apm-erc-alert)))


(defun apm-eshell-mode-setup ()
  "Initialise 'eshell-mode'."
  (setq mode-name ""))

(use-package eshell
  :commands eshell
  :bind ("C-x m" . eshell)
  :config (add-hook 'eshell-mode-hook #'apm-eshell-mode-setup))

(defun makefile-tabs-are-less-evil ()
  "Disable ethan-wspace from caring about tabs in Makefile's."
  ;; silence byte-compilation warnings
  (eval-when-compile
    (require 'ethan-wspace))
  (setq ethan-wspace-errors (remove 'tabs ethan-wspace-errors)))

(use-package ethan-wspace
  :ensure t
  :diminish ethan-wspace-mode
  :config (progn
            ;; ethan-wspace-mode raises lots of warnings if this is enabled...
            ;; hopefully this doesn't cause problems
            (setq mode-require-final-newline nil)
            ;; disable ethan-wspace caring about tabs in Makefile's
            (add-hook 'makefile-mode-hook #'makefile-tabs-are-less-evil))
  :init (global-ethan-wspace-mode 1))

(defun apm-make-underscore-word-character ()
  "Make _ a word character."
  (modify-syntax-entry ?_ "w"))

(use-package eyebrowse
  :ensure t
  :after evil
  :config (progn
            (eyebrowse-mode t)
            ;; start a new workspace clean with just the scratch buffer
            (setq eyebrowse-new-workspace t)
            ;; wrap workspaces like vim
            (setq eyebrowse-wrap-around t)
            (eyebrowse-setup-evil-keys)))

(use-package fancy-battery
  :ensure t
  :config (fancy-battery-mode 1))

(use-package fancy-narrow
  :ensure t
  :diminish fancy-narrow-mode
  :config (fancy-narrow-mode 1))

(use-package fic-mode
  :ensure t
  :defer t)

(use-package files
  :bind ("C-c r" . revert-buffer))

(use-package fill-column-indicator
  :ensure t
  :config (progn
            (define-global-minor-mode global-fci-mode fci-mode
              ;; only enable when buffer is not a special buffer (starts and
              ;; ends with an asterisk)
              (lambda () (if (not (string-match "^\*.*\*$" (buffer-name)))
                             (fci-mode 1))))
            (global-fci-mode 1)
            ;; make fci play nicely with company-mode - from https://github.com/alpaker/Fill-Column-Indicator/issues/54#issuecomment-218344694
            (with-eval-after-load 'company
              (defun on-off-fci-before-company(command)
                (when (string= "show" command)
                  (turn-off-fci-mode))
                (when (string= "hide" command)
                  (turn-on-fci-mode)))

              (advice-add 'company-call-frontends :before #'on-off-fci-before-company))))

(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :config (progn
            (global-flycheck-mode 1)
            (setq flycheck-check-syntax-automatically '(save new-line)
                  flycheck-idle-change-delay 5.0
                  flycheck-display-errors-delay 0.9
                  flycheck-highlighting-mode 'symbols
                  flycheck-indication-mode 'left-fringe
                  ;; 'flycheck-fringe-bitmap-double-arrow
                  flycheck-standard-error-navigation t ; [M-g n/p]
                  flycheck-deferred-syntax-check nil
                  ;; flycheck-mode-line '(:eval (flycheck-mode-line-status-text))
                  flycheck-completion-system nil ; 'ido, 'grizzl, nil
                  )))

(use-package flycheck-clangcheck
  :ensure t
  :after flycheck
  )

(use-package flycheck-irony
  :ensure t
  :after flycheck
  :config (progn
            (add-hook 'flycheck-mode-hook #'flycheck-irony-setup)
            (flycheck-add-next-checker 'irony '(warning . c/c++-cppcheck))))

(use-package flycheck-package
  :ensure t
  :defer t
  :after flycheck
  :init (flycheck-package-setup))

(use-package flycheck-pos-tip
  :ensure t
  :config (flycheck-pos-tip-mode 1))

(use-package flyspell
  :diminish flyspell-mode)

(use-package flyspell-correct-ivy
  :ensure t
  :after ivy
  ;; use instead of ispell-word which evil binds to z=
  :bind (([remap ispell-word] . flyspell-correct-word-generic)))

(use-package flx
  :ensure t)

(use-package fuzzy
  :ensure t)

;;(use-package git-gutter+
;;  :ensure t
;;  :diminish git-gutter+-mode
;;  :init
;;  (add-hook 'c-mode-common-hook 'git-gutter+-mode)
;;  (add-hook 'cmake-mode-hook 'git-gutter+-mode)
;;  (add-hook 'python-mode-hook 'git-gutter+-mode)
;;  (add-hook 'LaTeX-mode-hook 'git-gutter+-mode)
;;  )

(use-package gitconfig-mode
  :ensure t
  :defer t)

(use-package gitignore-mode
  :ensure t
  :defer t)

(use-package gl-conf-mode
  :load-path "vendor/gitolite-emacs"
  :mode  "gitolite\\.conf\\'"
  )

(defun apm-irony-mode-setup ()
  "Setup irony-mode."
  (irony-cdb-autosetup-compile-options)
  (with-eval-after-load 'company-irony
    (company-irony-setup-begin-commands))
  (with-eval-after-load 'irony-eldoc
    (irony-eldoc)))

;; autogenerate a .clang_complete if there is an associated .clang_complete.in
(defun apm-autogenerate-clang-complete ()
  "Autogenerate a .clang_complete if needed when opening a project."
  (when (and (fboundp 'projectile-project-root)
             ;; handle if not in project by returning nil
             (not (null (condition-case nil
                            (projectile-project-root)
                          (error nil))))
             (file-exists-p (concat (file-name-as-directory
                                     (projectile-project-root))
                                    ".clang_complete.in")))
    (projectile-with-default-dir (projectile-project-root)
      (shell-command "make .clang_complete"))))

(defun apm-irony-cdb-clang-complete--auto-generate-clang-complete (command &rest args)
  "Try and autogenerate a .clang_complete (COMMAND ARGS are ignored)."
  (apm-autogenerate-clang-complete))

(use-package irony
  :ensure t
  :diminish irony-mode
  :commands (irony-mode)
  :bind (:irony-mode-map ([remap completion-at-point] . irony-completion-at-point-async)
                         ([remap complete-symbol] . irony-completion-at-point-async))
  :init (progn
          (advice-add 'irony-cdb-clang-complete :before 'apm-irony-cdb-clang-complete--auto-generate-clang-complete)
          (add-hook 'c-mode-hook 'irony-mode)
          (add-hook 'c++-mode-hook 'irony-mode)
          (add-hook 'irony-mode-hook 'apm-irony-mode-setup)))

(use-package irony-eldoc
  :ensure t
  :defer t)

(use-package ivy
  :ensure t
  :diminish ivy-mode
  :commands (ivy-mode)
  :bind (("C-c C-r" . ivy-resume)
         ([remap switch-to-buffer] . ivy-switch-buffer))
  :init (progn
          (setq ivy-use-recent-buffers t
                ivy-count-format ""
                ivy-display-style 'fancy)
          (ivy-mode 1))
  :config (with-eval-after-load 'evil
            (define-key evil-ex-map "b " 'ivy-switch-buffer)))

(use-package gdb-mi
  :defer t
  :init (progn
          ;; use gdb-many-windows by default
          (setq gdb-many-windows nil)
          ;; Non-nil means display source file containing the main routine at startup
          (setq gdb-show-main t)))

(use-package gud
  :defer t
  :init (add-hook 'gud-mode-hook #'gud-tooltip-mode))

(use-package jenkins
  :ensure t
  :commands (jenkins)
  ;; don't set jenkins-api-token here - do it in custom.el so it is not checked
  ;; into git
  :config (setq jenkins-hostname "http://scitasadm.epfl.ch/jenkins/"
                jenkins-username 'user-login-name))

(defun apm-js2-mode-setup ()
  "Setup js2-mode."
  (setq mode-name "js2"))

(use-package js2-mode
  :ensure t
  :defer t
  :init (progn
          (setq-default js2-basic-offset 2)
          (add-hook 'js2-mode-hook 'apm-js2-mode-setup)))

(defun apm-emacs-lisp-mode-setup ()
  "Setup Emacs Lisp mode."
  (setq mode-name "el")
  ;; use aggressive indent
  (aggressive-indent-mode 1)
  (fic-mode 1)
  ;; make imenu list each package for easy navigation - from
  ;; https://github.com/jwiegley/use-package/issues/80#issuecomment-46687774
  (when (string= buffer-file-name (expand-file-name "init.el" "~/dot_emacs.d"))
    (add-to-list
     'imenu-generic-expression
     '("Packages" "^\\s-*(\\(use-package\\)\\s-+\\(\\(\\sw\\|\\s_\\)+\\)" 2)))
  ;; use smartparens in strict mode for lisp
  (with-eval-after-load 'smartparens
    (smartparens-strict-mode 1)))

(use-package lisp-mode
  :config (add-hook 'emacs-lisp-mode-hook #'apm-emacs-lisp-mode-setup))

(use-package magit
  :ensure t
  :defer t
  :bind ("C-x g" . magit-status))

(use-package markdown-mode
  :ensure t
  :defer t
  :mode
  (("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :config (progn
            (unless (executable-find markdown-command)
              (alert "markdown not found - is it installed?"))))

(use-package modern-cpp-font-lock
  :ensure t
  :defer t
  :diminish modern-c++-font-lock-mode
  :init (add-hook 'c++-mode-hook #'modern-c++-font-lock-mode))

(use-package multi-term
  :ensure t
  :init
  (add-hook 'term-mode-hook
            (lambda()
              (setq show-trailing-whitespace nil))))

(use-package paradox
  :ensure t
  :commands (paradox-list-packages)
  ;; don't bother trying to integrate with github
  :init (setq paradox-github-token nil))

(use-package pcap-mode
  :ensure t
  :mode ("\\.pcapng\\'" . pcap-mode))

(use-package pdf-tools
  :ensure t
  ;; only try and install when needed
  :mode ("\\.pdf\\'" . pdf-tools-install))

(defun apm-prog-mode-setup ()
  "Tweaks and customisations for all programming modes."
  ;; turn on spell checking for strings and comments
  (flyspell-prog-mode)
  ;; highlight TODO etc in comments only
  (fic-mode 1))

(use-package prog-mode
  :config (progn
            (when (boundp 'prettify-symbols-unprettify-at-point)
              ;; show original text when point is over a prettified symbol
              (setq prettify-symbols-unprettify-at-point 'right-edge))
            ;; prettify symbols (turn lambda -> λ)
            (global-prettify-symbols-mode 1)
            (add-hook 'prog-mode-hook #'apm-prog-mode-setup)))

(use-package projectile
  :ensure t
  :defer t
  :diminish projectile-mode
  :bind (("C-x C-m" . projectile-compile-project)
         ("C-x C-g" . projectile-find-file))
  :init (progn
          (setq projectile-enable-caching t)
          (projectile-global-mode))
  :config (progn
            (add-to-list 'projectile-project-root-files "configure.ac")
            (add-to-list 'projectile-project-root-files ".clang_complete")
            (add-to-list 'projectile-project-root-files ".clang_complete.in")
            (add-to-list 'projectile-project-root-files "AndroidManifest.xml")
            (with-eval-after-load 'ivy
              (setq projectile-completion-system 'ivy))))

(use-package psvn
  :ensure t
  :init (setq svn-status-state-mark-modeline nil))

(defun apm-python-mode-setup ()
  "Tweaks and customisations for `python-mode'."
  (setq python-indent-offset 4)
  (anaconda-mode 1)
  (anaconda-eldoc-mode 1))

(use-package python
  :defer t
  :init (add-hook 'python-mode-hook #'apm-python-mode-setup))

(use-package rainbow-mode
  :ensure t
  :diminish rainbow-mode
  :commands (rainbow-mode)
  :init (dolist (hook '(css-mode-hook html-mode-hook))
          (add-hook hook #'rainbow-mode)))

;; save minibuffer history
(use-package savehist
  :init (savehist-mode 1))

(use-package saveplace
  :config (progn
            (setq-default save-place t)
            (setq save-place-file (expand-file-name ".places" user-emacs-directory))))

(use-package server-functions
  :load-path "lisp/"
  )

(use-package sh-script
  :init (setq-default sh-basic-offset 2
                      sh-indentation 2))

(use-package smex
  :ensure t
  :config (smex-initialize))

(use-package spaceline-config
  :ensure spaceline
  :init (setq spaceline-workspace-numbers-unicode t
              spaceline-window-numbers-unicode t)
  :config (progn
            (require 'spaceline-config)
            ;; show evil state with colour change
            (setq spaceline-highlight-face-func #'spaceline-highlight-face-evil-state)
            (spaceline-spacemacs-theme)))

(use-package swig-mode
  :load-path "vendor/"
  :mode "\\.i\\'"
  )

(use-package tracwiki-mode
  :ensure t
  :defer t
  :commands tracwiki
  :config (tracwiki-define-project
           "akantu"
           "https://lsmssrv1.epfl.ch/akantu-trac"))

(use-package unicode-fonts
  :ensure t
  :config (unicode-fonts-setup))

(use-package uniquify
  :config (setq uniquify-buffer-name-style 'post-forward
                uniquify-separator ":"
                uniquify-after-kill-buffer-p t
                uniquify-ignore-buffers-re "^\\*"))

(defun apm-web-mode-setup ()
  "Setup web mode."
  (setq mode-name ""))

(use-package web-mode
  :ensure t
  :commands web-mode
  :config (progn
            ;; use smartparens instead
            (setq web-mode-enable-auto-pairing nil)
            (add-hook 'web-mode-hook #'apm-web-mode-setup))
  :mode ("\\.php\\'" . web-mode))

(use-package whitespace
  :diminish whitespace-mode
  :bind ([f3] . whitespace-cleanup)
  :config
  (defun show-whitespace ()
    "Show tabs and trailing white space."
    (if (not (eq major-mode 'Buffer-menu-mode))
        (setq font-lock-keywords
              (append font-lock-keywords
                      '(("^[\t]+"  (0 'tab-face t))
                        ("[ \t]+$" (0 'trailing-space-face t))
                        ("XXX" (0 'todo-face t))
                        ("TODO" (0 'todo-face t))
                        ("FIXME" (0 'todo-face t))
                        ("\\todo" (0 'todo-face t))
                        )))))
  (make-face 'tab-face)
  (make-face 'trailing-space-face)
  (make-face 'todo-face)
  (set-face-background 'tab-face "blue")
  (set-face-background 'trailing-space-face "blue")
  (set-face-foreground 'todo-face "green")
  (add-hook 'font-lock-mode-hook 'show-whitespace)
  (add-hook 'text-mode-hook 'font-lock-mode)
  )

(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :config (yas-global-mode 1))

(provide 'init)

;;; init.el ends here
