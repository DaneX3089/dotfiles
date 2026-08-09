;; fast loading hax
(setq gc-cons-threshold #x40000000)
(setq read-process-output-max (* 1024 1024 4))
(setq native-comp-jit-compilation nil)

(setq package-enable-at-startup nil) ;; Disables the default package manager.


;; set to nil if no wantie nerdie fontie
(defcustom ek-use-nerd-fonts t
  "Configuration for using Nerd Fonts Symbols."
  :type 'boolean
  :group 'appearance)


;; idk m8
(defun ek/lsp-describe-and-jump ()
	"Show hover documentation and jump to *lsp-help* buffer."
	(interactive)
	(lsp-describe-thing-at-point)
	(let ((help-buffer "*lsp-help*"))
		(when (get-buffer help-buffer)
			(switch-to-buffer-other-window help-buffer))))

;; Bootstraps `straight.el'
(setq straight-check-for-modifications nil)
(defvar bootstrap-version)
(let ((bootstrap-file
				(expand-file-name
					"straight/repos/straight.el/bootstrap.el"
					(or (bound-and-true-p straight-base-dir)
							user-emacs-directory)))
			(bootstrap-version 7))
	(unless (file-exists-p bootstrap-file)
		(with-current-buffer
			(url-retrieve-synchronously
				"https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
				'silent 'inhibit-cookies)
			(goto-char (point-max))
			(eval-print-last-sexp)))
	(load bootstrap-file nil 'nomessage))
(straight-use-package '(project :type built-in))
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)


(require 'package)


(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)


(use-package emacs
						 :ensure nil
						 :custom                                         ;; Set custom variables to configure Emacs behavior.
						 (auto-save-default nil)                         ;; Disable automatic saving of buffers.
						 (column-number-mode t)                          ;; Display the column number in the mode line.
						 (create-lockfiles nil)                          ;; Prevent the creation of lock files when editing.
						 (delete-by-moving-to-trash t)                   ;; Move deleted files to the trash instead of permanently deleting them.
						 (delete-selection-mode 1)                       ;; Enable replacing selected text with typed text.
						 (display-line-numbers-type 'relative)           ;; Use relative line numbering in programming modes.
						 (global-auto-revert-non-file-buffers t)         ;; Automatically refresh non-file buffers.
						 (history-length 25)                             ;; Set the length of the command history.
						 (indent-tabs-mode nil)                          ;; Disable the use of tabs for indentation (use spaces instead).
						 (inhibit-startup-message t)                     ;; Disable the startup message when Emacs launches.
						 (initial-scratch-message "")                    ;; Clear the initial message in the *scratch* buffer.
						 (ispell-dictionary "en_US")                     ;; Set the default dictionary for spell checking.
						 (make-backup-files nil)                         ;; Disable creation of backup files.
						 (pixel-scroll-precision-mode t)                 ;; Enable precise pixel scrolling.
						 (pixel-scroll-precision-use-momentum nil)       ;; Disable momentum scrolling for pixel precision.
						 (ring-bell-function 'ignore)                    ;; Disable the audible bell.
						 (split-width-threshold 300)                     ;; Prevent automatic window splitting if the window width exceeds 300 pixels.
						 (switch-to-buffer-obey-display-actions t)       ;; Make buffer switching respect display actions.
						 (tab-always-indent 'complete)                   ;; Make the TAB key complete text instead of just indenting.
						 (tab-width 4)                                   ;; Set the tab width to 4 spaces.
						 (treesit-font-lock-level 4)                     ;; Use advanced font locking for Treesit mode.
						 (truncate-lines t)                              ;; Enable line truncation to avoid wrapping long lines.
						 (use-dialog-box nil)                            ;; Disable dialog boxes in favor of minibuffer prompts.
						 (use-short-answers t)                           ;; Use short answers in prompts for quicker responses (y instead of yes)
						 (warning-minimum-level :emergency)              ;; Set the minimum level of warnings to display.

						 :hook                                           ;; Add hooks to enable specific features in certain modes.
						 (prog-mode . display-line-numbers-mode)         ;; Enable line numbers in programming modes.

						 :config
						 ;; By default emacs gives you access to a lot of *special* buffers, while navigating with [b and ]b,
						 ;; this might be confusing for newcomers. This settings make sure ]b and [b will always load a
						 ;; file buffer. To see all buffers use <leader> SPC, <leader> b l, or <leader> b i.
						 (defun skip-these-buffers (_window buffer _bury-or-kill)
							 "Function for `switch-to-prev-buffer-skip'."
							 (string-match "\\*[^*]+\\*" (buffer-name buffer)))
						 (setq switch-to-prev-buffer-skip 'skip-these-buffers)


						 (set-face-attribute 'default nil :family "JetBrainsMono Nerd Font"  :height 130)

						 ;; Makes Emacs vertical divisor the symbol │ instead of |.
						 (set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

						 :init                        ;; Initialization settings that apply before the package is loaded.
						 (tool-bar-mode -1)           ;; Disable the tool bar for a cleaner interface.
						 (menu-bar-mode -1)           ;; Disable the menu bar for a more streamlined look.

						 (when scroll-bar-mode
							 (scroll-bar-mode -1))      ;; Disable the scroll bar if it is active.

						 (global-hl-line-mode -1)     ;; Disable highlight of the current line
						 (global-auto-revert-mode 1)  ;; Enable global auto-revert mode to keep buffers up to date with their corresponding files.
						 (recentf-mode 1)             ;; Enable tracking of recently opened files.
						 (savehist-mode 1)            ;; Enable saving of command history.
						 (save-place-mode 1)          ;; Enable saving the place in files for easier return.
						 (winner-mode 1)              ;; Enable winner mode to easily undo window configuration changes.
						 (xterm-mouse-mode 1)         ;; Enable mouse support in terminal mode.
						 (file-name-shadow-mode 1)    ;; Enable shadowing of filenames for clarity.

						 ;; Set the default coding system for files to UTF-8.
						 (modify-coding-system-alist 'file "" 'utf-8)

						 ;; Add a hook to run code after Emacs has fully initialized.
						   (add-hook 'after-init-hook
            (lambda ()
              (message "Emacs has fully loaded. This code runs after startup.")

              ;; Insert a welcome message in the *scratch* buffer displaying loading time and activated packages.
              (with-current-buffer (get-buffer-create "*scratch*")
                (insert (format
                         ";;    Welcome to Emacs!
;;
;;    Loading time : %s
;;    Packages     : %s
"
                         (emacs-init-time)
                         (length (hash-table-keys straight--recipe-cache))))))))



;;; DIRED
;; In Emacs, the `dired' package provides a powerful and built-in file manager
;; that allows you to navigate and manipulate files and directories directly
;; within the editor. If you're familiar with `oil.nvim', you'll find that
;; `dired' offers similar functionality natively in Emacs, making file
;; management seamless without needing external plugins.

;; This configuration customizes `dired' to enhance its usability. The settings
;; below specify how file listings are displayed, the target for file operations,
;; and associations for opening various file types with their respective applications.
;; For example, image files will open with `feh', while audio and video files
;; will utilize `mpv'.
(use-package dired
						 :ensure nil                                                ;; This is built-in, no need to fetch it.
						 :straight nil   ;; add this line
						 :custom
						 (dired-listing-switches "-lah --group-directories-first")  ;; Display files in a human-readable format and group directories first.
						 (dired-dwim-target t)                                      ;; Enable "do what I mean" for target directories.
						 (dired-guess-shell-alist-user
							 '(("\\.\\(png\\|jpe?g\\|tiff\\)" "feh" "xdg-open" "open") ;; Open image files with `feh' or the default viewer.
								 ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)" "mpv" "xdg-open" "open") ;; Open audio and video files with `mpv'.
								 (".*" "open" "xdg-open")))                              ;; Default opening command for other files.
						 (dired-kill-when-opening-new-dired-buffer t)               ;; Close the previous buffer when opening a new `dired' instance.
						 :config
						 (when (eq system-type 'darwin)
							 (let ((gls (executable-find "gls")))                     ;; Use GNU ls on macOS if available.
								 (when gls
									 (setq insert-directory-program gls)))))

;;; VERTICO
;; Vertico enhances the completion experience in Emacs by providing a
;; vertical selection interface for both buffer and minibuffer completions.
;; Unlike traditional minibuffer completion, which displays candidates
;; in a horizontal format, Vertico presents candidates in a vertical list,
;; making it easier to browse and select from multiple options.
;;
;; In buffer completion, `switch-to-buffer' allows you to select from open buffers.
;; Vertico streamlines this process by displaying the buffer list in a way that
;; improves visibility and accessibility. This is particularly useful when you
;; have many buffers open, allowing you to quickly find the one you need.
;;
;; In minibuffer completion, such as when entering commands or file paths,
;; Vertico helps by showing a dynamic list of potential completions, making
;; it easier to choose the correct one without typing out the entire string.
(use-package vertico
  :ensure t
  :straight t
  :hook
  (after-init . vertico-mode)           ;; Enable vertico after Emacs has initialized.
  :custom
  (vertico-count 10)                    ;; Number of candidates to display in the completion list.
  (vertico-resize nil)                  ;; Disable resizing of the vertico minibuffer.
  (vertico-cycle nil)                   ;; Do not cycle through candidates when reaching the end of the list.
  :config
  ;; Customize the display of the current candidate in the completion list.
  ;; This will prefix the current candidate with “» ” to make it stand out.
  ;; Reference: https://github.com/minad/vertico/wiki#prefix-current-candidate-with-arrow
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "» " 'face '(:foreground "#80adf0" :weight bold))
                   "  ")
                 cand))))


