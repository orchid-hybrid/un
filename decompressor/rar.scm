(define-decompressor "rar"
  "unrar"
  (lambda (filename directory)
    (list "x" filename directory))
  (10))
