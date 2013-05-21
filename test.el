(require 'ert)
(require 'ox-inao)

(setq x-input "* 見出し1（大見出し、節）

** 見出し2（中見出し、項）

*** 見出し3（小見出し、目）

　段落冒頭の字下げは、このように手動でお願いします。
改行は、（改行）
このように自動で取り除かれます。

　通常の本文 *強調（ボールド）* 通常の本文 /斜体（イタリック）/ 通常の本文 =インラインのコード= 通常の本文[fn:1]通常の本文

* Footnotes

[fn:1] 注釈ですよ。
")

(setq x-output "■見出し1（大見出し、節）
■■見出し2（中見出し、項）
■■■見出し3（小見出し、目）
　段落冒頭の字下げは、このように手動でお願いします。改行は、（改行）このように自動で取り除かれます。
　通常の本文◆b/◆強調（ボールド）◆/b◆通常の本文◆i/◆斜体（イタリック）◆/i◆通常の本文◆cmd/◆インラインのコード◆/cmd◆通常の本文◆注/◆注釈ですよ。◆/注◆通常の本文
")

;(setq x-input "foot[fn:1]
;
;* Footnotes
;
;[fn:1] hoge
;")
;
;(setq x-output "foot◆注/◆hoge◆/注◆\n")

(ert-deftest sample-text ()
  (should (equal x-output
                 (org-export-string-as x-input 'inao t))))

(ert-run-tests-batch-and-exit)

