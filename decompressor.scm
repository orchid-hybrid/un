(define decompressors '())

(define-syntax push!
  (syntax-rules ()
    ((push! <place> <value>)
     (set! <place> (cons <value> <place>)))))

(define-syntax define-decompressor
  (syntax-rules ()
    ((define-decompressor (<extension> ...) <tool> <invocation> <error-exit-codes>)
     (begin
       (define-decompressor <extension> <tool> <invocation> <error-exit-codes>) ...))
    ((define-decompressor <extension> <tool> <invocation> <error-exit-codes>)
     (push! decompressors (list <extension> <tool> <invocation> '<error-exit-codes>)))))

(define decompressor-extension first)
(define decompressor-tool second)
(define (decompressor-invocation de name dir) ((third de) name dir))
(define (decompressor-error-code? de code) (member code (fourth de)))

