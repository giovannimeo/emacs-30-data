(message "Emacs 30 init.el")
(message "Initialize straight package manager")
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (load bootstrap-file nil 'nomessage))

(message "Start to initialize packages")
(straight-use-package 'use-package)
(straight-use-package 'solarized-emacs)
(straight-use-package 'git-grep)
(straight-use-package 'elpy)
(load-theme 'solarized-dark t)
(message "Treesitter settings")
(setq treesit-language-source-alist
      '((bash "https://github.com/tree-sitter/tree-sitter-bash")
        (cmake "https://github.com/uyha/tree-sitter-cmake")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (c "https://github.com/tree-sitter/tree-sitter-c")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (java "https://github.com/tree-sitter/tree-sitter-java")
        (elisp "https://github.com/Wilfred/tree-sitter-elisp")
        (go "https://github.com/tree-sitter/tree-sitter-go")
        (html "https://github.com/tree-sitter/tree-sitter-html")
        (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
        (json "https://github.com/tree-sitter/tree-sitter-json")
        (make "https://github.com/alemuller/tree-sitter-make")
        (markdown "https://github.com/ikatyang/tree-sitter-markdown")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(defun rebuildTreeSitter()
  "Rebuild all the tree-sitters mapping based on the treesit-language-source-alist"
  (interactive)
  (progn
    (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))
    ))

(setq major-mode-remap-alist
 '((yaml-mode . yaml-ts-mode)
   (bash-mode . bash-ts-mode)
   (c-mode . c-ts-mode)
   (js2-mode . js-ts-mode)
   (typescript-mode . typescript-ts-mode)
   (json-mode . json-ts-mode)
   (css-mode . css-ts-mode)
   (java-mode . java-ts-mode)
   (python-mode . python-ts-mode)))

;;Enable ELPY
(elpy-enable)
(add-hook 'python-mode-hook 'elpy-mode)

;; Do automatic cleanup of whitespaces
(require 'whitespace-cleanup-mode)
(add-hook 'python-mode-hook 'whitespace-cleanup-mode)
(add-hook 'yaml-mode-hook 'whitespace-cleanup-mode)
(add-hook 'c++-mode-hook 'whitespace-cleanup-mode)

;; Custom ELISP
;; MAKE SURE A SCRIPT IS SET TO BE EXECUTABLE
;; From Emacswiki
;; http://www.emacswiki.org/cgi-bin/emacs/MakingScriptsExecutableOnSave
(add-hook 'after-save-hook
          #'(lambda ()
              (and (save-excursion
                     (save-restriction
                       (widen)
                       (goto-char (point-min))
                       (save-match-data
                         (looking-at "^#!"))))
                   (not (file-executable-p buffer-file-name))
                   (shell-command (concat "chmod u+x " buffer-file-name))
                   (message
                    (concat "Saved as script: " buffer-file-name)))))

;; Toggle truncation and navigation keys
(defun truncate_and_navigate ()
  (interactive)
  (toggle-truncate-lines)
  )

;; Routine that remove duplicated lines from BLOG:
;; http://yesybl.org/blogen/?p=25
(defun uniq-lines (beg end)
  "Unique lines in region.
Called from a program, there are two arguments:
BEG and END (region to sort)."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (not (eobp))
        (kill-line 1)
        (yank)
        (let ((next-line (point)))
          (while
              (re-search-forward
               (format "^%s" (regexp-quote (car kill-ring))) nil t)
            (replace-match "" nil nil))
          (goto-char next-line))))))

;;Increment all the numbers in a line!
(defun another-line (num-lines)
    "Copies line, preserving cursor column, and increments any numbers found, wrapped by a pair of < >.
  Copies a block of optional NUM-LINES lines.  If no optional argument is given,
  then only one line is copied."
    (interactive "p")
    (if (not num-lines) (setq num-lines 0) (setq num-lines (1- num-lines)))
    (let* ((col (current-column))
           (bol (save-excursion (forward-line (- num-lines)) (beginning-of-line) (point)))
           (eol (progn (end-of-line) (point)))
           (line (buffer-substring bol eol)))
      (goto-char bol)
      (while (re-search-forward "<[0-9]+>" eol 1)
        (let ((num (string-to-int (buffer-substring
                                    (+ 1 (match-beginning 0)) (- (match-end 0) 1)))))
          (replace-match (concat "<" (int-to-string (1+ num)) ">" )))
        (setq eol (save-excursion (goto-char eol) (end-of-line) (point))))
      (goto-char bol)
      ;; Remove from the original line the tags "<" ">" so we can
      ;; reuse this multiple time
      (insert (replace-regexp-in-string "\\(<\\|>\\)" "" line) "\n")
      (move-to-column col)))

;;; Stefan Monnier <foo at acm.org>. It is the opposite of fill-paragraph
;;; Takes a multi-line paragraph and makes it into a single line of text.
(defun unfill-paragraph ()
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))


(defun gettodo ()
  "Give me the list of TODO in the current directory and subdirectory"
  (interactive)
  (compilation-start "time grep -nHRF -C2 'TODO' * --exclude='*~' || exit 0"))

(defun gettodobuffer ()
  "Give me the list of TODO in the current directory and subdirectory"
  (interactive)
  (compilation-start (concat "time grep -nHF -C2 'TODO' " (buffer-file-name) " || exit 0")))

(defun copy-open-files ()
  "Add paths to all open files to kill ring"
  (interactive)
  (kill-new (mapconcat 'identity
                       (delq nil (mapcar 'buffer-file-name (buffer-list)))
                       "\n")))

(defun dobuild (target)
  "Perform dobuild in Emacs itself"
  (interactive "s")
  (compilation-start (concat "/vol/apicbin/gmeo/bin/dobuild " target)))

(defun wcleanupfile ()
  "Cleanup whitespaces in file"
  (interactive)
  (whitespace-cleanup-region (point-min) (point-max)))

;; DEFINE VITAL KEY SETTINGS
(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-w" 'kill-region)
(global-set-key "\C-k" 'kill-line)
(global-set-key [end] 'end-of-line)
(global-set-key [home] 'beginning-of-line)
(global-set-key [f9] 'truncate_and_navigate)
;; Bind with F3 the find-file-at-point command
(global-set-key [f3] 'find-file-at-point)
;; Define a shortcut for revert-buffer
(defalias 'rv 'revert-buffer)

;; git grep interface
(use-package git-grep
             :commands (git-grep git-grep-repo)
             :bind (("C-c g g" . git-grep)
                    ("C-c g r" . git-grep-repo)))

;; Define sensible settings
(setq-default indent-tabs-mode nil)

(message "Customizations for user")
(message "End of Emacs 30 init.el")
