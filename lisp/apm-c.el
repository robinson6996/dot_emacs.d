;;; apm-c.el --- My customisations for c mode
;; c-only modes

;;; Commentary:
;;

;;; Code:
(require 'akantu-c)

(defun apm-c-mode-setup ()
  "Tweaks and customisations for `c-mode'."
  (aggressive-indent-mode 1)
  (c-set-style "akantu")
  ;; and treat linux style as safe for local variable
  (add-to-list 'safe-local-variable-values '(c-indentation-style . linux))
  ;; ensure fill-paragraph takes doxygen @ markers as start of new
  ;; paragraphs properly
  (setq paragraph-start "^[ ]*\\(//+\\|\\**\\)[ ]*\\([ ]*$\\|@param\\)\\|^\f")
  )

(provide 'apm-c)

;;; apm-c.el ends here
