(eval-when-compile (require 'cl))
(require 'ox-html)

(org-export-define-derived-backend
 'inao 'html
 :filters-alist '((:filter-paragraph . org-inao-filter-paragraph)
                  (:filter-quote-block . org-inao-filter-quote-block))
 :translate-alist '((paragraph . org-inao-paragraph)
                    (inner-template . org-inao-inner-template)
                    (headline . org-inao-headline)
                    (bold . org-inao-bold)
                    (italic . org-inao-italic)
                    (verbatim . org-inao-verbatim)
                    (footnote-reference . org-inao-footnote-reference)
                    (section . org-inao-section)
                    (quote-block . org-inao-quote-block)))

(defun org-inao-paragraph (paragraph contents info)
  (replace-regexp-in-string "\n" "" contents))

(defun org-inao-inner-template (contents info)
  contents)

(defun org-inao-headline (headline contents info)
  (unless (org-element-property :footnote-section-p headline)
    (let* ((level (org-export-get-relative-level headline info))
           (title (org-export-data (org-element-property :title headline) info)))
      (concat (make-string level ?■) title "\n" contents))))

(defun org-inao-bold (bold contents info)
  (format "◆b/◆%s◆/b◆" contents))

(defun org-inao-italic (italic contents info)
  (format "◆i/◆%s◆/i◆" contents))

(defun org-inao-verbatim (verbatim contents info)
  (let ((value (org-element-property :value verbatim)))
    (format "◆cmd/◆%s◆/cmd◆" value)))

(defun org-inao-filter-space-around-markup (markup prefix postfix)
  (replace-regexp-in-string
   (format "\\([[:nonascii:]]\\) \\(%s\\)" prefix) "\\1\\2"
   (replace-regexp-in-string
    (format "\\(%s\\) \\([[:nonascii:]]\\)" postfix) "\\1\\2" markup)))

(defun org-inao-filter-paragraph (paragraph back-end info)
  (replace-regexp-in-string
   "\n\n" "\n"
   (org-inao-filter-space-around-markup paragraph "◆\\(?:[bi]\\|cmd\\)/◆" "◆/\\(?:[bi]\\|cmd\\)◆")))

(defun org-inao-footnote-reference (footnote-reference contents info)
  (let ((def (org-export-get-footnote-definition footnote-reference info)))
    (format "◆注/◆%s◆/注◆" (org-export-data def info))))

(defun org-inao-section (section contents info)
  contents)

(defun org-inao-quote-block (quote-block contents info)
  (format "◆quote/◆\n%s◆/quote◆" contents))

(defun org-inao-filter-quote-block (quote-block back-end info)
  (replace-regexp-in-string
   "◆i/◆\\(.*?\\)◆/i◆" "◆i-j/◆\\1◆/i-j◆" quote-block))

(provide 'ox-inao)
