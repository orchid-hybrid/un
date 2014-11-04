(define decompressors '())

(define-syntax push!
  (syntax-rules ()
    ((push! <place> <value>)
     (set! <place> (cons <value> <place>)))))

(define-syntax define-decompressor
  (syntax-rules ()
    ((define-decompressor <extension> <tool> <invocation>)
     (push! decompressors (list <extension> <tool> <invocation>)))))

(define decompressor-tool second)
(define (decompressor-invocation de name dir) ((third de) name dir))
