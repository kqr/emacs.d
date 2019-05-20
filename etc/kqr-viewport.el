(when (require 'centered-cursor-mode nil)
  (when (require 'simpler-centered-cursor-mode nil)
    (defun switch-to-simple-scc ()
      "If this is a large file, switch to simpler-centered-cursor-mode."
      (when (> (buffer-size) 32000)
        (centered-cursor-mode -1)
        (simpler-centered-cursor-mode +1)))

    (diminish 'simpler-centered-cursor-mode)
    (add-hook 'org-mode-hook #'switch-to-simple-scc))

  (diminish 'centered-cursor-mode)
  (global-centered-cursor-mode +1))