(ido-mode t)


(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("SC"   . "http://joseito.republika.pl/sunrise-commander/"))
(add-to-list 'package-archives '("melpa"   . "http://melpa.milkbox.net/packages/") t)

(add-to-list 'load-path "~/.emacs.d/")

(setq scroll-step 1)
(setq scroll-conservatively 10000)

(setq-default truncate-lines t)


;; Show pressed buttons immediately
(setq echo-keystrokes 0.01)

;; Commands for moving between windows
(global-set-key (kbd "ESC <left>") 'windmove-left)
(global-set-key (kbd "ESC <right>") 'windmove-right)
(global-set-key (kbd "ESC <up>") 'windmove-up)
(global-set-key (kbd "ESC <down>") 'windmove-down)


;(add-to-list 'load-path "~/.emacs.d/smex")
;(require 'smex)
;(smex-initialize)
;(global-set-key (kbd "M-x") 'smex)
;(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
;(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (tango-dark)))
 '(ido-max-directory-size nil))

(package-initialize)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)


(require 'anything-config)

(global-set-key (kbd "C-x b")
        (lambda() (interactive)
          (anything
           :prompt "Switch to: "
           :candidate-number-limit 20                 ;; up to 20 of each
           :sources
           '( anything-c-source-buffers               ;; buffers
              anything-c-source-recentf               ;; recent files
              anything-c-source-bookmarks             ;; bookmarks
              anything-c-source-files-in-current-dir+ ;; current dir
              ))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
