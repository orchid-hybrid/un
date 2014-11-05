(define-decompressor "7z"
  "7z"
  (lambda (filename directory)
    (list "x" filename (string-append "-o" directory)))
  (2))
