(use posix) ;; http://wiki.call-cc.org/man/4/Unit%20posix
(use files)
(use srfi-1)
(use srfi-13)

(load "decompressor.scm")
(load "decompressor/zip.scm")
(load "decompressor/rar.scm")
(load "decompressor/tar.scm")
;;;;
;;;; Welcome to Un, the unfortunately unfinished uniformly unified universal unarchiver!
;;;;

;; Process command line arguments
(unless (= 1 (length (command-line-arguments)))
  (print (list "Provide an single command line argument: a path to archive to decompress."))
  (exit))

;; Extract the path and decompose it
(define filename (first (command-line-arguments)))

(unless (file-exists? filename)
  (print (list "The file" filename "does not exist."))
  (exit))

(define filename-decomposed (call-with-values (lambda () (decompose-pathname filename))
                              (lambda (base file extension)
                                (list base file extension))))

(define filename-basename (or (first filename-decomposed) ""))
(define filename-file (second filename-decomposed))
(define filename-extension (third filename-decomposed)) ;; will be false when no extension

(unless filename-extension
  (print (list "File has no extension"))
  (exit))

;; Look up how to extract this type of file, exit it we don't know about it
(define decompressor (assoc filename-extension decompressors))

(unless decompressor
  (print (list "I don't know how to handle" filename-extension "files yet"))
  (exit))

;; Create a directory to extract to
(define (fresh-directory-name string)
  (if (not (directory-exists? string))
      string
      (let loop ((counter 0))
        (let ((name (string-append string (string-append "-" (number->string counter)))))
          (if (directory-exists? name)
              (loop (+ counter 1))
              name)))))

(define directory (fresh-directory-name (make-pathname filename-basename filename-file)))

(print (list "Creating directory" directory)) ;; DEBUG

(create-directory directory)
(unless (directory-exists? directory)
  (print (list "Could not create directory" directory ".. aborting!"))
  (exit))

;; Extract the file to the directory
(call-with-values (lambda () (process* (decompressor-tool decompressor) (decompressor-invocation decompressor filename directory)))
  (lambda (in-port out-port proc-id err-port)
    (let loop ()
      (let ((line (read-line in-port)))
        (if (not (eof-object? line))
            (begin (print line)
                   (loop))
            (let inner-loop ()
              (let ((line (read-line err-port)))
                (if (not (eof-object? line))
                    (begin (print line)
                           (loop))
                    (print "DONE!")))))))))
