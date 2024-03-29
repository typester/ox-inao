(eval-when-compile (require 'cl))
(require 'ox-html)

(org-export-define-derived-backend
 'inao 'html
 :filters-alist '((:filter-paragraph . org-inao-filter-paragraph)
                  (:filter-quote-block . org-inao-filter-quote-block)
                  (:filter-plain-list . org-inao-filter-plain-list)
                  (:filter-src-block . org-inao-filter-src-block)
                  (:filter-section . org-inao-filter-section))
 :translate-alist '((paragraph . org-inao-paragraph)
                    (inner-template . org-inao-inner-template)
                    (headline . org-inao-headline)
                    (bold . org-inao-bold)
                    (italic . org-inao-italic)
                    (verbatim . org-inao-verbatim)
                    (footnote-reference . org-inao-footnote-reference)
                    (section . org-inao-section)
                    (quote-block . org-inao-quote-block)
                    (plain-list . org-inao-plain-list)
                    (item . org-inao-item)
                    (src-block . org-inao-src-block)
                    ))

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
   "\n\n+$" "\n"
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
   "\n\n$" "\n"
  (replace-regexp-in-string
   "◆i/◆\\(.*?\\)◆/i◆" "◆i-j/◆\\1◆/i-j◆" quote-block)))

(defun org-inao-plain-list (plain-list contents info)
  contents)

(defun org-inao-ordered-item-bullet (bullet)
  (if (string-match "^[0-9]+[.)]" bullet)
      (format "（%s）" (replace-regexp-in-string ".*?\\([0-9]+\\).*" "\\1" bullet))))

(defun org-inao-item (item contents info)
  (let* ((plain-list (org-export-get-parent item))
         (type (org-element-property :type plain-list))
         ;(counter (org-element-property :counter item) ;; counterで連番とれるとおもいきやとれないのでbulletを置換する
         (bullet (org-element-property :bullet item)))
    (concat
     (case type
       (ordered (org-inao-ordered-item-bullet bullet))
       (unordered "・"))
     contents)))

(defun org-inao-filter-plain-list (plain-list back-end info)
  (org-inao-filter-quote-block plain-list back-end info))

(defun org-inao-src-block (src-block contents info)
  (let* ((caption (org-export-get-caption src-block))
         (code (org-element-property :value src-block)))
    (concat "◆list/◆\n"
            (if (not caption) ""
              (format "●%s\n" (replace-regexp-in-string
                              "::" "	" (org-export-data caption info))))
            code
            "◆/list◆")))

(defun org-inao-filter-src-block (src-block back-end info)
  (replace-regexp-in-string
   "\n\n$" "\n"
  (replace-regexp-in-string
   "(注:\\(.*?\\))" "◆comment/◆\\1◆/comment◆"
  (replace-regexp-in-string
   "___\\(.*?\\)___" "◆i-j/◆\\1◆/i-j◆"
  (replace-regexp-in-string
   "\\*\\*\\(.*?\\)\\*\\*" "◆cmd-b/◆\\1◆/cmd-b◆" src-block)))))

(defun org-inao-filter-section (section back-end info)
  (replace-regexp-in-string
   "\n\n+$" "\n" section))

;; End-user functions
(defun org-inao-export-to-inao
  (&optional async subtreep visible-only body-only ext-plist)
  (interactive)
  (let* ((extension ".inao.txt")        ; TODO: make customize variable
         (body-only t)                  ; force body-only
         (file (org-export-output-file-name extension subtreep)))
    (if async
        (org-export-async-start
            (lambda (f) (org-export-add-to-stack f 'inao))
          (let ((org-export-coding-system 'utf-8))
            `(expand-file-name
              (org-export-to-file
               'inao ,file ,subtreep ,visible-only ,body-only ',ext-plist))))
      (let ((org-export-coding-system 'utf-8))
        (org-export-to-file
         'inao file subtreep visible-only body-only ext-plist)))))
            
(provide 'ox-inao)

