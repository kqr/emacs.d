;;; kqr-dotemacs --- summary
;;; Commentary:
;;
;; * Requires Emacs 25
;; * Requires an internet connection
;;


;;; Todo:
;; - find a way to browse tags (ggtags etc?)
;; - include a "site-local" config file if it exists
;;
;; Inspiration for further items:
;; - https://oremacs.com/2015/04/16/ivy-mode/
;; - https://github.com/julienfantin/.emacs.d/blob/master/init.el
;; - https://github.com/magnars/.emacs.d/blob/master/init.el
;; - https://github.com/sachac/.emacs.d/blob/gh-pages/Sacha.org
;; - https://github.com/rejeep/emacs/
;; - https://github.com/hlissner/doom-emacs
;; - https://github.com/redguardtoo/emacs.d
;; - https://github.com/defunkt/emacs
;; - https://github.com/lunaryorn/old-emacs-configuration
;; - https://github.com/grettke/home/blob/master/.emacs.el
;; - https://github.com/abo-abo/oremacs
;; - https://github.com/kaushalmodi/.emacs.d/blob/master/init.el
;; - https://github.com/grettke/home
;; - https://github.com/jorgenschaefer/Config/blob/master/emacs.el


;;; Configuration toggles:

;; Comment out an element to disable it from the config.
(defvar *ENABLED*
  '(
    ;; Appearance loaded first to avoid silly allocations and flashing UI.
    disable-gui
    instant-show-matching-paren
    highlight-todo-comments
    center-cursor
    no-soft-wrap
    highlight-text-beyond-fill-column

    ;; Config debugging loaded early to enable even if rest of init is broken.
    config-debugging
    
    ;; God mode loaded next because I'm practically addicted to it.
    cursor-toggles-with-god-mode
    god-mode

    ;; Global (or globalised) minor modes providing various Emacs improvements.
    ivy-fuzzy-matching
    undo-tree
    expand-region
    paredit-all-the-things

    ;; Programming specific minor modes.
    aggressive-indent
    flycheck-with-infer
    c-mode-config

    ;; Useful non-standard major modes.
    org-mode-basic-config
    magit-git-integration


    ;; Personal keybindings. Last in evaluation order to override other modes.
    backspace-kills-words
    bind-easy-line-join
    unbind-easy-suspend
    
    ))


;;; Various defaults

