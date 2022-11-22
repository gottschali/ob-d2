;;; ob-d2.el --- org-babel support for d2 evaluation

;; Copyright (C) 2018 Alexei Nunez
;; Copyright (C) 2022 Ali Gottschall

;; Author: Alexei Nunez <alexeirnunez@gmail.com>
;; URL: https://github.com/gottschali/ob-d2

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

;; Org-Babel support for evaluating mermaid diagrams.

;;; Requirements:
;; https://d2lang.com/tour/install

;;; Code:
(require 'ob)
(require 'ob-eval)

(defvar org-babel-default-header-args:d2
  '((:results . "file") (:exports . "results"))
  "Default arguments for evaluatiing a mermaid source block.")

(defcustom ob-d2-cli-path nil
  "Path to mermaid.cli executable."
  :group 'org-babel
  :type 'string)

(defun org-babel-execute:d2 (body params)
  (let* ((out-file (or (cdr (assoc :file params))
                       (error "d2 requires a \":file\" header argument")))
	 (theme (cdr (assoc :theme params)))
	 (width (cdr (assoc :width params)))
	 (height (cdr (assoc :height params)))
	 (background-color (cdr (assoc :background-color params)))
	 (mermaid-config-file (cdr (assoc :mermaid-config-file params)))
	 (css-file (cdr (assoc :css-file params)))
	 (pupeteer-config-file (cdr (assoc :pupeteer-config-file params)))
         (temp-file (org-babel-temp-file "d2-"))
         (d2 (or ob-d2-cli-path
                   (executable-find "d2")
                   (error "`ob-mermaid-cli-path' is not set and d2 is not in `exec-path'")))
         (cmd (concat (shell-quote-argument (expand-file-name d2))
                      " " (org-babel-process-file-name temp-file)
                      " " (org-babel-process-file-name out-file)
		      (when theme
			(concat " -t " theme))
		      (when background-color
			(concat " -b " background-color))
		      (when width
			(concat " -w " width))
		      (when height
			(concat " -H " height))
		      (when mermaid-config-file
			(concat " -c " (org-babel-process-file-name mermaid-config-file)))
		      (when css-file
			(concat " -C " (org-babel-process-file-name css-file)))
                      (when pupeteer-config-file
                        (concat " -p " (org-babel-process-file-name pupeteer-config-file))))))
    (unless (file-executable-p d2)
      ;; cannot happen with `executable-find', so we complain about
      ;; `ob-d2-cli-path'
      (error "Cannot find or execute %s, please check `ob-d2-cli-path'" d2))
    (with-temp-file temp-file (insert body))
    (message "%s" cmd)
    (org-babel-eval cmd "")
    nil))

(provide 'ob-d2)
;;; ob-d2.el ends here
