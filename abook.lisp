;;; Convert csv contacts export from Thunderbird to abook format
;;; abook format
;; static int csv_conv_table[] = {
;; NAME,
;; EMAIL,
;; PHONE,
;; NOTES,
;; NICK
;; };
;;; Thunder bird output
;;;  First Name,Last Name,Display Name,Nickname,Primary Email,
;;;  abook --convert --infile tmpfile.csv --informat csv --outfile ~/.abook/test --outformat abook
;;;  abook --convert --infile ~/.abook/addressbook --informat abook --outfile ~/.abook/test.csv --outformat csv
;;;Read more at https://www.geeksaresexy.net/2010/04/28/how-to-copy-outlook-contacts-to-abook/#v5OugTlZlVjQqRwU.99

(defpackage :scripts.abook
  (:use :cl
        :cl-csv
        :uiop))

(in-package :scripts.abook)

(defun collect-name-email (list)
  (let ((name (string-trim "'" (third list)))
        (email (fifth list)))
    (if (not (string-equal name "NIL"))
        (list name email))))
(defun load-thunderbird-csv (pathname)
  (with-open-file (in pathname
                      :direction :input)
    (cl-csv:read-csv in
                     :map-fn #'collect-name-email
                     :skip-first-p t
                     :separator #\,
                     ;;:quote nil ;; there are quotes in comment strings
                     ;;:escape nil
                     :unquoted-empty-string-is-nil t)))

(defun process-thunderbird-csv (pathname)
  (remove nil
          (remove-duplicates
           (stable-sort (load-thunderbird-csv pathname) #'string-lessp :key #'car)
           :test #'string-equal
           :key #'second)))

(defun write-abook-csv (lol pathname)
  (with-open-file (out pathname
                       :direction :output
                       :if-exists :supersede)
    (cl-csv:write-csv lol :stream out)))

(defun create-abook-file (input-csv abook-filepath)
  (let ((output-csv "/home/mpah/.abook/abookformat.csv"))
    (write-abook-csv
     (process-thunderbird-csv input-csv) output-csv)
    (uiop:run-program (list "/usr/bin/abook"
                            "--convert" "--infile" (namestring output-csv)
                            "--informat" "csv" "--outfile" abook-filepath
                            "--outformat" "abook")
                      :error-output "/home/mpah/.abook/errors.txt")))
(write-abook-csv
 (process-thunderbird-csv "~/Desktop/collectedaddressbook.csv") "~/Desktop/abookformat.csv")

;; abook --convert --infile abookformat.csv --informat csv --outfile ~/.abook/test --outformat book
;; --convert --infile /home/mpah/Desktop/abookformat.csv --informat csv --outfile /home/mpah/.abook/test --outformat abook ")
;; "--convert --infile /Desktop/abookformat.csv --informat csv --outfile ~/.abook/test --outformat abook ")
