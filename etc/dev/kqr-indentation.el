(when (require 'aggressive-indent nil)
  (diminish 'aggressive-indent-mode)
  (electric-indent-mode -1)

  (defun cancel-aggressive-indent-timers ()
    (interactive)
    (let ((count 0))
      (dolist (timer timer-idle-list)
        (when (eq 'aggressive-indent--indent-if-changed (aref timer 5))
          (incf count)
          (cancel-timer timer)))
      (when (> count 0)
        (message "Cancelled %s aggressive-indent timers" count))))
  (run-with-timer 60 nil 'cancel-aggressive-indent-timers)

  (add-to-list
   'aggressive-indent-dont-indent-if
   '(and (or (derived-mode-p 'c++-mode) (derived-mode-p 'csharp-mode))
         (null (string-match "\\([;{}]\\|\\b\\(if\\|for\\|while\\)\\b\\)"
                             (thing-at-point 'line)))))

  (global-aggressive-indent-mode +1))
