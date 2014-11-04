(use posix) ;; http://wiki.call-cc.org/man/4/Unit%20posix
(use srfi-13)

(unless (= 1 (length (command-line-arguments)))
  (print (list "Provide an single command line argument: a path to archive to decompress."))
  (exit))

(define filename (first (command-line-arguments)))

(unless (file-exists? filename)
  (print (list "The file" filename "does not exist."))
  (exit))

(define (type path)
  (let ((p (lambda (e) (string-suffix-ci? e path))))
    (cond ((p ".zip") `(,(string-drop-right path 4) zip))
          ((p ".tar") `(,(string-drop-right path 4) tar))
          ((p ".7z") `(,(string-drop-right path 3) 7z))
          ((p ".xz") `(,(string-drop-right path 3) xz))
          (else #f))))

(define extension (type filename))

(unless extension
  (print (list "Unknown or unsupported filetype.")))

(define (fresh-directory-name string)
  (if (not (directory-exists? string))
      string
      (let loop ((counter 0))
        (let ((name (string-append string (string-append "-" (number->string counter)))))
          (if (directory-exists? name)
              (loop (+ counter 1))
              name)))))

(create-directory (fresh-directory-name "bar"))

;; (call-with-values (lambda () (process* "unzip" (list filename)))
;;   (lambda (in-port out-port proc-id err-port)
;;     (print "I am parent")
;;     (write-line "2+3" out-port)
;;     (print (read-line in-port))
;;     (write-line "2*3" out-port)
;;     (print (read-line in-port))
;;     (write-line "halt" out-port)
;;     (print (read-line in-port))
;;     (print "that's all folks")))
