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

(message "List of packages to install")
(straight-use-package 'use-package)
(straight-use-package 'yaml-mode)
(message "Customizations for user")
(message "End of Emacs 30 init.el")
