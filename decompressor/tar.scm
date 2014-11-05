(define-decompressor ("tgz" "tar.gz" "tbz" "tbz2" "tb2" "tar.bz2" "taz" "tz" "tar.z" "tlz" "tar.lz" "tar.lzma" "txz" "tar.xz")
  "tar"
  (lambda (filename directory)
    (list "-xf" filename (string-append "-C" directory)))
  (2))