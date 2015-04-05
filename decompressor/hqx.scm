(define-decompressor "hqx"
  "uudeview"
  (lambda (filename directory)
    (list "-i" "+o" "-p" directory filename ))
  (10))
