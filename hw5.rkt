#lang racket

(define g '(a b c d e))
(define f (cons g (cdr (cdr g))))
(define r '(f g h i j))
(define t (cons r (cdr (cdr (cdr r)))))

(define (atom? x) (not (or (null? x) (pair? x))))

; diff between two list will be empty if they are the same
(define (null-ld? obj)
	(if (atom? obj) #f
		(eq? (car obj) (cdr obj))
	)
)

(define (listdiff? obj)
	; base case is when both lists are the same
	(or (null-ld? obj)
		(if (or (atom? obj) (eq?  (car obj) '())) #f
			(listdiff? (cons (cdr (car obj)) (cdr obj)))
		)
	)
)

(define (cons-ld obj listdiff)
	(if (listdiff? listdiff) (cons (cons obj (car listdiff)) (cdr listdiff))
		(error "not a listdiff")
	)
)

(define (car-ld listdiff)
	(if (listdiff? listdiff) (car (car listdiff))
		(error "listdiff has no elements")
	)
)

(define (cdr-ld listdiff)
	(if (listdiff? listdiff) (cons (cdr (car listdiff)) (cdr listdiff))
		(error "listdiff has no elements")
	)
)

(define (listdiff obj . args)
	(cons (cons obj args) '())
)

(define (length_helper obj num)
	(if (null? obj) num
		(if (atom? obj) (+ num 1)
			(length_helper (cdr obj) (+ num 1))
		)
	)	
)

(define (length-ld listdiff)
	(- (length_helper (car listdiff) 0) (length_helper (cdr listdiff) 0))
)

; returns a list from a listdiff
(define (get_list oglist lst num)
	(if (eq? num 0) lst
		(get_list (cdr oglist) (append lst (list (car oglist))) (- num 1))
	)
)

(define (append_helper accum args)
	(if (eq? (cdr args) '()) (cons (append accum (car (car args))) (cdr (car args)))
		(append_helper (append accum (get_list (car (car args)) '() (length-ld (car args)))) (cdr args))
	)
)

(define (append-ld listdiff . args)
	(if (null? args) listdiff
		(append_helper (get_list (car listdiff) '() (length-ld listdiff)) args)
	)
)

(define (all-pairs ls)
	(if (and (atom? (car ls)) (atom? (cdr ls))) #t
		(if (pair? ls) (and (all-pairs (car ls)) (all-pairs (cdr ls)))
			#f
		)
	)
)

(define (assq-helper obj alistdiff)
	(if (eq? (car (car (car alistdiff))) '()) #f
		(if (eq? (car (car (car alistdiff))) obj) 
			(car (car alistdiff))
			(assq-ld obj (cons (cdr (car alistdiff)) (cdr alistdiff)))
		)
	)
)

(define (assq-ld obj alistdiff)
	(if (and (listdiff? alistdiff) (all-pairs (car alistdiff)))
		(assq-helper obj alistdiff)
		(error "not a listdiff or not all pairs")
	)
)

(define (list->listdiff list)
	(if (list? list) (listdiff (car list) (cdr list))
		(error "not a list")
	)
)

(define (listdiff->list listdiff)
	(if (listdiff? listdiff) (get_list (car listdiff) (length-ld listdiff))
		(error "not a listdiff")
	)
)

(define (expr-returning listdiff)
	(if (listdiff? listdiff)
		'(cons ,(listdiff->list listdiff) '())
		(error "not a listdiff")
	)
)

(define ils (append '(a e i o u) 'y))
(define d1 (cons ils (cdr (cdr ils))))
(define d2 (cons ils ils))
(define d3 (cons ils (append '(a e i o u) 'y)))
(define d4 (cons '() ils))
(define d5 0)
(define d6 (listdiff ils d1 37))
(define d7 (append-ld d1 d2 d6))
(define e1 (expr-returning d1))

(listdiff? d1)                         ;===>  #t
(listdiff? d2)                         ;===>  #t
(listdiff? d3)                         ;===>  #f
(listdiff? d4)                         ;===>  #f
(listdiff? d5)                         ;===>  #f
(listdiff? d6)                         ;===>  #t
(listdiff? d7)                         ;===>  #t

(null-ld? d1)                          ;===>  #f
(null-ld? d2)                          ;===>  #t
(null-ld? d3)                          ;===>  #f
(null-ld? d6)                          ;===>  #f

(car-ld d1)                            ;===>  a
(car-ld d2)                            ;===>  error
(car-ld d3)                            ;===>  error
(car-ld d6)                            ;===>  (a e i o u . y)

(length-ld d1)                         ;===>  2
(length-ld d2)                         ;===>  0
(length-ld d3)                         ;===>  error
(length-ld d6)                         ;===>  3
(length-ld d7)                         ;===>  5

(define kv1 (cons d1 'a))
(define kv2 (cons d2 'b))
(define kv3 (cons d3 'c))
(define kv4 (cons d1 'd))
(define d8 (listdiff kv1 kv2 kv3 kv4))
(eq? (assq-ld d1 d8) kv1)              ;===>  #t
(eq? (assq-ld d2 d8) kv2)              ;===>  #t
(eq? (assq-ld d1 d8) kv4)              ;===>  #f

(eq? (car-ld d6) ils)                  ;===>  #t
(eq? (car-ld (cdr-ld d6)) d1)          ;===>  #t
(eqv? (car-ld (cdr-ld (cdr-ld d6))) 37);===>  #t
(equal? (listdiff->list d6)
        (list ils d1 37))              ;===>  #t
(eq? (list-tail (car d6) 3) (cdr d6))  ;===>  #t

(listdiff->list (eval e1))             ;===>  (a e)
(equal? (listdiff->list (eval e1))
        (listdiff->list d1))           ;===>  #t





