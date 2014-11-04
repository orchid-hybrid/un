(define-decompressor "zip"
  "unzip"
  (lambda (filename directory)
    (list filename "-d" directory)))
