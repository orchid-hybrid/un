(define-decompressor "tar"
  "tar"
  (lambda (filename directory)
    (list "-xf" filename (string-append "-C" directory)))
  (2))
