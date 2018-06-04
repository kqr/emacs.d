;;; init.el --- Configuration common to all my Emacs installations
;;
;;; Commentary:
;; For this to be fully functional, Emacs 25 is required.
;;
;; Testing I18N: Räksmörgås
;;
;;; Todo:
;; - find a way to list the defines in current buffer? imenu?
;;
;;; Code:
(setq gc-cons-threshold 87654321)

;;; GUI removal
;; Remove a bunch of distracting, unnecessary, silly graphic components We want
;; to do this very early to avoid annoying flickering of menu bars and such.
(when (display-graphic-p)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode -1))
(menu-bar-mode -1)
(blink-cursor-mode -1)

(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(tool-bar-lines . nil))
(add-to-list 'initial-frame-alist '(left-fringe . 40))
(add-to-list 'default-frame-alist '(left-fringe . 40))
(add-to-list 'initial-frame-alist '(right-fringe . 80))
(add-to-list 'default-frame-alist '(right-fringe . 80))

;;; Init file configuration
;; I don't use customize-set-variable as much anymore, but it's probably a
;; good idea to load the custom file anyway...
(setq custom-file "~/.emacs.d/var/custom.el")
(unless (file-exists-p custom-file)
  (unless (file-directory-p (file-name-directory custom-file))
    (make-directory (file-name-directory custom-file)))
  (write-region "" nil custom-file))
(load-file custom-file)

;; Set up the package system
(require 'package)
(mapc (lambda (elt) (push elt package-archives))
      '(("elpa" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.milkbox.net/packages/")
        ("org" . "http://orgmode.org/elpa/")
        ("sunrise" . "http://joseito.republika.pl/sunrise-commander/")))
(package-initialize)

;; Where to put temp files
(setq temporary-file-directory "/tmp/")
(unless (file-directory-p temporary-file-directory)
  (make-directory temporary-file-directory))

