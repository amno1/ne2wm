;;; ne2wm-popwin.el --- popwin integration

;; Copyright (C) 2012  Takafumi Arakaki

;; Author: Takafumi Arakaki
;; Keywords: tools, window manager

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(eval-when-compile (require 'cl-lib))
(require 'e2wm)
(require 'popwin nil t)


(defun ne2wm:popwin-noselect-buffer-p (buffer)
  "Return non-nil when the BUFFER is set to nonselect in popwin setting.

Almost all of the code is borrowed from `popwin:display-buffer-1'."
  (loop with name = (buffer-name buffer)
        with mode = (buffer-local-value 'major-mode buffer)
        for config in popwin:special-display-config
        for (pattern . keywords) = (popwin:listify config)
        do (destructuring-bind
               (&key regexp width height position noselect dedicated stick)
               keywords
             (when (cond ((eq pattern t) t)
                         ((and (stringp pattern) regexp)
                          (string-match pattern name))
                         ((stringp pattern)
                          (string= pattern name))
                         ((symbolp pattern)
                          (eq pattern mode))
                         ((functionp pattern)
                          (funcall pattern buffer))
                         (t (error "Invalid pattern: %s" pattern)))
               (return noselect)))))


(defun ne2wm:popup-sub-appropriate-select (buffer)
  "Use `:nonselect' setting of popwin in `e2wm:dp-*-popup-sub'.

See `popwin:special-display-config'."
  (let* ((buf-name (buffer-name buffer))
         (selectp
          (and (= 0 (minibuffer-depth))
               (not (ne2wm:popwin-noselect-buffer-p buffer)))))
    (unless (eq (wlf:get-window-name (e2wm:pst-get-wm) (selected-window))
                'sub)
      (ne2wm:record-main-window))
    (e2wm:with-advice
     (e2wm:pst-buffer-set 'sub buffer t selectp))))


;;; popwin compatible commands

(declare-function ne2wm:popup-messages "ne2wm-utils")  ; FIXME

;; Command named `ne2wm:popwin-*' does thing similar to what
;; `popwin:*' does.  When e2wm is not enabled, it just calls
;; `popwin:*'.

(defun ne2wm:popwin-messages ()
  (interactive)
  (if (e2wm:managed-p)
      (ne2wm:popup-messages)
    (popwin:messages)))

(defun ne2wm:popwin-display-last-buffer ()
  (interactive)
  (if (e2wm:managed-p)
      (wlf:show (e2wm:pst-get-wm) 'sub)
    (popwin:display-last-buffer)))


(provide 'ne2wm-popwin)
;;; ne2wm-popwin.el ends here
