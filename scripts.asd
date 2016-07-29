(asdf:defsystem :scripts
  :version "0.1"
  :author "Matthew Henderson"
  :license "LLGPL"
  :depends-on (:uiop
               :cl-csv)
  :serial t
  :components ((:file "package")
               (:file "abook")))