(setq-default major-mode 'text-mode)

(setq-default make-backup-files nil)
(setq-default large-file-warning-threshold 100000000)


;;; Prerequisites:

(require 'package)
(push '("marmalade" . "http://marmalade-repo.org/packages/") package-archives)
(push '("melpa stable" . "http://stable.melpa.org/packages/") package-archives)
(push '("melpa" . "http://melpa.milkbox.net/packages/") package-archives)
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(use-package no-littering :init
  (setq backup-inhibited t)
  (setq auto-save-default nil))


;;; Code:

(defun disable-gui ()
  "Disable various UI elements for a distraction free experience."
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (blink-cursor-mode -1)
  (global-linum-mode -1)
  (setq-default inhibit-startup-screen t)
  (require 'diminish))


(defun instant-show-matching-paren ()
  "Show matching parens immediately."
  (setq-default show-paren-delay 0)
  (setq-default show-paren-when-point-inside-paren t)
  (setq-default show-paren-style 'expression)
  ;; This is in order for selected region to take priority over
  ;; show-paren expression style
  (setq-default show-paren-priority -50)
  (show-paren-mode +1))


(defun highlight-todo-comments ()
  "Highlight words like TODO, FIXME and similar in comments."
  (use-package fic-mode :init
    (add-hook 'prog-mode-hook 'fic-mode)))


(defun center-cursor ()
  "Scroll buffers to keep the cursor centered."
  (use-package centered-cursor-mode :diminish centered-cursor-mode :config
    (global-centered-cursor-mode +1)))


(defun no-soft-wrap ()
  "Enable horizontal scrolling for lines extending beyond frame border."
  (setq-default truncate-lines t)
  (set-display-table-slot standard-display-table 0 ?›))


(defun highlight-text-beyond-fill-column ()
  "Indicate overlong lines by highlighting the protruding text."
  (use-package column-enforce-mode :diminish column-enforce-mode :init
    (setq-default fill-column 80)
    (global-column-enforce-mode +1)))


(defun config-debugging ()
  "Install bug-hunter to better spot errors in dotemacs file."
  (use-package bug-hunter :commands bug-hunter-init-file))


(defun ivy-fuzzy-matching ()
  "Use Ivy for fuzzy matching buffers, files, commands etc."
  (use-package ivy :diminish ivy-mode :config (ivy-mode +1)))


(defun undo-tree ()
  "Enable undo-tree for easier traversal of edit history."
  (use-package undo-tree :diminish undo-tree-mode :config
    (global-undo-tree-mode)
    (setq undo-tree-visualizer-diff t)))


(defun expand-region ()
  "Set up expand-region with convenient keybinds."
  (use-package expand-region
    :bind (("C-t" . er/expand-region))
    
    :config
    (setq expand-region-contract-fast-key "n")
    (delete-selection-mode +1)))


(defun aggressive-indent ()
  "Enable aggressive automatic indentation everywhere."
  (use-package aggressive-indent :diminish aggressive-indent-mode :config
    (global-aggressive-indent-mode +1)))


(defun paredit-all-the-things ()
  "Enable paredit everywhere."
  (use-package paredit :diminish paredit-mode :config
    ;; Fixes to make paredit more convenient to work with in other languages
    (setq-default paredit-space-for-delimiter-predicates
		  (list (lambda (&rest args) nil)))
    (unbind-key "\\" paredit-mode-map)
    (unbind-key "M-q" paredit-mode-map)
    
    (add-hook 'text-mode-hook #'paredit-mode)
    (add-hook 'prog-mode-hook #'paredit-mode)))


(defun flycheck-with-infer ()
  "Enable flycheck with Java infer support."
  (use-package flycheck :config
    (global-flycheck-mode 1)
    (add-to-list 'load-path "~/.emacs.d/config/libs")
    (require 'flycheck-infer)))


(defun c-mode-config ()
  "Set a few defaults for C mode."
  (setq-default c-default-style "stroustrup")
  (setq-default c-basic-offset 4))


(defun org-mode-basic-config ()
  "Install org mode with desired keywords."
  (use-package org
    :mode ("\\.org\\'" . org-mode)

    :config
    (setq org-todo-keywords '((sequence "NEW" "TODO" "|" "DONE" "HOLD")))
    (setq org-todo-keyword-faces '(("HOLD" . (:foreground "dim grey"))))
    (setq org-lowest-priority ?F)
    (setq org-default-priority ?D)))


(defun magit-git-integration ()
  "Install magit and trigger on x g g."
  (use-package magit :defines god-exempt-major-modes
    :bind (("C-x M-g" . magit-status))
    :config
    (add-to-list 'god-exempt-major-modes 'magit-mode)))


(defvar god-local-mode)

(defun cursor-toggles-with-god-mode ()
  "Default to bar cursor and switch to box type in God mode."
  (setq-default cursor-type 'box)
  (defun god-mode-update-cursor ()
    (defun god-mode-update-cursor ()
      (setq cursor-type (if (or god-local-mode buffer-read-only) 'box 'bar))))
  (add-hook 'god-mode-enabled-hook 'god-mode-update-cursor)
  (add-hook 'god-mode-disabled-hook 'god-mode-update-cursor))

(defun god-mode ()
  "Reduce wrist pain by installing God mode."
  (use-package god-mode :defines god-mode-isearch-map
    :bind (("<escape>" . god-local-mode)
           :map isearch-mode-map ("<escape>" . god-mode-isearch-activate)
           :map god-mode-isearch-map ("<escape>" . god-mode-isearch-disable))

    :demand t
    
    :init
    (define-key key-translation-map (kbd "<backtab>") (kbd "TAB"))
    (define-key key-translation-map (kbd "<S-iso-lefttab>") (kbd "TAB"))
    (define-key input-decode-map (kbd "<tab>") (kbd "<escape>"))
    (define-key input-decode-map (kbd "C-i") (kbd "<escape>"))

    :config
    (god-mode-all)
    (require 'god-mode-isearch)))


(defun x11-clipboard-integration ()
  "Enable the X11 clipboard in Emacs."
  (setq-default x-select-enable-primary t))


(defun bind-easy-line-join ()
  "Set up a quicker keybind J to join a line to the one above."
  (bind-key* "C-J" 'delete-indentation))


(defun unbind-easy-suspend ()
  "Reduce frustration by disabling the z binding for suspending Emacs."
  (unbind-key "C-z"))


(defun backspace-kills-words ()
  "Make backspace delete entire full words for efficiency."

  (defun kill-word (arg)
    "Do what I mean and don't kill the word if there is whitespace to kill..."
    (interactive "P")
    (kill-region (point) (progn (forward-same-syntax arg) (point))))

  (bind-key* "DEL" 'backward-kill-word)
  (eval-after-load "paredit" #'(bind-key* "DEL" 'paredit-backward-kill-word)))





(dolist (config *ENABLED*)
  (funcall config))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "beige" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 135 :width normal :foundry "nil" :family "Luxi Mono"))))
 '(fic-face ((t (:foreground "red"))))
 '(font-lock-builtin-face ((t nil)))
 '(font-lock-comment-face ((t (:foreground "dim gray"))))
 '(font-lock-constant-face ((t nil)))
 '(font-lock-function-name-face ((t nil)))
 '(font-lock-keyword-face ((t (:foreground "dark orange"))))
 '(font-lock-string-face ((t (:foreground "OliveDrab3"))))
 '(font-lock-type-face ((t (:foreground "dodger blue"))))
 '(font-lock-variable-name-face ((t nil)))
 '(fringe ((t (:background "black" :foreground "grey11"))))
 '(helm-buffer-file ((t (:foreground "dim grey"))))
 '(helm-candidate-number ((t (:foreground "dim grey"))))
 '(helm-ff-file ((t (:foreground "dim grey"))))
 '(helm-match ((t (:foreground "dodger blue"))))
 '(helm-selection ((t (:foreground "dark orange"))))
 '(helm-source-header ((t (:background "grey11" :foreground "white" :weight bold))))
 '(highlight ((t (:background "grey11"))))
 '(hl-line ((t (:background "grey11"))))
 '(ledger-font-payee-pending-face ((t (:foreground "olive drab" :weight normal))))
 '(ledger-font-payee-uncleared-face ((t (:foreground "dim grey"))))
 '(ledger-font-pending-face ((t (:foreground "olivedrab3" :weight normal))))
 '(ledger-font-posting-account-face ((t (:foreground "olivedrab3"))))
 '(ledger-font-posting-amount-face ((t (:foreground "dark orange"))))
 '(ledger-font-posting-date-face ((t (:foreground "dodger blue"))))
 '(linum ((t (:background "grey11" :foreground "dim grey"))))
 '(message-header-cc ((t (:foreground "dim grey"))))
 '(message-header-name ((t (:foreground "dim gray"))))
 '(message-header-other ((t (:foreground "dim grey"))))
 '(message-header-subject ((t (:foreground "default" :weight bold))))
 '(message-header-to ((t (:foreground "dim grey"))))
 '(message-mml ((t (:foreground "dim grey"))))
 '(mode-line ((t (:background "gray11" :foreground "dim gray"))))
 '(mode-line-inactive ((t (:inherit mode-line :background "black" :foreground "dim grey"))))
 '(notmuch-message-summary-face ((t (:foreground "dim grey"))))
 '(notmuch-search-count ((t (:foreground "dim gray"))))
 '(notmuch-search-date ((t (:foreground "dim gray"))))
 '(notmuch-search-matching-authors ((t (:foreground "dark orange"))))
 '(notmuch-search-non-matching-authors ((t (:foreground "dark orange"))))
 '(notmuch-tag-face ((t (:foreground "dodger blue"))))
 '(notmuch-tree-match-author-face ((t (:foreground "dim gray"))))
 '(notmuch-tree-match-date-face ((t (:foreground "dim gray"))) t)
 '(notmuch-tree-match-tag-face ((t (:foreground "dodger blue"))))
 '(notmuch-tree-no-match-author-face ((t (:foreground "dim gray"))) t)
 '(notmuch-tree-no-match-date-face ((t (:foreground "dim gray"))) t)
 '(notmuch-tree-no-match-face ((t nil)))
 '(notmuch-tree-no-match-tag-face ((t (:foreground "dodger blue"))) t)
 '(notmuch-wash-cited-text ((t (:foreground "olivedrab3"))))
 '(org-level-1 ((t (:foreground "dodger blue" :weight bold))))
 '(org-level-2 ((t (:foreground "light blue"))))
 '(org-level-3 ((t (:foreground "slate blue"))))
 '(org-link ((t (:foreground "OliveDrab3" :underline t))))
 '(org-todo ((t (:foreground "magenta" :weight bold))))
 '(region ((t (:background "beige" :foreground "black"))))
 '(show-paren-match ((t (:background "gray20"))))
 '(show-paren-mismatch ((t (:background "red"))))
 '(widget-field ((t (:background "gray11" :foreground "default")))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(browse-url-browser-function (quote browse-url-generic))
 '(browse-url-generic-program "links")
 '(expand-region-contract-fast-key "n")
 '(message-confirm-send t)
 '(message-hidden-headers
   (quote
    ("^User-Agent:" "^Face:" "^X-Face:" "^X-Draft-From:")))
 '(notmuch-archive-tags (quote ("-inbox" "-unread")))
 '(notmuch-hello-sections
   (quote
    (notmuch-hello-insert-saved-searches notmuch-hello-insert-search notmuch-hello-insert-recent-searches notmuch-hello-insert-alltags notmuch-hello-insert-footer)))
 '(notmuch-poll-script nil)
 '(notmuch-saved-searches
   (quote
    ((:name "inbox" :query "tag:inbox" :key "i")
     (:name "sent" :query "tag:sent" :key "s")
     (:name "all mail" :query "*" :key "a"))))
 '(notmuch-search-line-faces (quote (("unread" :weight bold))))
 '(notmuch-search-oldest-first nil)
 '(notmuch-show-indent-messages-width 1)
 '(org-agenda-files (quote ("/home/kqr/Dropbox/Orgzly/brain.org")))
 '(package-selected-packages
   (quote
    (undo-tree use-package ivy hl-line+ god-mode flycheck fill-column-indicator fic-mode expand-region column-enforce-mode centered-cursor-mode bug-hunter aggressive-indent)))
 '(safe-local-variable-values
   (quote
    ((haskell-process-use-ghci . t)
     (haskell-indent-spaces . 4))))
 '(send-mail-function (quote smtpmail-send-it)))
