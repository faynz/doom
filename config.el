(setq display-line-numbers-type nil)

;; Theme
;(setq doom-theme 'doom-outrun-electric)
(setq doom-theme 'doom-dracula)
(setq doom-font (font-spec :family "Monego" :size 16)
      doom-variable-pitch-font (font-spec :family "Monego" :size 16)
      doom-big-font (font-spec :family "Monego" :size 18))

(add-to-list 'default-frame-alist
             '(font . "Monego-10"))
(set-fontset-font "fontset-default" '(#xf000 . #xf23a) "all-the-icons")

(setq-default header-line-format " ")
(set-fringe-mode 25)
(setq-default left-fringe-width  25)
(setq-default right-fringe-width 25)

(setq doom-themes-enable-bold t
      doom-themes-enable-italic nil)

(after! doom-modeline
  (set-face-attribute 'mode-line nil :box nil)
  (set-face-attribute 'mode-line-inactive nil :box nil))

(custom-set-faces!
  ;'(default :background "#000000" :foreground "#ffffff")
  '(default :foreground "#ffffff")
  '(ivy-minibuffer-match-face-1 :background "#ff79c6" :foreground "#000000")
  '(ivy-minibuffer-match-face-2 :background "#ff79c6" :foreground "#000000")
  '(ivy-minibuffer-match-face-3 :background "#ff79c6" :foreground "#000000")
  '(ivy-minibuffer-match-face-4 :background "#ff79c6" :foreground "#000000")
  '(mode-line :background nil)
  '(header-line :background nil)
  '(magit-header-line :background nil :box nil)
  '(match :background nil)
  '(org-block-begin-line :background nil)
  '(org-block :background nil)
  '(org-block-end-line :background nil)
  '(whitespace-tab :background nil)
  '(whitespace-space :background nil)
  '(solaire-mode-line-face :background nil)
  '(solaire-mode-line-inactive-face :background nil)
  '(mode-line-inactive :background nil)
  '(ivy-virtual :foreground "#444444" :italic nil)
  '(ivy-current-match :background "#ff79c6" :foreground "#000000" :inherit bold)
  '(font-lock-comment-face :foreground "#444444")
  '(font-lock-variable-name-face :foreground "#ffb86c")
  '(hl-line :background "#171717")
  '(region :background "#355461")
  )

(setq-local MODELINE '(getenv "MODELINE"))
(after! doom-modeline
  (doom-modeline-def-modeline 'main
    '(bar window-number matches buffer-info remote-host buffer-position selection-info)
    '(objed-state misc-info persp-name irc mu4e github debug input-method buffer-encoding lsp major-mode process vcs checker "  ")))

(setq window-divider-default-bottom-width 0)

(after! git-gutter-fringe
  (fringe-helper-define 'git-gutter-fr:deleted nil
    "........"
    "..XXXX.."
    "..XXXX.."
    "..XXXX.."
    "..XXXX.."
    "..XXXX.."
    "..XXXX.."
    "........")
  (define-fringe-bitmap 'git-gutter-fr:deleted [224]
      nil nil '(center repeated)))

;; evil
(setq evil-insert-state-map (make-sparse-keymap))
(define-key evil-insert-state-map (kbd "<escape>") 'evil-normal-state)

;; counsel-projectile
(after! counsel-projectile
  (ivy-set-display-transformer
   'counsel-projectile-find-file
   'counsel-projectile-find-file-transformer))

;; lsp/flycheck
(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024))

(setq lsp-disabled-clients '(angular-ls))

(after! lsp-clangd
  (set-lsp-priority! 'clangd 1))  ; ccls has priority 0

(add-hook 'lsp-mode-hook (lambda ()
                           (setq header-line-format nil)
                           (lsp-headerline-breadcrumb-mode)))

(defvar-local my/flycheck-local-cache nil)

(add-hook 'lsp-managed-mode-hook
          (lambda ()
            (when (derived-mode-p 'python-mode)
              (setq my/flycheck-local-cache '((lsp . ((next-checkers . (python-pylint)))))))))


(defun my/flycheck-checker-get (fn checker property)
  (or (alist-get property (alist-get checker my/flycheck-local-cache))
      (funcall fn checker property)))

(advice-add 'flycheck-checker-get :around 'my/flycheck-checker-get)

(add-hook 'lsp-managed-mode-hook
          (lambda ()
            (when (or (derived-mode-p 'typescript-mode)
                      (string-equal "tsx" (file-name-extension buffer-file-name)))
              (setq my/flycheck-local-cache '((lsp . ((next-checkers . (typescript-tslint)))))))))

(add-hook 'lsp-managed-mode-hook
          (lambda ()
            (when (derived-mode-p 'js-mode)
              (setq my/flycheck-local-cache '((lsp . ((next-checkers . (javascript-eslint)))))))))

(map! :leader "[" #'flycheck-previous-error)

(map! :leader "]" #'flycheck-next-error)

;; dap-mode
(after! dap-mode
  (require 'dap-gdb-lldb)
  (dap-gdb-lldb-setup)
  (setq dap-output-buffer-filter '("stdout"))
  (map! :leader "d d" #'dap-debug)
  (map! :leader "d b" #'dap-breakpoint-toggle)
  (map! :leader "d h" #'dap-hydra))

;; company
(after! company
  (setq company-idle-delay 0.01)
  (define-key company-mode-map (kbd "H-SPC") 'company-complete)
  (define-key company-active-map (kbd "<backtab>") 'counsel-company))

;; js-react-redux-yasnippets
(after! js-react-redux-yasnippets
  (setq js-react-redux-yasnippets-want-semicolon t))

;; treemacs
(setq treemacs-is-never-other-window nil)
;; lsp-treemacs
(map! :leader "o s" #'lsp-treemacs-symbols)

;; smartparens
(after! smartparens
  (define-key smartparens-mode-map (kbd "M-<backspace>") 'sp-backward-unwrap-sexp))

;; multiple-cursors
(use-package! multiple-cursors
  :bind
  (("C-."  . 'mc/mark-next-like-this)
   ("C-,"  . 'mc/mark-previous-like-this)
   ("C-\"" . 'mc/mark-all-like-this)

   :map mc/keymap
   ("C->"     . 'mc/skip-to-next-like-this)
   ("C-<"     . 'mc/skip-to-previous-like-this)
   ("C-x C-." . 'mc/unmark-next-like-this)
   ("C-x C-," . 'mc/unmark-previous-like-this)
   ("C-x C-:" . 'mc/mark-pop)
   ("M-["     . 'mc/insert-numbers)
   ("M-]"     . 'mc/insert-letters)
   ("C-a"     . 'mc/vertical-align-with-space)))

;; buffermove
(use-package! buffer-move
  :bind (("H-K" . buf-move-up)
         ("H-J" . buf-move-down)
         ("H-H" . buf-move-left)
         ("H-L" . buf-move-right)))

;; dired
(after! dired-x
  (defun dired-open-in-external-app ()
    "Open the file(s) at point with an external application."
    (interactive)
    (let ((file-list (dired-get-marked-files)))
      (mapc
       (lambda (file-path)
         (let ((process-connection-type nil))
           (start-process "" nil "gio" "open" file-path)))
       file-list)))

  (define-key dired-mode-map (kbd "M-o")
    (lambda () (interactive) (dired-open-in-external-app))))

(add-hook 'dired-mode-hook
          (lambda ()
            (dired-hide-details-mode)))

;; window-rules
(defvar parameters
  '(window-parameters . ((no-delete-other-windows . t))))

(setq
 display-buffer-alist
 `(("\\*Buffer List\\*" display-buffer-in-side-window
    (side . bottom) (slot . 0) (window-height . fit-window-to-buffer)
    (preserve-size . (nil . t)) ,parameters)
   ("\\*Tags List\\*" display-buffer-in-side-window
    (side . right) (slot . 0) (window-width . fit-window-to-buffer)
    (preserve-size . (t . nil)) ,parameters)
   ("^magit:" display-buffer-in-side-window
    (side . left) (slot . 3) (window-width . 0.2)
    (preserve-size . (t . nil)) ,parameters)
   ("\\*\\(?:help\\|grep\\|Completions\\)\\*\\|^*compilation"
    (display-buffer-reuse-window display-buffer-in-side-window)
    (side . top) (slot . -1) (preserve-size . (nil . t)) (window-height . 0.15)
    ,parameters)
   ("\\*\\(?:shell\\|vterm\\)\\*"
    (display-buffer-reuse-window display-buffer-in-side-window)
    (side . top) (slot . 1) (preserve-size . (nil . t)) (window-height . 0.15)
    ,parameters)))

(map! :leader "w x" #'window-toggle-side-windows)

;; vterm
(defun projectile-vterm ()
  (interactive)
  (if (projectile-project-p)
      (let* ((project (projectile-project-root)))
        (unless (require 'vterm nil 'noerror)
          (error "Package 'vterm' is not available"))
        (projectile-with-default-dir project
          (vterm "*vterm*")
          (vterm-send-string "cd .")
          (vterm-send-return)))
    (unless (require 'vterm nil 'noerror)
      (error "Package 'vterm' is not available"))
    (vterm "*vterm*")
    (vterm-send-string "cd .")
    (vterm-send-return)))

(map! "M-V" #'projectile-vterm)

(setq vterm-buffer-name-string "*vterm %s*")

;; Set zsh as default shell in vterm
(cl-loop for file in '("/usr/local/bin/zsh" "/bin/zsh")
   when (file-exists-p file)
     do (progn
      (setq shell-file-name file)
      (cl-return)))
  (setenv "SHELL" shell-file-name)

;; org
(after! org
  (map! :map org-mode-map :n "g k" #'org-up-element)
  (map! :map org-mode-map :n "g j" #'org-down-element)
  (map! :map org-mode-map :leader "j s" 'jupyter-org-insert-src-block)
  (map! :map org-mode-map :leader "j c" 'jupyter-org-clone-block)

  (add-to-list 'org-latex-packages-alist '("" "minted"))
  (setq org-latex-toc-command "\\tableofcontents \\clearpage")
  (setq org-latex-listings 'minted)
  (setq org-latex-minted-options
        '(("breaklines" "true")
          ("breakanywhere" "true")
          ("linenos" "true")
          ("gobble" "-8")
          ("xleftmargin" "20pt")
          ("bgcolor" "borlandbg")))

  (setq org-latex-pdf-process
        '("xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"
          "xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"
          "xelatex -shell-escape -interaction nonstopmode -output-directory %o %f"))

  (setq org-src-fontify-natively t))

(use-package! org-bullets
  :ensure t
  :config
  (setq org-bullets-face-name (quote org-bullet-face))

  ;; define keyword sequences (last items of a sequence or after "|" are marked as org-done)
  (setq org-todo-keywords
      '(
        (sequence "TODO(t)" "INPROGRESS(p)" "CANCELED(c)" "WAITING(w)" "VERIFY(v)" "STOPPED(s)" "|" "DONE(d)")
        (sequence "[]( )" "[?](?)" "[-](-)" "|" "[X](X)")
        (sequence "YES(y)" "NO(n)" "MAYBE(m)")
        (sequence "PARTNER1(1)" "PARTNER2(2)" "PARTNER3(3)" "PARTNER4(4)" "PARTNER5(5)" "|" "COMPLETED(x)")
        ))

  ;; define keyword color
  (setq org-todo-keyword-faces
      '(
        ("TODO" . (:foreground "gold" :underline t :slant italic))
        ("INPROGRESS" . (:foreground "SpringGreen3" :underline t :slant italic))
        ("CANCELED" . (:foreground "DarkOrchid2" :underline t :slant italic))
        ("WAITING" . (:foreground "chocolate2" :underline t :slant italic))
        ("VERIFY" . (:foreground "turquoise3" :underline t :slant italic))
        ("STOPPED" . (:foreground "VioletRed2" :underline t :slant italic))
        ("DONE" . (:foreground "gray48" :underline t :slant italic))
        ("[]" . "DeepPink4")
        ("[?]" . "DeepPink4")
        ("[-]" . "DeepPink4")
        ("YES" . "green1")
        ("NO" . "firebrick2")
        ("PARTNER1" . "firebrick2")
        ("PARTNER2" . "DeepSkyBlue3")
        ("PARTNER3" . "SpringGreen2")
        ("PARTNER4" . "chocolate2")
        ("PARTNER5" . "DarkOrchid2")
        ("COMPLETED" . "gray48")
        ))

  ;; define bullet shape
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (setq org-bullets-bullet-list '("???" "???" "???" "???" "???" "???" "???" "???" "???" "???"))
  )

;; custom binds
(global-set-key (kbd "H-!") (lambda()
                              (interactive)
                              (display-buffer-in-side-window (get-buffer (buffer-name)) '((side . top) (slot . -1) (window-height . 0.15)))))
(global-set-key (kbd "H-@") (lambda()
                              (interactive)
                              (display-buffer-in-side-window (get-buffer (buffer-name)) '((side . top) (slot . 1) (window-height . 0.15)))))
(global-set-key (kbd "H-#") (lambda()
                              (interactive)
                              (display-buffer-in-side-window (get-buffer (buffer-name)) '((side . right) (slot . 1) (window-width . 0.35)))))

(defun open-nautilus ()
  (interactive)
  (call-process "nautilus" nil 0 nil "."))

(map! "C-c C-n" #'open-nautilus)

(map! :i
      "C-?" #'undo-fu-only-redo)

(map! :i
      "C-M-/" #'undo-fu-only-redo-all)

(global-set-key (kbd "H-d") (lambda ()
                              (interactive)
                              (scroll-up 4)
                              (setq this-command 'next-line)
                              (forward-line 4)))
(global-set-key (kbd "H-u") (lambda ()
                              (interactive)
                              (scroll-down 4)
                              (setq this-command 'previous-line)
                              (forward-line -4)))

(defun switch-to-previous-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer)))
(global-set-key (kbd "H-<tab>") 'switch-to-previous-buffer)

(defun my-ivy-read (prompt)
  (ivy-read prompt (seq-filter
                    (lambda (x) (and (or (string-match-p "^*compilation" x)
                                         (string-match-p "^*vterm" x)
                                         (string-match-p "^magit:" x))
                                     (not (string-equal (buffer-name) x))))
                    (mapcar #'buffer-name (buffer-list)))))

(defun ivy-compilation-buffers (&optional name)
  "Read desktop with a name."
  (interactive)
  (unless name
    (setq name (my-ivy-read "compilation buffers: ")))
  (switch-to-buffer name))

(global-set-key (kbd "H-x b") 'ivy-compilation-buffers)

(defun my-make-room-for-new-compilation-buffer ()
  "Renames existing *compilation* buffer to something unique so
         that a new compilation job can be run."
  (interactive)
  (let ((cbuf (get-buffer (concat "*compilation*<" (projectile-project-name) ">")))
        (more-cbufs t)
        (n 1)
        (new-cbuf-name ""))
    (when cbuf
      (while more-cbufs
        (setq new-cbuf-name (concat (format "*compilation %d*<" n) compile-command " " (projectile-project-name) ">"))
        (setq n (1+ n))
        (setq more-cbufs (get-buffer new-cbuf-name)))
      (with-current-buffer cbuf
        (rename-buffer new-cbuf-name)))))

(map! :leader "c n" #'my-make-room-for-new-compilation-buffer)

(after! ivy
  ;; (setq company-idle-delay 0.01)
  (define-key ivy-mode-map (kbd "C-k") 'ivy-switch-buffer-kill)
  ;; (ivy-define-key map (kbd "C-k") 'ivy-switch-buffer-kill)
  )

;; remaping

;; windows
(global-set-key (kbd "H-h") 'windmove-left)
(global-set-key (kbd "H-l") 'windmove-right)
(global-set-key (kbd "H-k") 'windmove-up)
(global-set-key (kbd "H-j") 'windmove-down)

(global-set-key (kbd "H-M-h") 'shrink-window-horizontally)
(global-set-key (kbd "H-M-l") 'enlarge-window-horizontally)
(global-set-key (kbd "H-M-k") 'enlarge-window)
(global-set-key (kbd "H-M-j") 'shrink-window)

(global-set-key (kbd "H-/") 'winner-undo)
(global-set-key (kbd "H-?") 'winner-redo)

;; open file externally
(map! :leader "f o" #'counsel-find-file-extern)

;; workspaces
(map! :leader "TAB TAB" #'+workspace/other)
(map! :leader "TAB '" #'+workspace/display)

(global-set-key (kbd "C-c l") 'avy-goto-line)
(global-set-key (kbd "C-c y") 'avy-copy-region)
(global-set-key (kbd "C-c w") 'avy-kill-region)

(defun move-lines (n)
  (let ((beg) (end) (keep))
    (if mark-active
        (save-excursion
          (setq keep t)
          (setq beg (region-beginning)
                end (region-end))
          (goto-char beg)
          (setq beg (line-beginning-position))
          (goto-char end)
          (setq end (line-beginning-position 2)))
      (setq beg (line-beginning-position)
            end (line-beginning-position 2)))
    (let ((offset (if (and (mark t)
                           (and (>= (mark t) beg)
                                (< (mark t) end)))
                      (- (point) (mark t))))
          (rewind (- end (point))))
      (goto-char (if (< n 0) beg end))
      (forward-line n)
      (insert (delete-and-extract-region beg end))
      (backward-char rewind)
      (if offset (set-mark (- (point) offset))))
    (if keep
        (setq mark-active t
              deactivate-mark nil))))

(defun move-lines-up (n)
  "move the line(s) spanned by the active region up by N lines."
  (interactive "*p")
  (move-lines (- (or n 1))))

(defun move-lines-down (n)
  "move the line(s) spanned by the active region down by N lines."
  (interactive "*p")
  (move-lines (or n 1)))

(global-set-key (kbd "H-p") 'move-lines-up)
(global-set-key (kbd "H-n") 'move-lines-down)

(use-package! org-ref
  :after org)

(after! org
  ;; for minted
  (add-to-list 'org-latex-packages-alist '("" "minted"))
  (setq org-latex-toc-command "\\tableofcontents \\clearpage")
  (setq org-latex-listings 'minted)
  (setq org-latex-minted-options
        '(("breaklines" "true")
          ("breakanywhere" "true")
          ("linenos" "true")
          ("gobble" "-8")
          ("xleftmargin" "20pt")
          ("bgcolor" "borlandbg")))

  ;; bibtex for references and citations export
  (setq org-latex-pdf-process '("latexmk -pdflatex=xelatex -shell-escape -pdf %f"))

  (after! ox-latex
    (add-to-list 'org-latex-classes
                 '("extarticle"
                   "\\documentclass{extarticle}"
                   ("\\section{%s}" . "\\section*{%s}")
                   ("\\subsection{%s}" . "\\subsection*{%s}")
                   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                   ("\\paragraph{%s}" . "\\paragraph*{%s}")
                   ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

  (setq org-src-fontify-natively t))
