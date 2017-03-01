
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
		(if (atom? obj) #f
			(listdiff? (cons (cdr (car obj)) (cdr obj)))
		)
	)
)

(define (cons-ld object listdiff)
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
	(- (length_helper (car listdiff) 0) (length_helper (cdr listdiff)) 0)
)

; returns a list from a listdiff
(define (get_list oglist lst num)
	(if (eq? num 0) lst
		(get_list (cdr oglist) (cons (car oglist) lst) (- num 1))
	)
)

(define (append_helper accum args)
	(if (eq? (cdr args) '()) (cons (append accum (car (car args))) (cdr (car args)))
		(append_helper (append accum (get_list (car (car args)) (length-ld (car args)))) (cdr args)
	)
)

(define (append-ld listdiff . args)
	(if (null? args) listdiff
		(append_helper (get_list (car listdiff) '() (length-ld listdiff)))
	)
)

(define (assq-ld obj alistdiff)

)

(define (list->listdiff list)

)

(define (listdiff->list listdiff)

)

(define (expr-returning listdiff)

)





