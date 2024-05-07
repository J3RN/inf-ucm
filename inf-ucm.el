;;; inf-ucm.el --- Run an interactive UCM shell -*- lexical-binding: t -*-

;; Copyright © 2019–2021 Jonathan Arnett <jonathan.arnett@protonmail.com>

;; Author: Jonathan Arnett <jonathan.arnett@protonmail.com>
;; URL: https://github.com/J3RN/inf-ucm
;; Keywords: languages, processes, tools
;; Version: 2.1.2
;; Package-Requires: ((emacs "25.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this package. If not, see https://www.gnu.org/licenses.

;;; Commentary:

;; Provides access to an IEx shell buffer, optionally running a
;; specific command (e.g. iex -S mix, iex -S mix phx.server, etc)

;;; Code:

(require 'comint)
(require 'subr-x)
(require 'map)


;;; Customization

(defgroup inf-ucm nil
  "Ability to interact with an UCM REPL."
  :prefix "inf-ucm-"
  :group 'languages)

(defcustom inf-ucm-base-command "ucm"
  "The command that forms the base of all REPL commands.

Should be able to be run without any arguments."
  :type 'string
  :group 'inf-ucm)

(defcustom inf-ucm-repl-buffer nil
  "Override for what REPL buffer code snippets should be sent to.

If this variable is set and the corresponding REPL buffer exists
and has a living process, all `inf-ucm-send-*' commands will
send to it.  If this variable is unset (the default) or the
indicated buffer is dead or has a dead process, a warning will be
printed instead."
  :type 'buffer
  :group 'inf-ucm)


;;; Mode definitions and configuration

;;;###autoload
(define-minor-mode inf-ucm-minor-mode
  "Minor mode for UCM buffers that allows interacting with the REPL.")

;;;###autoload
(define-derived-mode inf-ucm-mode comint-mode "Inf-Ucm"
  "Major mode for interacting with an UCM REPL.")


;;; Private functions

(defvar inf-ucm--buffers '()
  "List of buffers that contain a UCM process.")

(defun inf-ucm--up-directory (dir)
  "Return the directory above DIR."
  (file-name-directory (directory-file-name dir)))

(defun inf-ucm--send (cmd)
  "Determine where to send CMD and send it."
  (when-let ((buf (inf-ucm--determine-repl-buf)))
    (with-current-buffer buf
      (comint-add-to-input-history cmd)
      (comint-send-string buf (concat cmd "\n")))
    (pop-to-buffer buf)))

(defun inf-ucm--start-repl (cmd)
  "Start a UCM REPL by running `CMD'."
  (with-current-buffer
      (apply #'make-comint-in-buffer "Inf-UCM" nil (car cmd) nil (cdr cmd))
    (inf-ucm-mode)
    (add-to-list 'inf-ucm--buffers (current-buffer))
    (current-buffer)))

(defun inf-ucm--determine-repl-buf ()
  "Determine where to send a cmd when `inf-ucm-send-*' are used."
  (if inf-ucm-repl-buffer
      (if (process-live-p (get-buffer-process inf-ucm-repl-buffer))
          inf-ucm-repl-buffer
        (inf-ucm--prompt-repl-buffers "`inf-ucm-repl-buffer' is dead, please choose another REPL buffer: "))
    (inf-ucm--prompt-repl-buffers)))

(defun inf-ucm--prompt-repl-buffers (&optional prompt)
  "Prompt the user to select an inf-ucm REPL buffers or create an new one.

Returns the select buffer (as a buffer object).

If PROMPT is supplied, it is used as the prompt for a REPL buffer.

When the user selects a REPL, it is set as `inf-ucm-repl-buffer' locally in
the buffer so that the choice is remembered for that buffer."
  ;; Cleanup
  (setq inf-ucm--buffers (seq-filter 'buffer-live-p inf-ucm--buffers))
  ;; Actual functionality
  (let* ((repl-buffers (append
                       '("Create new")
                       (mapcar (lambda (buf) `(,(buffer-name buf) . buf)) inf-ucm--buffers)))
         (prompt (or prompt "Which REPL?"))
         (selected-buf (completing-read prompt repl-buffers (lambda (_) t) t)))
    (setq-local inf-ucm-repl-buffer (if (equal selected-buf "Create new")
                                           (inf-ucm)
                                         selected-buf))))


;;; Public functions

;;;###autoload
(defun inf-ucm (&optional cmd)
  "Create an UCM REPL, using CMD if given.

When called from ELisp, an argument (CMD) can be passed which will be the
command run to start the REPL.  The default is provided by
`inf-ucm-base-command'.

When called interactively with a prefix argument, the user will
be prompted for the REPL command.  The default is provided by
`inf-ucm-base-command'."
  (interactive)
  (let ((cmd (cond
              (cmd cmd)
              (current-prefix-arg (read-from-minibuffer "Command: " inf-ucm-base-command nil nil 'inf-ucm))
              (t inf-ucm-base-command))))
    (pop-to-buffer (inf-ucm--start-repl (split-string cmd)))))

(defun inf-ucm-set-repl ()
  "Select which REPL to use for this buffer."
  (interactive)
  (inf-ucm--prompt-repl-buffers))

(defun inf-ucm-send-buffer ()
  "Send the buffer to the REPL buffer and run it."
  (interactive)
  (inf-ucm--send (buffer-string)))

(provide 'inf-ucm)

;;; inf-ucm.el ends here
