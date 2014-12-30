(use posix) ;; http://wiki.call-cc.org/man/4/Unit%20posix
(use files)
(use srfi-1)
(use srfi-13)

(declare (uses decompressors))

;;;;
;;;; Welcome to Un, the unfortunately unfinished uniformly unified universal unarchiver!
;;;;

;; Process command line arguments
(unless (= 1 (length (command-line-arguments)))
  (print (list "Provide an single command line argument: a path to archive to decompress."))
  (exit))

;; Extract the path and decompose it by looping through the list of decompressors
(define filename (first (command-line-arguments)))

(unless (file-exists? filename)
  (print (list "The file" filename "does not exist."))
  (exit))

(define (string-extension-split-ci? suffix string)
  ;; This tries to split an extension `.suffix' off the end of a filename
  ;; returns false if it wasn't there
  (if (string-suffix-ci? (string-append "." suffix) string)
      (string-drop-right string (+ 1 (string-length suffix)))
      #f))

(define filename-decomposed
  (let ((filename-directory (pathname-directory filename))
        (filename-basename (pathname-strip-directory filename)))
    (let loop ((d decompressors))
      (if (null? d)
          (begin
            (print (list "I don't know how to handle" (pathname-extension filename) "files yet"))
            (exit))
          (let ((ext (decompressor-extension (car d))))
            (cond ((string-extension-split-ci? ext filename-basename)
                   => (lambda (filename)
                        (list filename-directory
                              filename
                              ext
                              (car d))))
                  (else (loop (cdr d)))))))))

(define filename-basename (first filename-decomposed))
(define filename-file (second filename-decomposed))
(define filename-extension (third filename-decomposed)) ;; will be false when no extension
(define decompressor (fourth filename-decomposed))

;; Create a directory to extract to
(define (fresh-directory-name string)
  (if (not (file-exists? string))
      string
      (let loop ((counter 0))
        (let ((name (string-append string (string-append "-" (number->string counter)))))
          (if (directory-exists? name)
              (loop (+ counter 1))
              name)))))

(define (fresh-file-name string ext)
  (if (not (file-exists? (string-append string "." ext)))
      (string-append string "." ext)
      (let loop ((counter 0))
        (let ((name (string-append string (string-append "-" (number->string counter))
				   "." ext)))
          (if (file-exists? name)
              (loop (+ counter 1))
              name)))))

(define directory-path (fresh-directory-name filename-file))

(print (list "Creating directory" directory-path)) ;; DEBUG

(create-directory directory-path)
(unless (directory-exists? directory-path)
  (print (list "Could not create directory" directory-path ".. aborting!"))
  (exit))

;; Extract the file to the directory
(define command (cons (decompressor-tool decompressor) (decompressor-invocation decompressor filename directory-path)))

(print command)

(call-with-values (lambda () (process* (car command) (cdr command)))
  (lambda (in-port out-port proc-id err-port)
    (let loop ()
      (let ((line (read-line in-port)))
        (if (not (eof-object? line))
            (begin (print (string-append "[ ] " line))
                   (loop))
            (let inner-loop ()
              (let ((line (read-line err-port)))
                (if (not (eof-object? line))
                    (begin (print (string-append "[!] " line))
                           (loop))
                    (call-with-values (lambda () (process-wait proc-id))
                        (lambda (pid status n)
                          (cond ((and status (decompressor-error-code? decompressor n))
                                 (begin
                                   (print (list "Process failed with exit code" n))
                                   (delete-directory directory-path)
                                   (exit)))
                                (status (print "DONE!"))
                                (else (begin
                                        (print (list "Process exited abnormally, via signal" n))
                                        (exit))))))))))))))

;; Check how many things were extracted to the directory
;; and if it was only one move it down and delete the unused directory
(let ((paths (directory directory-path #t)))
  (when (= 1 (length paths))
    (let* ((path (car paths))
           (tmp-directory (fresh-directory-name ".un")))
      (rename-file directory-path tmp-directory)
      (unless (directory-exists? tmp-directory)
        (print (list "Could not rename directory" directory-path "to" tmp-directory ".. aborting!"))
        (exit))
      (let ((to-path (fresh-file-name (pathname-file path) (pathname-extension path))))
        (rename-file (make-pathname tmp-directory path) to-path)
        (delete-directory tmp-directory #f)))))
