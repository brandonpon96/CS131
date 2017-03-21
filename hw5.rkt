
(define (atom? x) (or (eq? x '())  (not (or (null? x) (pair? x)))))

; diff between two list will be empty if they are the same
(define (null-ld? obj)
	(if (atom? obj) #f
		(eq? (car obj) (cdr obj))
	)
)

(define (listdiff? obj)
	; base case is when both lists are the same
	(if (null-ld? obj) #t
		(if (or (atom? obj) (atom? (car obj) )) #f
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
	(if (and  (listdiff? listdiff) (not (null-ld? listdiff))) (car (car listdiff))
		(error "listdiff has no elements")
	)
)

(define (cdr-ld listdiff)
	(if (and  (listdiff? listdiff) (not (null-ld? listdiff))) (cons (cdr (car listdiff)) (cdr listdiff))
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
	(if (listdiff? listdiff)	
		(- (length_helper (car listdiff) 0) (length_helper (cdr listdiff) 0))
		(error "not a listdiff")
	)
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
	(if (not (pair? ls)) #f
		(if (and (atom? (car ls)) (atom? (cdr ls))) #t
		(if (atom? (car ls)) (all-pairs (cdr ls))
		(if (atom? (cdr ls)) (all-pairs (car ls))
			(and (all-pairs (car ls)) (all-pairs (cdr ls)))
		)))
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
	(if (list? list) (apply listdiff (car list) (cdr list))
		(error "not a list")
	)
)

(define (listdiff->list listdiff)
	(if (listdiff? listdiff) (get_list (car listdiff) '() (length-ld listdiff))
		(error "not a listdiff")
	)
)

(define (expr-returning listdiff)
	(if (listdiff? listdiff)
		`(cons ',(listdiff->list listdiff) '())
		(error "not a listdiff")
	)
)