;; Avoid littering in working directory and ~/.emacs.d/ by moving
;; temporary/soon to be overwritten files elsewhere
;; Require this as early as possible
(require 'no-littering)
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

(push "~/.emacs.d/etc" load-path)
(push "~/.emacs.d/lib" load-path)
;;(eval-and-compile (push "~/.emacs.d/etc" load-path))

(load "load-path-local.el" 'noerror)

;;; User information and various other basic settings
(setq user-full-name "Christoffer Stjernlöf"
      user-mail-address "a@xkqr.org")

(setq-default inhibit-startup-screen t
              initial-scratch-message ""

              major-mode 'fundamental-mode
              make-backup-files nil
              large-file-warning-threshold 100000000

              ;; Reduces lag, I think
              auto-window-vscroll nil
              scroll-conservatively 101
              line-move-visual nil

              ;; No need to fake typesetting.
              sentence-end-double-space nil

              ;; Hide cursor in inactive windows
              cursor-in-non-selected-windows nil

              ;; Set a column limit at 80 characters
              fill-column 80
              ;; Automatically hard wrap content instead
              auto-fill-function #'do-auto-fill
              ;; Create new lines when moving past end of buffer
              next-line-add-newlines t

              ;; Copy stuff to the X11 primary selection
              select-enable-primary t
              ;; Typing stuff with active region replaces region
              delete-selection-mode 1

              ;; Focus on newly opened help windows
              help-window-select t

              browse-url-browser-function 'browse-url-generic
              browse-url-generic-program "firefox")

;; Let text extend beyond the window width
(setq-default truncate-lines t
              
              ;; Prevent Emacs from mixing tabs and spaces.
              indent-tabs-mode nil)

;; C-z defaults to suspend-frame which behaves weirdly and is never necessary
(define-key global-map (kbd "C-z") nil)

;; Config troubleshooting
(autoload 'bug-hunter-init-file "bug-hunter" nil t)

;; Printing directly from Emacs
(when (require 'ps-print nil :noerror) 
  (add-to-list
   'ps-font-info-database
   '(kqr-mixed-family (fonts (normal . "Helvetica")
                             (bold . "Helvetica-Bold")
                             (italic . "Helvetica-Oblique")
                             (bold-italic . "Helvetica-BoldOblique")
                             (org-verse . "Courier")
                             (fixed-pitch . "Courier"))
                      (size . 10.0)
                      (line-height . 11.56)
                      (space-width . 2.78)
                      (avg-char-width . 5.09243)))
  (setq ps-print-header t
        ps-header-lines 1
        ps-font-family 'kqr-mixed-family
        ps-font-size '(10 . 10)
        ps-line-spacing 0
        ps-paper-type 'a4)
  (setq ps-number-of-columns 1
        ps-left-margin 60
        ps-inter-column 20
        ps-right-margin 70)
  (setq ps-top-margin 20
        ps-header-pad 0
        ps-header-offset 10
        ps-footer-offset 20
        ps-bottom-margin 40)
  (setq ps-print-header-frame t
        ps-print-only-one-header t
        ps-header-font-family 'kqr-mixed-family
        ps-header-title-font-size '(10 . 10)
        ps-header-font-size '(10 . 10)
        ps-header-frame-alist
        '((fore-color . 0.0)
          (back-color . 1.0)
          (shadow-color . 1.0)
          (border-color . 0.0)
          (border-width . 0.4))))

;;; UI
;;;; Typography
;; Fixed width font
(when (display-graphic-p)
  (set-frame-font (font-spec :name "Hack" :size 12) t t)
  (custom-theme-set-faces 'user '(fixed-pitch
                                  ((t :family "Hack" :height 1.0))))  ;; was Luxi Mono
  (custom-theme-set-faces 'user '(variable-pitch
                                  ((t :family "Linux Libertine O" :height 1.2))))
  (add-to-list 'initial-frame-alist '(line-spacing . 1))
  (add-to-list 'default-frame-alist '(line-spacing . 1)))

;; Replace the default line-extends-beyond-window symbol
(set-display-table-slot standard-display-table 0 ?›)

(when (require 'face-remap nil 'noerror)
  ;; Make available smaller changes in text size
  (setq-default text-scale-mode-step 1.05)

  ;; Set fixed-width fonts where needed
  (setq-default buffer-face-mode-face '(:inherit fixed-pitch))
  (add-hook 'calendar-mode-hook #'buffer-face-mode)
  (add-hook 'notmuch-tree-mode-hook #'buffer-face-mode))

;; Replace keywords with Unicode symbols
(global-prettify-symbols-mode +1)
(setq prettify-symbols-unprettify-at-point 'right-edge)
(defun prettify-programming-symbols ()
  "Prettify programming symbols!"
  (interactive)
  (mapc (lambda (pair) (push pair prettify-symbols-alist))
        '(;; Common operators
          ("==" . (?＝ (Bc . Bl) ?＝))  ;; ==
          ("!=" . (?＝ (Bc . Bc) ?/))  ;; =/=
          (">=" . ?≥)
          ("<=" . ?≤)
          ("||" . ?∨)
          ;;          ("or" . ?∨)
          ;;          ("or else" . ?∨)
          ;;          ("&&" . ?∧)
          ;;          ("and" . ?∧)
          ;;          ("and then" . ?∧)
          ;;          ("!" . ?¬)
          ;;          ("not" . ?¬)
          ;; Control structures
          ;;("for" . ?∀)
          ;; Common types
          ;;          ("void" . ?∅)
          ;;          ("bool" . ?𝔹)
          ;;          ("boolean" . ?𝔹)
          ;;          ("Bool" . ?𝔹)
          ;;          ("Boolean" . ?𝔹)
          ;;          ("unsigned" . ?ℕ)
          ;;          ("int" . ?ℤ)
          ;;          ("integer" . ?ℤ)
          ;;          ("Integer" . ?ℤ)
          ;;          ("float" . ?ℝ)
          ;;          ("double" . (?ℝ (Br . Bc) ?ℝ))  ;; RR
          ;;          ("char" . ?Σ)
          ;;          ("Character" . ?Σ)
          ;;          ("string" . (?Σ (tr . cl) ?*))  ;; Σ*
          ;;          ("String" . (?Σ (tr . cl) ?*))
          ;; Greek
          ("alpha" . ?α)
          ("beta" . ?β)
          ("gamma" . ?γ)
          ("Gamma" . ?Γ)
          ("delta" . ?δ)
          ("Delta" . ?Δ)
          ("lambda" . ?λ)
          ("sigma" . ?σ)
          ("Sigma" . ?Σ)
          ("pi" . ?π)
          ("tau" . ?τ)
          ("psi" . ?ψ)
          ("Psi" . ?Ψ)
          ("Phi" . ?Φ))))
(add-hook 'prog-mode-hook 'prettify-programming-symbols)
(add-hook 'ess-mode-hook 'prettify-programming-symbols)

;; Highlight FIXME TODO etc. in comments
(autoload 'fic-mode "fic-mode")
(add-hook 'prog-mode-hook 'fic-mode)
(eval-after-load "fic-mode"
  '(setq-default fic-highlighted-words
                 (split-string "FIXME TODO BUG XXX")))

(when (require 'paren nil 'noerror)
  (show-paren-mode +1)
  (setq-default show-paren-delay 0
                show-paren-when-point-inside-paren t
                show-paren-style 'expression)
  ;; This is in order for region to take priority over show-paren highlighting
  (setq-default show-paren-priority -200))

;;;; Centered cursor and scrolling
(when (require 'centered-cursor-mode nil 'noerror)
  (when (require 'simpler-centered-cursor-mode nil 'noerror)
    (defun switch-to-simple-scc ()
      "If this is a large file, switch to simpler-centered-cursor-mode."
      (when (> (buffer-size) 32000)
        (centered-cursor-mode -1)
        (simpler-centered-cursor-mode +1)))

    (diminish 'simpler-centered-cursor-mode)
    (add-hook 'org-mode-hook #'switch-to-simple-scc))
  
  (diminish 'centered-cursor-mode)
  (global-centered-cursor-mode +1))

;;;; Tooltips
(require 'popup nil 'noerror)

;;;; Prefer opening frames instead of windows in Emacs
(when (require 'frames-only-mode nil 'noerror)
  ;; Trying without frames-only mode for a while
  (frames-only-mode -1)
  ;; A new frame for each LaTeX refresh gets annoying
  (push
   '(".*Org PDF LaTeX Output.*" .
     (display-buffer-no-window . ((allow-no-window . t))))
   display-buffer-alist))

;;; Interaction
;;;; Navigation and fuzzy finding
;; Better buffer browser
(autoload 'ibuffer "ibuffer")
(define-key ctl-x-map (kbd "C-b") #'ibuffer)

;; Sidebar based on dired
(define-key global-map (kbd "<C-tab>") 'dired-sidebar-jump-to-sidebar)
(autoload 'dired-sidebar-toggle-sidebar "dired-sidebar")
(with-eval-after-load "dired-sidebar"
  (setq dired-sidebar-subtree-line-prefix " .")
  (setq dired-sidebar-close-sidebar-on-file-open t))
(when (and
       (display-graphic-p)
       (require 'all-the-icons nil 'noerror)
       (require 'all-the-icons-dired nil 'noerror))
  (all-the-icons-dired-mode)
  (diminish 'all-the-icons-dired-mode))

;; Provide a list of recently opened files
;; bind to C-x C-r because I don't use find-file-read-only too much (though I
;; probably should...)
(when (require 'recentf nil 'noerror)
  (define-key global-map (kbd "C-x C-r") #'counsel-recentf))

;; Smart M-x and fuzzy matching everywhere
(run-with-idle-timer
 6 nil
 (lambda ()
   (require 'smex nil 'noerror)
   (when (require 'ivy nil 'noerror)
     (diminish 'ivy-mode)
     (setq-default ivy-initial-inputs-alist nil)
     (ivy-mode +1)

     (autoload 'counsel-M-x "counsel")
     (define-key global-map (kbd "M-x") #'counsel-M-x))))

;;;;; Org-like outlining of ANY document, not only Org files
(autoload 'outshine-minor-mode "outshine")
(add-hook 'outline-minor-mode-hook #'outshine-hook-function)
(add-hook 'prog-mode-hook #'outline-minor-mode)
(eval-after-load "outshine"
  '(progn
     (define-key outline-minor-mode-map (kbd "M-n")
       #'outshine-narrow-to-subtree)
     (define-key outline-minor-mode-map (kbd "M-h")
       #'widen)
     
     (setq-default outshine-startup-folded-p t)

     ;; Allow narrowing to subtree even when inside subtree
     (advice-add 'outshine-narrow-to-subtree :before
                 (lambda (&rest args) (unless (outline-on-heading-p t)
                                   (outline-previous-visible-heading 1))))))


;;;; God mode
;; Modal editing *is* the greatest. This reduces hand-strain in an Emacs
;; default friendly sort of way. Very cool, actually.
(when (require 'god-mode nil 'noerror)
  (define-key global-map (kbd "<escape>") #'god-local-mode)

  (when (require 'tab-as-escape nil 'noerror)
    (diminish 'tab-as-escape-mode)
    (tab-as-escape-mode +1))
  
  (when (require 'god-mode-isearch nil 'noerror)
    (define-key isearch-mode-map (kbd "<escape>") #'god-mode-isearch-activate)
    (define-key god-mode-isearch-map (kbd "<escape>") #'god-mode-isearch-disable))

  (defun god-exempt-mode-p ()
    "Return non-nil if major-mode is exempt or inherits from exempt mode."
    (or (memq major-mode god-exempt-major-modes)
       (seq-some (lambda (exempt) (god-mode-child-of-p major-mode exempt))
                 god-exempt-major-modes)))

  (setq god-exempt-predicates '(god-exempt-mode-p god-special-mode-p))
  (setq god-exempt-major-modes
        '(org-agenda-mode
          dired-mode
          sr-mode
          eshell-mode
          doc-view-mode
          magit-popup-mode
          calc-mode
          Custom-mode
          notmuch-hello-mode
          notmuch-search-mode
          notmuch-show-mode
          notmuch-tree-mode
          sldb-mode))
  
  (god-mode-all)

  (defun god-mode-update-cursor (&optional _)
    "Make sure the modeline and cursor is updated with god mode state."
    (if (or god-local-mode buffer-read-only) (setq cursor-type 'box)
      (setq cursor-type 'bar))
    (if god-local-mode
        (progn
          (set-face-background 'mode-line "dodger blue")
          (set-face-foreground 'mode-line "dodgerblue4"))
      (set-face-background 'mode-line "antiquewhite2")
      (set-face-foreground'mode-line "antiquewhite4")))

  (add-hook 'god-mode-enabled-hook #'god-mode-update-cursor)
  (add-hook 'god-mode-disabled-hook #'god-mode-update-cursor)
  (add-hook 'read-only-mode-hook #'god-mode-update-cursor)

  ;; I have barely any idea what I'm doing here... I'm just spamming these
  ;; to ensure the modeline is updated timely...
  (add-hook 'after-change-major-mode-hook #'god-mode-update-cursor)
  (add-hook 'window-configuration-change-hook #'god-mode-update-cursor)
  (add-hook 'mode-selection-hook #'god-mode-update-cursor)
  (add-hook 'buffer-selection-hook #'god-mode-update-cursor)
  (add-hook 'find-file-hook #'god-mode-update-cursor)

  (defun god-has-priority ()
    "Try to ensure that god mode keeps priority over other minor modes."
    (unless (and (consp (car minor-mode-map-alist))
               (eq (caar minor-mode-map-alist) 'god-local-mode-map))
      (let ((godkeys (assq 'god-local-mode minor-mode-map-alist)))
        (assq-delete-all 'god-local-mode minor-mode-map-alist)
        (add-to-list 'minor-mode-map-alist godkeys))))
  (add-hook 'god-mode-enabled-hook #'god-has-priority))

;;;; Completion with company mode (hopefully practically intrusion-free)
(run-with-idle-timer
 10 nil
 (lambda ()
   (when (require 'company nil 'noerror)
     (diminish 'company-mode)
     (global-company-mode +1)

     (defun company-complete-common-or-selected ()
       "Insert the common part, or if none, complete using selection."
       (interactive)
       (when (company-manual-begin)
         (if (not (equal company-common company-prefix))
             (company--insert-candidate company-common)
           (company-complete-selection))))
     
     (setq company-frontends '(company-preview-frontend)
           company-idle-delay 0)

     ;; We don't want completion to prevent us from actually navigating the code
     (define-key company-active-map (kbd "<return>") nil)
     (define-key company-active-map (kbd "C-p") nil)
     (define-key company-active-map (kbd "<up>") nil)
     (define-key company-active-map (kbd "C-n") nil)
     (define-key company-active-map (kbd "<down>") nil)
     (define-key company-active-map (kbd "C-<up>") #'company-select-previous)
     (define-key company-active-map (kbd "C-<down>") #'company-select-next)
     (define-key company-active-map (kbd "TAB")
       #'company-complete-common-or-selected))))


;;;; Miscellaneous interaction
;;;;; Export window contents to neat HTML
;; Tried autoloading but that didn't work and I don't have time to troubleshoot
(when (require 'htmlize nil 'noerror)
  (setq htmlize-output-type 'inline-css)
  
  ;; Automatically upload HTML of region-or-buffer to remote
  (defvar htmlize-paste-it-target-directory "/two-wrongs.com:pastes/")
  (defvar htmlize-paste-it-base-url "https://two-wrongs.com/pastes/")

  (defun htmlize-paste-it ()
    "Htmlize region-or-buffer and copy to directory."
    (interactive)
    (let* ((start (if (region-active-p) (region-beginning) (point-min)))
           (end (if (region-active-p) (region-end) (point-max)))
           (basename (file-name-base (buffer-name)))
           (extension (file-name-extension (buffer-name)))
           (hash (sha1 (current-buffer) start end))
           (file-name (concat basename "-" (substring hash 0 6)
                              "." extension ".html"))
           (new-file (concat htmlize-paste-it-target-directory file-name))
           (access-url (concat htmlize-paste-it-base-url file-name)))
      ;; Region messes with clipboard, so deactivate it
      (deactivate-mark)
      (with-current-buffer (htmlize-region start end)
        ;; Copy htmlized contents to target
        (write-file new-file)
        ;; Ensure target can be accessed by web server
        (chmod new-file #o755))
      ;; Put URL into clipboard
      (kill-new access-url))))

;;;;; Analyse command usage frequency to optimise config
(when (require 'keyfreq nil 'noerror)
  (keyfreq-mode 1)
  (keyfreq-autosave-mode 1))

;;; General editing
;;;; Basic binds
;; This is neat to quickly go back to the previous buffer
(define-key global-map (kbd "C-q") #'kill-this-buffer)
;; But then we also need this...
(define-key global-map (kbd "C-S-q") #'quoted-insert)

;; Make "join this line to the one above" a bit more convenient to perform
(define-key global-map (kbd "C-S-j") #'delete-indentation)

;;;; Autorevert
(when (require 'autorevert nil 'noerror)
  (global-auto-revert-mode 1))

;;;; Undo-tree
(autoload 'undo-tree-undo "undo-tree")
(autoload 'undo-tree-redo "undo-tree")
(autoload 'undo-tree-visualize "undo-tree")
(define-key global-map (kbd "C-/") 'undo-tree-undo)
(define-key global-map (kbd "C-?") 'undo-tree-redo)
(define-key global-map (kbd "C-x u") 'undo-tree-visualize)
(with-eval-after-load "undo-tree"
  (diminish 'undo-tree-mode)
  (global-undo-tree-mode +1)
  (setq-default undo-tree-visualizer-diff t))

;;;; Merge binds
(when (require 'smerge-mode nil 'noerror)
  (defun sm-try-smerge ()
    "Start smerge-mode automatically when a git conflict is detected."
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward "^<<<<<<< " nil t)
        (smerge-mode 1))))
  (add-hook 'find-file-hook 'sm-try-smerge t))

;;;; Visual regexp (on steroids!)
(autoload 'vr/query-replace "visual-regexp")
(autoload 'vr/isearch-forward "visual-regexp")
(autoload 'vr/isearch-backward "visual-regexp")
(define-key global-map (kbd "C-\%") 'vr/query-replace)
(define-key global-map (kbd "C-s") 'vr/isearch-forward)
(define-key global-map (kbd "C-r") 'vr/isearch-backward)
(eval-after-load "visual-regexp"
  '(progn
     (require 'visual-regexp-steroids nil 'noerror)
     (setq-default sr/default-regexp-modifiers '(:I t :M nil :S nil :U nil))))

;;;; Expand-region
(autoload 'er/expand-region "expand-region")
(define-key global-map (kbd "M-SPC") 'er/expand-region)

;;;; Yas-snippet
(setq yas-snippet-dirs '("~/.emacs.d/etc/snippets"))
(when (require 'yasnippet nil 'noerror)
  (setq yas-indent-line 'fixed)
  (yas-global-mode 1))

;;;; Thesaurus/synonyms tooltip
(define-key global-map (kbd "C-@") #'synosaurus-choose-and-replace)
(autoload 'synosaurus "synosaurus-choose-and-replace")
(eval-after-load "synosaurus"
  '(setq-default synosaurus-choose-method 'popup))

;;;; LaTeX preview pane
(require 'tex-site nil :noerror)

(setq-default font-latex-deactivated-keyword-classes
              '("textual" "type-command" "type-declaration"))

(defun configure-latex ()
  "Configure AUCTeX in mode hooks."
  (setq-default TeX-PDF-mode t)
  (setq-default TeX-engine 'xetex)
  (setq-default TeX-auto-save t)
  (require 'latex-preview-pane)
  (latex-preview-pane-mode))

(add-hook 'LaTeX-mode-hook #'configure-latex)

;;; Programming
;;;; Edit by balanced parentheses
;; Trying out smartparens-strict-mode instead of paredit
(run-with-idle-timer
 5 nil
 (lambda ()
   (when (require 'smartparens nil 'noerror)
     (diminish 'smartparens-mode)
     (require 'smartparens-config)
     (smartparens-global-strict-mode)
     (sp-use-smartparens-bindings)
     (sp-local-pair 'ada-mode "'" nil :actions nil)
     (define-key global-map (kbd "M-s") 'sp-split-sexp)
     (define-key global-map (kbd "M-r") 'sp-join-sexp))))

;;;; Indentation/whitespace stuff
(when (require 'aggressive-indent nil 'noerror)
  (diminish 'aggressive-indent-mode)
  (electric-indent-mode -1)
  (global-aggressive-indent-mode +1))

(autoload 'whitespace "whitespace-mode")
(define-key global-map (kbd "C-z") #'whitespace-mode)
(eval-after-load "whitespace"
  '(progn
     (setq-default whitespace-style
		   '(face trailing tabs spaces newline space-mark tab-mark newline-mark))     
     (setq-default whitespace-display-mappings
		   '((space-mark 32 [183] [46])
		     (tab-mark 9 [187 9] [92 9])
		     (newline-mark 10 [182 10])))))

(autoload 'global-flycheck-mode "flycheck")
(add-hook 'prog-mode-hook 'global-flycheck-mode)
(eval-after-load "flycheck"
  '(diminish 'flycheck-mode))

;;;; Project management
(autoload 'projectile-command-map "projectile")
(define-key global-map (kbd "<f8>") 'projectile-command-map)
(with-eval-after-load "projectile"
  (projectile-mode +1)
  (when (require 'counsel-projectile nil 'noerror)
    (counsel-projectile-mode +1))

  (defun load-two-wrongs ()
    (load (concat (projectile-project-root) "two-wrongs.el")))
  
  (add-hook 'projectile-find-file-hook #'load-two-wrongs))

;;;; C and C++ mode
(autoload 'c-mode "cc-mode")
(push '("\\.c\\'" . c-mode) auto-mode-alist)
(push '("\\.h\\'" . c-mode) auto-mode-alist)
(with-eval-after-load "cc-mode"
  (setq-default c-default-style "stroustrup"
                c-basic-offset 4))

;;;; Web mode (multi-modal editing of templates)
(autoload 'web-mode "web-mode"  nil t)
(push '("\\.html\\'" . web-mode) auto-mode-alist)
(push '("\\.css\\'" . web-mode) auto-mode-alist)
(push '("\\.js\\'" . web-mode) auto-mode-alist)
(eval-after-load "web-mode"
  '(progn
     (setq-default web-mode-enable-auto-pairing t
                   web-mode-enable-css-colorization nil
                   web-mode-css-indent-offset 2)

     ;; If we like web-mode, we'll probably like impatient-mode too!
     (require 'impatient-mode nil 'noerror)))

;;;; Ada mode
(autoload 'ada-mode "ada-mode")
(push '("\\.adb\\'" . ada-mode) auto-mode-alist)
(push '("\\.ads\\'" . ada-mode) auto-mode-alist)
(with-eval-after-load "ada-mode"
  (setq-default flycheck-gnat-args "-gnat12")
  (setq ada-language-version 'ada2012)
  (setq ada-skel-initial-string nil))

;;;; Emacs Speaks Statistics, used for R
(autoload 'ess-r-mode "ess-site")
(push '("\\.r\\'" . ess-r-mode) auto-mode-alist)

;;;; SLIME and Lisp stuff
(autoload 'slime "slime")
(autoload 'slime-connected-p "slime")
(add-hook 'lisp-mode-hook
          (lambda () (or (slime-connected-p)
                   (save-excursion (slime)))))
(with-eval-after-load "slime"  
  (setq inferior-lisp-program "/usr/bin/sbcl")
  (setq slime-contribs '(slime-fancy))
  (defun popup-slime-documentation (symbol-name)
    "Popup function- or symbol-documentation for SYMBOL-NAME."
    (interactive (list (slime-read-symbol-name "Documentation for symbol: ")))
    (when (not symbol-name)
      (error "No symbol given"))
    (slime-eval-async `(swank:documentation-symbol ,symbol-name) 'popup-tip)))

;;;; Meghanada (NOT jdee!) for Java development
;; Should automatically install meghanada-server?
(add-hook
 'java-mode-hook
 '(lambda ()
    (require 'meghanada)
    (meghanada-mode +1)
    (setq c-basic-offset 2)
    (add-hook 'before-save-hook 'meghanada-code-beautify-before-save)
    (setq meghanada-java-path "java")
    (setq meghanada-maven-path "mvn")
    (define-key global-map (kbd "C-c C-v C-b") 'meghanada-compile-project)
    (define-key global-map (kbd "C-c C-v C-r") 'meghanada-exec-main)))


;;;; Haskell-mode maybe?
(autoload 'haskell-mode "haskell")
(push '("\\.hs\\'" . haskell-mode) auto-mode-alist)
(push '("\\.lhs\\'" . haskell-mode) auto-mode-alist)


;;; Calculator
(autoload 'calc "calc")
(define-key global-map (kbd "<f12>") 'calc)
(eval-after-load "calc"
  '(progn
     (setq calc-display-trail nil
	   calc-simplify-mode 'units)))

;;; Orthodox file manager
(autoload 'sunrise-cd "sunrise-commander")
(define-key global-map (kbd "<f2>") 'sunrise-cd)
(with-eval-after-load "sunrise-commander"
  (setq sr-show-file-attributes nil))

;;; Git integration
(autoload 'magit-status "magit")
(define-key global-map (kbd "<f3>") 'magit-status)

;;; Organizer, planner, note taking etc.
;; I /think/ these need to be set before Org is required
(setq-default org-export-backends '(org html publish s5 latex rss))
;; Allow longer sections of italics, and italicise mid-word with
;; zero width no break space
(setq-default org-emphasis-regexp-components
	      '("- ﻿\t('\"{"
		"- ﻿\t.,:!?;'\")}\\["
		" \t\r\n"
		"."
		8))


(autoload 'org-mode "org")
(autoload 'org-store-link "org")
(autoload 'org-agenda "org")
(autoload 'org-capture "org")

(defun narrow-or-widen-dwim (p)
  "If the buffer is narrowed, it widens. Otherwise, it narrows
    intelligently.  Intelligently means: region, org-src-block,
    org-subtree, or defun, whichever applies first.  Narrowing to
    org-src-block actually calls `org-edit-src-code'.

    With prefix P, don't widen, just narrow even if buffer is already
    narrowed."
  (interactive "P")
  (declare (interactive-only))
  (cond ((and (buffer-narrowed-p) (not p)) (widen))
        ((and (boundp 'org-src-mode) org-src-mode (not p))
         (org-edit-src-exit))
        ((region-active-p)
         (narrow-to-region (region-beginning) (region-end)))
        ((derived-mode-p 'org-mode)
         (cond ((ignore-errors (org-edit-src-code))
                (delete-other-windows))
               ((org-at-block-p)
                (org-narrow-to-block))
               (t (org-narrow-to-subtree))))
        ((derived-mode-p 'prog-mode)
         (save-excursion
           (cond ((or (outline-on-heading-p) (outline-previous-heading))
                  (outshine-narrow-to-subtree))
                 (t (narrow-to-defun)))))
        (t (error "Please select a region to narrow to"))))

(defun capture-general-inbox (args)
  "Run inbox capture with ARGS."
  (interactive "P")
  (org-capture args "i"))

(defun capture-mail-inbox (args)
  "Run mail capture with ARGS."
  (interactive "P")
  (org-capture args "m")) 

(define-prefix-command 'kqr-org-prefix)
(define-key 'kqr-org-prefix (kbd "l") #'org-store-link)
(define-key 'kqr-org-prefix (kbd "RET") #'narrow-or-widen-dwim)
(define-key 'kqr-org-prefix (kbd "a") #'org-agenda)
(define-key 'kqr-org-prefix (kbd "i") #'capture-general-inbox)
(define-key 'kqr-org-prefix (kbd "m") #'capture-mail-inbox)

;; This must happen last, when we have defined all keys in the prefix map
(define-key global-map (kbd "<f4>") 'kqr-org-prefix)

(with-eval-after-load "org"
  (require 'org-notmuch nil 'noerror)
  (when (require 'calendar nil 'noerror)
    (setq-default calendar-date-style 'iso))

;;;; Regular Org operation   
  (setq org-return-follows-link t
        org-list-allow-alphabetical t
        org-hide-emphasis-markers t
        org-fontify-quote-and-verse-blocks t
        org-ellipsis "↴"
        org-show-context-detail
        '((agenda . ancestors)
          (bookmark-jump . lineage)
          (isearch . lineage)
          (default . ancestors)))  

  ;; TODO: Set faces for org-level-1 (1.618) and org-level-2 (1.618Q?)
  (when (require 'org-bullets nil 'noerror)
    (setq org-bullets-bullet-list '("⊛")))
  
  (org-set-emph-re 'org-emphasis-regexp-components
                   org-emphasis-regexp-components)
  
;;;; Using Org as a planner
  (setq org-todo-keywords
        '((sequence "HOLD(h)" "WAIT(w)" "TODO(t)" "|")
          (sequence "|" "DONE(d)")
          (sequence "|" "CANCELED(c)"))

        org-todo-keyword-faces
        '(("HOLD" . (:foreground "dodger blue" :weight bold))
          ("WAIT" . (:foreground "black" :weight bold))
          ("TODO" . (:foreground "dark orange" :weight bold))
          ("DONE" . (:foreground "olivedrab3" :weight bold))
          ("CANCELED" . (:foreground "dim grey" :weight bold)))

        ;; Normally we'd want tasks to reset to HOLD, but since this is a
        ;; repeated task it also has a new scheduled date so it's okay if it
        ;; becomes a todo because it won't clutter until scheduled anyway!
        org-todo-repeat-to-state "TODO"
        
        org-enforce-todo-dependencies t
        org-hierarchical-todo-statistics nil

        ;; When closing an item, ask for a note – just in case there's an
        ;; important thought there that may otherwise not get recorded
        org-log-done 'note
        ;; Don't ask for a log message if cycling through with shift-arrow keys
        org-treat-S-cursor-todo-selection-as-state-change nil

        ;; Let's simplify this...
        ;; A = screamingly important
        ;; B = normal day-to-day "you should do this or bad things will happen"
        ;; C = fine if rescheduled
        org-lowest-priority ?C
        org-default-priority ?B)

;;;;; Capturing, refiling and archiving
  (setq org-capture-templates
        '(("i" ">inbox" entry (file "") "* %?\n")
          ("m" "mail>inbox" entry (file "") "* %?\n%a\n"))
        org-default-notes-file "~/org/inbox.org"
        org-refile-targets
        '(("~/org/projects.org" :maxlevel . 3)
          ("~/org/tickler.org" :maxlevel . 1)
          ("~/org/someday.org" :maxlevel . 3)
          ("~/org/notes.org" :maxlevel . 2))
        org-refile-allow-creating-parent-nodes 'confirm
        org-refile-use-outline-path t
        org-outline-path-complete-in-steps nil
        org-log-refile 'time
        org-reverse-note-order t
        org-archive-location "~/org/archive.org::* %s")

;;;;; Agenda
  (setq org-agenda-files '("/home/kqr/org/inbox.org" "/home/kqr/org/projects.org" "/home/kqr/org/tickler.org")
        org-agenda-dim-blocked-tasks 'invisible
        org-agenda-span 'day
        org-agenda-use-time-grid nil
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t)

  (defun skip-living-projects ()
    "Skip top level trees that do have a TODO or WAIT child item"
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
          (case-fold-search nil))
      (and (re-search-forward "TODO\\|WAIT" subtree-end t)
           subtree-end)))

  (setq org-agenda-custom-commands
        '((" " "Agenda"
           ((tags "FILE={inbox.org}"
                  ((org-agenda-overriding-header "Inbox")))
            (agenda "" nil)
            (tags "-@out/TODO"
                  ((org-agenda-overriding-header "To do (not scheduled)")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'scheduled))))
            (todo "WAIT"
                  ((org-agenda-overriding-header "Waiting")
                   (org-agenda-todo-ignore-scheduled t)))
            (tags "FILE={projects.org}+LEVEL=1-noproject"
                  ((org-agenda-overriding-header "Stuck projects")
                   (org-agenda-skip-function #'skip-living-projects)))))))

;;;; Using Org to publish documents
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((emacs-lisp . t)
                                 (R . t)
                                 (python . t)
                                 (lisp . t)))
  
  (setq org-babel-python-command "python3"
        org-export-with-smart-quotes t
        org-export-with-emphasize t
        org-export-with-sub-superscripts nil
        org-export-with-footnotes t)
  
  (when (require 'ox-latex nil 'noerror)
    (push (append '(("tufte-handout"
                     "\\documentclass[a4paper,11pt]{tufte-handout}"
                     ("\\section{%s}" . "\\section*{%s}")
                     ("\\subsection{%s}" . "\\subsection*{%s}"))
                    ("tufte-book"
                     "\\documentclass[a4paper,10pt]{tufte-book}")))
          org-latex-classes)
    (setq org-latex-compiler "xelatex"
          org-latex-default-class "tufte-handout"
          org-latex-packages-alist
          ;; These depend on xelatex, so be careful with that!
          `(("" "fontspec" t)
            "\\setmainfont[Ligatures=TeX,Numbers=OldStyle]{Whitman}"
            ("AUTO" "polyglossia" t)
            ("" "pdflscape" t)
            ("" "pseudo-ewd" t)
            ;; tufte-handout xelatex shim
            ,(concat
              "\\ifxetex\n"
              "  \\newcommand{\\textls}[2][5]{%\n"
              "    \\begingroup\\addfontfeatures{LetterSpace=#1}#2\\endgroup\n"
              "  }\n"
              "  \\renewcommand{\\allcapsspacing}[1]{\\textls[15]{#1}}\n"
              "  \\renewcommand{\\smallcapsspacing}[1]{\\textls[0]{#1}}\n"
              "  \\renewcommand{\\allcaps}[1]{\\textls[15]{\\MakeTextUppercase{#1}}}\n"
              " \\renewcommand{\\smallcaps}[1]{\\smallcapsspacing{\\scshape\\MakeTextLowercase{#1}}}\n"
              " \\renewcommand{\\textsc}[1]{\\smallcapsspacing{\\textsmallcaps{#1}}}\n"
              "\\fi\n")))))


;;; Email client
(when (require 'notmuch nil 'noerror)
  (define-key global-map (kbd "<f5>") 'notmuch)

  (defun notmuch-toggle-deleted-tag (&optional beg end)
    (interactive (notmuch-search-interactive-region))
    (if (member "deleted" (notmuch-search-get-tags))
        (notmuch-search-tag (list "-deleted") beg end)
      (notmuch-search-tag (list "+deleted") beg end)))
  (define-key notmuch-search-mode-map "k" #'notmuch-toggle-deleted-tag)

  (setq notmuch-search-line-faces '(("unread" :weight bold))
        notmuch-show-indent-messages-width 4
        notmuch-search-oldest-first nil
        notmuch-archive-tags '("-inbox" "-unread")
        notmuch-poll-script nil)

  (labels ((ebrela (gh hu us st tg)
                   (concat us (cons ?\100 nil)
                           hu (list ?\x2e)
                           tg)))
    (let ((a (ebrela "word" "xkqr" "a" "fz" "org"))
          (k (ebrela "spam" "rdw" "k" "protection" "se"))
          (s (ebrela "i" "kth" "stjernl" "hope" "se")))
      (setq notmuch-fcc-dirs
            (list (cons a (concat a "/Sent"))
                  (cons k (concat k "/Sent"))
                  (cons s (concat s "/Sent")) 
                  (cons ".*" "sent")))))
  
  (setq notmuch-hello-sections
        '(notmuch-hello-insert-saved-searches
          notmuch-hello-insert-search
          notmuch-hello-insert-recent-searches
          notmuch-hello-insert-alltags
          notmuch-hello-insert-footer))

  (setq notmuch-saved-searches
        '((:name "inbox" :query "tag:inbox" :key "i")
          (:name "unread" :query "tag:unread OR (tag:spam AND tag:unread)" :key "u")
          (:name "spam" :query "tag:spam" :key "m")
          (:name "sent" :query "tag:sent" :key "s")
          (:name "all mail" :query "*" :key "a")))

  ;;;;;; Message mode for composing emails
  (setq message-cite-function 'message-cite-original-without-signature
        message-citation-line-function 'message-insert-formatted-citation-line
        message-cite-reply-position 'traditional
        message-yank-prefix "> "
        message-yank-cited-prefix ">"
        message-yank-empty-prefix ">"
        message-citation-line-format "%N (%n) %Y-%m-%d:"
        message-auto-save-directory "~/mail/drafts"
        message-default-mail-headers "Cc: \nBcc: \n"
        message-kill-buffer-on-exit t
        message-sendmail-envelope-from 'header
        message-send-mail-function 'message-send-mail-with-sendmail
        message-confirm-send t
        mail-specify-envelope-from t
        send-mail-function 'smtpmail-send-it)
  (setq message-hidden-headers
        '("^User-Agent:" "^Face:" "^X-Face:" "^X-Draft-From"))

  (defun message-split-quote ()
    (interactive)
    (save-excursion
      (message-beginning-of-line)
      (when (equal (following-char) ?>)
        (re-search-backward "^[^>]")
        (let ((from (point))
              (to (progn (end-of-visual-line) (point))))
          (copy-region-as-kill from to))))
    (insert "\n\n")
    (yank)
    (insert "\n> "))
  (define-key message-mode-map (kbd "C-M-s") 'message-split-quote)
  
  ;; Always sign outgoing messages
  (add-hook 'message-setup-hook 'mml-secure-sign-pgpmime)

  ;;;;;; Sendmail integration
  (when (require 'sendmail nil 'noerror)
    (setq mail-envelope-from 'header
          sendmail-program "/usr/bin/msmtp")))



;;; Theming
;; Location of my themes
(setq custom-theme-directory "~/.emacs.d/etc/theme/")

;; Diminish a bunch of modes according to the theme
;; We do tihs here because apparently requiring modes
;; will override it otherwise

;; We like our theme
(setq frame-background-mode 'light)
(load-theme 'modern-minik t)
(modern-minik-set-icons)

(load "init-local.el" 'noerror)

(provide 'init)
;;; init.el ends here
