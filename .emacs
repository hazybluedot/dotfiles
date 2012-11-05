(setq server-use-tcp t)
;;(server-start)
(global-set-key (kbd "C-z") nil)
(setq split-height-threshold 80) (setq split-width-threshold nil)
(defvar my-load-path (expand-file-name "~/.emacs.d/lisp"))
(add-to-list 'load-path my-load-path)
(add-to-list 'load-path "~/.emacs.d/lisp/emacs-color-theme-solarized")
(require 'color-theme-solarized)
(if (window-system) (color-theme-solarized-dark))
(load "gtags")
(load "cmake-mode")
(load "haskell-mode")
;;(load "docbook-xml-mode")

;; Haskell mode
(load "/usr/share/emacs/site-lisp/haskell-mode/haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)

;; Yaml mode
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\.yml\'" . yaml-mode))

(set-default-font "Inconsolata-11")

(global-visual-line-mode 1)
(scroll-bar-mode nil)
(show-paren-mode 1)
;;(global-hl-line-mode 1)
;;(set-face-background 'hl-line "#0F0")
;;(set-face-foreground 'hl-line "#330")

(setq c-default-style "linux"
          c-basic-offset 4)

;; AucTeX
(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)

;;(add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)
;;(setq TeX-auto-save t)
;;(setq TeX-parse-self t)
;;(setq-default TeX-master nil)
;;(setq reftex-plug-into-AUCTeX t)
;;(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
;; )
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
;; '(LaTeX-command "latex -synctex=1")
 '(TeX-PDF-mode t))
;; '(TeX-source-correlate-method (quote synctex))
;; '(TeX-source-correlate-mode t)
;; '(TeX-view-program-list (quote (("Evince-forward" "/usr/local/bin/evince_forward_search %o %(outpage) %s"))))
;; '(TeX-view-program-selection (quote (((output-dvi style-pstricks) "dvips and gv") (output-dvi "xdvi") (output-pdf "Evince-forward") (output-html "xdg-open")))))

;; The following only works with AUCTeX loaded
(require 'tex-site)
(add-hook 'TeX-mode-hook 'turn-on-flyspell)
;;(add-hook 'TeX-mode-hook
;;    (lambda ()
;;       (add-to-list 'TeX-output-view-style
;;            '("^pdf$" "."
;;              "/usr/bin/okular %o %(outpage)")))
;;)

;; Gtags stuff
(defun djcb-gtags-create-or-update ()
  "create or update the gnu global tag file"
  (interactive)
  (if (not (= 0 (call-process "global" nil nil nil " -p"))) ; tagfile doesn't exist?
    (let ((olddir default-directory)
          (topdir (read-directory-name  
                    "gtags: top of source tree:" default-directory)))
      (cd topdir)
      (shell-command "gtags && echo 'created tagfile'")
      (cd olddir)) ; restore   
    ;;  tagfile already exists; update it
    (shell-command "global -u && echo 'updated tagfile'")))

(add-hook 'gtags-mode-hook 
  (lambda()
    (local-set-key (kbd "M-.") 'gtags-find-tag)   ; find a tag, also M-.
    (local-set-key (kbd "M-,") 'gtags-find-rtag)))  ; reverse tag

(add-hook 'c-mode-common-hook
  (lambda ()
    (require 'gtags)
    (gtags-mode t)
    (djcb-gtags-create-or-update)))

(require 'dbus)
(defun th-evince-sync (file linecol time)
  (let ((buf (get-buffer file))
         (line (car linecol))
        (col (cadr linecol)))
     (if (null buf)
         (message "Sorry, %s is not opened..." file)
       (switch-to-buffer buf)
       (goto-line (car linecol))
       (unless (= col -1)
         (move-to-column col)))))

(when (and
       (eq window-system 'x)
       (fboundp 'dbus-register-signal))
  (dbus-register-signal
   :session nil "/org/gnome/evince/Window/0"
   "org.gnome.evince.Window" "SyncSource"
   'th-evince-sync))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; texinputs

;; bibtex
(setenv "BSTINPUTS" 
	".:$HOME/Dropbox/texmf/bibtex/bst/")

(setenv "BIBINPUTS"
	".:$HOME/Dropbox/texmf/bibtex/bib/")

;; Change this to the place where you store all the electronic versions.
    (defvar bibtex-papers-directory "~/Dropbox/papers/")
    ;; Translates a BibTeX key into the base filename of the corresponding
    ;; file. Change to suit your conventions.
    ;; Mine is:
    ;; - author1-author2-author3.conferenceYYYY for the key
    ;; - author1-author2-author3_conferenceYYYY.{ps,pdf} for the file
    (defun bibtex-key->base-filename (key)
      (concat bibtex-papers-directory
              (replace-regexp-in-string "\\." "_" key)))
    ;; Finds the BibTeX key the point is on.
    ;; You might want to change the regexp if you use other strange characters in the keys.
    (defun bibtex-key-at-point ()
      (let ((chars-in-key "A-Z-a-z0-9_:-\\."))
        (save-excursion
          (buffer-substring-no-properties
           (progn (skip-chars-backward chars-in-key) (point))
           (progn (skip-chars-forward chars-in-key) (point))))))
    ;; Opens the appropriate viewer on the electronic version of the paper referenced at point.
    ;; Again, customize to suit your preferences.
    (defun browse-paper-at-point ()
      (interactive)
      (let ((base (bibtex-key->base-filename (bibtex-key-at-point))))
        (cond
         ((file-exists-p (concat base ".pdf"))
          (shell-command (concat "evince " base ".pdf &")))
         ((file-exists-p (concat base ".ps"))
          (shell-command (concat "gv " base ".ps &")))
         (t (message (concat "No electronic version available: " base ".{pdf,ps}"))))))
    (global-set-key [S-f6] 'browse-paper-at-point)

(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(setq auto-mode-alist
   (cons '("\.md" . markdown-mode) auto-mode-alist))

(require 'epa)
;;(require 'color-theme)
;;(require 'color-theme-autoload "color-theme-autoloads")
;;(load "color-theme-sunburst")
;;(color-theme-sunburst)
;;(load-theme 'sunburst)