;;; ORDERLESS
;; Orderless enhances completion in Emacs by allowing flexible pattern matching.
;; It works seamlessly with Vertico, enabling you to use partial strings and
;; regular expressions to find files, buffers, and commands more efficiently.
;; This combination provides a powerful and customizable completion experience.
(use-package orderless
  :ensure t
  :straight t
  :defer t                                    ;; Load Orderless on demand.
  :after vertico                              ;; Ensure Vertico is loaded before Orderless.
  :init
  (setq completion-styles '(orderless basic)  ;; Set the completion styles.
        completion-category-defaults nil      ;; Clear default category settings.
        completion-category-overrides '((file (styles partial-completion))))) ;; Customize file completion styles.




(use-package eldoc
						 :ensure nil                                ;; This is built-in, no need to fetch it.
						 :config
						 (setq eldoc-idle-delay 0)                  ;; Automatically fetch doc help
						 (setq eldoc-echo-area-use-multiline-p nil) ;; We use the "K" floating help instead
						 ;; set to t if you want docs on the echo area
						 (setq eldoc-echo-area-display-truncation-message nil)
						 :init
						 (global-eldoc-mode))


;;; FLYMAKE
;; Flymake is an on-the-fly syntax checking extension that provides real-time feedback
;; about errors and warnings in your code as you write. This can greatly enhance your
;; coding experience by catching issues early. The configuration below activates
;; Flymake mode in programming buffers.
(use-package flymake
						 :ensure nil          ;; This is built-in, no need to fetch it.
						 :defer t
						 :hook (prog-mode . flymake-mode)
						 :custom
						 (flymake-margin-indicators-string
							 '((error "!»" compilation-error) (warning "»" compilation-warning)
																								(note "»" compilation-info))))


;;; ORG-MODE
;; Org-mode is a powerful system for organizing and managing your notes,
;; tasks, and documents in plain text. It offers features like task management,
;; outlining, scheduling, and much more, making it a versatile tool for
;; productivity. The configuration below simply defers loading Org-mode until
;; it's explicitly needed, which can help speed up Emacs startup time.
(use-package org
						 :ensure nil     ;; This is built-in, no need to fetch it.
						 :defer t)       ;; Defer loading Org-mode until it's needed.



;;; TREESITTER-AUTO
;; Treesit-auto simplifies the use of Tree-sitter grammars in Emacs,
;; providing automatic installation and mode association for various
;; programming languages. This enhances syntax highlighting and
;; code parsing capabilities, making it easier to work with modern
;; programming languages.
(use-package treesit-auto
						 :ensure t
						 :straight t
						 :after emacs
						 :custom
						 (treesit-auto-install 'prompt)
						 :config
						 (treesit-auto-add-to-auto-mode-alist 'all)
						 (global-treesit-auto-mode t))



;;; MARGINALIA
;; Marginalia enhances the completion experience in Emacs by adding
;; additional context to the completion candidates. This includes
;; helpful annotations such as documentation and other relevant
;; information, making it easier to choose the right option.
(use-package marginalia
						 :ensure t
						 :straight t
						 :hook
						 (after-init . marginalia-mode))


;;; WHICH-KEY
;; `which-key' is an Emacs package that displays available keybindings in a
;; popup window whenever you partially type a key sequence. This is particularly
;; useful for discovering commands and shortcuts, making it easier to learn
;; Emacs and improve your workflow. It helps users remember key combinations
;; and reduces the cognitive load of memorizing every command.
(use-package which-key
						 :ensure nil     ;; This is built-in, no need to fetch it.
						 :defer t        ;; Defer loading Which-Key until after init.
						 :hook
						 (after-init . which-key-mode)) ;; Enable which-key mode after initialization.

;;; CORFU
;; Corfu Mode provides a text completion framework for Emacs.
;; It enhances the editing experience by offering context-aware
;; suggestions as you type.
;; Corfu Mode is highly customizable and can be integrated with
;; various modes and languages.
(use-package corfu
						 :ensure t
						 :straight t
						 :defer t
						 :custom
						 (corfu-auto t)                        ;; Only completes when hitting TAB
						 ;; (corfu-auto-delay 0)                ;; Delay before popup (enable if corfu-auto is t)
						 (corfu-auto-prefix 1)                  ;; Trigger completion after typing 1 character
						 (corfu-quit-no-match t)                ;; Quit popup if no match
						 (corfu-scroll-margin 5)                ;; Margin when scrolling completions
						 (corfu-max-width 50)                   ;; Maximum width of completion popup
						 (corfu-min-width 50)                   ;; Minimum width of completion popup
						 (corfu-popupinfo-delay 0.5)            ;; Delay before showing documentation popup
						 :config
						 (if ek-use-nerd-fonts
							 (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))
						 :init
						 (global-corfu-mode)
						 (corfu-popupinfo-mode t))


;;; NERD-ICONS-CORFU
;; Provides Nerd Icons to be used with CORFU.
(use-package nerd-icons-corfu
						 :if ek-use-nerd-fonts
						 :ensure t
						 :straight t
						 :defer t
						 :after (:all corfu))


;;; LSP
;; Emacs comes with an integrated LSP client called `eglot', which offers basic LSP functionality.
;; However, `eglot' has limitations, such as not supporting multiple language servers
;; simultaneously within the same buffer (e.g., handling both TypeScript, Tailwind and ESLint
;; LSPs together in a React project). For this reason, the more mature and capable
;; `lsp-mode' is included as a third-party package, providing advanced IDE-like features
;; and better support for multiple language servers and configurations.
;;
;; NOTE: To install or reinstall an LSP server, use `M-x install-server RET`.
;;       As with other editors, LSP configurations can become complex. You may need to
;;       install or reinstall the server for your project due to version management quirks
;;       (e.g., asdf or nvm) or other issues.
;;       Fortunately, `lsp-mode` has a great resource site:
;;       https://emacs-lsp.github.io/lsp-mode/
(use-package lsp-mode
						 :ensure t
						 :straight t
						 :defer t
						 :hook (;; Replace XXX-mode with concrete major mode (e.g. python-mode)
										(lsp-mode . lsp-enable-which-key-integration)  ;; Integrate with Which Key
										((js-mode                                      ;; Enable LSP for JavaScript
											 tsx-ts-mode                                  ;; Enable LSP for TSX
											 typescript-ts-base-mode                      ;; Enable LSP for TypeScript
											 css-mode                                     ;; Enable LSP for CSS
											 go-ts-mode                                   ;; Enable LSP for Go
											 js-ts-mode                                   ;; Enable LSP for JavaScript (TS mode)
                                             prisma-mode                                  ;; Enable LSP for Prisma
											 python-base-mode                             ;; Enable LSP for Python
											 ruby-base-mode                               ;; Enable LSP for Ruby
											 rust-ts-mode                                 ;; Enable LSP for Rust
											 c++-ts-mode
											 cmake-ts-mode
											 web-mode) . lsp-deferred))                   ;; Enable LSP for Web (HTML)
						 :commands lsp
						 :custom
						 (lsp-keymap-prefix "C-c l")                           ;; Set the prefix for LSP commands.
						 (lsp-inlay-hint-enable nil)                           ;; Usage of inlay hints.
						 (lsp-completion-provider :none)                       ;; Disable the default completion provider.
						 (lsp-session-file (locate-user-emacs-file ".lsp-session")) ;; Specify session file location.
						 (lsp-log-io nil)                                      ;; Disable IO logging for speed.
						 (lsp-idle-delay 0.5)                                  ;; Set the delay for LSP to 0 (debouncing).
						 (lsp-keep-workspace-alive nil)                        ;; Disable keeping the workspace alive.
						 ;; Core settings
						 (lsp-enable-xref t)                                   ;; Enable cross-references.
						 (lsp-auto-configure t)                                ;; Automatically configure LSP.
						 (lsp-enable-links nil)                                ;; Disable links.
						 (lsp-eldoc-enable-hover t)                            ;; Enable ElDoc hover.
						 (lsp-enable-file-watchers nil)                        ;; Disable file watchers.
						 (lsp-enable-folding nil)                              ;; Disable folding.
						 (lsp-enable-imenu t)                                  ;; Enable Imenu support.
						 (lsp-enable-indentation nil)                          ;; Disable indentation.
						 (lsp-enable-on-type-formatting nil)                   ;; Disable on-type formatting.
						 (lsp-enable-suggest-server-download t)                ;; Enable server download suggestion.
						 (lsp-enable-symbol-highlighting t)                    ;; Enable symbol highlighting.
						 (lsp-enable-text-document-color t)                    ;; Enable text document color.
						 ;; Modeline settings
						 (lsp-modeline-code-actions-enable nil)                ;; Keep modeline clean.
						 (lsp-modeline-diagnostics-enable nil)                 ;; Use `flymake' instead.
						 (lsp-modeline-workspace-status-enable t)              ;; Display "LSP" in the modeline when enabled.
						 (lsp-signature-doc-lines 1)                           ;; Limit echo area to one line.
						 (lsp-eldoc-render-all t)                              ;; Render all ElDoc messages.
						 ;; Completion settings
						 (lsp-completion-enable t)                             ;; Enable completion.
						 (lsp-completion-enable-additional-text-edit t)        ;; Enable additional text edits for completions.
						 (lsp-enable-snippet nil)                              ;; Disable snippets
						 (lsp-completion-show-kind t)                          ;; Show kind in completions.
						 ;; Lens settings
						 (lsp-lens-enable t)                                   ;; Enable lens support.
						 ;; Headerline settings
						 (lsp-headerline-breadcrumb-enable-symbol-numbers t)   ;; Enable symbol numbers in the headerline.
						 (lsp-headerline-arrow "▶")                            ;; Set arrow for headerline.
						 (lsp-headerline-breadcrumb-enable-diagnostics nil)    ;; Disable diagnostics in headerline.
						 (lsp-headerline-breadcrumb-icons-enable nil)          ;; Disable icons in breadcrumb.
						 ;; Semantic settings
						 (lsp-semantic-tokens-enable nil)
                         )

;;; ELDOC-BOX
;; eldoc-box enhances the default Eldoc experience by displaying documentation in a popup box,
;; usually in a child frame. This makes it easier to read longer docstrings without relying on
;; the minibuffer. It integrates seamlessly with Eldoc and activates when Eldoc is active.
;; Useful for graphical Emacs; terminal users may want to fall back to `eldoc-box-display-at-point-mode'.
(use-package eldoc-box
						 :ensure t
						 :straight t
						 :defer t)


;;; CONSULT
;; Consult provides powerful completion and narrowing commands for Emacs.
;; It integrates well with other completion frameworks like Vertico, enabling
;; features like previews and enhanced register management. It's useful for
;; navigating buffers, files, and xrefs with ease.
(use-package consult
						 :ensure t
						 :straight t
						 :defer t
						 :init
						 ;; Enhance register preview with thin lines and no mode line.
						 (advice-add #'register-preview :override #'consult-register-window)

						 ;; Use Consult for xref locations with a preview feature.
						 (setq xref-show-xrefs-function #'consult-xref
									 xref-show-definitions-function #'consult-xref))


;;; EMBARK
;; Embark provides a powerful contextual action menu for Emacs, allowing
;; you to perform various operations on completion candidates and other items.
;; It extends the capabilities of completion frameworks by offering direct
;; actions on the candidates.
;; Just `<leader> .' over any text, explore it :)
(use-package embark
						 :ensure t
						 :straight t
						 :defer t)


;;; EMBARK-CONSULT
;; Embark-Consult provides a bridge between Embark and Consult, ensuring
;; that Consult commands, like previews, are available when using Embark.
(use-package embark-consult
						 :ensure t
						 :straight t
						 :hook
						 (embark-collect-mode . consult-preview-at-point-mode))
;; EVIL
;; The `evil' package provides Vim emulation within Emacs, allowing
;; users to edit text in a modal way, similar to how Vim
;; operates. This setup configures `evil-mode' to enhance the editing
;; experience.
(use-package evil
						 :ensure t
						 :straight t
						 :defer t
						 :hook
						 (after-init . evil-mode)
						 :init
						 (setq evil-want-integration t)      ;; Integrate `evil' with other Emacs features (optional as it's true by default).
						 (setq evil-want-keybinding nil)     ;; Disable default keybinding to set custom ones.
						 (setq evil-want-C-u-scroll t)       ;; Makes C-u scroll
						 (setq evil-want-C-u-delete t)       ;; Makes C-u delete on insert mode
						 :config
						 (evil-set-undo-system 'undo-tree)   ;; Uses the undo-tree package as the default undo system

						 ;; Set the leader key to space for easier access to custom commands. (setq evil-want-leader t)
						 (setq evil-leader/in-all-states t)  ;; Make the leader key available in all states.
						 (setq evil-want-fine-undo t)        ;; Evil uses finer grain undoing steps

						 ;; Define the leader key as Space
						 (evil-set-leader 'normal (kbd "SPC"))
						 (evil-set-leader 'visual (kbd "SPC"))

						 ;; Keybindings for searching and finding files.
						 (evil-define-key 'normal 'global (kbd "<leader> s f") 'consult-find)
						 (evil-define-key 'normal 'global (kbd "<leader> s g") 'consult-grep)
						 (evil-define-key 'normal 'global (kbd "<leader> s G") 'consult-git-grep)
						 (evil-define-key 'normal 'global (kbd "<leader> s r") 'consult-ripgrep)
						 (evil-define-key 'normal 'global (kbd "<leader> s h") 'consult-info)
						 (evil-define-key 'normal 'global (kbd "<leader> /") 'consult-line)

						 ;; Flymake navigation
						 (evil-define-key 'normal 'global (kbd "<leader> x x") 'consult-flymake);; Gives you something like `trouble.nvim'
						 (evil-define-key 'normal 'global (kbd "] d") 'flymake-goto-next-error) ;; Go to next Flymake error
						 (evil-define-key 'normal 'global (kbd "[ d") 'flymake-goto-prev-error) ;; Go to previous Flymake error

						 ;; Dired commands for file management
						 (evil-define-key 'normal 'global (kbd "<leader> x d") 'dired)
						 (evil-define-key 'normal 'global (kbd "<leader> x j") 'dired-jump)
						 (evil-define-key 'normal 'global (kbd "<leader> x f") 'find-file)


						 ;; Project management keybindings
						 (evil-define-key 'normal 'global (kbd "<leader> p b") 'consult-project-buffer) ;; Consult project buffer
						 (evil-define-key 'normal 'global (kbd "<leader> p p") 'project-switch-project) ;; Switch project
						 (evil-define-key 'normal 'global (kbd "<leader> p f") 'project-find-file) ;; Find file in project
						 (evil-define-key 'normal 'global (kbd "<leader> p g") 'project-find-regexp) ;; Find regexp in project
						 (evil-define-key 'normal 'global (kbd "<leader> p k") 'project-kill-buffers) ;; Kill project buffers
						 (evil-define-key 'normal 'global (kbd "<leader> p D") 'project-dired) ;; Dired for project

						 ;; Yank from kill ring
						 (evil-define-key 'normal 'global (kbd "P") 'consult-yank-from-kill-ring)
						 (evil-define-key 'normal 'global (kbd "<leader> P") 'consult-yank-from-kill-ring)

						 ;; Embark actions for contextual commands
						 (evil-define-key 'normal 'global (kbd "<leader> .") 'embark-act)

						 ;; Undo tree visualization
						 (evil-define-key 'normal 'global (kbd "<leader> u") 'undo-tree-visualize)

						 ;; LSP commands keybindings
						 (evil-define-key 'normal lsp-mode-map
															;; (kbd "gd") 'lsp-find-definition                ;; evil-collection already provides gd
															(kbd "gr") 'lsp-find-references                   ;; Finds LSP references
															(kbd "<leader> c a") 'lsp-execute-code-action     ;; Execute code actions
															(kbd "<leader> r n") 'lsp-rename                  ;; Rename symbol
															(kbd "gI") 'lsp-find-implementation               ;; Find implementation
															(kbd "<leader> l f") 'lsp-format-buffer)          ;; Format buffer via lsp



						 ;; Emacs 31 finaly brings us support for 'floating windows' (a.k.a. "child frames")
						 ;; to terminal Emacs. If you're still using 30, docs will be shown in a buffer at the
						 ;; inferior part of your frame.
						 (evil-define-key 'normal 'global (kbd "K")
															(if (>= emacs-major-version 31)
																#'eldoc-box-help-at-point
																#'ek/lsp-describe-and-jump))

						 ;; Commenting functionality for single and multiple lines
						 (evil-define-key 'normal 'global (kbd "gcc")
															(lambda ()
																(interactive)
																(if (not (use-region-p))
																	(comment-or-uncomment-region (line-beginning-position) (line-end-position)))))

						 (evil-define-key 'visual 'global (kbd "gc")
															(lambda ()
																(interactive)
																(if (use-region-p)
																	(comment-or-uncomment-region (region-beginning) (region-end)))))

						 ;; Enable evil mode
						 (evil-mode 1))


;; EVIL COLLECTION
;; The `evil-collection' package enhances the integration of
;; `evil-mode' with various built-in and third-party packages. It
;; provides a better modal experience by remapping keybindings and
;; commands to fit the `evil' style.
(use-package evil-collection
						 :defer t
						 :straight t
						 :ensure t
						 :custom
						 (evil-collection-want-find-usages-bindings t)
						 ;; Hook to initialize `evil-collection' when `evil-mode' is activated.
						 :hook
						 (evil-mode . evil-collection-init))


;; EVIL SURROUND
;; The `evil-surround' package provides text object surround
;; functionality for `evil-mode'. This allows for easily adding,
;; changing, or deleting surrounding characters such as parentheses,
;; quotes, and more.
;;
;; With this you can change 'hello there' with ci'" to have
;; "hello there" and cs"<p> to get <p>hello there</p>.
;; More examples here:
;; - https://github.com/emacs-evil/evil-surround?tab=readme-ov-file#examples
(use-package evil-surround
						 :ensure t
						 :straight t
						 :after evil-collection
						 :config
						 (global-evil-surround-mode 1))


;; EVIL MATCHIT
;; The `evil-matchit' package extends `evil-mode' by enabling
;; text object matching for structures such as parentheses, HTML
;; tags, and other paired delimiters. This makes it easier to
;; navigate and manipulate code blocks.
;; Just use % for jumping between matching structures to check it out.
(use-package evil-matchit
						 :ensure t
						 :straight t
						 :after evil-collection
						 :config
						 (global-evil-matchit-mode 1))


;; UNDO TREE
;; The `undo-tree' package provides an advanced and visual way to
;; manage undo history. It allows you to navigate and visualize your
;; undo history as a tree structure, making it easier to manage
;; changes in your buffers.
(use-package undo-tree
						 :defer t
						 :ensure t
						 :straight t
						 :hook
						 (after-init . global-undo-tree-mode)
						 :init
						 (setq undo-tree-visualizer-timestamps t
									 undo-tree-visualizer-diff t
									 ;; Increase undo limits to avoid losing history due to Emacs' garbage collection.
									 ;; These values can be adjusted based on your needs.
									 ;; 10X bump of the undo limits to avoid issues with premature
									 ;; Emacs GC which truncates the undo history very aggressively.
									 undo-limit 800000                     ;; Limit for undo entries.
									 undo-strong-limit 12000000            ;; Strong limit for undo entries.
									 undo-outer-limit 120000000)           ;; Outer limit for undo entries.
						 :config
						 ;; Set the directory where `undo-tree' will save its history files.
						 ;; This keeps undo history across sessions, stored in a cache directory.
						 (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/.cache/undo"))))


;;; RAINBOW DELIMITERS
;; The `rainbow-delimiters' package provides colorful parentheses, brackets, and braces
;; to enhance readability in programming modes. Each level of nested delimiter is assigned
;; a different color, making it easier to match pairs visually.
(use-package rainbow-delimiters
						 :defer t
						 :straight t
						 :ensure t
						 :hook
						 (prog-mode . rainbow-delimiters-mode))



;;; NERD ICONS
;; The `nerd-icons' package provides a set of icons for use in Emacs. These icons can
;; enhance the visual appearance of various modes and packages, making it easier to
;; distinguish between different file types and functionalities.
(use-package nerd-icons
						 :if ek-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
						 :ensure t                               ;; Ensure the package is installed.
						 :straight t
						 :defer t)                               ;; Load the package only when needed to improve startup time.


;;; NERD ICONS Dired
;; The `nerd-icons-dired' package integrates nerd icons into the Dired mode,
;; providing visual icons for files and directories. This enhances the Dired
;; interface by making it easier to identify file types at a glance.
(use-package nerd-icons-dired
						 :if ek-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
						 :ensure t                               ;; Ensure the package is installed.
						 :straight t
						 :defer t                                ;; Load the package only when needed to improve startup time.
						 :hook
						 (dired-mode . nerd-icons-dired-mode))


;;; NERD ICONS COMPLETION
;; The `nerd-icons-completion' package enhances the completion interfaces in
;; Emacs by integrating nerd icons with completion frameworks such as
;; `marginalia'. This provides visual cues for the completion candidates,
;; making it easier to distinguish between different types of items.
(use-package nerd-icons-completion
						 :if ek-use-nerd-fonts                   ;; Load the package only if the user has configured to use nerd fonts.
						 :ensure t                               ;; Ensure the package is installed.
						 :straight t
						 :after (:all nerd-icons marginalia)     ;; Load after `nerd-icons' and `marginalia' to ensure proper integration.
						 :config
						 (nerd-icons-completion-mode)            ;; Activate nerd icons for completion interfaces.
						 (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)) ;; Setup icons in the marginalia mode for enhanced completion display.



;;; DOOM MODELINE
;; The `doom-modeline' package provides a sleek, modern mode-line that is visually appealing
;; and functional. It integrates well with various Emacs features, enhancing the overall user
;; experience by displaying relevant information in a compact format.
(use-package doom-modeline
						 :ensure t
						 :straight t
						 :defer t
						 :custom
						 (doom-modeline-buffer-file-name-style 'buffer-name)  ;; Set the buffer file name style to just the buffer name (without path).
						 (doom-modeline-project-detection 'project)           ;; Enable project detection for displaying the project name.
						 (doom-modeline-buffer-name t)                        ;; Show the buffer name in the mode line.
						 (doom-modeline-vcs-max-length 25)                    ;; Limit the version control system (VCS) branch name length to 25 characters.
						 :config
						 (if ek-use-nerd-fonts                                ;; Check if nerd fonts are being used.
							 (setq doom-modeline-icon t)                      ;; Enable icons in the mode line if nerd fonts are used.
							 (setq doom-modeline-icon nil))                     ;; Disable icons if nerd fonts are not being used.
						 :hook
						 (after-init . doom-modeline-mode))




;;; CATPPUCCIN THEME
;; The `catppuccin-theme' package provides a visually pleasing color theme
;; for Emacs that is inspired by the popular Catppuccin color palette.
;; This theme aims to create a comfortable and aesthetic coding environment
;; with soft colors that are easy on the eyes.
(use-package catppuccin-theme
  :ensure t
  :straight t
  :config
  (custom-set-faces
   ;; Set the color for changes in the diff highlighting to blue.
   `(diff-hl-change ((t (:background unspecified :foreground ,(catppuccin-get-color 'blue))))))

  (custom-set-faces
   ;; Set the color for deletions in the diff highlighting to red.
   `(diff-hl-delete ((t (:background unspecified :foreground ,(catppuccin-get-color 'red))))))

  (custom-set-faces
   ;; Set the color for insertions in the diff highlighting to green.
   `(diff-hl-insert ((t (:background unspecified :foreground ,(catppuccin-get-color 'green))))))

  ;; Load the Catppuccin theme without prompting for confirmation.
  (load-theme 'catppuccin :no-confirm))


(provide 'init)
