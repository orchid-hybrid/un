(define-decompressor "zip"
  "unzip"
  (lambda (filename directory)
    (list filename "-d" directory))
  (2 3 9 11 50 51 81))
